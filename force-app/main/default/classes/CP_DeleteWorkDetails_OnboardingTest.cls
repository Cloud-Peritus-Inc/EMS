@isTest
public class CP_DeleteWorkDetails_OnboardingTest {
	public testmethod static void deleteWorkDetails(){
        user adminuser = TestDataFactory.createAdminUser(true);
        
        system.runAs(adminuser){
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            
            Account acc = TestDataFactory.createAccount(true);
            
            Contact con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10235';
            con.EMS_RM_ApplicantStatus_Update__c ='Active';
            con.EMS_Phone_Number__c ='0123456789';
            con.EMS_EM_CAddress_Line_1__c ='Hyd';
            con.EMS_EM_CA_City__c ='Hyd';
            con.EMS_EM_CA_State__c ='AP';
            con.Timesheet_NoNeed__c =false;
            con.Resource_Role__c = role.Id;
            con.Email = 'Test@gmail.com';
            con.EMS_EM_JD__c = System.today().addDays(-30);
            insert con; 
            
            List<EMS_EM_Onboarding_Request__c> onboardingList = [select id, EMS_EM_Last_Name__c from EMS_EM_Onboarding_Request__c where ContactId1__c =: con.Id];
            List<EMS_EM_Onboarding_Request__c> finalList = new List<EMS_EM_Onboarding_Request__c>();
            System.debug('Onboarding value => '+onboardingList);
            for(EMS_EM_Onboarding_Request__c onboaerdingRec : onboardingList){
                onboaerdingRec.EMS_EM_First_Name__c = 'Test';
                finalList.add(onboaerdingRec);
            }
            update finalList;
        }
    }
}