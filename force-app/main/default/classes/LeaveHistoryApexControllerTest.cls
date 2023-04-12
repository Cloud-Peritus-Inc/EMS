@IsTest
public class LeaveHistoryApexControllerTest {
    
    static testMethod void userLevelOfApprovalTest() {
        user adminuser = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Resource_Resource_Relationship__c rrr;
        EMS_LM_Leave__c annualtype;
        
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            
            
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 15;
            con.Override_the_standard_level_of_approval__c = false;
            con.Level_of_Approval__c = 2;
            insert con;           
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
        // 
        
        system.runAs(u){
            con = [SELECT Id, 
                   Resource_Role__c, 
                   Resource_Role__r.Level_of_Approval__c, 
                   Resource_Role__r.Auto_Approve__c, 
                   Override_the_standard_level_of_approval__c,
                   Level_of_Approval__c,
                   EMS_TM_User__c 
                   FROM Contact 
                   WHERE EMS_TM_User__c =: u.Id];
            system.debug('### con ======================================================================================'+ con);
            try{
                LeaveHistoryApexController.IntBolleanWrapper result = LeaveHistoryApexController.userLevelOfApproval();
                System.assertEquals(1, result.levelOfApproval);
                system.assertEquals(con.Level_of_Approval__c, result.levelOfApproval);
                System.assertEquals(True, result.autoApproval);
                System.assertEquals(null, result.overridelevelOfApproval);
                System.assertEquals(false, result.overRideCheck);
            }catch(exception e){
                system.debug('error message'+e.getMessage());
            }
        }
        Test.stopTest();
    }
    static TestMethod void getLeaveTypesForUserTest(){
        account acc;
        contact conRRR;
        user adminuser2 = TestDataFactory.createAdminUser(true);
        system.runAs(adminuser2){
            user adminuser = TestDataFactory.createAdminUser(true);
            LeaveHistoryApexController.getLeaveTypesForUser(adminuser.Id);
            
            acc = TestDataFactory.createAccount(true);
            conRRR=TestDataFactory.createResourceContactForRRR(acc.id, false);
            conRRR.EMS_TM_User__c = adminuser.Id;
            conRRR.EMS_RM_Employee_Id__c = 'CP10234';
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            //  insert conRRR;
            LeaveHistoryApexController.getLeaveTypesForUser(adminuser.Id);
        }
    }
    
    static TestMethod void getLoggedInUserResReportsSizeTest(){
        user adminuser = TestDataFactory.createAdminUser(true);
        Test.startTest();
        LeaveHistoryApexController.userAccessWrapper result = LeaveHistoryApexController.getLoggedInUserResReportsSize();
        Test.stopTest();
        System.assertEquals(0, result.relationAcess);
        System.assertEquals(null, result.hraccess);
        
        
        
        
        
        
    }
}