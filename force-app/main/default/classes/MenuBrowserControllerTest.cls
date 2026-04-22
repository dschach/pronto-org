@IsTest
private class MenuBrowserControllerTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    Menu__c menu = TestDataFactory.createMenu(sf.Id, 'Lunch', true, true);
    Menu_Category__c cat = TestDataFactory.createMenuCategory('Mains', true);
    TestDataFactory.createMenuItem(menu.Id, 'Burger', 12.99, false);
    List<Menu_Item__c> items = new List<Menu_Item__c>{
      new Menu_Item__c(
        Menu__c = menu.Id,
        Name = 'Burger',
        Price__c = 12.99,
        Available__c = true,
        Menu_Category__c = cat.Id
      ),
      new Menu_Item__c(
        Menu__c = menu.Id,
        Name = 'Pizza',
        Price__c = 15.99,
        Available__c = true,
        Menu_Category__c = cat.Id
      ),
      new Menu_Item__c(
        Menu__c = menu.Id,
        Name = 'Hidden',
        Price__c = 0,
        Available__c = false,
        Menu_Category__c = cat.Id
      )
    };
    insert items;
  }

  @IsTest
  static void shouldReturnCategoriesWithItemCounts() {
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];

    Test.startTest();
    List<MenuBrowserController.CategoryWrapper> wrappers = MenuBrowserController.getMenuCategories(menu.Id);
    Test.stopTest();

    Assert.areEqual(1, wrappers.size(), 'One category should be returned');
    Assert.areEqual('Mains', wrappers[0].Name);
    Assert.areEqual(2, wrappers[0].itemCount, 'Only available items should be counted');
  }

  @IsTest
  static void shouldReturnEmpty_WhenMenuHasNoItems() {
    Menu__c emptyMenu = TestDataFactory.createMenu([SELECT Id FROM Storefront__c LIMIT 1].Id, 'Empty', true, true);
    List<MenuBrowserController.CategoryWrapper> wrappers = MenuBrowserController.getMenuCategories(emptyMenu.Id);
    Assert.areEqual(0, wrappers.size());
  }

  @IsTest
  static void shouldReturnAvailableMenuItems() {
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];

    Test.startTest();
    List<Menu_Item__c> items = MenuBrowserController.getMenuItems(menu.Id);
    Test.stopTest();

    Assert.areEqual(2, items.size(), 'Only available items should be returned');
    for (Menu_Item__c item : items) {
      Assert.areEqual(true, item.Available__c);
    }
  }
}