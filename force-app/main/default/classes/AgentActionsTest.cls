@IsTest
private class AgentActionsTest {
  @IsTest
  static void storefrontQuery_returnsDtos() {
    // Arrange
    insert new Storefront__c(Name = 'Trailside Deli', Description__c = 'Test desc', Cuisine__c = 'Deli');
    insert new Storefront__c(Name = 'Urban Table Downtown', Description__c = 'Test desc 2', Cuisine__c = 'American');

    AgentStorefrontActions.Request req = new AgentStorefrontActions.Request();
    req.storefrontName = 'Trail';

    // Act
    Test.startTest();
    List<AgentStorefrontActions.Response> respList = AgentStorefrontActions.invoke(
      new List<AgentStorefrontActions.Request>{ req }
    );
    Test.stopTest();

    // Assert
    System.assertEquals(1, respList.size(), 'Expected one response wrapper');
    System.assertNotEquals(null, respList[0].storefronts, 'Expected storefront DTO list');
    System.assertEquals(1, respList[0].storefronts.size(), 'Expected one matching storefront');
    System.assertEquals('Trailside Deli', respList[0].storefronts[0].name);
    System.assertNotEquals(null, respList[0].storefrontsJson, 'Expected JSON payload');
  }

  @IsTest
  static void caseQuery_returnsDtos() {
    // Arrange
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;
    Case cs = new Case(Subject = 'Test Case', Origin = 'Phone', Status = 'New', ContactId = c.Id, Description = 'Test');
    insert cs;

    AgentCaseActions.Request req = new AgentCaseActions.Request();
    req.verifiedCustomerId = c.Id;
    req.caseStatus = 'All';

    // Act
    Test.startTest();
    List<AgentCaseActions.Response> respList = AgentCaseActions.invoke(new List<AgentCaseActions.Request>{ req });
    Test.stopTest();

    // Assert
    System.assertEquals(1, respList.size());
    System.assertEquals(1, respList[0].cases.size());
    System.assertEquals(cs.Id, respList[0].cases[0].id);
    System.assertNotEquals(null, respList[0].casesJson);
  }

  @IsTest
  static void giftCertificateCreate_returnsDtos() {
    // Arrange
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;

    AgentGiftCertificateActions.Request req = new AgentGiftCertificateActions.Request();
    req.verifiedCustomerId = c.Id;
    req.giftValue = 25;
    req.giftType = 'Promotion';
    req.sourceChannel = 'Agentforce';

    // Act
    Test.startTest();
    List<AgentGiftCertificateActions.Response> respList = AgentGiftCertificateActions.invoke(
      new List<AgentGiftCertificateActions.Request>{ req }
    );
    Test.stopTest();

    // Assert
    System.assertEquals(1, respList.size());
    System.assertEquals(1, respList[0].giftCertificates.size());
    System.assertNotEquals(null, respList[0].giftCertificates[0].id);
    System.assertEquals(c.Id, respList[0].giftCertificates[0].recipientId);
    System.assertNotEquals(null, respList[0].giftCertificatesJson);
  }

  @IsTest
  static void reviewCreate_returnsDtos() {
    // Arrange
    Storefront__c sf = new Storefront__c(Name = 'Trailside Deli');
    insert sf;
    Contact c = new Contact(LastName = 'Morgan', Email = 'alex.morgan@example.com');
    insert c;

    AgentReviewActions.Request req = new AgentReviewActions.Request();
    req.verifiedCustomerId = c.Id;
    req.storefrontId = sf.Id;
    req.rating = 5;
    req.reviewComment = 'Great!';

    // Act
    Test.startTest();
    List<AgentReviewActions.Response> respList = AgentReviewActions.invoke(new List<AgentReviewActions.Request>{ req });
    Test.stopTest();

    // Assert
    System.assertEquals(1, respList.size());
    System.assertEquals(1, respList[0].reviews.size());
    System.assertEquals(sf.Id, respList[0].reviews[0].storefrontId);
    System.assertEquals(c.Id, respList[0].reviews[0].customerId);
    System.assertNotEquals(null, respList[0].reviewsJson);
  }
}