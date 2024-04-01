@istest
public class BirthdayCheckerTest {
    @istest
    public static void testbirthanniversary(){
         user loginedUser =[SELECT id from User  where IsActive = true LIMIT 1];
          Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
         Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('United States of America',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        // Office_Location__c officlocRec =TestDataFactory.createOfficeLocation(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
         con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =loginedUser.Id;
         con.Work_Location__c =officlocRec.Id;
        con.EMS_EM_DOB__c=system.today().addyears(-1);
        INSERT con;
       Test.starttest();
        BirthdayChecker batchJob = new BirthdayChecker();
      String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, batchJob);
       Test.stopTest();
    }

}