@IsTest
private class AniversaryReminderEmailTest {
   @testSetup static void methodName() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);

       Office_Location__c Office=TestDataFactory.createOfficeLocation(True);
             Contact con=  TestDataFactory.createResourceContact(false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Timesheet_NoNeed__c =false;
      //  con.Resource_Role__c = role.Id;
       // con.EMS_TM_User__c =userId.Id;
        con.Work_Location__c=Office.Id;
        con.EMS_EM_JD__c=system.today().adddays(365);
       try{
             INSERT con;
       }catch(exception e){
           system.debug('error -----------'+e.getmessage());
       }
      
      
   
   }
    
        

    @IsTest
    static void testBatchExecution() {
        // Create test data
        
        // Start the batch execution
        Test.startTest();
        AniversaryReminderEmail batchInstance = new AniversaryReminderEmail();
         Database.executeBatch(batchInstance);
        Test.stopTest();
       
    }
    
}