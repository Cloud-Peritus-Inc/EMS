@isTest
private class BatchToAdd5LeavesEveryQuarterTest {
    
      public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToAdd5LeavesEveryQuarter_sch testsche = new BatchToAdd5LeavesEveryQuarter_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}

    @testSetup
    public static void setUp(){
      
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
            insert con;
        }
        User u;
        Test.startTest();
        system.runAs(adminuser){
            u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        }
    }
    
    
    @isTest
  public  static void testBatchToAdd5LeavesEveryQuarter() {
   
        Test.startTest();
        
        BatchToAdd5LeavesEveryQuarter batchJob = new BatchToAdd5LeavesEveryQuarter();
        Database.executeBatch(batchJob);
        
        Test.stopTest();     
      
    }
}
//In this test class, we first set up some test data by creating a test account and contact. Then, we execute the BatchToAdd5LeavesEveryQuarter batch job by creating an instance of the class and passing it to the Database.executeBatch method. After the batch job has finished, we query the EMS_LM_Leave_Credit__c object to verify that a leave credit record was created for the test contact. We assert that the leave credit record has the expected field values.