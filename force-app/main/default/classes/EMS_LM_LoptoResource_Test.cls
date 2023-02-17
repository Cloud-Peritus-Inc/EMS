@isTest
public class EMS_LM_LoptoResource_Test {
    
    @istest
    public static void lopresourcemethod(){
        Test.startTest();
        Contact con = new Contact();
        con.lastName = 'Test';
        con.EMS_Phone_Number__c = '9898989898';
        con.Email = 'test@gmail.com';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Resource').getRecordTypeId();
        con.EMS_EM_JD__c = system.today() - 120;
        insert con;
        
        EMS_LM_Leave_Credit__c leaveCredit = new EMS_LM_Leave_Credit__c();
        leaveCredit.EMS_LM_Employee__c = con.id;
        leaveCredit.EMS_LM_Leave_Credited_Date__c = System.today();
        leaveCredit.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
        insert leaveCredit;
        Test.stopTest();
        
        //System.assertEquals(1.66, 1.66);
   
           Test.startTest();  
       // EMS_LM_LoptoResource lotresource =New EMS_LM_LoptoResource();
      //  lotresource.LoptoResourcemethod(conList);
        Test.stopTest();
    	
    }
}