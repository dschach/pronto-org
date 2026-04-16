/**
 * MenuDescriptionPromptGrounding
 *
 * Invocable grounding class for Prompt Builder. Summarises a Menu__c record's
 * items and categories into a structured text block the LLM can use to
 * generate a menu description.
 */
public with sharing class MenuDescriptionPromptGrounding {
  public class Request {
    @InvocableVariable(required=true)
    public Menu__c RelatedEntity;
  }

  public class Response {
    @InvocableVariable(required=true)
    public String Prompt;
  }

  @InvocableMethod(
    label='Menu Description Grounding'
    description='Returns a structured summary of a menu and its items for use in a Prompt Builder field generation template.'
  )
  public static List<Response> getMenuData(List<Request> requests) {
    if (requests.isEmpty()) {
      throw new IllegalArgumentException('At least one request is required.');
    }

    Menu__c menu = requests[0].RelatedEntity;

    Menu__c fullMenu = [
      SELECT Id, Name, Menu_Display_Name__c, Active__c, Storefront__r.Name, Storefront__r.Cuisine__c
      FROM Menu__c
      WHERE Id = :menu.Id
      LIMIT 1
    ];

    List<Menu_Item__c> items = [
      SELECT Name, Description__c, Price__c, Calories__c, Available__c, Menu_Category__r.Name
      FROM Menu_Item__c
      WHERE Menu__c = :menu.Id
      ORDER BY Menu_Category__r.Name ASC, Name ASC
    ];

    String result =
      'Menu: ' +
      (String.isNotBlank(fullMenu.Menu_Display_Name__c) ? fullMenu.Menu_Display_Name__c : fullMenu.Name) +
      '\n';
    result += 'Storefront: ' + (fullMenu.Storefront__r != null ? fullMenu.Storefront__r.Name : 'Unknown') + '\n';
    result +=
      'Cuisine: ' +
      (fullMenu.Storefront__r != null &&
        fullMenu.Storefront__r.Cuisine__c != null
        ? fullMenu.Storefront__r.Cuisine__c
        : 'Not specified') +
      '\n';
    result += 'Total Items: ' + items.size() + '\n\n';

    if (items.isEmpty()) {
      result += 'No items on this menu yet.';
    } else {
      Set<String> categories = new Set<String>();
      Decimal minPrice = null;
      Decimal maxPrice = null;

      Map<String, List<String>> categoryItems = new Map<String, List<String>>();

      for (Menu_Item__c item : items) {
        String cat = item.Menu_Category__r != null &&
          item.Menu_Category__r.Name != null
          ? item.Menu_Category__r.Name
          : 'Uncategorized';
        categories.add(cat);

        if (item.Price__c != null) {
          if (minPrice == null || item.Price__c < minPrice)
            minPrice = item.Price__c;
          if (maxPrice == null || item.Price__c > maxPrice)
            maxPrice = item.Price__c;
        }

        String line = item.Name;
        if (item.Price__c != null)
          line += ' ($' + item.Price__c.setScale(2) + ')';
        if (String.isNotBlank(item.Description__c))
          line += ' - ' + item.Description__c;

        if (!categoryItems.containsKey(cat)) {
          categoryItems.put(cat, new List<String>());
        }
        categoryItems.get(cat).add(line);
      }

      result += 'Categories: ' + String.join(new List<String>(categories), ', ') + '\n';
      if (minPrice != null && maxPrice != null) {
        result += 'Price Range: $' + minPrice.setScale(2) + ' - $' + maxPrice.setScale(2) + '\n';
      }
      result += '\nItems by Category:\n';

      for (String cat : categoryItems.keySet()) {
        result += '\n' + cat + ':\n';
        for (String line : categoryItems.get(cat)) {
          result += '  - ' + line + '\n';
        }
      }
    }

    Response res = new Response();
    res.Prompt = result;
    return new List<Response>{ res };
  }
}