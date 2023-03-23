/**
* @author Eswar
* @date 25/01/2023
* @description  This batch will run daily, if any applicant DOJ is equal to 10days from today then will create onboarding record as well as send email with 
				onboarding form. Or if DOJ less than 10days then on which date DOJ is updated on that day itself create onboarding record as well as send 
				email with onboarding form.
*
*               Test code coverage for CP_ConvertContactToOnboarding class
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class CP_ConvertContactToOnboardingTest {
    
    @testsetup
  	public static void testdata(){
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'Test';
        con.Email = 'test@gmail.com';
        con.EMS_EM_JD__c = System.today().addDays(5);
        con.Phone = '7878787878';
        con.AccountId = acc.Id;
        con.RecordTypeId = devRecordTypeId;
        insert con;
        
        Contact con1 = new Contact();
        con1.lastName = 'Test2';
        con1.Email = 'test2@gmail.com';
        con1.EMS_EM_JD__c = System.today().addDays(10);
        con1.Phone = '7878787879';
        con1.AccountId = acc.Id;
        con1.RecordTypeId = devRecordTypeId;
        insert con1;
                
    }
    
	@isTest
    public static void CP_ConvertContactToOnboardingMethod(){
        
        Contact con = [SELECT id, email, EMS_EM_JD__c from Contact where email='test@gmail.com'];
        
        Test.startTest();
     	Database.executeBatch(new CP_ConvertContactToOnboarding());
        Test.stopTest();
        List<EMS_EM_Onboarding_Request__c> onboardingList = new List<EMS_EM_Onboarding_Request__c> ([SELECT id, EMS_EM_Personal_Email__c FROM EMS_EM_Onboarding_Request__c WHERE EMS_EM_Personal_Email__c =: con.email]);
        System.assertEquals(1, onboardingList.size());
    }
    
    @isTest
    public static void CP_ConvertContactToOnboardingMethod2(){
        
        Contact con = [SELECT id, email, EMS_EM_JD__c from Contact where email='test2@gmail.com'];
        
        Test.startTest();
        Database.executeBatch(new CP_ConvertContactToOnboarding());
        Test.stopTest();
        List<EMS_EM_Onboarding_Request__c> onboardingList = new List<EMS_EM_Onboarding_Request__c> ([SELECT id, EMS_EM_Personal_Email__c FROM EMS_EM_Onboarding_Request__c WHERE EMS_EM_Personal_Email__c =: con.email]);
        System.assertEquals(1, onboardingList.size());
    }
}