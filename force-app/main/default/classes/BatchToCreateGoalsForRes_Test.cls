@isTest
public class BatchToCreateGoalsForRes_Test {
    public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToCreateGoalsForRes_Sch testsche = new BatchToCreateGoalsForRes_Sch();
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
         con.EMS_RM_ApplicantStatus_Update__c = 'Active';
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); 
       Grid_Configuration__c gc = Testdatafactory.createGridConfig('namevalue','test description','Org Level Goal',null,true);
       
        
         Test.startTest();
             BatchToCreateGoalsForRes batchExecute = new BatchToCreateGoalsForRes(); 
             Database.executeBatch(batchExecute,1);
         Test.stopTest();
    } 
    
            public static testMethod void testBatchclass2() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         con.EMS_RM_ApplicantStatus_Update__c = 'Active';
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); 
            
         List<Grid_Configuration__c> gCon = new List<Grid_Configuration__c>();
        gCon.add(Testdatafactory.createGridConfig('namevalue Role Resource','test descrsdsiption','Resource Role Level Goal',role.id,false));
        insert gCon;
        
         Test.startTest();
             BatchToCreateGoalsForRes batchExecute = new BatchToCreateGoalsForRes(); 
             Database.executeBatch(batchExecute,1);
         Test.stopTest();
    } 
}