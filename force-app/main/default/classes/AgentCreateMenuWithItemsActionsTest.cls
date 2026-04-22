@IsTest
private class AgentCreateMenuWithItemsActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme Diner', true);
    TestDataFactory.createStorefront(acc.Id, 'Main Storefront', true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
    Assert.areEqual('[]', resp[0].createdItemsJson);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuNameMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('menuName is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    req.menuName = 'Lunch';
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontDoesNotBelongToAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    req.menuName = 'Lunch';
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldCreateMenu_WithoutItems() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.menuName = 'Empty Menu';

    Test.startTest();
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual(0, resp[0].itemCount);
    Assert.isNotNull(resp[0].menu);
  }

  @IsTest
  static void shouldCreateMenu_WithItemsAndNewCategory() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.menuName = 'Full Menu';
    req.menuDisplayName = 'Lunch Menu';
    req.active = true;
    req.itemsJson = '[{"name":"Burger","price":12.99,"category":"Mains"},{"name":"Fries","price":4.99,"category":"Sides"},{"name":"","price":0}]';

    Test.startTest();
    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual(2, resp[0].itemCount, 'Blank-named item should be skipped');
    Assert.areEqual(2, resp[0].createdItems.size());
    List<Menu_Category__c> cats = [SELECT Id FROM Menu_Category__c WHERE Name IN ('Mains', 'Sides')];
    Assert.areEqual(2, cats.size(), 'Both categories should be created');
  }

  @IsTest
  static void shouldReuseExistingCategory_WhenNameMatches() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    TestDataFactory.createMenuCategory('Existing Cat', true);

    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.menuName = 'Test';
    req.itemsJson = '[{"name":"Item A","category":"Existing Cat"}]';

    Test.startTest();
    AgentCreateMenuWithItemsActions.invoke(new List<AgentCreateMenuWithItemsActions.Request>{ req });
    Test.stopTest();

    List<Menu_Category__c> cats = [SELECT Id FROM Menu_Category__c WHERE Name = 'Existing Cat'];
    Assert.areEqual(1, cats.size(), 'Should not duplicate an existing category');
  }

  @IsTest
  static void shouldHandleInvalidItemsJson_AsEmptyList() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreateMenuWithItemsActions.Request req = new AgentCreateMenuWithItemsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.menuName = 'Test';
    req.itemsJson = 'not valid json';

    List<AgentCreateMenuWithItemsActions.Response> resp = AgentCreateMenuWithItemsActions.invoke(
      new List<AgentCreateMenuWithItemsActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(0, resp[0].itemCount);
  }
}