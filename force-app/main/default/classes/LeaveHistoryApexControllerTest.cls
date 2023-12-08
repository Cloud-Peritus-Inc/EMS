@IsTest
public class LeaveHistoryApexControllerTest {
    @testSetup static void setup()  {
        user adminuser = TestDataFactory.createAdminUser(true);
        system.debug('adminuser====================='+adminuser);
        Resource_Role__c techLead;
        Resource_Role__c role1;
        Resource_Role__c role;
        Account acc;
        Contact con;
        Contact conRRR;
        Contact leadcontact;
        EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c compofftype;
        Resource_Resource_Relationship__c rrr;
        system.runAs(adminuser){
            role = TestDataFactory.createResourceRole(true);
            //Contact con;
           
            techLead = TestDataFactory.createResourceRole('Software Engineer',true);
            role1 = TestDataFactory.createResourceRole('tech Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
             loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
             compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
             EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
              EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            
            Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
            
           

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
            try{
                            leaduser = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true); //pm
                             
            }catch(exception e){
                system.debug('error==='+e);
            }
        }
    }   
    
    static testMethod void userLevelOfApprovalTest() {
        User resourceUser = [SELECT Id,ContactId FROM User where isactive=True LIMIT 1];
        system.debug('resourceUser========----------='+resourceUser);
        //User leaduser1;
        
        //leaduser1 = Testdatafactory.createCommunityUser2WithAccAndContact(acc.id,conRRR.Id,true);
        system.runAs(resourceUser){
        Contact con = [SELECT Id, 
                           Resource_Role__c, 
                           Resource_Role__r.Level_of_Approval__c, 
                           Resource_Role__r.Auto_Approve__c, 
                           Override_the_standard_level_of_approval__c,
                           Level_of_Approval__c,
                           EMS_TM_User__c 
                           FROM Contact 
                   WHERE EMS_TM_User__c =: resourceUser.Id limit 1];   
            EMS_LM_Leave__c annualtype=TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype=TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c compofftype=TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
            EMS_LM_Leave_Credit__c lcreditAnnual1 = Testdatafactory.createLeaveCredit(con.id,system.today(),10,loptype.id, false);
            // EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,bretype.id, true);
            EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, false);
            //EMS_LM_Leave_Credit__c patAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true); 
            
            LeaveHistoryApexController.IntBolleanWrapper result = LeaveHistoryApexController.userLevelOfApproval();
            system.debug('-------Intbooleanwrapper-----'+result);
            Test.startTest();
            LeaveHistoryApexController.getLeaveTypesForUser(resourceUser.id);
            Test.stopTest();
            /*System.assertEquals(1, result.levelOfApproval);
            system.assertEquals(con.Level_of_Approval__c, result.levelOfApproval);
            System.assertEquals(True, result.autoApproval);
            System.assertEquals(null, result.overridelevelOfApproval);
            System.assertEquals(false, result.overRideCheck); */
            
        }
        
    } 
    static TestMethod void getLeaveTypesForUserTest(){
        User resourceUser = [SELECT Id,ContactId FROM User WHERE isActive=True limit 1];
         system.debug('84');
        
        
        user adminuser = TestDataFactory.createAdminUser(true);
        system.runAs(resourceUser){
            LeaveHistoryApexController.getLeaveTypesForUser(resourceUser.Id);
            LeaveHistoryApexController.getLeaveTypesForUser(adminuser.Id);
        }
    }
    
    static TestMethod void getLoggedInUserResReportsSizeTest(){
        User LeadUser = [SELECT Id,ContactId FROM User where isactive=True limit 1];
        System.runAs(LeadUser){
            LeaveHistoryApexController.userAccessWrapper result = LeaveHistoryApexController.getLoggedInUserResReportsSize();
           // System.assertEquals(1, result.relationAcess);
            System.assertEquals(null, result.hraccess);
        }
    }
}
