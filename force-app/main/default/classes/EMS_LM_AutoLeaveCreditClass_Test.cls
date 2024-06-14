@isTest
public class EMS_LM_AutoLeaveCreditClass_Test {
    static testMethod void testMethod1() 
    {
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0 ; i<20; i++)
        {
            Contact cnt = new Contact();
            cnt.LastName ='Name'+i;
            cnt.EMS_Phone_Number__c = '8897789449';
            contactList.add(cnt);
        }
        
        insert contactList;
        
        Test.startTest();
        
        EMS_LM_AutoLeaveCreditClass obj = new EMS_LM_AutoLeaveCreditClass();
        DataBase.executeBatch(obj);         
        Test.stopTest();
    }
}