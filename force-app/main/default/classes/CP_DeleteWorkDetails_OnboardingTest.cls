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
            
            EMS_EM_Onboarding_Request__c request = new EMS_EM_Onboarding_Request__c(Do_you_have_work_experience__c = 'No');
            insert request;
            
            EMS_EM_Additional_Detail__c detail = new EMS_EM_Additional_Detail__c();
            detail.Onboarding_Request__c = request.Id;
            detail.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_EM_Additional_Detail__c' AND DeveloperName = 'Work_Details'].Id;
            insert detail;
            
            ContentVersion document = new ContentVersion();
            document.Title = 'Work_Details_Test_File';
            document.PathOnClient = 'Work_Details_Test_File.pdf';
            document.VersionData = Blob.valueOf('Test document body');
            insert document;
            
            ContentDocumentLink documentLink = new ContentDocumentLink(
                LinkedEntityId = request.Id,
                ContentDocumentId = [SELECT Id FROM ContentDocument WHERE Title = 'Work_Details_Test_File'].Id,
                ShareType = 'I'
            );
            insert documentLink;
                        
            Test.startTest();
            new CP_DeleteWorkDetails_Onboarding().deleteWorkDetailsWhenWorkIsNo(new List<EMS_EM_Onboarding_Request__c>{request});
            Test.stopTest();
        }
    }
}