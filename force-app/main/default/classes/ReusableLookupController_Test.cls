/**
* @author Shubham Maske 
* @date 29/02/2024
* @description  Test class for ReusableLookupController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 29/02/2024    Shubham Maske           Initial Version
* ====================================================================================================
**/
@isTest
public class ReusableLookupController_Test {
    
    @testSetup
    static void setupTestData() {
        
        user adminuser = TestDataFactory.createAdminUser(true); 
        Resource_Role__c role;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
        EMS_LM_Leave__c  Bereavementtype;
        EMS_LM_Leave__c paidTimeOff;
        Office_Location__c hydIndia;
        Office_Location__c usLocation;
        
        Resource_Role__c techLead;
        Resource_Resource_Relationship__c rrr;
        List<Resource_Role__c> resourceRoleList = new List<Resource_Role__c>();
        List<Contact> contactList = new List<Contact>();
        List<User> userList = new List<User>();
        
        Account acc;Contact con;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole(true);
            
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
            paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            
            
            hydIndia = TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            usLocation = TestDataFactory.createOfficeLocation('California - USA',true);
            List<Office_Location__c> OfficeLocationList = new List<Office_Location__c>();
            OfficeLocationList.add(hydIndia);
            OfficeLocationList.add(usLocation);
            acc = TestDataFactory.createAccount(true);
            
            resourceRoleList.add(techLead = TestDataFactory.createResourceRole('Software Engineer',false));
            insert resourceRoleList;
            
            
            for(Integer i=0; i<2; i++){
                con =TestDataFactory.createResourceContact(acc.id, false);
                con.EMS_RM_Employee_Id__c = 'CP1035'+i;
                con.Resource_Role__c = resourceRoleList[0].Id;
                con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
                con.EMS_RM_ApplicantStatus_Update__c = 'Active';
                con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
                con.EMS_EM_JD__c = system.today() - 180;
                con.Work_Location__c = OfficeLocationList[i].Id;
                contactList.add(con);              
            }
            insert contactList;
            
            for(Contact cont : contactList){
                User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,cont.Id,false);
                u.Username = u.Username + cont.Id;
                u.ContactId = cont.Id;
                userList.add(u);
            }
            Insert userList;
            
            for(Integer i=0; i<2; i++){
                contactList[i].EMS_TM_User__c = userList[i].Id;
            }
            update contactList;
            System.debug('Updated Contact List ' + contactList);
            
            rrr = TestDataFactory.createRRR(contactList[0].Id, true, contactList[1].Id);
            
            Fiscal_Year__c FiscalYear = TestDataFactory.createFiscalYear(true);
            
            Fulfillment__c Ful = TestDataFactory.createFulfillment(contactList[0].Id, true);
            Fulfillment__c Ful2 = TestDataFactory.createFulfillment(contactList[1].Id, true);
        }
    }
    
    testmethod static void  testFetchRecords(){
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10350'];
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();
        inputWrapper.objectApiName = 'Contact';
        inputWrapper.fieldApiName = 'Name';
        inputWrapper.otherFieldApiName = 'EMS_RM_ApplicantStatus_Update__c';
        inputWrapper.otherFieldApiName2 = 'EMS_TM_User__r.IsActive'; // Assuming this is a checkbox field
        inputWrapper.searchString = 'Test';
        inputWrapper.selectedRecordId = MentorCon.Id;
        inputWrapper.parentRecordId = null;
        inputWrapper.parentFieldApiName = null;
        Test.startTest();
        List<ReusableLookupController.ResultWrapper> result = ReusableLookupController.fetchRecords(inputWrapper);
        Test.stopTest();
    }
    
    testmethod static void  testFetchRecords2(){
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,AccountId From Contact WHERE EMS_RM_Employee_Id__c = 'CP10350'];
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();
        inputWrapper.objectApiName = 'Contact';
        inputWrapper.fieldApiName = 'Name';
        inputWrapper.otherFieldApiName = 'EMS_RM_ApplicantStatus_Update__c';
        inputWrapper.otherFieldApiName2 = 'EMS_TM_User__r.IsActive'; // Assuming this is a checkbox field
        inputWrapper.searchString = 'Test';
        inputWrapper.selectedRecordId = Null;
        inputWrapper.parentRecordId = MentorCon.AccountId;
        inputWrapper.parentFieldApiName = 'Account';
        Test.startTest();
        try{
            List<ReusableLookupController.ResultWrapper> result = ReusableLookupController.fetchRecords(inputWrapper);
        }catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        Test.stopTest();
    }
    
    testmethod static void  testFetchRecords3(){
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,AccountId,EMS_TM_User__r.IsActive From Contact WHERE EMS_RM_Employee_Id__c = 'CP10350'];
        MentorCon.EMS_RM_ApplicantStatus_Update__c = 'Inactive' ;
        update MentorCon;
        
        Contact MenteeCon = [Select Id,Name,EMS_RM_Employee_Id__c,AccountId,EMS_TM_User__r.IsActive From Contact WHERE EMS_RM_Employee_Id__c = 'CP10351'];
        MenteeCon.EMS_RM_ApplicantStatus_Update__c = 'Inactive' ;
        update MenteeCon;
        
        ReusableLookupController.SearchWrapper inputWrapper = new ReusableLookupController.SearchWrapper();
        inputWrapper.objectApiName = 'Contact';
        inputWrapper.fieldApiName = 'Name';
        inputWrapper.otherFieldApiName = 'EMS_RM_ApplicantStatus_Update__c';
        inputWrapper.otherFieldApiName2 = 'EMS_TM_User__r.IsActive'; // Assuming this is a checkbox field
        inputWrapper.searchString = 'Test';
        inputWrapper.selectedRecordId = Null;
        inputWrapper.parentRecordId = Null;
        inputWrapper.parentFieldApiName = 'Account';
        Test.startTest();
        try{
            List<ReusableLookupController.ResultWrapper> result = ReusableLookupController.fetchRecords(inputWrapper);
            System.debug('result: ' + result);
        }catch (Exception ex) {
            String errorMsg = ex.getMessage();
            System.debug('An exception occurred: ' + errorMsg);
        }
        Test.stopTest();
    }
    
    testmethod static void  fetcgLoggedinContactTest(){
        Contact MentorCon = [Select Id,Name,EMS_RM_Employee_Id__c,EMS_TM_User__c From Contact WHERE EMS_RM_Employee_Id__c = 'CP10350'];
        User u = [Select Id FROM User WHERE Id =:MentorCon.EMS_TM_User__c LIMIT 1];
        System.debug('MentorCon 158 :' + MentorCon);
        System.debug('User 159:' + u);
        Test.startTest();
        system.runAs(u){
            Contact returnedContact = ReusableLookupController.fetcgLoggedinContact();
        }
        Test.stopTest();
    }
    
}