@isTest
public class CP_SendEmailToAdminTeamNewApplicantTest {
	public testmethod static void  sendEmailToAdmin(){
        user adminuser = TestDataFactory.createAdminUser(true);
        
        system.runAs(adminuser){
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            
            Account acc = TestDataFactory.createAccount(true);
                       
            Contact conRec=  TestDataFactory.createApplicantContact(acc.id, false);
            conRec.EMS_Phone_Number__c ='0123456788';
            conRec.Resource_Role__c = role.Id;
            conRec.EMS_EM_JD__c = System.today().addDays(3);
            conRec.Personal_Email__c = 'Test@gmail.com';
            INSERT conRec;
            
        }
    }
}