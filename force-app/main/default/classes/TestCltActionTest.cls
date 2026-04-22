@IsTest
private class TestCltActionTest {
  @IsTest
  static void shouldEchoComment_WhenProvided() {
    TestCltAction.TestFeedbackValue fb = new TestCltAction.TestFeedbackValue();
    fb.comment = 'Great work';
    TestCltAction.Request req = new TestCltAction.Request();
    req.feedback = fb;

    Test.startTest();
    List<TestCltAction.Response> resp = TestCltAction.run(new List<TestCltAction.Request>{ req });
    Test.stopTest();

    Assert.areEqual(1, resp.size());
    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('Received: Great work', resp[0].message);
  }

  @IsTest
  static void shouldFallbackToEmpty_WhenFeedbackMissing() {
    TestCltAction.Request req = new TestCltAction.Request();
    List<TestCltAction.Response> resp = TestCltAction.run(new List<TestCltAction.Request>{ req });

    Assert.areEqual(1, resp.size());
    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('Received: (empty)', resp[0].message);
  }

  @IsTest
  static void menuUploadTypes_dtosAreInstantiable() {
    MenuUploadTypes.UploadedFile f = new MenuUploadTypes.UploadedFile();
    f.documentId = '069000000000000';
    f.name = 'test.pdf';
    f.size = 1024;
    f.mimeType = 'application/pdf';
    MenuUploadTypes.MenuUploadValue v = new MenuUploadTypes.MenuUploadValue();
    v.storefrontId = null;
    v.files = new List<MenuUploadTypes.UploadedFile>{ f };
    Assert.areEqual(1, v.files.size());
    Assert.areEqual('test.pdf', v.files[0].name);
  }

  @IsTest
  static void shouldHandleMultipleRequests() {
    TestCltAction.TestFeedbackValue fb1 = new TestCltAction.TestFeedbackValue();
    fb1.comment = 'A';
    TestCltAction.TestFeedbackValue fb2 = new TestCltAction.TestFeedbackValue();
    fb2.comment = 'B';
    TestCltAction.Request r1 = new TestCltAction.Request();
    r1.feedback = fb1;
    TestCltAction.Request r2 = new TestCltAction.Request();
    r2.feedback = fb2;

    List<TestCltAction.Response> resp = TestCltAction.run(new List<TestCltAction.Request>{ r1, r2 });

    Assert.areEqual(2, resp.size());
    Assert.areEqual('Received: A', resp[0].message);
    Assert.areEqual('Received: B', resp[1].message);
  }
}