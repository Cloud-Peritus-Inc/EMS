@isTest
public class BatchToUpdateAccountOnAppContacts_Test {
          public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToUpdateAccountOnAppContacts_SCH testsche = new BatchToUpdateAccountOnAppContacts_SCH();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
    
            public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
                   EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
       
         Account acc = TestDataFactory.createAccount('Cloud Peritus Inc',true);
		 Contact con=  TestDataFactory.createResourceContact(acc.id, false);
         con.EMS_RM_Employee_Id__c = 'CP10234';
         con.Resource_Role__c = role.Id;
         con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
         insert con;
         User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true); 
                system.runAs(u){
                    Contact con2 =  TestDataFactory.createResourceContact(acc.id, false);
                    con2.AccountId = null;
                    con2.Email = 'testwhgasbdasgicaweaocsaasedc@gmail.com';
                    con2.RecordTypeId = ContactConstant.APPLICANT_RECORDTYPEID;
                    insert con2;
                   }      
         Test.startTest();
             BatchToUpdateAccountOnAppContacts batchExecute = new BatchToUpdateAccountOnAppContacts(); 
             Database.executeBatch(batchExecute,10);
         Test.stopTest();
    }

}