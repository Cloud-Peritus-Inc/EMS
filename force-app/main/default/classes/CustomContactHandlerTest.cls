@isTest
public class CustomContactHandlerTest {
    @isTest
    public static void CustomContactHandlerTestMethod()
    {
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);    
          EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Contact Con = new Contact();
        con.RecordTypeId=Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        Con.FirstName = 'Test';
        Con.LastName = 'SF Contact';
        Con.Email = 'testSF@Salesforce.com';
        Con.EMS_Phone_Number__c = '1234567890';
        insert Con;  
        
        CP_Sales_Contact__c cp = new CP_Sales_Contact__c();
        cp.Name ='Contact ';
        cp.Contact__c = Con.id;
        cp.Phone_Number__c = '1234567890';
        insert cp;
        update cp;
        
        Campaign ca1 = new Campaign();
        ca1.Name = '5Rings';
        ca1.IsActive = TRUE;
        ca1.Type = 'Email';
        insert ca1;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = Con.Id; 
        m1.CampaignId = ca1.Id;
        m1.Status ='Sent';
        
        Test.StartTest();
        insert m1;
        update m1;
        Test.stopTest();
    }
}