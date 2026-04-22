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
    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual('No changes provided.', resp[0].message);
    Assert.isNotNull(resp[0].returnedContact, 'Returned contact should be queried even with no changes');
  }

  @IsTest
  static void missingVerifiedCustomerIdReturnsError() {
    AgentUpdateContactRecordActions.Request req = new AgentUpdateContactRecordActions.Request();

    Test.startTest();
    List<AgentUpdateContactRecordActions.Response> resp = AgentUpdateContactRecordActions.invoke(
      new List<AgentUpdateContactRecordActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void nullRequestListReturnsError() {
    Test.startTest();
    List<AgentUpdateContactRecordActions.Response> resp = AgentUpdateContactRecordActions.invoke(null);
    Test.stopTest();

    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('verifiedCustomerId is required.', resp[0].message);
  }

  @IsTest
  static void updatesAllAddressFieldsWhenProvided() {
    Contact c = new Contact(LastName = 'Tester', Email = 'old@example.com');
    insert c;

    AgentUpdateContactRecordActions.Request req = new AgentUpdateContactRecordActions.Request();
    req.verifiedCustomerId = c.Id;
    req.email = 'new@example.com';
    req.phone = '555-9999';
    req.mailingStreet = '1 Updated Way';
    req.mailingCity = 'New Town';
    req.mailingPostalCode = '94000';

    Test.startTest();
    List<AgentUpdateContactRecordActions.Response> resp = AgentUpdateContactRecordActions.invoke(
      new List<AgentUpdateContactRecordActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success, resp[0].message);
    Assert.areEqual('OK', resp[0].message);
    Contact reloaded = [
      SELECT Email, Phone, MailingStreet, MailingCity, MailingPostalCode
      FROM Contact
      WHERE Id = :c.Id
    ];
    Assert.areEqual('new@example.com', reloaded.Email);
    Assert.areEqual('555-9999', reloaded.Phone);
    Assert.areEqual('1 Updated Way', reloaded.MailingStreet);
    Assert.areEqual('New Town', reloaded.MailingCity);
    Assert.areEqual('94000', reloaded.MailingPostalCode);
  }
}