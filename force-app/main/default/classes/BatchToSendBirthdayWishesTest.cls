@isTest

public class BatchToSendBirthdayWishesTest {
    
      public static testMethod void testscheduleclass() {
		Test.StartTest();
		 BatchToSendBirthdayWishes_sch testsche = new BatchToSendBirthdayWishes_sch();
		 String sch = '0 0 23 * * ?';
		 system.schedule('Test BatchToSendBirthdayWishes', sch, testsche );
		Test.stopTest();
	}
        public testMethod static void testBatchclass() {
        
            user adminuser = TestDataFactory.createAdminUser(true);
            system.runAs(adminuser){
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            
            Date birthday = system.today();


            Account acc = TestDataFactory.createAccount(true);
		    Contact con=  TestDataFactory.createResourceContact(acc.id, false);
			con.EMS_RM_Employee_Id__c = 'CP10236';
            con.EMS_RM_ApplicantStatus_Update__c ='Active';
            con.EMS_Phone_Number__c ='1345635678';
            con.Email = 'Test@gmail.com';
         	con.EMS_EM_DOB__c = birthday;
         	con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
         	insert con;
      
         Test.startTest();
            List<Contact> conRec = [SELECT id, EMS_EM_DOB__c FROM Contact WHERE Email != NULL];
             BatchToSendBirthdayWishes batchExecute = new BatchToSendBirthdayWishes(); 
             Database.executeBatch(batchExecute,10);
             System.assertEquals(True,conRec.size()>0);
         Test.stopTest();
            
            }
        }
    }