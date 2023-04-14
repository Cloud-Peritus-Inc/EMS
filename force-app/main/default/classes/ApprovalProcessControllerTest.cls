@isTest
public class ApprovalProcessControllerTest {
    @isTest
    public static void recallApprovalTest(){
        
        Account acc = new Account();
        acc.Name ='rama';
        acc.Phone='96529015';
        //  acc.IsCustomerPortal = true;
        insert acc;
        System.debug('acc'+acc);
        Contact con = new contact();
        con.Email ='ramakrishna@gmail.com';
        con.AccountId = acc.id;
        con.FirstName ='rama111';
        con.LastName ='krishna11';
        con.EMS_Phone_Number__c ='965210752';
        con.EMS_EM_Mstatus__c  = 'Single';
        con.EMS_EM_JD__c = System.today();
        con.RecordTypeId = [SELECT Id FROM RecordType where name = 'Resource'].Id;
        insert con;
        
        EMS_EM_Request__c req1 = new EMS_EM_Request__c();
        req1.Contact__c = con.id;
        req1.EMS_EM_Request_Type__c = 'Bank Details';
        req1.Account_Number__c = '123456789456';
        req1.IFSC_Code__c = 'ABCD1234567';
        req1.Account_Holder_Name__c = 'Mukesh';
        req1.Bank_Name__c='Axis Bank Ltd.';
        insert req1;
        
        EMS_EM_Request__c req2 = new EMS_EM_Request__c();
        req1.Contact__c = con.id;
        req1.EMS_EM_Request_Type__c = 'Bank Details2';
        req1.Account_Number__c = '1234567894546';
        req1.IFSC_Code__c = 'ABCD12345667';
        req1.Account_Holder_Name__c = 'Mukesh2';
        req1.Bank_Name__c='Axis Bank Ltd.';
        insert req2;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(req2.id);
        Approval.ProcessResult result = Approval.process(app);
        ApprovalProcessController.recallApproval(req2.id);
        
    }
}