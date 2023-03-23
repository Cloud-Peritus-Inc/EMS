@isTest
public class CustomLeadUpdateHandlerTest {
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
        
        /*
        Lead led1 = new Lead();
        led1.id = led.id;
        led1.FirstName = 'Test';
        led1.LastName = 'SF Lead';
        led1.Email = 'testSF@Salesforce.com';
        led1.Company = 'Salesforce';
        led1.Industry = 'Agriculture';
        //led.Status = 'Open';
         */
                
        CP_Sales_lead__c cp = new CP_Sales_lead__c();
        
        cp.Name ='lead ';
        cp.Company__c ='salesforce';
        
        insert cp;
        led.Sales_Lead__c = cp.id;
        
        update led;
        
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
        
        Test.stopTest();
    }
}