@isTest
public class BatchToUpdateUserAccessTest {
    
       public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
       
       
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); 
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