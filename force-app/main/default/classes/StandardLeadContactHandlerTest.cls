@isTest
public class StandardLeadContactHandlerTest
{
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
        
        
        CP_Sales_lead__c cp = new CP_Sales_lead__c();
        cp.Name ='lead ';
        cp.Lead__c = led.id;
        cp.Company__c ='salesforce';
        insert cp;
        led.Sales_Lead__c = cp.id;
        update led;
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
        Test.StopTest();
    }
      @isTest
    public static void testmethod2(){
               
        Contact Con = new Contact();
        Con.FirstName = 'Test';
        Con.LastName = 'SF Contact';
        Con.Email = 'testSF@Salesforce.com';
        Con.EMS_Phone_Number__c = '9999999999';
        insert Con;  
        
        CP_Sales_Contact__c cp = new CP_Sales_Contact__c();
        cp.Name ='Contact ';
        cp.Contact__c = Con.id;
        cp.Phone_Number__c = '123456789';
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
        update ca1;
        insert m1;
        update con;
        Test.stopTest(); 	
    }
        
}