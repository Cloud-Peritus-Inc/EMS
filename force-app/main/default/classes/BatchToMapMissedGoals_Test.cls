@isTest
public class BatchToMapMissedGoals_Test {
  public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToMapMissedGoals_sch testsche = new BatchToMapMissedGoals_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
    
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
            
          Goal__c gl = new Goal__c();
          gl.Goal_Name__c = 'TEST GOAL';
          gl.Resource__c = con.Id;
          gl.Start_Date__c = system.today().adddays(-6);
          gl.End_Date__c  = system.today().adddays(-4);
          gl.Description__c = 'TEST TESTETST';
          gl.Status__c = 'Active';
          insert gl;
       
         
         Test.startTest();
             BatchToMapMissedGoals batchExecute = new BatchToMapMissedGoals(); 
             Database.executeBatch(batchExecute,10);
         Test.stopTest();
    } 
}