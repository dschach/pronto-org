@IsTest
private class MenuDescriptionPromptGroundingTest {
  @TestSetup
  static void setup() {
    Account acc = TestDataFactory.createAccount('Acme', true);
    Storefront__c sf = TestDataFactory.createStorefront(acc.Id, 'Trailside', true);
    Menu__c menu = TestDataFactory.createMenu(sf.Id, 'Lunch', true, true);
    Menu_Category__c cat = TestDataFactory.createMenuCategory('Mains', true);
    insert new List<Menu_Item__c>{
      new Menu_Item__c(
        Menu__c = menu.Id,
        Name = 'Burger',
        Price__c = 12.99,
        Description__c = 'Juicy',
        Available__c = true,
        Menu_Category__c = cat.Id
      ),
      new Menu_Item__c(
        Menu__c = menu.Id,
        Name = 'Salad',
        Price__c = 9.99,
        Available__c = true,
        Menu_Category__c = cat.Id
      )
    };
  }

  @IsTest
  static void shouldThrow_WhenRequestsEmpty() {
    Test.startTest();
    try {
      MenuDescriptionPromptGrounding.getMenuData(new List<MenuDescriptionPromptGrounding.Request>());
      Assert.fail('Expected IllegalArgumentException to be thrown');
    } catch (IllegalArgumentException e) {
      Assert.isTrue(e.getMessage().contains('At least one request'));
    }
    Test.stopTest();
  }

  @IsTest
  static void shouldBuildPrompt_WithMenuDetails() {
    Menu__c menu = [SELECT Id FROM Menu__c LIMIT 1];
    MenuDescriptionPromptGrounding.Request req = new MenuDescriptionPromptGrounding.Request();
    req.RelatedEntity = menu;

    Test.startTest();
    List<MenuDescriptionPromptGrounding.Response> resp = MenuDescriptionPromptGrounding.getMenuData(
      new List<MenuDescriptionPromptGrounding.Request>{ req }
    );
    Test.stopTest();

    Assert.areEqual(1, resp.size());
    String prompt = resp[0].Prompt;
    Assert.isTrue(prompt.contains('Menu:'));
    Assert.isTrue(prompt.contains('Trailside'));
    Assert.isTrue(prompt.contains('Total Items: 2'));
    Assert.isTrue(prompt.contains('Mains'));
    Assert.isTrue(prompt.contains('Burger'));
    Assert.isTrue(prompt.contains('Price Range:'));
  }

  @IsTest
  static void shouldReportNoItems_WhenMenuIsEmpty() {
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Storefront__c sf = [SELECT Id FROM Storefront__c LIMIT 1];
    Menu__c emptyMenu = TestDataFactory.createMenu(sf.Id, 'Empty', true, true);

    MenuDescriptionPromptGrounding.Request req = new MenuDescriptionPromptGrounding.Request();
    req.RelatedEntity = emptyMenu;
    List<MenuDescriptionPromptGrounding.Response> resp = MenuDescriptionPromptGrounding.getMenuData(
      new List<MenuDescriptionPromptGrounding.Request>{ req }
    );

    Assert.isTrue(resp[0].Prompt.contains('No items on this menu yet'));
  }
}