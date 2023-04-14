@istest
public class EMS_EM_RequestViewFetch_Test {
   
    public static testmethod void testMethod1(){
        EMS_EM_Request__c req = new EMS_EM_Request__c();
        req.EMS_EM_Request_Type__c = 'Address Details';
        req.EMS_EM_CAddress_Line_1__c = 'Line1';
        req.EMS_EM_CAddress_Line_2__c = 'Line 2';
        req.EMS_EM_CA_City__c = 'Hyderabad';
        req.EMS_EM_CA_State__c = 'Telangana';
        req.EMS_EM_CA_Zip__c = '500082';
        insert req;
        EMS_EM_RequestViewFetch.getUserContactInfo(req.Id);
    }
}