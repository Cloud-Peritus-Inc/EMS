@isTest
public class BatchToAssignTasksForOffboardingTest {
	public static testMethod void testscheduleclass(){
        Test.StartTest();
        BatchToAssignTasksForOffboarding_Sch testsche = new BatchToAssignTasksForOffboarding_Sch();
        String sch = '0 0 23 * * ?';
        system.schedule('Test to create offboarding tasks', sch, testsche );
        Test.stopTest();
    }
    public static testMethod void testBatchclass() {
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        //Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true); 
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c officlocRec2 =TestDataFactory.createOfficeLocation('California - USA',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.LastName='Lokesh';
        con.Work_Location__c = officlocRec.Id;
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        con.EMS_EM_JD__c = system.today();
        con.EMS_TM_User__c = UserInfo.getUserId();
        insert con;
        
        Off_boarding_Request__c offboardingRec = new Off_boarding_Request__c();
        offboardingRec.Status__c = 'Approved';
        offboardingRec.Resource__c = con.id;
        offboardingRec.Reason_For_Offboarding__c = 'Resignation';
        insert offboardingRec;
        
        Test.startTest();
        BatchToAssignTasksForOffboarding batchExecute = new BatchToAssignTasksForOffboarding(); 
        Database.executeBatch(batchExecute,10);
        Test.stopTest();
    }
}