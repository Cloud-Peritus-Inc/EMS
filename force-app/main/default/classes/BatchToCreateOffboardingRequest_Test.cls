@isTest
public class BatchToCreateOffboardingRequest_Test {
    
    public static testMethod void testscheduleclass() {
        
        Test.StartTest();
        BatchToCreateOffboardingRequest_sch testsche = new BatchToCreateOffboardingRequest_sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test BatchToCreateOffboardingRequest', sch, testsche );
        Test.stopTest();
    }
    public testMethod static void testBatchclass() {
        
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        Date dt = system.today().adddays(-1);
        Date dt1 = system.today().adddays(1);
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        role.Notice_Consider_Days__c = 15;
        insert role;
        // Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.Work_Location__c =officlocRec.Id;
        INSERT con;
        Case caseRec = TestDataFactory.createCaseWithAccAndContact(acc.id,con.id,'Resignation','Offboarding','Resignation','desc',false);
        caseRec.Status = 'Resignation Approved';	
        caseRec.Last_Working_Date__c = dt1;
        insert caseRec;
        System.debug('***caseData'+[Select id,Last_Working_Date__c,Status,type from Case]);
        
        Test.startTest();
        
        BatchToCreateOffboardingRequest batchExecute = new  BatchToCreateOffboardingRequest(); 
        Database.executeBatch(batchExecute,10);
        
        Test.stopTest();
        
        
    }
}