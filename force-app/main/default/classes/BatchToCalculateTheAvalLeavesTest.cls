@isTest
public class BatchToCalculateTheAvalLeavesTest {
    
    public static testMethod void testBatchclass() {
         user adminuser = TestDataFactory.createAdminUser(true);
         user adminuser2 = TestDataFactory.createAdminUser(true);
        Resource_Role__c role;
       EMS_LM_Leave__c annualtype;
        EMS_LM_Leave__c loptype;
        EMS_LM_Leave__c bretype;
        EMS_LM_Leave__c compofftype;
        Account acc;Contact con;
        system.runAs(adminuser){
           role = TestDataFactory.createResourceRole(true);
         annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
         loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
         bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
         compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
          acc = TestDataFactory.createAccount(true);
		 con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         con.EMS_RM_ApplicantStatus_Update__c = 'Active';
         con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
         insert con;
        }
       
        
         Test.startTest();
         User u;
         system.runAs(adminuser){
        
         u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
         
        }
        system.runAs(adminuser2){
         EMS_LM_Leave_Credit__c lcreditAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1.6,annualtype.id, true);
         EMS_LM_Leave_Credit__c bretAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),20,bretype.id, true);
         EMS_LM_Leave_Credit__c commOffAnnual = Testdatafactory.createLeaveCredit(con.id,system.today(),1,compofftype.id, true);
        }
        system.runAs(u){
          List<EMS_LM_Leave_History__c> hlist = new List<EMS_LM_Leave_History__c>();
         hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today(), system.today().adddays(1), annualtype.id, false, null));
          hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(6), system.today().adddays(7), bretype.id, false, null));
          hlist.add(TestDataFactory.createLeaveRequest(con.id, system.today().adddays(8), system.today().adddays(9), compofftype.id, false, null));
         insert hlist;
        }
            TriggerBase.bypass('Contact');
             BatchToCalculateTheAvailableLeaves  batchExecute = new BatchToCalculateTheAvailableLeaves(); 
             Database.executeBatch(batchExecute,10);
             TriggerBase.clearBypass('Contact');
         Test.stopTest();
    }    
    
    public static testMethod void testscheduleclass() {
		Test.StartTest();
        
		BatchToCalculateTheAvaiLeaves_sch testsche = new BatchToCalculateTheAvaiLeaves_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}

}