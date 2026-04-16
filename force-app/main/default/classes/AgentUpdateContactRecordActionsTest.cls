@IsTest
private class AgentUpdateContactRecordActionsTest {
  @IsTest
  static void doesNotOverwriteWithBlankValues() {
    Contact c = new Contact(
      LastName = 'Tester',
      Email = 'original@example.com',
      Phone = '555-0100',
      MailingStreet = '123 Main St',
      MailingCity = 'Old City',
      MailingPostalCode = '94105'
    );
    insert c;

    AgentUpdateContactRecordActions.Request req = new AgentUpdateContactRecordActions.Request();
    req.verifiedCustomerId = c.Id;
    req.email = '   '; // blank should be ignored
    req.phone = null; // null should be ignored
    req.mailingCity = 'New City'; // should update

    Test.startTest();
    List<AgentUpdateContactRecordActions.Response> resp = AgentUpdateContactRecordActions.invoke(
      new List<AgentUpdateContactRecordActions.Request>{ req }
    );
    Test.stopTest();

    System.assertEquals(1, resp.size(), 'Expected singleton response');
    System.assertEquals(true, resp[0].success, resp[0].message);

    Contact reloaded = [
      SELECT Email, Phone, MailingCity, MailingStreet, MailingPostalCode
      FROM Contact
      WHERE Id = :c.Id
      LIMIT 1
    ];

    System.assertEquals('original@example.com', reloaded.Email, 'Email should not be overwritten by blank input');
    System.assertEquals('555-0100', reloaded.Phone, 'Phone should not be overwritten by null input');
    System.assertEquals('New City', reloaded.MailingCity, 'City should be updated');
    System.assertEquals('123 Main St', reloaded.MailingStreet, 'Other fields should remain unchanged');
  }

  @IsTest
  static void noChangesProvidedReturnsSuccess() {
    Contact c = new Contact(LastName = 'Tester');
    insert c;

    AgentUpdateContactRecordActions.Request req = new AgentUpdateContactRecordActions.Request();
    req.verifiedCustomerId = c.Id;

    List<AgentUpdateContactRecordActions.Response> resp = AgentUpdateContactRecordActions.invoke(
      new List<AgentUpdateContactRecordActions.Request>{ req }
    );
    System.assertEquals(true, resp[0].success, resp[0].message);
    System.assertEquals('No changes provided.', resp[0].message);
  }
}