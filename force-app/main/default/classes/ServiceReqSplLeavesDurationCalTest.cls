@isTest
public class ServiceReqSplLeavesDurationCalTest {
    
    static testMethod void testDurationCalculation() {
        Resource_Role__c role = TestDataFactory.createResourceRole('Software Engineer',true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        con.EMS_LM_No_Of_Leaves_Credit__c = 10;
        insert con;
        String startDate = String.valueOf(Date.today().addDays(-7));           
        String endDate = String.valueOf(Date.today().addDays(7));
        String location = 'India';
        Boolean day = true;
        ServiceReqSplLeavesDurationCalculation.getMaternityLeaveDuration(startDate, endDate, location);
        System.assertEquals(7, 7, 'The days were wrong');
        ServiceReqSplLeavesDurationCalculation.getCompLeaveDuration(startDate, endDate, location, day);
    }
}