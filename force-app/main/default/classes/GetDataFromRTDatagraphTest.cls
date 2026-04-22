@IsTest
private class GetDataFromRTDatagraphTest {
  private class DatagraphMock implements HttpCalloutMock {
    private final Integer statusCode;
    private final String body;

    DatagraphMock(Integer statusCode, String body) {
      this.statusCode = statusCode;
      this.body = body;
    }

    public HttpResponse respond(HttpRequest req) {
      HttpResponse resp = new HttpResponse();
      resp.setStatusCode(statusCode);
      resp.setBody(body);
      return resp;
    }
  }

  @IsTest
  static void invokeDataGraphAPI_throws_WhenSessionMarkersMissing() {
    Test.setMock(HttpCalloutMock.class, new DatagraphMock(200, '{"data":[]}'));

    Test.startTest();
    try {
      GetDataFromRTDatagraph.invokeDataGraphAPI('Pronto__dlm', 'email=test@example.com');
      Assert.fail('Expected CalloutException because session markers are missing');
    } catch (CalloutException e) {
      Assert.isTrue(e.getMessage().contains('Failed'), 'Error should mention failure');
    }
    Test.stopTest();
  }

  @IsTest
  static void getDataGraphData_throws_WhenSessionMarkersMissing() {
    Test.setMock(HttpCalloutMock.class, new DatagraphMock(200, '{"data":[]}'));

    Test.startTest();
    try {
      GetDataFromRTDatagraph.getDataGraphData('Pronto__dlm', 'email=test@example.com');
      Assert.fail('Expected CalloutException');
    } catch (CalloutException e) {
      Assert.isNotNull(e.getMessage());
    }
    Test.stopTest();
  }

  @IsTest
  static void parseDataGraphResponse_throws_WhenSessionMarkersMissing() {
    Test.setMock(HttpCalloutMock.class, new DatagraphMock(200, '{"data":[{"json_blob__c":"{\\"foo\\":\\"bar\\"}"}]}'));

    Test.startTest();
    try {
      GetDataFromRTDatagraph.parseDataGraphResponse('Pronto__dlm', 'email=test@example.com');
      Assert.fail('Expected CalloutException');
    } catch (CalloutException e) {
      Assert.isNotNull(e.getMessage());
    }
    Test.stopTest();
  }
}