@istest
public class Testclass_ResourceriseToHR {
    public TestMethod static void SendmailToHrTest(){
          EMS_LM_Leave__c   annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
        contact con=TestDataFactory.createResourceContact(True);
        list<Resource_Request__c> resourcelist=new list<Resource_Request__c>();
      Resource_Role__c role=  TestDataFactory.createResourceRole('Salesforce develpoer',True);
        Resource_Request__c resource =new Resource_Request__c();
        resource.Resource_Role1__c =role.Id;
        resource.Request_Priority__c='High';
       // resource.Skills__c='salesforce lightning';
       resource.Requested_By__c=con.Id;
        insert resource;
            resourcelist.add(resource);
        Test.startTest();
        ResourceriseToHR.SendmailToHr(resourcelist);
        Test.stopTest();
        
    }
}