@isTest
public class BatchToCreatePostOnboardingTasks_Test {
    
      public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToCreatePostOnboardingTasks_SCH testsche = new BatchToCreatePostOnboardingTasks_SCH();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
    
        public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            
         Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
         Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
         EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);   
       
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         con.EMS_EM_JD__c = system.today();
         insert con;
      
         Test.startTest();
             BatchToCreatePostOnboardingTasks batchExecute = new BatchToCreatePostOnboardingTasks(); 
             Database.executeBatch(batchExecute,10);
         Test.stopTest();
    }

}