@isTest
public class updateContactEmailTest {
    public static testmethod void updateOfficialMailTest(){
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            
            Account acc = TestDataFactory.createAccount(true);
        Contact con = new Contact();
        con.accountId = acc.id;
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