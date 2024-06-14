@IsTest
private class BirthdayReminderEmailTest {
   @testSetup static void birthing() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
       Office_Location__c Office=TestDataFactory.createOfficeLocation(True);
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
        con.EMS_EM_DOB__c=system.today().adddays(-365);    // con.EMS_TM_User__c =userId.Id;
        INSERT con;
             

       
   }
    
        

    @IsTest
    static void testBatchExecution() {
        Test.startTest();
        BirthdayReminderEmail batchInstance = new BirthdayReminderEmail();
         Database.executeBatch(batchInstance);
        Test.stopTest();
   
    }
    
}