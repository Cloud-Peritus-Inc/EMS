/**
    * @author Mukesh Rawat
    * @date 1/02/2023
    * @description  ConvertButton to Change the Status Approved to Converted on Onboarding Records 
    *
    *               Test code coverage for CP_ConvertButtonOnOnboarding class
    *        
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
@istest
public class CP_ConvertButtonOnOnboardingTest {
    
    static testmethod void approveButtonTest(){
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        onboard.Status__c = 'Approved';
        insert onboard;
        onboard.Status__c = 'Converted';
        update onboard;
        test.startTest();
        CP_ConvertButtonOnOnboarding.ConvertButton(onboard.Id);
        test.stopTest();
    }

}