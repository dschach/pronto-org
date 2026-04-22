@IsTest
private class AgentSummarizeReviewsActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    Contact cust = TestDataFactory.createContact(acc.Id, 'Reviewer', 'reviewer@example.com', true);

    List<Review__c> reviews = new List<Review__c>();
    reviews.add(
      new Review__c(Storefront__c = sf.Id, Customer__c = cust.Id, Rating__c = 5, Order_Date__c = Date.today())
    );
    reviews.add(
      new Review__c(
        Storefront__c = sf.Id,
        Customer__c = cust.Id,
        Rating__c = 4,
        Order_Date__c = Date.today().addDays(-5)
      )
    );
    reviews.add(
      new Review__c(
        Storefront__c = sf.Id,
        Customer__c = cust.Id,
        Rating__c = 3,
        Order_Date__c = Date.today().addDays(-10)
      )
    );
    reviews.add(
      new Review__c(
        Storefront__c = sf.Id,
        Customer__c = cust.Id,
        Rating__c = 2,
        Order_Date__c = Date.today().addDays(-15)
      )
    );
    reviews.add(
      new Review__c(
        Storefront__c = sf.Id,
        Customer__c = cust.Id,
        Rating__c = 1,
        Order_Date__c = Date.today().addDays(-20)
      )
    );
    reviews.add(
      new Review__c(
        Storefront__c = sf.Id,
        Customer__c = cust.Id,
        Rating__c = 5,
        Order_Date__c = Date.today().addDays(-90)
      )
    );
    insert reviews;
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentSummarizeReviewsActions.Request req = new AgentSummarizeReviewsActions.Request();
    List<AgentSummarizeReviewsActions.Response> resp = AgentSummarizeReviewsActions.invoke(
      new List<AgentSummarizeReviewsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentSummarizeReviewsActions.Request req = new AgentSummarizeReviewsActions.Request();
    req.accountId = acc.Id;
    List<AgentSummarizeReviewsActions.Response> resp = AgentSummarizeReviewsActions.invoke(
      new List<AgentSummarizeReviewsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentSummarizeReviewsActions.Request req = new AgentSummarizeReviewsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = '01tAB0000000001AAA';
    List<AgentSummarizeReviewsActions.Response> resp = AgentSummarizeReviewsActions.invoke(
      new List<AgentSummarizeReviewsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No storefront found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotOwnedByAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentSummarizeReviewsActions.Request req = new AgentSummarizeReviewsActions.Request();
    req.accountId = other.Id;
    req.storefrontId = sf.Id;
    List<AgentSummarizeReviewsActions.Response> resp = AgentSummarizeReviewsActions.invoke(
      new List<AgentSummarizeReviewsActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This storefront does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnReviews_WithinDefaultDaysBack() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentSummarizeReviewsActions.Request req = new AgentSummarizeReviewsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;

    Test.startTest();
    List<AgentSummarizeReviewsActions.Response> resp = AgentSummarizeReviewsActions.invoke(
      new List<AgentSummarizeReviewsActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(5, resp[0].reviewCount, 'Should exclude the 90-day-old review (default 30 days)');
    Assert.areEqual(1, resp[0].fiveStarCount);
    Assert.areEqual(1, resp[0].fourStarCount);
    Assert.areEqual(1, resp[0].threeStarCount);
    Assert.areEqual(1, resp[0].twoStarCount);
    Assert.areEqual(1, resp[0].oneStarCount);
    Assert.areEqual(3.00, resp[0].averageRating);
  }

  @IsTest
  static void shouldRespectDaysBackAndReviewLimit() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentSummarizeReviewsActions.Request req = new AgentSummarizeReviewsActions.Request();
    req.accountId = acc.Id;
    req.storefrontId = sf.Id;
    req.daysBack = 100;
    req.reviewLimit = 2;

    List<AgentSummarizeReviewsActions.Response> resp = AgentSummarizeReviewsActions.invoke(
      new List<AgentSummarizeReviewsActions.Request>{ req }
    );

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(2, resp[0].reviewCount, 'Should enforce reviewLimit of 2');
  }
}