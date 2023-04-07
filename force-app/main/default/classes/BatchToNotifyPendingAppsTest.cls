@isTest
public class BatchToNotifyPendingAppsTest {
     public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
       
         Account acc = TestDataFactory.createAccount(true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); 
         EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
         EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,bretype.id, true);
         EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
       
        system.runAs(u){
          EMS_LM_Leave_History__c request = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(-1), system.today().adddays(0), annualtype.id, false,null);
           request.EMS_LM_Approver__c = userinfo.getUserId();
           request.Approver_3__c = userinfo.getUserId();
           request.EMS_LM_2nd_Approver__c = userinfo.getUserId();
            TriggerBase.bypass('EMS_LM_Leave_History__c');
            insert request;
          EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), bretype.id, true,null);
          EMS_LM_Leave_History__c request3 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, true,null);
          TriggerBase.clearBypass('EMS_LM_Leave_History__c');
        }
         Test.startTest();
             BatchToNotifyPendingApps batchExecute = new BatchToNotifyPendingApps(); 
             Database.executeBatch(batchExecute,10);
         Test.stopTest();
    }    
    
    public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToNotifyPendingApps_sch testsche = new BatchToNotifyPendingApps_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToNotifyPendingApps_sch Check', sch, testsche );
		Test.stopTest();
	}

}