@isTest
public class Ems_Em_Request_DataFetch_Test {
    
    @isTest
    private static void getRequestHistoryTest(){
        
        EMS_EM_Request__c req1 = new EMS_EM_Request__c();
        req1.EMS_EM_Request_Type__c = 'Personal Details';
        req1.What_do_you_want_to_change__c = 'Contact Info';
        req1.EMS_EM_Contact_Number__c = '7897897897';
        req1.Personal_Email_Id__c = 'abcds@gmail.com';
        insert req1;
        
        Test.startTest();
        Ems_Em_Request_DataFetch.getRequestHistory();
        Test.stopTest();
        EMS_EM_Request__c req = [select EMS_EM_Request_Type__c from EMS_EM_Request__c LIMIT 1];
        
    }
    
    @isTest
    private static void getRequestByStatusTest(){
        
        EMS_EM_Request__c req1 = new EMS_EM_Request__c();
        req1.EMS_EM_Request_Type__c = 'Personal Details';
        req1.What_do_you_want_to_change__c = 'Contact Info';
        req1.EMS_EM_Contact_Number__c = '7897897897';
        req1.Personal_Email_Id__c = 'abcds@gmail.com';
        req1.EMS_EM_Request_Status__c = 'Pending';
        insert req1;
        
        Test.startTest();
        Ems_Em_Request_DataFetch.getRequestByStatus('Pending');
        Test.stopTest();
      
        
    }
    
    @isTest
    private static void getRelatedFilesByRecordIdTest(){
        
        Contact con = new Contact();
        con.Firstname = 'test';
        con.LastName = 'dsd';
        insert con;
        
        ContentVersion cv = new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='ABC.jpg';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];	
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = con.id;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        
        Test.startTest();
        //Please write your class name before function.
        Ems_Em_Request_DataFetch.getRelatedFilesByRecordId(con.Id);
        Test.stopTest();
    }
    
}