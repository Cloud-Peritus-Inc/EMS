@isTest
public class EMS_EM_CreationOnboardTestClass {
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
    static testMethod void testcreateDriveFornewRequest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Account accobj = new Account(
        Name ='test acc',
        phone ='1122334455');
          insert accobj;
        Contact contactObj = new Contact (
			FirstName = 'test value',
            Lastname='rdg',
            Title='Mr',
            AccountId = accobj.id,
			EMS_Domain_Technology__c ='Salesforce', 
			//EMS_RM_Current_Job_Role__c ='Accountant', 
			EMS_RM_Domain_Technology__c ='Salesforce', 
			EMS_RM_Industry__c ='Information Technology', 
			email = 'testEmail@gmail.com',  
			phone = '1234567890'
		);
		insert contactObj;
        string contactId=contactObj.Id;
        
        List<EMS_EM_Onboarding_Request__c> RequestList = new List<EMS_EM_Onboarding_Request__c>();
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.EMS_EM_Personal_Email__c='sangharsh.kamble@cloudpertius.com';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        insert onboard;
        RequestList.add(onboard);
        String onboardId=onboard.Id;
        String onboardEmail=onboard.EMS_EM_Personal_Email__c;
        ems_EM_Additional_Detail__c additionalList=New ems_EM_Additional_Detail__c();
        additionalList.EMS_EM_Degree__c='BE';
        additionalList.EMS_EM_Job_Title1__c='Salesforce Dev';
        additionalList.EMS_EM_Previous_Company_HR_EmailId__c='san@gmail.com';
        additionalList.EMS_EM_Previous_Company_Name1__c='Cp';
        additionalList.ContactId__c=contactObj.Id;
        additionalList.Onboarding_Request__c=onboard.Id;
       
        test.startTest();
        Insert additionalList;
       string additionalId =additionalList.Id;
        List<Map<String,Object>> listForUpdate = new List<Map<String,Object>>();
        Map<String, Object> filemap=New Map<String, Object>();
       
      //  List<filemap> files =new List<filemap>();
        //Create a new file
        //string reader = new FileReader();
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
         insert newFile;
        filemap.put(newFile.Id,newFile);
        listForUpdate.add(filemap);
       

        EMS_EM_CreationOnboard.sendEmail('subject',onboardId,'Body');
        EMS_EM_CreationOnboard.getonOnboardformInfo(onboardEmail);
  		EMS_EM_CreationOnboard.getonOnboardformInfo(null);
        
         EMS_EM_CreationOnboard.getUserOnboardInfo(onboardId);
     
        EMS_EM_CreationOnboard.getonOnboardAdditionalInfo(contactId);
        EMS_EM_CreationOnboard.getonOnboardAdditionalInfo(null);
        test.stopTest();
    }
    /*
    public static testMethod void createguestOnboard(){
         Test.setMock(HttpCalloutMock.class, new RestMock());
        List<Map<String,Object>> listForUpdate = new List<Map<String,Object>>();
        Map<String, Object> filemap=New Map<String, Object>();
        
         EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        
         ems_EM_Additional_Detail__c addionalDetail=new ems_EM_Additional_Detail__c();
        addionalDetail.EMS_EM_Job_Title1__c='sdfghj';
        
         List<EMS_EM_CreationOnboard.relatedFile> fInfoList = new List<EMS_EM_CreationOnboard.relatedFile>();
        EMS_EM_CreationOnboard.relatedFile singlefileInfo = new EMS_EM_CreationOnboard.relatedFile();
        
        test.startTest();
        singlefileInfo.PathOnClient='/' + 'Header_Picture1' + '.jpg';
        singlefileInfo.Title = 'Header_Picture1'; 
         Blob bodyBlobs=Blob.valueOf('Unit Test ContentVersion Body');
        singlefileInfo.VersionData = bodyBlobs;
        singlefileInfo.Title='aSDF';
        fInfoList.add(singlefileInfo); 
        filemap.put(singlefileInfo.Title,singlefileInfo);
        listForUpdate.add(filemap);
        
         EMS_EM_CreationOnboard.createGuest(onboard,addionalDetail,listForUpdate);
        test.stopTest();
    }*/
   
    @IsTest
    private static void createContentVersionSuccess() {
        Test.setMock(HttpCalloutMock.class, new RestMock());
       // List<Map<String,Object>> listForUpdate = new List<Map<String,Object>>();
       // Map<String, Object> filemap=New Map<String, Object>();
        
         EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        
         ems_EM_Additional_Detail__c addionalDetail=new ems_EM_Additional_Detail__c();
        addionalDetail.EMS_EM_Job_Title1__c='sdfghj';
        
        Blob b=EncodingUtil.base64Decode('Unit Test Attachment Body'); 
        List<EMS_EM_CreationOnboard.relatedFile> fInfoList = new List<EMS_EM_CreationOnboard.relatedFile>();
        EMS_EM_CreationOnboard.relatedFile singlefileInfo = new EMS_EM_CreationOnboard.relatedFile();
        singlefileInfo.PathOnClient = '/' + 'Header_Picture1' + '.jpg';
        singlefileInfo.Title = 'ABC';
        singlefileInfo.VersionData = b;
        fInfoList.add(singlefileInfo);
        
        test.startTest();
        EMS_EM_CreationOnboard.createGuest(onboard,addionalDetail, fInfoList);
        test.stopTest();
    }
    
    
}