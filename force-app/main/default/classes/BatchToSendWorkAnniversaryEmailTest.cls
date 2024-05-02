@isTest
public class BatchToSendWorkAnniversaryEmailTest {
    
    public testMethod static void testBatchclass() {
        Office_Location__c usLocation;
        Office_Location__c hydIndia;
        user adminuser = TestDataFactory.createAdminUser(true);
        system.runAs(adminuser){
            usLocation = TestDataFactory.createOfficeLocation('California - USA',true);
            hydIndia = TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            //prod error
            EMS_LM_Leave__c PTOtype = TestDataFactory.createLeaveType('Paid time off',true);
            
            Date dt = System.today().addYears(-1);
            Account acc = TestDataFactory.createAccount(true);
            Contact con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10237';
            con.EMS_RM_ApplicantStatus_Update__c ='Active';
            con.EMS_Phone_Number__c ='0123423559';
            con.Email = 'Test@gmail.com';
            con.Work_Location__c =usLocation.Id;
            con.EMS_EM_JD__c  = dt;
            con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
            insert con;
            
            Test.startTest();
            List<Contact> conRec = [SELECT id, EMS_EM_JD__c  FROM Contact WHERE Email != NULL];
            BatchToSendWorkAnniversaryEmail batchExecute = new BatchToSendWorkAnniversaryEmail('California - USA'); 
            Database.executeBatch(batchExecute,10);
            System.assertEquals(True,conRec.size()>0);
            Test.stopTest();
            
        }
    }
    
}