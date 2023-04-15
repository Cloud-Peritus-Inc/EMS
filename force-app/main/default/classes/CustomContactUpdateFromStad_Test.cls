@isTest
public class CustomContactUpdateFromStad_Test {
    
    @isTest
    public static void testmethod1(){
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        Contact Con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'SF Contact';
        Con.Email = 'testSF@Salesforce.com';
        Con.EMS_Phone_Number__c = '1234567809';
        insert Con;  
        
        CP_Sales_Contact__c cp = new CP_Sales_Contact__c();
        cp.Name ='Contact ';
        cp.Contact__c = Con.id;
        cp.Phone_Number__c = '1234567890';
        insert cp;
        
        Campaign ca1 = new Campaign();
        ca1.Name = 'CP 5Rings Campaign';
        ca1.IsActive = TRUE;
        ca1.Type = 'Email';
        insert ca1;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = Con.Id; 
        m1.CampaignId = ca1.Id;
        m1.Status ='Sent';
        
        Test.StartTest();
        insert m1;
        Database.executeBatch(new CustomContactUpdateFromStad());
        Test.stopTest(); 	
        
    }
    @isTest
    public static void testmethod2(){
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        Contact Con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'SF Contact';
        Con.Email = 'testSF@Salesforce.com';
        Con.EMS_Phone_Number__c = '1234567890';
        insert Con;
        
        Campaign ca1 = new Campaign();
        ca1.Name = 'CP 5Rings Campaign';
        ca1.IsActive = TRUE;
        ca1.Type = 'Email';
        insert ca1;
        
        CampaignMember m1 = new CampaignMember();
        m1.ContactId = Con.Id; 
        m1.CampaignId = ca1.Id;
        m1.Status ='Sent';
        
        Test.StartTest();
        insert m1;
        Database.executeBatch(new CustomContactUpdateFromStad());
        Test.stopTest(); 	
        
    }
}