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
    public static testMethod void testscheduleclass2() {
        Test.StartTest();
        BatchToCreateKRAforQuaterly2_Sch testsche = new BatchToCreateKRAforQuaterly2_Sch();
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

        
        Office_Location__c INDIAoffice = new Office_Location__c(); 
        INDIAoffice.Name = 'Hyderabad - India';
        INDIAoffice.Address__c = '4th floor plot no, 703/A, Rd Number 36, Aditya Enclave, Venkatagiri, Jubilee Hills, Hyderabad, Telangana 500033';
        INDIAoffice.Country__c = 'India';
        insert INDIAoffice;
        
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        con.Work_Location__c = INDIAoffice.Id;
        insert con;
        
        //smaske :
        Office_Location__c USAoffice = new Office_Location__c(); 
        USAoffice.Name = 'California - USA';
        USAoffice.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA	';
        USAoffice.Country__c = 'United States of America';
        insert USAoffice;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        con1.EMS_RM_ApplicantStatus_Update__c = 'Active';
        con1.Work_Location__c = USAoffice.Id;
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
        
        con.EMS_TM_User__c = u.Id;
        update con;
        
        Resource_Resource_Relationship__c resourceRelationship2 = new Resource_Resource_Relationship__c();
        resourceRelationship2.Resource__c = con1.Id;
        resourceRelationship2.Resource_Reports_To__c=con.Id;
        resourceRelationship2.Relationship_Type__c = 'Mentor';
        insert resourceRelationship2;
        
        con1.EMS_TM_User__c = u.Id;
        update con1;
        System.debug('Final Contact ::' + con);
        
        Test.startTest();
        BatchToCreateKRAforQuaterly batchExecute = new BatchToCreateKRAforQuaterly(); 
             Database.executeBatch(batchExecute,10);
        BatchToCreateKRAforQuaterly2 batchExecute2 = new BatchToCreateKRAforQuaterly2(); 
             Database.executeBatch(batchExecute2,10);
        Test.stopTest();
    }
    
    
}