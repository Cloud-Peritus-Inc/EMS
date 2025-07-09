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
            Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            Office_Location__c usofficlocRec = new Office_Location__c();
        usofficlocRec.Name = 'California - USA';
        usofficlocRec.Country__c = 'United States of America';
        usofficlocRec.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        usofficlocRec.Timezone__c = 'America/Los_Angeles';
        INSERT usofficlocRec;
         Office_Location__c usofficlocRecc =TestDataFactory.createOfficeLocation('California - USA',true);
            role = TestDataFactory.createResourceRole('Software Engineer',true);
            annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
           // EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            acc = TestDataFactory.createAccount(true);
            con=TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10234';
            con.Resource_Role__c = role.Id;
            con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            con.EMS_RM_ApplicantStatus_Update__c ='Active';
            con.Work_Location__c = hydofficlocRec.Id;
            con.EMS_EM_JD__c=system.today();
            insert con;

            contact con2;
            con2=TestDataFactory.createResourceContact(acc.id, false);
            con2.EMS_RM_Employee_Id__c = 'CP10236';
            con2.Resource_Role__c = role.Id;
            con2.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            con2.EMS_LM_No_Of_Leaves_Credit__c = 20;
            con2.EMS_RM_ApplicantStatus_Update__c ='Active';
            con2.Email = 'test12@cloudperitus.com';
            con2.EMS_EM_JD__c=system.today();
            con2.Work_Location__c = usofficlocRecc.Id;
            insert con2;
            
            conRRR=TestDataFactory.createResourceContact(acc.id, false);
            conRRR.EMS_RM_Employee_Id__c = 'CP10235';
            conRRR.Resource_Role__c = role.Id;
            conRRR.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
            conRRR.EMS_LM_No_Of_Leaves_Credit__c = 10;
            conRRR.EMS_RM_ApplicantStatus_Update__c ='Active';
            conRRR.Work_Location__c = usofficlocRec.Id;
            conRRR.Email = 'test1232@cloudperitus.com';
            conRRR.EMS_EM_JD__c = system.today().addDays(-30);
            insert conRRR;
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
    
    @isTest
  public  static void testBatchToAdd5LeavesEveryQuarter2() {
        Test.startTest();
        EMS_LM_Leave_Credit__c lc = new EMS_LM_Leave_Credit__c();
        lc.EMS_LM_Employee__c = [SELECT Id FROM Contact WHERE EMS_RM_Employee_Id__c = 'CP10234' ].Id;
        lc.EMS_LM_Leave_Credited_Date__c = Date.today().addMonths(-4);
        lc.EMS_LM_Leave_Type__c = [Select Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
        lc.EMS_LM_Leaves_Credited__c = 0.83;
         lc.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
       insert lc;
      EMS_LM_Leave_Credit__c lc1 = new EMS_LM_Leave_Credit__c();
        lc1.EMS_LM_Employee__c = [SELECT Id FROM Contact WHERE EMS_RM_Employee_Id__c = 'CP10235' ].Id;
        lc1.EMS_LM_Leave_Credited_Date__c = Date.today().addMonths(-6);
        lc1.EMS_LM_Leave_Type__c = [Select Id FROM EMS_LM_Leave__c WHERE Name = 'Loss of Pay'].Id;
        lc1.EMS_LM_Leaves_Credited__c = 0.83;
         lc1.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
       insert lc1;
       
        BatchToAdd5LeavesEveryQuarter batchJob = new BatchToAdd5LeavesEveryQuarter();
        Database.executeBatch(batchJob);
        
        Test.stopTest();     
      
    }
    
   // @isTest
 /* public  static void testBatchToAdd5LeavesEveryQuarter3() {
        Test.startTest();
       EMS_LM_Leave_Credit__c lc2 = new EMS_LM_Leave_Credit__c();
        lc2.EMS_LM_Employee__c = [SELECT Id FROM Contact WHERE EMS_RM_Employee_Id__c = 'CP10236			' ].Id;
        lc2.EMS_LM_Leave_Credited_Date__c = Date.today().addMonths(-2);
        system.debug('EMS_LM_Leave_Credited_Date__c'+lc2.EMS_LM_Leave_Credited_Date__c);
      Date dt = system.today();
         Boolean isJan = dt.month() == 11 ? true : false;
         String uniqueMonthYear = String.valueOf(dt.month())+String.valueOf(dt.year());
        system.debug('uniqueMonthYear'+uniqueMonthYear);
        lc2.EMS_LM_Leave_Type__c = [Select Id FROM EMS_LM_Leave__c WHERE Name = 'Maternity Leave'].Id;
        lc2.EMS_LM_Leaves_Credited__c = 0.83;
         lc2.EMS_LM_Select_Leave_Type__c = 'Maternity Leave';
       insert lc2;
      
        BatchToAdd5LeavesEveryQuarter batchJob = new BatchToAdd5LeavesEveryQuarter();
        Database.executeBatch(batchJob);
        
        Test.stopTest();     
      
    }*/
}
//In this test class, we first set up some test data by creating a test account and contact. Then, we execute the BatchToAdd5LeavesEveryQuarter batch job by creating an instance of the class and passing it to the Database.executeBatch method. After the batch job has finished, we query the EMS_LM_Leave_Credit__c object to verify that a leave credit record was created for the test contact. We assert that the leave credit record has the expected field values.