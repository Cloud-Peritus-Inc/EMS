@isTest
public class BatchToCreateOnboardingTasksOnDOJ_Test {
      public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToCreateOnboardingTasksOnDOJ_SCH testsche = new BatchToCreateOnboardingTasksOnDOJ_SCH();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
    
        public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
       
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         con.EMS_EM_JD__c = system.today().adddays(-1);
         con.RecordTypeId = ContactConstant.APPLICANT_RECORDTYPEID;
         insert con;
      
         Test.startTest();
             BatchToCreateOnboardingTasksOnDOJ batchExecute = new BatchToCreateOnboardingTasksOnDOJ(); 
             Database.executeBatch(batchExecute,10);
         Test.stopTest();
    }
    
         public static testMethod void testscheduleclass1() {
		Test.StartTest();
		BatchToCreateOnboardingTasksOnDOJ_SCH testsche = new BatchToCreateOnboardingTasksOnDOJ_SCH();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
}