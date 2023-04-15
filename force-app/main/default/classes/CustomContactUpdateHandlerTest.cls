@isTest
public class CustomContactUpdateHandlerTest {
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
        Con.EMS_Phone_Number__c = '1234567890';
        RecordType rt = [select Id,name from RecordType where Name ='Sales Contact' and SobjectType = 'Contact'];
        Con.RecordTypeId=rt.id;
        insert Con;  
        
        update Con;
        
        
        
    }
    /*
Contact Con1 = new Contact();
Con1.id=Con.id;
Con.FirstName = 'Test';
Con.LastName = 'SF Contact1';
Con.Email = 'testSF@Salesforce.com';
Con.EMS_Phone_Number__c = '123456789';

update Con1;

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
update m1;
Test.stopTest(); 	

}

@isTest
public static void testmethod2(){

Campaign ca1 = new Campaign();
ca1.Name = '5Rings';
ca1.IsActive = TRUE;
ca1.Type = 'Email';
insert ca1;


Contact Con = new Contact();
Con.FirstName = 'Test';
Con.LastName = 'SF Contact';
Con.Email = 'testSF@Salesforce.com';
Con.EMS_Phone_Number__c = '123456789';
insert Con;

CampaignMember m1 = new CampaignMember();
m1.ContactId = Con.Id; 
m1.CampaignId = ca1.Id;
m1.Status ='Sent';
insert m1;

CP_Sales_Contact__c cp = new CP_Sales_Contact__c();
cp.Contact__c = Con.id;
cp.First_Name__c = 'Test';
cp.Last_Name__c = 'SF Contact';
cp.Email__c = 'testSF@Salesforce.com';
insert cp;

update Con;


update cp;


}*/
}