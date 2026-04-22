@IsTest
private class AgentGetActiveMenusActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme Diner', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    TestDataFactory.createMenu(sf.Id, 'Active Menu A', true, true);
    TestDataFactory.createMenu(sf.Id, 'Active Menu B', true, true);
    TestDataFactory.createMenu(sf.Id, 'Inactive Menu', false, true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentGetActiveMenusActions.Request req = new AgentGetActiveMenusActions.Request();
    List<AgentGetActiveMenusActions.Response> resp = AgentGetActiveMenusActions.invoke(
      new List<AgentGetActiveMenusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentGetActiveMenusActions.Request req = new AgentGetActiveMenusActions.Request();
    req.accountId = acc.Id;
    List<AgentGetActiveMenusActions.Response> resp = AgentGetActiveMenusActions.invoke(
      new List<AgentGetActiveMenusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentGetActiveMenusActions.Request req = new AgentGetActiveMenusActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    List<AgentGetActiveMenusActions.Response> resp = AgentGetActiveMenusActions.invoke(
      new List<AgentGetActiveMenusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontBelongsToOtherAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentGetActiveMenusActions.Request req = new AgentGetActiveMenusActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    List<AgentGetActiveMenusActions.Response> resp = AgentGetActiveMenusActions.invoke(
      new List<AgentGetActiveMenusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnActiveMenusOnly() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentGetActiveMenusActions.Request req = new AgentGetActiveMenusActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;

    Test.startTest();
    List<AgentGetActiveMenusActions.Response> resp = AgentGetActiveMenusActions.invoke(
      new List<AgentGetActiveMenusActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(2, resp[0].menuCount, 'Only active menus should be returned');
    Assert.areEqual(2, resp[0].menus.size());
    Assert.isNotNull(resp[0].menusJson);
  }
}