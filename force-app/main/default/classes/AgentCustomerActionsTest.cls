@IsTest
private class AgentCustomerActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme Diner', true);
    TestDataFactory.createContact(acc.Id, 'Morgan', 'alex.morgan@example.com', true);
  }

  @IsTest
  static void shouldReturnError_WhenNoRequest() {
    Test.startTest();
    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(null);
    Test.stopTest();

    Assert.areEqual(1, resp.size());
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('A request is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenNeitherIdNorEmailProvided() {
    AgentCustomerActions.Request req = new AgentCustomerActions.Request();
    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(
      new List<AgentCustomerActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Either verifiedCustomerId or customerEmail is required.', resp[0].message);
  }

  @IsTest
  static void shouldFindCustomer_ById() {
    Contact c = [SELECT Id, AccountId FROM Contact LIMIT 1];
    AgentCustomerActions.Request req = new AgentCustomerActions.Request();
    req.verifiedCustomerId = c.Id;

    Test.startTest();
    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(
      new List<AgentCustomerActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual(true, resp[0].found);
    Assert.areEqual(c.Id, resp[0].verifiedCustomerId);
    Assert.areEqual(c.AccountId, resp[0].accountId);
    Assert.areEqual('Morgan', resp[0].lastName);
    Assert.isNotNull(resp[0].customerJson);
  }

  @IsTest
  static void shouldFindCustomer_ByEmail() {
    AgentCustomerActions.Request req = new AgentCustomerActions.Request();
    req.customerEmail = 'alex.morgan@example.com';

    Test.startTest();
    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(
      new List<AgentCustomerActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(true, resp[0].found);
    Assert.areEqual('alex.morgan@example.com', resp[0].customer.email);
  }

  @IsTest
  static void shouldFindCustomer_ByIdAndEmail() {
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    AgentCustomerActions.Request req = new AgentCustomerActions.Request();
    req.verifiedCustomerId = c.Id;
    req.customerEmail = 'alex.morgan@example.com';

    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(
      new List<AgentCustomerActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(true, resp[0].found);
  }

  @IsTest
  static void shouldReturnNotFound_ForUnknownEmail() {
    AgentCustomerActions.Request req = new AgentCustomerActions.Request();
    req.customerEmail = 'nobody@nowhere.example';

    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(
      new List<AgentCustomerActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success, 'Success true even when no record found');
    Assert.areEqual(false, resp[0].found);
    Assert.isTrue(resp[0].message.contains('No customer found'));
  }

  @IsTest
  static void shouldReturnNotFound_ForUnknownIdAndEmailCombo() {
    Contact c = [SELECT Id FROM Contact LIMIT 1];
    AgentCustomerActions.Request req = new AgentCustomerActions.Request();
    req.verifiedCustomerId = c.Id;
    req.customerEmail = 'wrong@example.com';

    List<AgentCustomerActions.Response> resp = AgentCustomerActions.invoke(
      new List<AgentCustomerActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(false, resp[0].found);
    Assert.isTrue(resp[0].message.contains('No customer found'));
  }
}