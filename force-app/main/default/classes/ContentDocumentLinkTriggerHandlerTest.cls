@isTest
public class ContentDocumentLinkTriggerHandlerTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"name" : "","mimeType" : "application/vnd.google-apps.folder"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }  
    static testMethod void createDriveFileTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        insert onboard;
        ems_EM_Additional_Detail__c addionalDetail=new ems_EM_Additional_Detail__c();
        addionalDetail.Onboarding_Request__c = onboard.id;
        insert addionalDetail;
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId=onboard.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        ContentDocumentLink contentlink1 = new ContentDocumentLink();
        contentlink1.LinkedEntityId=addionalDetail.id;
        contentlink1.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink1.ShareType = 'I';
        contentlink1.Visibility = 'AllUsers'; 
        insert contentlink1;
        ContentDocumentLinkList.add(contentlink1);
        test.startTest();
        ContentDocumentLinkTriggerHandler.createDriveFile(ContentDocumentLinkList);
        test.stopTest();
    }
    
}