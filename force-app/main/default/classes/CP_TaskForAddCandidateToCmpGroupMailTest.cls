/**
* @author Eswar
* @date 01/01/2023
* @description  This batch will run daily, on date of joining one task will create and send mail to IT team regarding addition of the 
				candidate to the company group emails.

*               Test code coverage for CP_TaskForAddCandidateToCmpGroupMail class
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class CP_TaskForAddCandidateToCmpGroupMailTest {
    
	@testsetup
  	public static void testdata(){
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;
        
        Contact con = new Contact();
        con.lastName = 'Test';
        con.Email = 'test@gmail.com';
        con.EMS_EM_JD__c = System.today();
        con.Phone = '7878787878';
        con.AccountId = acc.Id;
        con.RecordTypeId = devRecordTypeId;
        insert con;
        
        Contact con1 = new Contact();
        con1.lastName = 'IT Departement';
        con1.Email = 'test2@gmail.com';
        con1.EMS_EM_JD__c = System.today().addDays(10);
        con1.Phone = '7878787879';
        con1.AccountId = acc.Id;
        insert con1;
                
    }
    
    @isTest
    public static void CP_TaskForAddCandidateToCmpGroupMailMethod(){
    	Contact con = [SELECT id, email, EMS_EM_JD__c from Contact where email='test@gmail.com'];
        
        Test.startTest();
     	Database.executeBatch(new CP_TaskForAddCandidateToCmpGroupMail());
        Test.stopTest();
        List<Task> taskList = new List<Task> ([SELECT id,Subject FROM Task WHERE Subject = 'Add the new employee\'s email ID to the company\'s email groups']);
        System.assertEquals(1, taskList.size());
        
    }
}