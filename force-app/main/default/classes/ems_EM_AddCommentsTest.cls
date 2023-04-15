@isTest
public class ems_EM_AddCommentsTest {
	public testmethod static void sendOnboardingFormReopenTest(){
        EMS_EM_Onboarding_Request__c onRec = new EMS_EM_Onboarding_Request__c();
        onRec.EMS_EM_Last_Name__c = 'Test';
        insert onRec;
        
        String commentsOnRec = 'Testing comments';
        
        Test.startTest();
        ems_EM_AddComments.sendOnboardingFormReopenEmail(onRec.Id,commentsOnRec);
        Test.stopTest();
    }       
}