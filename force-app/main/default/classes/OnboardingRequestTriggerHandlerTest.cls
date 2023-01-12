@isTest
public class OnboardingRequestTriggerHandlerTest { 
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
        onboard.EMS_EM_First_Name__c='test';
        onboard.EMS_EM_Last_Name__c='last';
        onboard.Is_Inegration_Needed__c=true;
        onboard.Google_Drive_ID__c = '';
        insert onboard;
        RequestList.add(onboard);
        test.startTest();
        OnboardingRequestTriggerHandler.createDriveFornewRequest(RequestList);
        test.stopTest();
    }
}