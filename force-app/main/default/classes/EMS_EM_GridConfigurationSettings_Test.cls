@isTest
public class EMS_EM_GridConfigurationSettings_Test {
    
    public testmethod static void getCompanyInformationTest(){
        
        Grid_Configuration__c CompanyInfoData = new Grid_Configuration__c(Name = 'Company Information', Grid_Configuration_Type__c = 'Company Information - EMP- Onboarding', Description__c = 'description');
        Insert CompanyInfoData;
        Test.StartTest();
        EMS_EM_GridConfigurationSettings.getCompanyInformation();
        Test.StopTest();
    }
}