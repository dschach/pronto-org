@IsTest
private class AgentUploadMenuActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    TestDataFactory.createStorefront(acc.Id, 'Main', true);
  }

  @IsTest
  static void shouldReturnEmptyList_WhenRequestsNull() {
    Test.startTest();
    List<AgentUploadMenuActions.Response> resp = AgentUploadMenuActions.execute(null);
    Test.stopTest();
    Assert.areEqual(0, resp.size());
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontIdMissing() {
    AgentUploadMenuActions.Request req = new AgentUploadMenuActions.Request();
    List<AgentUploadMenuActions.Response> resp = AgentUploadMenuActions.execute(
      new List<AgentUploadMenuActions.Request>{ req }
    );
    Assert.areEqual(1, resp.size());
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('A storefrontId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenStorefrontNotFound() {
    AgentUploadMenuActions.Request req = new AgentUploadMenuActions.Request();
    req.storefrontId = '01tAB0000000001AAA';
    List<AgentUploadMenuActions.Response> resp = AgentUploadMenuActions.execute(
      new List<AgentUploadMenuActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Storefront not found or not accessible.', resp[0].message);
  }

  @IsTest
  static void shouldReportNoFiles_WhenNoneExist() {
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    AgentUploadMenuActions.Request req = new AgentUploadMenuActions.Request();
    req.storefrontId = sf.Id;

    Test.startTest();
    List<AgentUploadMenuActions.Response> resp = AgentUploadMenuActions.execute(
      new List<AgentUploadMenuActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.isTrue(resp[0].message.contains('No files found'));
    Assert.areEqual(0, resp[0].files.size());
  }

  @IsTest
  static void shouldReportFiles_WhenLinkedToStorefront() {
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];

    ContentVersion cv = new ContentVersion(
      Title = 'menu.pdf',
      PathOnClient = 'menu.pdf',
      VersionData = Blob.valueOf('test content')
    );
    insert cv;
    Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
    insert new ContentDocumentLink(ContentDocumentId = cdId, LinkedEntityId = sf.Id, ShareType = 'V');

    AgentUploadMenuActions.Request req = new AgentUploadMenuActions.Request();
    req.storefrontId = sf.Id;

    Test.startTest();
    List<AgentUploadMenuActions.Response> resp = AgentUploadMenuActions.execute(
      new List<AgentUploadMenuActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(1, resp[0].files.size());
    Assert.isTrue(resp[0].message.contains('menu file(s)'));
  }

  @IsTest
  static void shouldAcceptDocumentsFromMenuUploadPayload() {
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];

    ContentVersion cv = new ContentVersion(
      Title = 'uploaded.pdf',
      PathOnClient = 'uploaded.pdf',
      VersionData = Blob.valueOf('body')
    );
    insert cv;
    Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;

    MenuUploadTypes.UploadedFile uf = new MenuUploadTypes.UploadedFile();
    uf.documentId = String.valueOf(cdId);
    MenuUploadTypes.MenuUploadValue mv = new MenuUploadTypes.MenuUploadValue();
    mv.files = new List<MenuUploadTypes.UploadedFile>{ uf };

    AgentUploadMenuActions.Request req = new AgentUploadMenuActions.Request();
    req.storefrontId = sf.Id;
    req.menuUpload = mv;

    Test.startTest();
    List<AgentUploadMenuActions.Response> resp = AgentUploadMenuActions.execute(
      new List<AgentUploadMenuActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Assert.areEqual(1, resp[0].files.size());
  }
}