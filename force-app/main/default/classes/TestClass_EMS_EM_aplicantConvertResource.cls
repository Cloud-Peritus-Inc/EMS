@istest
public class TestClass_EMS_EM_aplicantConvertResource { 
   /* private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"name" : "","mimeType" : "application/vnd.google-apps.folder"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    public static map<id,contact>conmap=new map<id,contact>();
    public static list<contact>conlist=new list<contact>();
    
    @istest
    public static void methodName() {
        recordType rec =[SELECT Id, Name, IsActive FROM RecordType where name ='Resource Inactive'];
        for(integer i=1; i<=1; i++){
            Contact con = new contact();
            con.LastName = 'yugandhar';
            con.EMS_EM_Father__c ='nagababu';
            con.Personal_Email__c='sai327ch@gmail.com';
            con.RecordTypeId = rec.id;
            insert con;
            conmap.put(con.id,con);
        }
        contact cn=[select id, firstName, lastname, EMS_RM_ApplicantStatus_Update__c, Official_Mail__c from contact where LastName ='yugandhar'];
        cn.Official_Mail__c='naga.karpurapu@cloudperitus.com';
        cn.EMS_RM_ApplicantStatus_Update__c='Active - Probation';
        
        update cn;
        conlist.add(cn);      
    } 
    static testmethod void createContactTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<EMS_EM_Onboarding_Request__c> RequestList = new List<EMS_EM_Onboarding_Request__c>();
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        onboard.Status__c = 'Pending';
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
        Map<Id,EMS_EM_Onboarding_Request__c> oldOnboardRecordMap = new Map<Id,EMS_EM_Onboarding_Request__c>();
        onboard.Status__c = 'Approved';
        update onboard;
        oldOnboardRecordMap.put(onboard.Id,onboard);
        RequestList.add(onboard);
        test.startTest();
        EMS_EM_aplicantConvertResource.createContact(RequestList,oldOnboardRecordMap);
        test.stopTest();     
    }
    static testmethod void approveButtonTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        onboard.Status__c = 'Pending';
        insert onboard;
        onboard.Status__c = 'Approved';
        update onboard;
        test.startTest();
        EMS_EM_aplicantConvertResource.approveButton(onboard.Id);
        test.stopTest();
    }
     static testmethod void rejectButtonTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        onboard.Status__c = 'Pending';
        insert onboard;
        onboard.Status__c = 'Rejected';
        update onboard;
        test.startTest();
        EMS_EM_aplicantConvertResource.rejectButton(onboard.Id);
        test.stopTest();
    }*/
}