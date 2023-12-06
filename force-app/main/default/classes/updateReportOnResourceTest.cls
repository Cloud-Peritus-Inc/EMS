@isTest
public class updateReportOnResourceTest {
  
    public testmethod static void insertingNewRRRShouldPopulateContact(){
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
          EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
               EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
               EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Account newacc = new Account();
        newacc.Name = 'CP TEST';
        insert newacc;
        
        List<Contact> conList = new List<Contact>();
        Contact con1 = new Contact();
        con1.AccountId = newacc.Id;
        con1.EMS_TM_User__c = userinfo.getUserId();
        con1.FirstName = 'Test Emp';
        con1.LastName = 'Test Emp';
        con1.Email = 'Test@TestEmail.com';
        con1.RecordTypeId = contactConstant.RESOURCE_RECORDTYPEID;
        con1.EMS_Phone_Number__c = '1234567895';
        conList.add(con1); 
        
        Contact con2 = new Contact();
        con2.RecordTypeId = contactConstant.RESOURCE_RECORDTYPEID;
        con2.AccountId = newacc.Id;
        con2.EMS_TM_User__c = userinfo.getUserId();
        con2.FirstName = 'Test Manager';
        con2.LastName = 'Test Manager';
        con2.Email = 'TestManager@TestEmail.com';
        con2.EMS_Phone_Number__c = '1234560895';
        conList.add(con2); 
       
        insert conList;
      Resource_Resource_Relationship__c rrr = new Resource_Resource_Relationship__c();
      rrr.Resource__c = con1.Id;
      rrr.Resource_Reports_To__c = con2.Id;
      insert rrr;
      system.assertEquals(con2.Id, [SELECT ReportsToId FROM Contact WHERE Id=:con1.Id ].ReportsToId, 'Not Updated as expected');
    } 

}