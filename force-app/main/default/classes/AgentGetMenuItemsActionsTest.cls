@IsTest
private class AgentGetMenuItemsActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme Diner', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    Menu__c menu = TestDataFactory.createMenu(sf.Id, 'Lunch', true, true);
    TestDataFactory.createMenuItem(menu.Id, 'Burger', 12.99, true);
    TestDataFactory.createMenuItem(menu.Id, 'Salad', 9.99, true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenNeitherMenuNorStorefrontProvided() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = acc.Id;
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Either menuId or storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = acc.Id;
    req.menuId = 'a00AB0000000001AAA';
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No menu found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuDoesNotBelongToAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = other.Id;
    req.menuId = menu.Id;
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This menu does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontBelongsToOtherAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnItemsForMenu() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = acc.Id;
    req.menuId = menu.Id;

    Test.startTest();
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(2, resp[0].itemCount);
    Assert.areEqual(2, resp[0].menuItems.size());
    Assert.isNotNull(resp[0].menuItemsJson);
  }

  @IsTest
  static void shouldReturnItemsForStorefront() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentGetMenuItemsActions.Request req = new AgentGetMenuItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;

    Test.startTest();
    List<AgentGetMenuItemsActions.Response> resp = AgentGetMenuItemsActions.invoke(
      new List<AgentGetMenuItemsActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(2, resp[0].itemCount);
  }
}