/**
 * TestDataFactory
 *
 * Central factory for creating test data used by Agent*Actions tests.
 */
@IsTest
public class TestDataFactory {
  public static Account createAccount(String name, Boolean doInsert) {
    Account a = new Account(Name = name);
    if (doInsert) {
      insert a;
    }
    return a;
  }

  public static Contact createContact(Id accountId, String lastName, String email, Boolean doInsert) {
    Contact c = new Contact(AccountId = accountId, LastName = lastName, Email = email);
    if (doInsert) {
      insert c;
    }
    return c;
  }

  public static Storefront__c createStorefront(Id accountId, String name, Boolean doInsert) {
    Storefront__c sf = new Storefront__c(Name = name, Account__c = accountId, Cuisine__c = 'American');
    if (doInsert) {
      insert sf;
    }
    return sf;
  }

  public static Menu__c createMenu(Id storefrontId, String displayName, Boolean active, Boolean doInsert) {
    Menu__c m = new Menu__c(Storefront__c = storefrontId, Menu_Display_Name__c = displayName, Active__c = active);
    if (doInsert) {
      insert m;
    }
    return m;
  }

  public static Menu_Category__c createMenuCategory(String name, Boolean doInsert) {
    Menu_Category__c c = new Menu_Category__c(Name = name);
    if (doInsert) {
      insert c;
    }
    return c;
  }

  public static Menu_Item__c createMenuItem(Id menuId, String name, Decimal price, Boolean doInsert) {
    Menu_Item__c mi = new Menu_Item__c(Menu__c = menuId, Name = name, Price__c = price, Available__c = true);
    if (doInsert) {
      insert mi;
    }
    return mi;
  }
}