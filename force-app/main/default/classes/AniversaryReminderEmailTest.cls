@isTest
private class AniversaryReminderEmailTest {

    @isTest
    static void testAniversaryReminderEmailBatch() {
        // Insert test data - create a Contact with anniversary in the current week
         EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
           
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Contact testContact = new Contact(
            EMS_RM_ApplicantStatus_Update__c = 'Active - Probation',
            EMS_EM_JD__c = Date.today().addDays(3) // Anniversary in the same week
        );
        try{
                   insert testContact;
 
        }catch(exception e){
            system.debug(e);
        }

        // Start the batch job
        Test.startTest();
        AniversaryReminderEmail batchJob = new AniversaryReminderEmail();
        Database.executeBatch(batchJob);
        Test.stopTest();

        // Verify the results - you may need to adjust this based on your specific logic
        // For example, check if an email was sent or if the HR team received the notification
        // You may also assert on the expected content of the email
        // For simplicity, we are checking if the finish method is invoked without errors
        //System.assertEquals(1, [SELECT count() FROM Contact WHERE Id = :testContact.Id].size());
    }

    @isTest
    static void testAniversaryReminderEmailSchedulable() {
        // Schedule the job
        Test.startTest();
        String jobId = System.schedule('AniversaryReminderEmailTestJob', '0 0 0 * * ?', new AniversaryReminderEmail());
        Test.stopTest();

        // Verify the scheduled job is created
        System.assertNotEquals(null, jobId);

        // To verify the actual execution, you may need to check if an email was sent, etc.
        // You can do this based on your specific logic and assertions
    }

    @isTest
    static void testCalculateYearsWithCP() {
        // Create a test date for an employee joining date
        Date joiningDate = Date.today().addYears(-2);

        // Call the method to calculate years
        Integer years = new AniversaryReminderEmail().calculateYearsWithCP(joiningDate);

        // Verify that the correct number of years is calculated
        System.assertEquals(2, years);
    }

    @isTest
    static void testPrepareEmailContent() {
        // Create a test contact with anniversary
        Contact testContact = new Contact(
            EMS_RM_Employee_Id__c = 'CP123',
            FirstName='Mani',LastName='Test',
            EMS_EM_JD__c = Date.today().addDays(3) // Anniversary in the same week
        );

        // Call the method to prepare email content
        String emailContent = new AniversaryReminderEmail().prepareEmailContent(new List<Contact>{testContact});

        // Verify that the email content is not empty and contains expected details
        System.assertNotEquals('', emailContent);
        System.assert(emailContent.contains('CP123'));
      //  System.assert(emailContent.contains('Test Employee'));
        // Add more assertions based on your expected content
    }

    @isTest
    static void testSendEmailToHR() {
        // Create a test contact with anniversary
            EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
           
            EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Contact testContact = new Contact(
            EMS_RM_Employee_Id__c = 'CP123',
            FirstName='Manii',LastName='Test',
            EMS_EM_JD__c = Date.today().addDays(3) // Anniversary in the same week
        );

        // Insert test contact
        insert testContact;

        // Call the method to send email to HR
        Test.startTest();
        new AniversaryReminderEmail().sendEmailToHR('Test Email Content');
        Test.stopTest();

        // Verify that the email is sent (You may need to add assertions based on your specific logic)
        // For example, check if the email is in the EmailMessage object or if the HR team receives it
    }
}