@isTest
public class LeadHandlerTest {
 
    @isTest
    public static void testmethod1(){
         CP_Sales_lead__c cp = new CP_Sales_lead__c();
        cp.Name ='lead ';
       // cp.Lead__c = led.id;
        cp.Company__c ='salesforce';
        insert cp;
        Lead led = new Lead();
        led.FirstName = 'Test';
        led.LastName = 'SF Lead';
        led.Email = 'testSF@Salesforce.com';
        led.Company = 'Salesforce';
        led.Industry = 'Agriculture';
        //led.Status = 'Open';
         led.Our_Offerings__c='Advisory Services';
        insert led; 
         led.Sales_Lead__c=cp.Id;        
        update led;  
       
        update cp;
        Campaign ca1 = new Campaign();
        ca1.Name = '5Rings';
        ca1.IsActive = TRUE;
        ca1.Type = 'Email';
        insert ca1;
        
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
