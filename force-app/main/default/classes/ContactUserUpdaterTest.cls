@isTest
public class ContactUserUpdaterTest {
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
            usLocation = TestDataFactory.createOfficeLocation('United States of America',true);
            
            acc = TestDataFactory.createAccount(true);
            con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_RM_ApplicantStatus_Update__c = 'Active';
            con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            con.EMS_EM_JD__c = system.today() - 180;
            insert con;
            User u;
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
    }
    
    
    @isTest
    static void testUpdateUsersAsync() {
        
        //set EMS_RM_ApplicantStatus_Update__c to 'Inactive'
        Contact testContact = [SELECT Id,EMS_TM_User__c FROM Contact WHERE EMS_RM_ApplicantStatus_Update__c = 'Active' LIMIT 1];
        testContact.EMS_RM_ApplicantStatus_Update__c = 'Inactive';
        update testContact;
        
         Test.startTest();
        // Call the updateUsersAsync method
        ContactUserUpdater.updateUsersAsync(new Set<Id>{testContact.Id});
        Test.stopTest();
        
        // Query User records and assert that their IsActive fields are updated correctly
        User updatedUser = [SELECT IsActive FROM User WHERE Id = :testContact.EMS_TM_User__c];
        System.assertEquals(false, updatedUser.IsActive);
    }
    
    @isTest
    static void testUpdateProjectAssigne() {
        //set EMS_RM_ApplicantStatus_Update__c to 'Inactive'
        Contact testContact = [SELECT Id,EMS_TM_User__c FROM Contact WHERE EMS_RM_ApplicantStatus_Update__c = 'Active' LIMIT 1];
        
        //get projectAssignee
        List<EMS_TM_Assignment__c> projAssigneeList = TestDataFactory.createProjectAssignee(testContact.Id);
        
        testContact.EMS_RM_ApplicantStatus_Update__c = 'Inactive';
        update testContact;
        Set<Id> updatedConIdSet = new Set<Id>{testContact.Id};
        
        Test.startTest();
        // Call the updateUsersAsync method
        ContactUserUpdater.UpdateRelatedProjectAssignment(updatedConIdSet);
        Test.stopTest();
        
    }
}