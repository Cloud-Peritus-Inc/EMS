@IsTest
public class LeaveHistoryApexControllerTest {
    @testSetup static void setup()  {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c techLead;
        Resource_Role__c role1;
        Account acc;
        Contact con;
        Contact conRRR;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            
            techLead = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            acc = TestDataFactory.createAccount(true);
            
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = techLead.id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 15;
            con.Override_the_standard_level_of_approval__c = false;
            con.Level_of_Approval__c = 2;
            insert con;
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role1.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            insert conRRR;
            rrr = TestDataFactory.createRRR(con.Id, true, conRRR.Id);
        }
        User contactuser;
        User leaduser;
        User empUser;
        system.runAs(adminuser){
            contactuser = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); //tech
            leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true); //pm
        }
        
    }   
    
    static testMethod void userLevelOfApprovalTest() {
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        contact con1 = [select id,EMS_TM_User__c from contact where EMS_RM_Employee_Id__c ='CP10234'];
        con1.EMS_TM_User__c = resourceUser.Id;
        
        
        system.runAs(resourceUser){
        update con1;
        Contact con = [SELECT Id, 
                           Resource_Role__c, 
                           Resource_Role__r.Level_of_Approval__c, 
                           Resource_Role__r.Auto_Approve__c, 
                           Override_the_standard_level_of_approval__c,
                           Level_of_Approval__c,
                           EMS_TM_User__c 
                           FROM Contact 
                   WHERE EMS_TM_User__c =: resourceUser.Id limit 1];            
            
            LeaveHistoryApexController.IntBolleanWrapper result = LeaveHistoryApexController.userLevelOfApproval();
            system.debug('-------Intbooleanwrapper-----'+result);
            /*System.assertEquals(1, result.levelOfApproval);
            system.assertEquals(con.Level_of_Approval__c, result.levelOfApproval);
            System.assertEquals(True, result.autoApproval);
            System.assertEquals(null, result.overridelevelOfApproval);
            System.assertEquals(false, result.overRideCheck);*/
            
        }
        
    }
    static TestMethod void getLeaveTypesForUserTest(){
        User resourceUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail@testclass.com.they'];
        user adminuser = TestDataFactory.createAdminUser(true);
        system.runAs(resourceUser){
            LeaveHistoryApexController.getLeaveTypesForUser(resourceUser.Id);
            LeaveHistoryApexController.getLeaveTypesForUser(adminuser.Id);
        }
    }
    
    static TestMethod void getLoggedInUserResReportsSizeTest(){
        User LeadUser = [SELECT Id,ContactId FROM User WHERE Email = 'testemail4@testclass.com.they'];
        System.runAs(LeadUser){
            LeaveHistoryApexController.userAccessWrapper result = LeaveHistoryApexController.getLoggedInUserResReportsSize();
           
           // System.assertEquals(1, result.relationAcess);
           // System.assertEquals(null, result.hraccess);
        }
    }
}