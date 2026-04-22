@IsTest
private class AgentUpdateStorefrontHoursActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    TestDataFactory.createStorefront(acc.Id, 'Main', true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    req.accountId = acc.Id;
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenDayOfWeekMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('dayOfWeek is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    req.dayOfWeek = 'Monday';
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotOwnedByAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    req.dayOfWeek = 'Monday';
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldCreateHours_WhenNoneExist() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.dayOfWeek = 'monday';
    req.openingTime = '09:00';
    req.closingTime = '21:00';
    req.notes = 'Normal hours';

    Test.startTest();
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('Monday', resp[0].dayOfWeek, 'Day should be normalized to title case');
    Assert.isNotNull(resp[0].hoursRecordId);
    Assert.isTrue(resp[0].message.startsWith('Hours created'));
  }

  @IsTest
  static void shouldUpdateHours_WhenExisting() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    Storefront_Hours_of_Operation__c existing = new Storefront_Hours_of_Operation__c(
      Storefront__c = sf.Id,
      Day_of_Week__c = 'Tuesday',
      Opening_Time__c = '08:00',
      Closing_Time__c = '20:00'
    );
    insert existing;

    AgentUpdateStorefrontHoursActions.Request req = new AgentUpdateStorefrontHoursActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.dayOfWeek = 'Tuesday';
    req.openingTime = '10:00';

    Test.startTest();
    List<AgentUpdateStorefrontHoursActions.Response> resp = AgentUpdateStorefrontHoursActions.invoke(
      new List<AgentUpdateStorefrontHoursActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.isTrue(resp[0].message.startsWith('Hours updated'));
    Storefront_Hours_of_Operation__c updated = [
      SELECT Opening_Time__c, Closing_Time__c
      FROM Storefront_Hours_of_Operation__c
      WHERE Id = :existing.Id
    ];
    Assert.areEqual('10:00', updated.Opening_Time__c);
    Assert.areEqual('20:00', updated.Closing_Time__c, 'Unchanged field should be preserved');
  }
}