public with sharing class GetDataFromRTDatagraph {
  /**
   * Utility method to extract session ID from Page.GetSession content
   * @return String The extracted session ID
   */
  private static String getSessionIdFromPage() {
    try {
      String content = Page.GetSession.getContent().toString();
      Integer startIndex = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
      Integer endIndex = content.indexOf('End_Of_Session_Id');

      if (startIndex >= 0 && endIndex > startIndex) {
        return content.substring(startIndex, endIndex);
      } else {
        throw new CalloutException('Session ID markers not found in page content');
      }
    } catch (Exception e) {
      System.debug('Error extracting session ID: ' + e.getMessage());
      throw new CalloutException('Failed to extract session ID: ' + e.getMessage());
    }
  }

  /**
   * Invokes the Real-Time Data Graph API to retrieve data
   * @param dataGraphEntityName The data graph entity name
   * @param lookupKeys The lookup keys for the query
   * @return HttpResponse The response from the API
   */
  public static HttpResponse invokeDataGraphAPI(String dataGraphEntityName, String lookupKeys) {
    try {
      // Get the session ID using the new utility method
      String sessionId = getSessionIdFromPage();

      // Construct the endpoint URL
      String endpoint =
        URL.getOrgDomainUrl().toExternalForm() +
        '/services/data/v64.0/ssot/data-graphs/data/' +
        dataGraphEntityName +
        '?lookupKeys=' +
        lookupKeys;

      // Create HTTP request
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      request.setEndpoint(endpoint);
      request.setMethod('GET');
      request.setHeader('Authorization', 'Bearer ' + sessionId);
      request.setHeader('Content-Type', 'application/json');

      // Make the HTTP callout
      HttpResponse response = http.send(request);

      return response;
    } catch (Exception e) {
      // Log the exception and return null or throw a custom exception
      System.debug('Error invoking Data Graph API: ' + e.getMessage());
      throw new CalloutException('Failed to invoke Data Graph API: ' + e.getMessage());
    }
  }

  /**
   * Alternative method that returns the response body as a string
   * @param dataGraphEntityName The data graph entity name
   * @param lookupKeys The lookup keys for the query
   * @return String The response body as a string
   */
  @AuraEnabled
  public static String getDataGraphData(String dataGraphEntityName, String lookupKeys) {
    HttpResponse response = invokeDataGraphAPI(dataGraphEntityName, lookupKeys);

    if (response != null && response.getStatusCode() == 200) {
      System.debug('Response: ' + response.getBody());
      return response.getBody();
    } else {
      throw new CalloutException(
        'API call failed with status code: ' + (response != null ? String.valueOf(response.getStatusCode()) : 'null')
      );
    }
  }

  /**
   * Parses the Data Graph API response and extracts the JSON blob data
   * @param dataGraphEntityName The data graph entity name
   * @param lookupKeys The lookup keys for the query
   * @return Map<String, Object> The parsed JSON data as a map
   */
  @AuraEnabled
  public static Map<String, Object> parseDataGraphResponse(String dataGraphEntityName, String lookupKeys) {
    try {
      // Get the raw response
      Map<String, Object> parsedData = new Map<String, Object>();

      String responseBody = getDataGraphData(dataGraphEntityName, lookupKeys);

      // Parse the outer JSON response
      Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

      // Extract the data array
      List<Object> dataArray = (List<Object>) responseMap.get('data');

      // Get the first item
      if (dataArray != null && dataArray.size() > 0) {
        Map<String, Object> firstItem = (Map<String, Object>) dataArray[0];

        // Extract the json_blob__c field
        String jsonBlob = (String) firstItem.get('json_blob__c');

        if (jsonBlob != null) {
          // Unescape HTML entities using built-in method
          String unescapedJson = jsonBlob.unescapeHtml4();

          // Parse the unescaped JSON
          parsedData = (Map<String, Object>) JSON.deserializeUntyped(unescapedJson);
        }
      }

      return parsedData;
    } catch (Exception e) {
      System.debug('Error parsing Data Graph response: ' + e.getMessage());
      throw new CalloutException('Failed to parse Data Graph response: ' + e.getMessage());
    }
  }
}