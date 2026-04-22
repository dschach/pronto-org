@IsTest
private class AgentUpdateMenuItemActionsTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Main', true);
    Menu__c menu = TestDataFactory.createMenu(sf.Id, 'Lunch', true, true);
    TestDataFactory.createMenuItem(menu.Id, 'Burger', 12.99, true);
  }

  @IsTest
  static void shouldReturnError_WhenAccountIdMissing() {
    AgentUpdateMenuItemActions.Request req = new AgentUpdateMenuItemActions.Request();
    List<AgentUpdateMenuItemActions.Response> resp = AgentUpdateMenuItemActions.invoke(
      new List<AgentUpdateMenuItemActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('accountId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenMenuItemIdMissing() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateMenuItemActions.Request req = new AgentUpdateMenuItemActions.Request();
    req.accountId = acc.Id;
    List<AgentUpdateMenuItemActions.Response> resp = AgentUpdateMenuItemActions.invoke(
      new List<AgentUpdateMenuItemActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('menuItemId is required.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenItemNotFound() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    AgentUpdateMenuItemActions.Request req = new AgentUpdateMenuItemActions.Request();
    req.accountId = acc.Id;
    req.menuItemId = 'a00AB0000000001AAA';
    List<AgentUpdateMenuItemActions.Response> resp = AgentUpdateMenuItemActions.invoke(
      new List<AgentUpdateMenuItemActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('No menu item found with the provided Id.', resp[0].message);
  }

  @IsTest
  static void shouldReturnError_WhenItemBelongsToOtherAccount() {
    Account other = TestDataFactory.createAccount('Other', true);
    Menu_Item__c item = [SELECT Id FROM Menu_Item__c LIMIT 1];
    AgentUpdateMenuItemActions.Request req = new AgentUpdateMenuItemActions.Request();
    req.accountId = other.Id;
    req.menuItemId = item.Id;
    List<AgentUpdateMenuItemActions.Response> resp = AgentUpdateMenuItemActions.invoke(
      new List<AgentUpdateMenuItemActions.Request>{ req }
    );
    Assert.areEqual(false, resp[0].success);
    Assert.areEqual('Access denied. This menu item does not belong to the specified account.', resp[0].message);
  }

  @IsTest
  static void shouldReturnNoUpdates_WhenNoFieldsProvided() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu_Item__c item = [SELECT Id FROM Menu_Item__c LIMIT 1];
    AgentUpdateMenuItemActions.Request req = new AgentUpdateMenuItemActions.Request();
    req.accountId = acc.Id;
    req.menuItemId = item.Id;
    List<AgentUpdateMenuItemActions.Response> resp = AgentUpdateMenuItemActions.invoke(
      new List<AgentUpdateMenuItemActions.Request>{ req }
    );
    Assert.areEqual(true, resp[0].success);
    Assert.areEqual('No fields provided to update.', resp[0].message);
  }

  @IsTest
  static void shouldUpdateDescriptiveFields() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Menu_Item__c item = [SELECT Id FROM Menu_Item__c LIMIT 1];
    AgentUpdateMenuItemActions.Request req = new AgentUpdateMenuItemActions.Request();
    req.accountId = acc.Id;
    req.menuItemId = item.Id;
    req.description = 'Updated desc';
    req.available = false;
    req.calories = 650;
    req.imageUrl = 'https://example.com/burger.jpg';

    Test.startTest();
    List<AgentUpdateMenuItemActions.Response> resp = AgentUpdateMenuItemActions.invoke(
      new List<AgentUpdateMenuItemActions.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(true, resp[0].success);
    Menu_Item__c updated = [
      SELECT Description__c, Available__c, Calories__c, Image_URL__c
      FROM Menu_Item__c
      WHERE Id = :item.Id
    ];
    Assert.areEqual('Updated desc', updated.Description__c);
    Assert.areEqual(false, updated.Available__c);
    Assert.areEqual(650, updated.Calories__c);
    Assert.areEqual('https://example.com/burger.jpg', updated.Image_URL__c);
  }
}