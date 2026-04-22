@IsTest
private class AgentUpdateMenuActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    TestDataFactory.createMenu(sf.Id, 'Lunch Menu', true, true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentUpdateMenuActions.Request req = new AgentUpdateMenuActions.Request();
    List<AgentUpdateMenuActions.Response> resp = AgentUpdateMenuActions.invoke(
      new List<AgentUpdateMenuActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateMenuActions.Request req = new AgentUpdateMenuActions.Request();
    req.accountId = acc.Id;
    List<AgentUpdateMenuActions.Response> resp = AgentUpdateMenuActions.invoke(
      new List<AgentUpdateMenuActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('menuId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateMenuActions.Request req = new AgentUpdateMenuActions.Request();
    req.accountId = acc.Id;
    req.menuId = 'a00AB0000000001AAA';
    List<AgentUpdateMenuActions.Response> resp = AgentUpdateMenuActions.invoke(
      new List<AgentUpdateMenuActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No menu found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuBelongsToOtherAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];
    AgentUpdateMenuActions.Request req = new AgentUpdateMenuActions.Request();
    req.accountId = other.Id;
    req.menuId = menu.Id;
    List<AgentUpdateMenuActions.Response> resp = AgentUpdateMenuActions.invoke(
      new List<AgentUpdateMenuActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This menu does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnNoUpdates_WhenNoFieldsProvided() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];
    AgentUpdateMenuActions.Request req = new AgentUpdateMenuActions.Request();
    req.accountId = acc.Id;
    req.menuId = menu.Id;

    List<AgentUpdateMenuActions.Response> resp = AgentUpdateMenuActions.invoke(
      new List<AgentUpdateMenuActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('No fields provided to update.', resp[0].message);
  }

  @IsTest
  static void shouldUpdateMenuFields() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];
    AgentUpdateMenuActions.Request req = new AgentUpdateMenuActions.Request();
    req.accountId = acc.Id;
    req.menuId = menu.Id;
    req.displayName = 'Dinner Menu';
    req.description = 'Evening offerings';
    req.active = false;

    Test.startTest();
    List<AgentUpdateMenuActions.Response> resp = AgentUpdateMenuActions.invoke(
      new List<AgentUpdateMenuActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Menu__c updated = [SELECT Menu_Display_Name__c, Description__c, Active__c FROM Menu__c WHERE Id = :menu.Id];
    Assert.areEqual('Dinner Menu', updated.Menu_Display_Name__c);
    Assert.areEqual('Evening offerings', updated.Description__c);
    Assert.areEqual(false, updated.Active__c);
  }
}