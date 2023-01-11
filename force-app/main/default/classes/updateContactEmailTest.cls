@isTest
public class updateContactEmailTest {
    public static testmethod void updateOfficialMailTest(){
        Contact con = new Contact();
        con.lastName = 'Test';
        con.EMS_Phone_Number__c = '9898989898';
        con.Official_Mail__c = null;
        con.Email = 'test@gmail.com';
        insert con;

        Test.startTest();
        Contact conList = [select id, lastName, Official_Mail__c from Contact];
        update conList;
        System.assertEquals([SELECT EMAIL FROM CONTACT LIMIT 1].EMAIL, 'test@gmail.com');
        Test.stopTest();
    }
}