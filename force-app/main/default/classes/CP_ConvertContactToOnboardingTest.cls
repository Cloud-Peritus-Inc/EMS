@isTest
public class CP_ConvertContactToOnboardingTest {
    public testmethod static void  convertContactToOnboarding(){
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
            conRec.EMS_EM_JD__c = System.today().addDays(10);
            conRec.Personal_Email__c = 'Test@gmail.com';
            INSERT conRec;
            
            Contact conRec2=  TestDataFactory.createApplicantContact(acc.id, false);
            conRec2.EMS_Phone_Number__c ='0123456788';
            conRec2.Resource_Role__c = role.Id;
            conRec2.EMS_EM_JD__c = System.today();
            conRec2.Personal_Email__c = 'Test1@gmail.com';
            INSERT conRec2;
        }
        
        Test.startTest();
        List<Contact> conRec = [Select id, EMS_EM_JD__c from Contact where EMS_Phone_Number__c = '0123456788'];
        Database.executeBatch(new CP_ConvertContactToOnboarding());
        System.assertEquals(True,conRec.size()>0);
        Test.stopTest();
    }
        
}