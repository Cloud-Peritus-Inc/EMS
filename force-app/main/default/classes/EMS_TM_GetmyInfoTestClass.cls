@isTest
public class EMS_TM_GetmyInfoTestClass {
    
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
        List<EMS_EM_Onboarding_Request__c> RequestList = new List<EMS_EM_Onboarding_Request__c>();
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        Account accobj = new Account(
        Name ='test acc',
        phone ='1122334455');
          insert accobj;
        Contact contactObj = new Contact (
			FirstName = 'test value',
            Lastname='rdg',
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
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        insert onboard;
        ems_EM_Additional_Detail__c additionalList=New ems_EM_Additional_Detail__c();
        additionalList.EMS_EM_Degree__c='BE';
        additionalList.EMS_EM_Job_Title1__c='Salesforce Dev';
        additionalList.EMS_EM_Previous_Company_HR_EmailId__c='san@gmail.com';
        additionalList.EMS_EM_Previous_Company_Name1__c='Cp';
        additionalList.ContactId__c=contactObj.Id;
        additionalList.Onboarding_Request__c=onboard.Id;
        test.startTest();
        Insert additionalList;
        RequestList.add(onboard);
        
        EMS_TM_GetmyInfo.getContactAdditionalInfo(contactId);
        test.stopTest();
    }

    @isTest static void testMethod1() {
        Account accobj = new Account(
        Name ='test acc',
        phone ='1122334455');
          insert accobj;
        Contact contactObj = new Contact (
			FirstName = 'test value',
            Lastname='rdg',
            AccountId = accobj.id,
			EMS_Domain_Technology__c ='Salesforce', 
			//EMS_RM_Current_Job_Role__c ='Accountant', 
			EMS_RM_Domain_Technology__c ='Salesforce', 
			EMS_RM_Industry__c ='Information Technology', 
			email = 'testEmail@gmail.com',  
			phone = '1234567890'
		);
        
		insert contactObj;    
       
        string contactObjId =contactObj.Id;
         Profile p = [Select id from profile where name='TM Customer Community'];
		User userObj = new User (
			ContactId = contactObj.id, 
			Username = 'trt3@gmail.com', 
			LastName = 'test', 
            firstName='te',
			Email = 'testEmail@gmail.com', 
			EmailPreferencesAutoBcc = TRUE, 
			EmailPreferencesAutoBccStayInTouch = TRUE, 
			EmailPreferencesStayInTouchReminder = TRUE, 
			Alias = 'test',
            isActive = true,
			CommunityNickname = 'test value', 
			TimeZoneSidKey ='Pacific/Kiritimati', 
			LocaleSidKey ='af_ZA', 
			EmailEncodingKey ='UTF-8', 
			ProfileId = p.id, 
            PortalRole = 'Manager',
			LanguageLocaleKey ='en_US'
			
		);
		
		 test.startTest();
        insert userObj;
         EMS_TM_GetmyInfo.getUserContactInfo(userObj.id); 
        EMS_TM_GetmyInfo.getUserInfo(contactObjId,'7767987565'); 
        test.stopTest();
	}
}