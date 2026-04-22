@IsTest
private class AgentUpdateStorefrontDetailsActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    TestDataFactory.createStorefront(acc.Id, 'Main', true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentUpdateStorefrontDetailsActions.Request req = new AgentUpdateStorefrontDetailsActions.Request();
    List<AgentUpdateStorefrontDetailsActions.Response> resp = AgentUpdateStorefrontDetailsActions.invoke(
      new List<AgentUpdateStorefrontDetailsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateStorefrontDetailsActions.Request req = new AgentUpdateStorefrontDetailsActions.Request();
    req.accountId = acc.Id;
    List<AgentUpdateStorefrontDetailsActions.Response> resp = AgentUpdateStorefrontDetailsActions.invoke(
      new List<AgentUpdateStorefrontDetailsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateStorefrontDetailsActions.Request req = new AgentUpdateStorefrontDetailsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    List<AgentUpdateStorefrontDetailsActions.Response> resp = AgentUpdateStorefrontDetailsActions.invoke(
      new List<AgentUpdateStorefrontDetailsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotOwnedByAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUpdateStorefrontDetailsActions.Request req = new AgentUpdateStorefrontDetailsActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    List<AgentUpdateStorefrontDetailsActions.Response> resp = AgentUpdateStorefrontDetailsActions.invoke(
      new List<AgentUpdateStorefrontDetailsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnNoUpdates_WhenNoFieldsProvided() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUpdateStorefrontDetailsActions.Request req = new AgentUpdateStorefrontDetailsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    List<AgentUpdateStorefrontDetailsActions.Response> resp = AgentUpdateStorefrontDetailsActions.invoke(
      new List<AgentUpdateStorefrontDetailsActions.Request>{ req }
    );
    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('No fields provided to update.', resp[0].message);
  }

  @IsTest
  static void shouldUpdateAllFields() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUpdateStorefrontDetailsActions.Request req = new AgentUpdateStorefrontDetailsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.description = 'New description';
    req.phone = '555-1234';
    req.status = 'Open';
    req.overview = 'Busy, popular spot';

    Test.startTest();
    List<AgentUpdateStorefrontDetailsActions.Response> resp = AgentUpdateStorefrontDetailsActions.invoke(
      new List<AgentUpdateStorefrontDetailsActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Storefront__c updated = [
      SELECT Description__c, Phone__c, Status__c, Storefront_Overview__c
      FROM Storefront__c
      WHERE Id = :sf.Id
    ];
    Assert.areEqual('New description', updated.Description__c);
    Assert.areEqual('555-1234', updated.Phone__c);
    Assert.areEqual('Open', updated.Status__c);
    Assert.areEqual('Busy, popular spot', updated.Storefront_Overview__c);
  }
}