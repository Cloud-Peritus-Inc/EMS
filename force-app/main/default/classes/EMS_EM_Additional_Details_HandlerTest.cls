@isTest
public class EMS_EM_Additional_Details_HandlerTest {
      private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"name" : "","mimeType" : "application/vnd.google-apps.folder"}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    static testMethod void myTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        List<ems_EM_Additional_Detail__c> addList=new List<ems_EM_Additional_Detail__c>();
        EMS_EM_Onboarding_Request__c onboard =new EMS_EM_Onboarding_Request__c();
        //onboard.EMS_EM_First_Name__c='test';
        onboard.Is_Inegration_Needed__c=true;
        
        insert onboard;
        
        ems_EM_Additional_Detail__c addionalDetail=new ems_EM_Additional_Detail__c();
        //addionalDetail.Name='AD-00331';
        addionalDetail.Onboarding_Request__c=onboard.Id;
        addionalDetail.EMS_EM_Education__c='Graduate';
        addionalDetail.EMS_EM_Education1__c='Graduate';
        addionalDetail.EMS_EM_Education2__c='Graduate';
        addionalDetail.EMS_EM_Education3__c='Graduate';
        addionalDetail.EMS_EM_Education4__c='Graduate';
        addionalDetail.EMS_EM_Education5__c='Graduate';
        addionalDetail.EMS_EM_IName__c='Manipal university';
         addionalDetail.EMS_EM_IName2__c='Manipal university';
         addionalDetail.EMS_EM_IName3__c='Manipal university';
         addionalDetail.EMS_EM_IName4__c='Manipal university';
         addionalDetail.EMS_EM_IName1__c='Manipal university';
         addionalDetail.EMS_EM_IName5__c='Manipal university';
        addList.add(addionalDetail);
       
        insert addList;
        
       

    }
   
}