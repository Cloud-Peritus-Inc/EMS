@isTest
public class ProgressBarApplicantControllerTest {
	public testmethod static void progressBarData(){
        EMS_EM_Onboarding_Request__c onboardingRequestRec = new EMS_EM_Onboarding_Request__c();
        onboardingRequestRec.EMS_EM_Last_Name__c = 'Test';
        onboardingRequestRec.Personal_Details_Value_Filled__c = True;
        onboardingRequestRec.Identify_Details_Value_Filled__c = True;
        onboardingRequestRec.Address_Details_Value_Filled__c = True;
        onboardingRequestRec.Other_Certifications_Value_Filled__c = True;
        onboardingRequestRec.Work_Details_Filled__c = True;
        onboardingRequestRec.Education_Details_Filled__c = True;
        
        insert onboardingRequestRec;
        
        Test.startTest();
        ProgressBarApplicantController.fetchOnboardingRecords(onboardingRequestRec.Id);
        Test.stopTest();
    }
}