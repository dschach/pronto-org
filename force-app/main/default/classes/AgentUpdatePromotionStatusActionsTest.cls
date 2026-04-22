@IsTest
private class AgentUpdatePromotionStatusActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    Promotion__c p = new Promotion__c(Storefront__c = sf.Id, Description__c = 'Initial promo', Status__c = 'Draft');
    insert p;
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentUpdatePromotionStatusActions.Request req = new AgentUpdatePromotionStatusActions.Request();
    List<AgentUpdatePromotionStatusActions.Response> resp = AgentUpdatePromotionStatusActions.invoke(
      new List<AgentUpdatePromotionStatusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenPromotionIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdatePromotionStatusActions.Request req = new AgentUpdatePromotionStatusActions.Request();
    req.accountId = acc.Id;
    List<AgentUpdatePromotionStatusActions.Response> resp = AgentUpdatePromotionStatusActions.invoke(
      new List<AgentUpdatePromotionStatusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('promotionId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStatusMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Promotion__c p = [SELECT Id FROM Promotion__c LIMIT 1];
    AgentUpdatePromotionStatusActions.Request req = new AgentUpdatePromotionStatusActions.Request();
    req.accountId = acc.Id;
    req.promotionId = p.Id;
    List<AgentUpdatePromotionStatusActions.Response> resp = AgentUpdatePromotionStatusActions.invoke(
      new List<AgentUpdatePromotionStatusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('status is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenPromotionNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdatePromotionStatusActions.Request req = new AgentUpdatePromotionStatusActions.Request();
    req.accountId = acc.Id;
    req.promotionId = 'a00AB0000000001AAA';
    req.status = 'Active';
    List<AgentUpdatePromotionStatusActions.Response> resp = AgentUpdatePromotionStatusActions.invoke(
      new List<AgentUpdatePromotionStatusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No promotion found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenPromotionNotOwnedByAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Promotion__c p = [SELECT Id FROM Promotion__c LIMIT 1];
    AgentUpdatePromotionStatusActions.Request req = new AgentUpdatePromotionStatusActions.Request();
    req.accountId = other.Id;
    req.promotionId = p.Id;
    req.status = 'Active';
    List<AgentUpdatePromotionStatusActions.Response> resp = AgentUpdatePromotionStatusActions.invoke(
      new List<AgentUpdatePromotionStatusActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This promotion does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldUpdateStatus() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Promotion__c p = [SELECT Id FROM Promotion__c LIMIT 1];
    AgentUpdatePromotionStatusActions.Request req = new AgentUpdatePromotionStatusActions.Request();
    req.accountId = acc.Id;
    req.promotionId = p.Id;
    req.status = 'Active';

    Test.startTest();
    List<AgentUpdatePromotionStatusActions.Response> resp = AgentUpdatePromotionStatusActions.invoke(
      new List<AgentUpdatePromotionStatusActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('Draft', resp[0].previousStatus);
    Assert.areEqual('Active', resp[0].newStatus);
    Promotion__c updated = [SELECT Status__c FROM Promotion__c WHERE Id = :p.Id];
    Assert.areEqual('Active', updated.Status__c);
  }
}