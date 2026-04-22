@IsTest
private class AgentCaseCreateActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme Diner', true);
    TestDataFactory.createContact(acc.Id, 'Customer', 'customer@example.com', true);
  }

  @IsTest
  static void shouldReturnError_WhenVerifiedCustomerIdMissing() {
    AgentCaseCreateActions.Request req = new AgentCaseCreateActions.Request();

    Test.startTest();
    List<AgentCaseCreateActions.Response> resp = AgentCaseCreateActions.invoke(
      new List<AgentCaseCreateActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, resp.size(), 'Expected singleton response');
    Assert.areEqual(false, resp[0].success, 'Should fail when verifiedCustomerId missing');
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenRequestListNull() {
    Test.startTest();
    List<AgentCaseCreateActions.Response> resp = AgentCaseCreateActions.invoke(null);
    Test.stopTest();

    Assert.areEqual(1, resp.size(), 'Expected singleton response');
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void shouldCreateCase_WithDefaults() {
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    AgentCaseCreateActions.Request req = new AgentCaseCreateActions.Request();
    req.verifiedCustomerId = c.Id;

    Test.startTest();
    List<AgentCaseCreateActions.Response> resp = AgentCaseCreateActions.invoke(
      new List<AgentCaseCreateActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual('OK', resp[0].message);
    Assert.isNotNull(resp[0].createdCase, 'CreatedCase DTO should be set');
    Assert.areEqual('Customer Support Request', resp[0].createdCase.subject);
    Assert.areEqual('Agentforce', resp[0].createdCase.origin);
    Assert.areEqual(c.Id, resp[0].createdCase.customerId);
    Assert.isNotNull(resp[0].createdCase.caseNumber, 'Case number should be populated');
    Assert.isNotNull(resp[0].createdCaseJson, 'JSON should be populated');
  }

  @IsTest
  static void shouldCreateCase_WithAllOptionalFields() {
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    AgentCaseCreateActions.Request req = new AgentCaseCreateActions.Request();
    req.verifiedCustomerId = c.Id;
    req.subject = 'Specific subject';
    req.description = 'Detailed description';
    req.origin = 'Email';
    req.status = 'New';
    req.priority = 'High';
    req.type = 'Problem';
    req.reason = 'Performance';

    Test.startTest();
    List<AgentCaseCreateActions.Response> resp = AgentCaseCreateActions.invoke(
      new List<AgentCaseCreateActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual('Specific subject', resp[0].createdCase.subject);
    Assert.areEqual('Email', resp[0].createdCase.origin);
    Assert.areEqual('High', resp[0].createdCase.priority);
    Assert.areEqual('Problem', resp[0].createdCase.type);
    Assert.areEqual('Performance', resp[0].createdCase.reason);
  }
}