@isTest
public class AutoFollowTheCPAccount_Test {
    
    testmethod static void autofollowTest(){
         EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        Account acc = TestDataFactory.createAccount('Cloud Peritus Inc',true);
         EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Timesheet_NoNeed__c =false;
        INSERT con;
        
        con.EMS_TM_User__c = userinfo.getUserId();
        con.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        
        update con;
    }

}