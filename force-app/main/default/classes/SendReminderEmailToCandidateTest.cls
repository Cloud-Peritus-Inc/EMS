@isTest
public class SendReminderEmailToCandidateTest {
    public static testMethod void testscheduleclass() {
        Test.StartTest();
        SendReminderEmailToCandidate testsche = new SendReminderEmailToCandidate();
        String sch = '0 0 23 * * ?';
        system.schedule('SendReminderEmailToCandidate', sch, testsche );
        Test.stopTest();
    }
    
    public testmethod static void sendReminderEmailToCandidate(){
        user adminuser = TestDataFactory.createAdminUser(true);
        
        system.runAs(adminuser){
            
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
            EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
            
            Account acc = TestDataFactory.createAccount(true);
            
            Contact conRec=  TestDataFactory.createApplicantContact(acc.id, false);
            conRec.EMS_Phone_Number__c ='0123456788';
            conRec.Resource_Role__c = role.Id;
            conRec.EMS_EM_JD__c = System.today().addDays(3);
            conRec.Personal_Email__c = 'Test123885@gmail.com';
            INSERT conRec;
            
            EMS_EM_Onboarding_Request__c onboardingRecord = [SELECT Id, Date_of_Joining__c, EMS_EM_Personal_Email__c, Is_Confirm__c, 
                                                             CreatedDate, Reminder_Email_Sent__c, ContactId1__c
                                                             FROM EMS_EM_Onboarding_Request__c
                                                             WHERE Is_Confirm__c = false 
                                                             AND ContactId1__c =:conRec.Id];
            
            /*new EMS_EM_Onboarding_Request__c(
EMS_EM_First_Name__c = 'Test',
EMS_EM_Last_Name__c = 'Employee',
EMS_EM_Gender__c = 'Male',
Phone_Number__c = '0123456788',
EMS_EM_Phone_Number__c = '9595959556',
EMS_EM_DOB__c = Date.newInstance(1990, 1, 1),
EMS_EM_Personal_Email__c = 'Test123885@gmail.com',
ContactId1__c = conRec.Id,
Date_of_Joining__c = System.today().addDays(3)
);
insert onboardingRecord;*/
            Test.setCreatedDate(onboardingRecord.Id, Date.today().addDays(-5));
            Test.startTest();
            SendReminderEmailToCandidate batchExecute = new SendReminderEmailToCandidate(); 
            Database.executeBatch(batchExecute,10);
            Test.stopTest();
        }
        
    }
    
}