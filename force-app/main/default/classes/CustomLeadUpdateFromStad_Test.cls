@isTest
public class CustomLeadUpdateFromStad_Test {
    @isTest
    public static void testmethod1(){
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'SF Lead';
        led.Email = 'testSF@Salesforce.com';
        led.Company = 'Salesforce';
        led.Industry = 'Agriculture';
        //led.Status = 'Open';
        insert led;         
        update led;
        CP_Sales_lead__c cp = new CP_Sales_lead__c();
        cp.Name ='lead ';
        cp.Lead__c = led.id;
        cp.Company__c ='salesforce';
        insert cp;
        update cp;
        Campaign ca1 = new Campaign();
        ca1.Name = 'CP 5Rings Campaign';
        ca1.IsActive = TRUE;
        ca1.Type = 'Email';
        insert ca1;
        update ca1;
        CampaignMember m1 = new CampaignMember();
        m1.leadId = led.Id; 
        m1.CampaignId = ca1.Id;
        m1.Status ='Sent';
        
        Test.StartTest();
        insert m1;
        update m1;
        update led;
        Test.stopTest(); 	
        
    }
    @isTest
    public static void testmethod2(){
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'SF Lead';
        led.Email = 'testSF@Salesforce.com';
        led.Company = 'Salesforce';
        led.Industry = 'Agriculture';
       // led.Status = 'Open';
        insert led;         
        update led;
      
        Campaign ca1 = new Campaign();
        ca1.Name = 'CP 5Rings Campaign';
        ca1.IsActive = TRUE;
        ca1.Type = 'Email';
        insert ca1;
        update ca1;
        CampaignMember m1 = new CampaignMember();
        m1.leadId = led.Id; 
        m1.CampaignId = ca1.Id;
        m1.Status ='Sent';
        
        Test.StartTest();
        insert m1;
        update m1;
        Test.stopTest(); 	
        
    }
}