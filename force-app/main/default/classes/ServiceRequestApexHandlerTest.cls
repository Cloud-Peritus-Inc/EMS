@isTest
public class ServiceRequestApexHandlerTest {
    
    @testSetup static void setup()  {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c emp;
        Resource_Role__c projectManager;
        Account acc;
        Contact con;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            
            techLead = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            acc = TestDataFactory.createAccount(true);
            
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = techLead.id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;            
            insert con;
        }
        User contactuser;
        system.runAs(adminuser){
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); //tech
        }
    }
    
    static testMethod void testGetPayrollInfo(){
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        System.runAs(resourceUser) {
            PayRoll__c result = TestDataFactory.createPayroll(resourceUser.ContactId, true);
            System.debug('### result' +result);
            ServiceRequestApexHandler.getPayrollInfo();
        } 
    }
    
    static testMethod void testGetLoggedInUserFamilyData(){
		User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        System.runAs(resourceUser) {
            List<Family_Information__c> results = new List<Family_Information__c>();
            results.add(TestDataFactory.createFamilyInfo(resourceUser.ContactId,false, false, true));
            insert results;
            ServiceRequestApexHandler.getLoggedInUserFamilyData();
            System.assertEquals('test member', results[0].Family_Member_Name__c);
            System.assertEquals(false, results[0].Is_It_Emergency_Contact__c);
            System.assertEquals(true, results[0].Is_It_Dependent_Contact__c);
            System.assertEquals('Father', results[0].Relationships__c);
        } 
    }
    
    static testMethod void testGetLoggedInUserContactData(){
		User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        System.runAs(resourceUser) {
            Contact result = ServiceRequestApexHandler.getLoggedInUserContactData();
        } 
    }   
    
}