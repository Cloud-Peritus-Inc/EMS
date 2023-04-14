@isTest
public class BatchToUpdateUserAccessTest {
    
       public static testMethod void testBatchclass() {
          
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
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            system.debug('----Contact insert----'+con);
            insert con;
        }
        User u;
      
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
           system.runAs(u){
         PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'HR_Admin'];
         insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
           }
      
         Test.startTest();
             BatchToUpdateUserAccess batchExecute = new BatchToUpdateUserAccess(); 
             Database.executeBatch(batchExecute);
         Test.stopTest();
    }    
    
    public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToUpdateUserAccess_sch testsche = new BatchToUpdateUserAccess_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}

}