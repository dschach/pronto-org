@IsTest
private class AgentActionsTest {
  @IsTest
  static void storefrontQuery_returnsDtos() {
    insert new Storefront__c(Name = 'Trailside Deli', Description__c = 'Test desc', Cuisine__c = 'Deli');
    insert new Storefront__c(Name = 'Urban Table Downtown', Description__c = 'Test desc 2', Cuisine__c = 'American');

    AgentStorefrontActions.Request req = new AgentStorefrontActions.Request();
    req.storefrontName = 'Trail';

    Test.startTest();
    List<AgentStorefrontActions.Response> respList = AgentStorefrontActions.invoke(
      new List<AgentStorefrontActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, respList.size(), 'Expected one response wrapper');
    Assert.isNotNull(respList[0].storefronts, 'Expected storefront DTO list');
    Assert.areEqual(1, respList[0].storefronts.size(), 'Expected one matching storefront');
    Assert.areEqual('Trailside Deli', respList[0].storefronts[0].name);
    Assert.isNotNull(respList[0].storefrontsJson, 'Expected JSON payload');
  }

  @IsTest
  static void storefrontQuery_blankName_returnsError() {
    AgentStorefrontActions.Request req = new AgentStorefrontActions.Request();
    req.storefrontName = '   ';

    List<AgentStorefrontActions.Response> respList = AgentStorefrontActions.invoke(
      new List<AgentStorefrontActions.Request>{ req }
    );

    Assert.areEqual(1, respList.size());
    Assert.areEqual(false, respList[0].success);
    Assert.areEqual('storefrontName is required.', respList[0].message);
    Assert.areEqual('[]', respList[0].storefrontsJson);
  }

  @IsTest
  static void storefrontQuery_emptyRequests_returnsError() {
    List<AgentStorefrontActions.Response> respList = AgentStorefrontActions.invoke(null);
    Assert.areEqual(1, respList.size());
    Assert.areEqual(false, respList[0].success);
  }

  @IsTest
  static void caseQuery_returnsDtos() {
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;
    Case cs = new Case(Subject = 'Test Case', Origin = 'Phone', Status = 'New', ContactId = c.Id, Description = 'Test');
    insert cs;

    AgentCaseActions.Request req = new AgentCaseActions.Request();
    req.verifiedCustomerId = c.Id;
    req.caseStatus = 'All';

    Test.startTest();
    List<AgentCaseActions.Response> respList = AgentCaseActions.invoke(new List<AgentCaseActions.Request>{ req });
    Test.stopTest();

    Assert.areEqual(1, respList.size());
    Assert.areEqual(1, respList[0].cases.size());
    Assert.areEqual(cs.Id, respList[0].cases[0].id);
    Assert.isNotNull(respList[0].casesJson);
  }

  @IsTest
  static void caseQuery_withStatusFilter_returnsOnlyMatching() {
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;
    insert new Case(Subject = 'New', Status = 'New', ContactId = c.Id);
    insert new Case(Subject = 'Closed', Status = 'Closed', ContactId = c.Id);

    AgentCaseActions.Request req = new AgentCaseActions.Request();
    req.verifiedCustomerId = c.Id;
    req.caseStatus = 'New';

    List<AgentCaseActions.Response> resp = AgentCaseActions.invoke(new List<AgentCaseActions.Request>{ req });

    Assert.areEqual(1, resp[0].cases.size(), 'Should filter to only "New"');
    Assert.areEqual('New', resp[0].cases[0].status);
  }

  @IsTest
  static void caseQuery_missingCustomerId_returnsError() {
    AgentCaseActions.Request req = new AgentCaseActions.Request();
    req.caseStatus = 'All';

    List<AgentCaseActions.Response> resp = AgentCaseActions.invoke(new List<AgentCaseActions.Request>{ req });

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void caseQuery_missingStatus_returnsError() {
    Contact c = new Contact(LastName = 'Morgan');
    insert c;
    AgentCaseActions.Request req = new AgentCaseActions.Request();
    req.verifiedCustomerId = c.Id;

    List<AgentCaseActions.Response> resp = AgentCaseActions.invoke(new List<AgentCaseActions.Request>{ req });

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('caseStatus is required.', resp[0].message);
  }

  @IsTest
  static void caseQuery_nullRequests_returnsError() {
    List<AgentCaseActions.Response> resp = AgentCaseActions.invoke(null);
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void giftCertificateCreate_returnsDtos() {
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;

    AgentGiftCertificateActions.Request req = new AgentGiftCertificateActions.Request();
    req.verifiedCustomerId = c.Id;
    req.giftValue = 25;
    req.giftType = 'Promotion';
    req.sourceChannel = 'Agentforce';

    Test.startTest();
    List<AgentGiftCertificateActions.Response> respList = AgentGiftCertificateActions.invoke(
      new List<AgentGiftCertificateActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, respList.size());
    Assert.areEqual(1, respList[0].giftCertificates.size());
    Assert.isNotNull(respList[0].giftCertificates[0].id);
    Assert.areEqual(c.Id, respList[0].giftCertificates[0].recipientId);
    Assert.isNotNull(respList[0].giftCertificatesJson);
  }

  @IsTest
  static void giftCertificateCreate_missingCustomerId_returnsError() {
    AgentGiftCertificateActions.Request req = new AgentGiftCertificateActions.Request();
    req.giftValue = 25;
    req.giftType = 'Promotion';

    List<AgentGiftCertificateActions.Response> resp = AgentGiftCertificateActions.invoke(
      new List<AgentGiftCertificateActions.Request>{ req }
    );

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void giftCertificateCreate_missingValue_returnsError() {
    Contact c = new Contact(LastName = 'Morgan');
    insert c;
    AgentGiftCertificateActions.Request req = new AgentGiftCertificateActions.Request();
    req.verifiedCustomerId = c.Id;
    req.giftType = 'Promotion';

    List<AgentGiftCertificateActions.Response> resp = AgentGiftCertificateActions.invoke(
      new List<AgentGiftCertificateActions.Request>{ req }
    );

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('giftValue is required.', resp[0].message);
  }

  @IsTest
  static void giftCertificateCreate_missingType_returnsError() {
    Contact c = new Contact(LastName = 'Morgan');
    insert c;
    AgentGiftCertificateActions.Request req = new AgentGiftCertificateActions.Request();
    req.verifiedCustomerId = c.Id;
    req.giftValue = 25;

    List<AgentGiftCertificateActions.Response> resp = AgentGiftCertificateActions.invoke(
      new List<AgentGiftCertificateActions.Request>{ req }
    );

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('giftType is required.', resp[0].message);
  }

  @IsTest
  static void giftCertificateCreate_nullRequests_returnsError() {
    List<AgentGiftCertificateActions.Response> resp = AgentGiftCertificateActions.invoke(null);
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void reviewCreate_returnsDtos() {
    Storefront__c sf = new Storefront__c(Name = 'Trailside Deli');
    insert sf;
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;

    AgentReviewActions.Request req = new AgentReviewActions.Request();
    req.verifiedCustomerId = c.Id;
    req.storefrontId = sf.Id;
    req.rating = 5;
    req.reviewComment = 'Great!';

    Test.startTest();
    List<AgentReviewActions.Response> respList = AgentReviewActions.invoke(new List<AgentReviewActions.Request>{ req });
    Test.stopTest();

    Assert.areEqual(1, respList.size());
    Assert.areEqual(1, respList[0].reviews.size());
    Assert.areEqual(sf.Id, respList[0].reviews[0].storefrontId);
    Assert.areEqual(c.Id, respList[0].reviews[0].customerId);
    Assert.areEqual(5, respList[0].reviews[0].rating);
    Assert.isNotNull(respList[0].reviewsJson);
  }

  @IsTest
  static void reviewCreate_missingCustomerId_returnsError() {
    AgentReviewActions.Request req = new AgentReviewActions.Request();
    req.storefrontId = '01tAB0000000001AAA';
    req.rating = 5;

    List<AgentReviewActions.Response> resp = AgentReviewActions.invoke(new List<AgentReviewActions.Request>{ req });

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void reviewCreate_missingStorefrontId_returnsError() {
    Contact c = new Contact(LastName = 'Morgan');
    insert c;
    AgentReviewActions.Request req = new AgentReviewActions.Request();
    req.verifiedCustomerId = c.Id;
    req.rating = 5;

    List<AgentReviewActions.Response> resp = AgentReviewActions.invoke(new List<AgentReviewActions.Request>{ req });

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void reviewCreate_missingRating_returnsError() {
    Contact c = new Contact(LastName = 'Morgan');
    insert c;
    Storefront__c sf = new Storefront__c(Name = 'Test');
    insert sf;
    AgentReviewActions.Request req = new AgentReviewActions.Request();
    req.verifiedCustomerId = c.Id;
    req.storefrontId = sf.Id;

    List<AgentReviewActions.Response> resp = AgentReviewActions.invoke(new List<AgentReviewActions.Request>{ req });

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('rating is required.', resp[0].message);
  }

  @IsTest
  static void reviewCreate_nullRequests_returnsError() {
    List<AgentReviewActions.Response> resp = AgentReviewActions.invoke(null);
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }
}