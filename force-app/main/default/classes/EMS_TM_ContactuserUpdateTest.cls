@istest
public class EMS_TM_ContactuserUpdateTest {
     @testSetup
    public static void  contactUpdate(){
        Account acc = new Account();
        acc.Name ='rama';
        acc.Phone='96529015';
      //  acc.IsCustomerPortal = true;
        insert acc;
        System.debug('acc'+acc);
        Contact con = new contact();
        con.Email ='ramakrishna@gmail.com';
        con.AccountId = acc.id;
        con.FirstName ='rama111';
        con.LastName ='krishna11';
        con.EMS_Phone_Number__c ='965210752';
        con.EMS_RM_Phone_Number__c ='9652901075';
        con.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        con.EMS_EM_JD__c = system.today();
        insert con;
          System.debug('con'+con);
        
    }
    
    public static testmethod void chaneuser(){
        contact con = [Select id,FirstName from Contact where FirstName ='rama111'];
        System.debug('con'+con);
        Account a =[Select id,name  from Account where name ='rama'];
        System.debug('a'+a);
            test.startTest();
         Profile p = [Select id from profile where name='TM Customer Community'];
         User u = new User(Alias = 'Rk0', Email='Ramauser@testmethod.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing111',FirstName = 'one', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testuser.com', 
                           IsActive = true ,ContactId=con.id );   /*,UserType ='CspLitePortal' AccountId =a.Id*/        
        insert u;
        System.debug('u'+u);  
          test.stopTest();
        user uu =[Select id,lastname from user where lastname ='Testing111'];
        System.debug('uu'+uu);
        contact con1 = [Select id,FirstName,EMS_TM_User__c,Official_Mail__c from Contact where FirstName ='rama111'];
        con1.Official_Mail__c ='rk@rk.com';
        update con1;
     //    Contact c =[SELECT Id, FirstName, EMS_TM_User__c FROM Contact where EMS_TM_User__c =: uu.id];
         System.debug('c'+con1);
        
        //System.assertEquals(uu.id, con1.EMS_TM_User__c);
    }

}