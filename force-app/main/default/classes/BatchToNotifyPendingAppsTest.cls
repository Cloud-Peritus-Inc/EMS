@isTest
public class BatchToNotifyPendingAppsTest {
     public static testMethod void testBatchclass() {
       
            user adminuser = TestDataFactory.createAdminUser(true);
        
         user adminuser2 = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
       EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        EMS_LM_Leave__c paternitytype;
       EMS_LM_Leave__c  Bereavementtype;
            
        Account acc;Contact con;
        system.runAs(adminuser){
           role = TestDataFactory.createResourceRole(true);
         annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
         loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        //bretype  = TestDataFactory.createLeaveType('Maternity Leave',true);
         compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            paternitytype = TestDataFactory.createLeaveType('Paternity Leave',true);
            Bereavementtype = TestDataFactory.createLeaveType('Bereavement Leave',true);
          acc = TestDataFactory.createAccount(true);
		 con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         con.EMS_RM_ApplicantStatus_Update__c = 'Active';
         con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            con.EMS_EM_JD__c = system.today() - 180;
         insert con;
        }
      
         User u;
         system.runAs(adminuser){
        
         u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
         
        }
        system.runAs(adminuser2){
         EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
         EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
           EMS_LM_Leave_Credit__c patAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,paternitytype.id, true); 
            EMS_LM_Leave_Credit__c berveAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,Bereavementtype.id, true);
        }
        system.runAs(u){
          EMS_LM_Leave_History__c request = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(-1), system.today().adddays(0), annualtype.id, false,null);
           request.EMS_LM_Approver__c = userinfo.getUserId();
           request.Approver_3__c = userinfo.getUserId();
           request.EMS_LM_2nd_Approver__c = userinfo.getUserId();
            TriggerBase.bypass('EMS_LM_Leave_History__c');
            insert request;
          EMS_LM_Leave_History__c request2 = TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), paternitytype.id, true,null);
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