/**
* @author Mukesh Rawat
* @date 1/02/2023
* @description  createContact to Convert Onboarding Records to Resource-Contact Resource
*
*               Test code coverage for CP_OnboardingToResourceConvert class
*        
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

@istest
public class CP_OnboardingToResourceConvertTest {
    
    Public static testmethod void createContactTest(){
        
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
            
            EMS_EM_Onboarding_Request__c onboardingRecord = new EMS_EM_Onboarding_Request__c(
                EMS_EM_First_Name__c = 'John',
                EMS_EM_Last_Name__c = 'Doe',
                EMS_EM_Gender__c = 'Male',
                Phone_Number__c = '8585858585',
                EMS_EM_Phone_Number__c = '9595959556',
                EMS_EM_DOB__c = Date.newInstance(1990, 1, 1),
                EMS_EM_Personal_Email__c = 'johndoe@example.com',
                EMS_EM_AadhaarNo__c = '1234',
                EMS_EM_PanNo__c = 'ABCD1234',
                EMS_EM_Nationality__c = 'Indian',
                Permanent_Address_Line_1__c = '123 Main St',
                Permanent_Address_Line_2__c = 'Apt 1',
                Current_Address_Line_1__c = '456 Oak St',
                Current_Address_Line_2__c = 'Suite 2',
                EMS_EM_CA_State__c = 'CA',
                EMS_EM_PA_State__c = 'PA',
                EMS_EM_CA_City__c = 'San Francisco',
                EMS_EM_PA_City__c = 'Philadelphia',
                EMS_EM_CA_Zip__c = '94101',
                EMS_EM_PA_Zip__c = '19101',
                Trailblazer_ID_or_Public_URL__c = 'https://trailblazer.salesforce.com/profile?id=005',
                ContactId1__c = con.Id
            );
            insert onboardingRecord;
            
            test.startTest();
            List<Contact> contacts = CP_OnboardingToResourceConvert.createContact(onboardingRecord.Id);
            test.stopTest();     
        }
    } 
}