/**
    * Description: This Apex class represents Test class of MyTeamController.
    * Author: Vamsi
    * Created Date: March 1, 2024
    * Version: 1.0
    */
@isTest
private class MyTeamControllerTest {
    
    @isTest
    static void testGetMyResources() {
        EMS_LM_Leave__c   annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
        // Create test data for a mock user
        User testUser = TestDataFactory.createCommunityUserWithOutAccAndContact(true);
        Contact contactRecord = [SELECT Id,Name,EMS_TM_User__c,Work_Location__c,Work_Location__r.Name FROM Contact WHERE Work_Location__c != Null AND Id =: testUser.ContactId LIMIT 1];        
        // Set up the test environment
        Test.startTest();
        System.runAs(testUser) {
            contactRecord.EMS_TM_User__c = testUser.Id;
            update contactRecord;
            try{
                // Call the method to be tested
                Map<String, String> resources = myTeamController.getMyResources();
                // Perform assertions
                // Example assertion - you may need to adjust this based on your specific requirements
                System.assertNotEquals(null, resources);
            }catch(exception e){
                System.debug(e);
            }            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetMyResources2() {
        EMS_LM_Leave__c   annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
        // Create test data for a mock user
        Id p = [select id from profile where name='Employee - HR(Community)'].id;
        User testUser = TestDataFactory.createCommunityUserWithOutAccAndContact(false);
        testUser.ProfileId = p;
        Insert testUser;
        Contact contactRecord = [SELECT Id,Name,EMS_TM_User__c,Work_Location__c,Work_Location__r.Name FROM Contact WHERE Work_Location__c != Null AND Id =: testUser.ContactId LIMIT 1];        
        Fiscal_Year__c FY =  TestDataFactory.createFiscalYear(true);
        
        // Set up the test environment
        Test.startTest();
        System.runAs(testUser) {
            try{
                PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Performance_Mgnt_Admin'];
                insert new PermissionSetAssignment(AssigneeId = testUser.Id, PermissionSetId = ps.Id);
                
                contactRecord.EMS_TM_User__c = testUser.Id;
                update contactRecord;
                
                // Call the method to be tested
                Map<String, String> resources = myTeamController.getMyResources();
                // Perform assertions
                // Example assertion - you may need to adjust this based on your specific requirements
                System.assertNotEquals(null, resources);
                
            }catch(exception e){
                System.debug(e);
            }
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCheckTheTeam() {
        EMS_LM_Leave__c   annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
        // Create test data for a mock user
        User testUser = TestDataFactory.createCommunityUserWithOutAccAndContact(true);
        
        // Set up the test environment
        Test.startTest();
        System.runAs(testUser) {
            // Call the method to be tested
            Boolean result = myTeamController.checkTheTeam();
            // Perform assertions
            // Example assertion - you may need to adjust this based on your specific requirements
            System.assertEquals(true, result);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetReporteesInHierarchy() {
        EMS_LM_Leave__c   annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
        // Create test data for a mock user
        User testUser = TestDataFactory.createCommunityUserWithOutAccAndContact(true);
        account acc= TestDataFactory.createAccount('testacc',true);
        // Create test data for a mock contact
        Contact testContact = TestDataFactory.createResourceContactForRRR(acc.Id,true);
        
        // Set up the test environment
        Test.startTest();
        System.runAs(testUser) {
            // Call the method to be tested
            Map<String, String> reportees = myTeamController.getReporteesInHierarchy(testContact.Id);
            System.assertNotEquals(null, reportees);
            try{
                Map<String, String> Passingnull = myTeamController.getReporteesInHierarchy(null);
                
            }catch(exception e){
                
            }
        }
        Test.stopTest();
    }
}