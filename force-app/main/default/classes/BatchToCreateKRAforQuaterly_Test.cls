/**
* @author Mukesh Rawat 
* @date 29/02/2024
* @description  Test class for BatchToCreateKRAforQuaterly
BatchToCreateKRAforQuaterly_Sch

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class BatchToCreateKRAforQuaterly_Test {
    public static testMethod void testscheduleclass() {
        Test.StartTest();
        BatchToCreateKRAforQuaterly_Sch testsche = new BatchToCreateKRAforQuaterly_Sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test Batch To Create KRA for Quaterly', sch, testsche );
        Test.stopTest();
    }
    public static testMethod void testBatchclassForBatchToCreateKRAforQuaterly() {
        EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,true);
        u.Username='test005@admin.com';
        //Insert u;
        User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,false);
        u1.Username='test001@admin.com';
        //Insert u1;
        
        Fiscal_Year__c fy = Testdatafactory.createFiscalYear(true);
        //Fulfillment__c fulList = Testdatafactory.createFulfillment(con.Id, true);
        Test.startTest();
        BatchToCreateKRAforQuaterly batchExecute = new BatchToCreateKRAforQuaterly(); 
             Database.executeBatch(batchExecute,10);
        Test.stopTest();
    }
    
    
}