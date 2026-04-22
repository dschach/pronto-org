@IsTest
private class AgentGetStorefrontsByAccountActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    TestDataFactory.createStorefront(acc.Id, 'Downtown', true);
    TestDataFactory.createStorefront(acc.Id, 'Uptown', true);
    Account other = TestDataFactory.createAccount('Other', true);
    TestDataFactory.createStorefront(other.Id, 'Elsewhere', true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentGetStorefrontsByAccountActions.Request req = new AgentGetStorefrontsByAccountActions.Request();
    List<AgentGetStorefrontsByAccountActions.Response> resp = AgentGetStorefrontsByAccountActions.invoke(
      new List<AgentGetStorefrontsByAccountActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
    Assert.areEqual('[]', resp[0].storefrontsJson);
  }

  @IsTest
  static void shouldReturnOnlyOwnedStorefronts() {
    Account acc = [SELECT Id FROM Account WHERE Name = 'Acme' LIMIT 1];
    AgentGetStorefrontsByAccountActions.Request req = new AgentGetStorefrontsByAccountActions.Request();
    req.accountId = acc.Id;

    Test.startTest();
    List<AgentGetStorefrontsByAccountActions.Response> resp = AgentGetStorefrontsByAccountActions.invoke(
      new List<AgentGetStorefrontsByAccountActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(2, resp[0].storefronts.size(), 'Should only return storefronts for the given account');
    Assert.isNotNull(resp[0].storefrontsJson);
  }

  @IsTest
  static void shouldReturnEmpty_ForAccountWithNoStorefronts() {
    Account emptyAcc = TestDataFactory.createAccount('Empty', true);
    AgentGetStorefrontsByAccountActions.Request req = new AgentGetStorefrontsByAccountActions.Request();
    req.accountId = emptyAcc.Id;

    List<AgentGetStorefrontsByAccountActions.Response> resp = AgentGetStorefrontsByAccountActions.invoke(
      new List<AgentGetStorefrontsByAccountActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(0, resp[0].storefronts.size());
  }

  @IsTest
  static void shouldHandleNullRequestsList() {
    Test.startTest();
    List<AgentGetStorefrontsByAccountActions.Response> resp = AgentGetStorefrontsByAccountActions.invoke(null);
    Test.stopTest();

    Assert.areEqual(1, resp.size());
    Assert.areEqual(false, resp[0].success);
  }
}