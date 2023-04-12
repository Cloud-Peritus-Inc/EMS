@isTest
private class EMS_TM_GenericController_Test {
	@IsTest
	public static void testSearchWithFilterAndFullName() {
    // arrange
    String searchTerm = '';
    String myObject = 'Contact';
    String filter = 'Account.Name LIKE \'%Acme%\'';
    Boolean fullName = true;
    List<Contact> expectedContacts = [SELECT Id, Name, LastName, FirstName FROM Contact WHERE Name LIKE '%%' AND Account.Name LIKE '%Acme%' LIMIT 5];
    
    // act
    List<sObject> actualResult = EMS_TM_GenericController.search(searchTerm, myObject, filter, fullName);
    
    // assert
    System.assertEquals(expectedContacts.size(), actualResult.size(), 'Search result size should be same as expected');
    for(Integer i=0; i<actualResult.size(); i++) {
        Contact expected = expectedContacts[i];
        Contact actual = (Contact) actualResult[i];
        System.assertEquals(expected.Id, actual.Id, 'Contact Id should be same as expected');
        System.assertEquals(expected.Name, actual.Name, 'Contact Name should be same as expected');
        System.assertEquals(expected.LastName, actual.LastName, 'Contact Last Name should be same as expected');
        System.assertEquals(expected.FirstName, actual.FirstName, 'Contact First Name should be same as expected');
    	}
	}

	@IsTest
	public static void testSearchWithFilterAndNoFullName() {
    // arrange
    String searchTerm = 'Kumar';
    String myObject = 'Lead';
    String filter = 'Company LIKE \'%Salesforce%\'';
    Boolean fullName = false;
    List<Lead> expectedLeads = [SELECT Id, Name FROM Lead WHERE Name LIKE '%Kumar%' AND Company LIKE '%Salesforce%' LIMIT 5];
    
    // act
    List<sObject> actualResult = EMS_TM_GenericController.search(searchTerm, myObject, filter, fullName);
    
    // assert
    System.assertEquals(expectedLeads.size(), actualResult.size(), 'Search result size should be same as expected');
    for(Integer i=0; i<actualResult.size(); i++) {
        Lead expected = expectedLeads[i];
        Lead actual = (Lead) actualResult[i];
        System.assertEquals(expected.Id, actual.Id, 'Lead Id should be same as expected');
        System.assertEquals(expected.Name, actual.Name, 'Lead Name should be same as expected');
    	}
	}

	@IsTest
	public static void testSearchWithEmptyFilterAndFullName() {
    // arrange
    String searchTerm = 'SK';
    String myObject = 'Contact';
    String filter = '';
    Boolean fullName = true;
    List<Contact> expectedContacts = [SELECT Id, Name, LastName, FirstName FROM Contact WHERE Name LIKE '%SK%' LIMIT 5];
    
    // act
    List<sObject> actualResult = EMS_TM_GenericController.search(searchTerm, myObject, filter, fullName);
    
    // assert
    System.assertEquals(expectedContacts.size(), actualResult.size(), 'Search result size should be same as expected');
    for(Integer i=0; i<actualResult.size(); i++) {
        Contact expected = expectedContacts[i];
        Contact actual = (Contact) actualResult[i];
        System.assertEquals(expected.Id, actual.Id, 'Contact Id should be same as expected');
        System.assertEquals(expected.Name, actual.Name, 'Contact Name should be same as expected');
        System.assertEquals(expected.LastName, actual.LastName, 'Contact Last Name should be same as expected');
        System.assertEquals(expected.FirstName, actual.FirstName, 'Contact First Name should be same as expected');
    	}
	}
}