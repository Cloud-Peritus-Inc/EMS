@isTest
public class ServiceReqSplLeavesDurationCalTest {
    
    static testMethod void testDurationCalculation() {
        String startDate = String.valueOf(Date.today().addDays(-7));           
        String endDate = String.valueOf(Date.today().addDays(7));
        String location = 'India';
        Boolean day = true;
        ServiceReqSplLeavesDurationCalculation.getMaternityLeaveDuration(startDate, endDate, location);
        System.assertEquals(7, 7, 'The days were wrong');
        ServiceReqSplLeavesDurationCalculation.getCompLeaveDuration(startDate, endDate, location, false);
    }
}