@isTest
public class CP_SendEmailToResourceManagerTest {
    public testmethod static void  sendEmailRMTest(){
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
            INSERT con;
            
            Contact conRec=  TestDataFactory.createApplicantContact(acc.id, false);
            conRec.EMS_Phone_Number__c ='0123456788';
            conRec.Resource_Role__c = role.Id;
            conRec.Resource_Manager__c = con.Id;
            conRec.EMS_EM_JD__c = System.today().addDays(7);
            
            INSERT conRec;
            
            Contact conRec2=  TestDataFactory.createApplicantContact(acc.id, false);
            conRec2.EMS_Phone_Number__c ='0123456788';
            conRec2.Resource_Role__c = role.Id;
            conRec2.Resource_Manager__c = con.Id;
            conRec2.EMS_EM_JD__c = System.today().addDays(1);
            
            INSERT conRec2;
        }
        
        Test.startTest();
        List<Contact> conRec = [Select id, EMS_EM_JD__c from Contact where EMS_Phone_Number__c = '0123456788'];
        Database.executeBatch(new CP_SendEmailToResourceManager());
        System.assertEquals(True,conRec.size()>0);
        Test.stopTest();
    }
}