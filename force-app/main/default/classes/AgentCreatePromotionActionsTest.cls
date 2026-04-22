@IsTest
private class AgentCreatePromotionActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme Diner', true);
    TestDataFactory.createStorefront(acc.Id, 'Main Storefront', true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    req.accountId = acc.Id;
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenDescriptionMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('description is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontDoesNotBelongToAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    req.description = 'Test promo';
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    req.description = 'Test promo';
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldCreatePromotion_WithDefaults() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.description = 'Summer discount';

    Test.startTest();
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.isNotNull(resp[0].promotion);
    Promotion__c saved = [SELECT Status__c FROM Promotion__c WHERE Id = :resp[0].promotion.Id];
    Assert.areEqual('Draft', saved.Status__c, 'Should default to Draft');
  }

  @IsTest
  static void shouldCreatePromotion_WithAllFields() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentCreatePromotionActions.Request req = new AgentCreatePromotionActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.description = 'Fall sale';
    req.discountPercentage = 15;
    req.startDate = Date.today();
    req.endDate = Date.today().addDays(30);
    req.promotionCode = 'FALL15';
    req.status = 'Active';

    Test.startTest();
    List<AgentCreatePromotionActions.Response> resp = AgentCreatePromotionActions.invoke(
      new List<AgentCreatePromotionActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Promotion__c saved = [
      SELECT Status__c, Discount_Percentage__c, Promotion_Code__c
      FROM Promotion__c
      WHERE Id = :resp[0].promotion.Id
    ];
    Assert.areEqual('Active', saved.Status__c);
    Assert.areEqual(15, saved.Discount_Percentage__c);
    Assert.areEqual('FALL15', saved.Promotion_Code__c);
  }
}