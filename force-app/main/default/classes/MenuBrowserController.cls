public with sharing class MenuBrowserController {
  @AuraEnabled
  public static List<CategoryWrapper> getMenuCategories(String menuId) {
    List<CategoryWrapper> categories = new List<CategoryWrapper>();

    // First, get all menu items for this menu to understand the categories used
    List<Menu_Item__c> menuItems = [
      SELECT Id, Menu_Category__c, Menu_Category__r.Name
      FROM Menu_Item__c
      WHERE Menu__c = :menuId AND Available__c = TRUE
      LIMIT 1000
    ];

    // Get unique categories from these items
    Set<Id> categoryIds = new Set<Id>();
    Map<Id, String> categoryIdToName = new Map<Id, String>();

    for (Menu_Item__c item : menuItems) {
      if (item.Menu_Category__c != null) {
        categoryIds.add(item.Menu_Category__c);
        if (item.Menu_Category__r != null && item.Menu_Category__r.Name != null) {
          categoryIdToName.put(item.Menu_Category__c, item.Menu_Category__r.Name);
        }
      }
    }

    // Now query the actual categories with counts
    if (!categoryIds.isEmpty()) {
      List<Menu_Category__c> categoryList = [
        SELECT Id, Name, Description__c, Display_Order__c
        FROM Menu_Category__c
        WHERE Id IN :categoryIds
        ORDER BY Display_Order__c ASC, Name ASC
      ];

      // Count items per category
      Map<Id, Integer> itemCountMap = new Map<Id, Integer>();
      for (Menu_Item__c item : menuItems) {
        if (item.Menu_Category__c != null) {
          Integer count = itemCountMap.get(item.Menu_Category__c);
          if (count == null) {
            itemCountMap.put(item.Menu_Category__c, 1);
          } else {
            itemCountMap.put(item.Menu_Category__c, count + 1);
          }
        }
      }

      for (Menu_Category__c category : categoryList) {
        CategoryWrapper wrapper = new CategoryWrapper();
        wrapper.id = category.Id;
        wrapper.Name = category.Name;
        wrapper.description = category.Description__c;
        wrapper.itemCount = itemCountMap.get(category.Id) != null ? itemCountMap.get(category.Id) : 0;
        categories.add(wrapper);
      }
    }

    return categories;
  }

  @AuraEnabled
  public static List<Menu_Item__c> getMenuItems(String menuId) {
    // Query menu items with related category information
    return [
      SELECT
        Id,
        Name,
        Description__c,
        Price__c,
        Image_URL__c,
        Menu_Category__c,
        Menu_Category__r.Name,
        Available__c,
        Calories__c
      FROM Menu_Item__c
      WHERE Menu__c = :menuId AND Available__c = TRUE
      ORDER BY Menu_Category__c, Name ASC
    ];
  }

  // Wrapper class for category data
  public class CategoryWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String Name;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public Integer itemCount;
  }
}