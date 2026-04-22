@IsTest
private class AgentUpdateMenuItemPriceActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    Menu__c menu = TestDataFactory.createMenu(sf.Id, 'Lunch', true, true);
    TestDataFactory.createMenuItem(menu.Id, 'Burger', 12.99, true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentUpdateMenuItemPriceActions.Request req = new AgentUpdateMenuItemPriceActions.Request();
    List<AgentUpdateMenuItemPriceActions.Response> resp = AgentUpdateMenuItemPriceActions.invoke(
      new List<AgentUpdateMenuItemPriceActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuItemIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateMenuItemPriceActions.Request req = new AgentUpdateMenuItemPriceActions.Request();
    req.accountId = acc.Id;
    List<AgentUpdateMenuItemPriceActions.Response> resp = AgentUpdateMenuItemPriceActions.invoke(
      new List<AgentUpdateMenuItemPriceActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('menuItemId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenPriceMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu_Item__c item = [SELECT Id FROM Menu_Item__c LIMIT 1];
    AgentUpdateMenuItemPriceActions.Request req = new AgentUpdateMenuItemPriceActions.Request();
    req.accountId = acc.Id;
    req.menuItemId = item.Id;
    List<AgentUpdateMenuItemPriceActions.Response> resp = AgentUpdateMenuItemPriceActions.invoke(
      new List<AgentUpdateMenuItemPriceActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('price is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenItemNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateMenuItemPriceActions.Request req = new AgentUpdateMenuItemPriceActions.Request();
    req.accountId = acc.Id;
    req.menuItemId = 'a00AB0000000001AAA';
    req.price = 9.99;
    List<AgentUpdateMenuItemPriceActions.Response> resp = AgentUpdateMenuItemPriceActions.invoke(
      new List<AgentUpdateMenuItemPriceActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No menu item found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenItemNotOwnedByAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Menu_Item__c item = [SELECT Id FROM Menu_Item__c LIMIT 1];
    AgentUpdateMenuItemPriceActions.Request req = new AgentUpdateMenuItemPriceActions.Request();
    req.accountId = other.Id;
    req.menuItemId = item.Id;
    req.price = 9.99;
    List<AgentUpdateMenuItemPriceActions.Response> resp = AgentUpdateMenuItemPriceActions.invoke(
      new List<AgentUpdateMenuItemPriceActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This menu item does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldUpdatePrice() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu_Item__c item = [SELECT Id FROM Menu_Item__c LIMIT 1];
    AgentUpdateMenuItemPriceActions.Request req = new AgentUpdateMenuItemPriceActions.Request();
    req.accountId = acc.Id;
    req.menuItemId = item.Id;
    req.price = 14.99;

    Test.startTest();
    List<AgentUpdateMenuItemPriceActions.Response> resp = AgentUpdateMenuItemPriceActions.invoke(
      new List<AgentUpdateMenuItemPriceActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual(12.99, resp[0].previousPrice);
    Assert.areEqual(14.99, resp[0].newPrice);
    Menu_Item__c updated = [SELECT Price__c FROM Menu_Item__c WHERE Id = :item.Id];
    Assert.areEqual(14.99, updated.Price__c);
  }
}