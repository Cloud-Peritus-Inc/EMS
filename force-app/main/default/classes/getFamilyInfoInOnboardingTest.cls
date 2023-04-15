@isTest
public class getFamilyInfoInOnboardingTest {
	public testmethod static void sendMonthiversaryMailTest(){
           EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
         
        contact resource=TestDataFactory.createResourceContact(True);
        getFamilyInfoInOnboarding.getFamilyInfo(resource.Id);
    }
}