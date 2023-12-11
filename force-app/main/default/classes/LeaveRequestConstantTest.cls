@isTest
public class LeaveRequestConstantTest {
    
    @isTest
    static void testLeaveRequestConstants() {
        // Test that constants are not null
        System.assertNotEquals(null, LeaveRequestConstant.LOGGEDIN_USERID);
        System.assertNotEquals(null, LeaveRequestConstant.APPROVER_2_WAITING);
        System.assertNotEquals(null, LeaveRequestConstant.APPROVER_3_WAITING);
        System.assertNotEquals(null, LeaveRequestConstant.APPROVER_4_WAITING);
        System.assertNotEquals(null, LeaveRequestConstant.APPROVED);
        System.assertNotEquals(null, LeaveRequestConstant.PENDING);
        System.assertNotEquals(null, LeaveRequestConstant.CANCELLED);
        System.assertNotEquals(null, LeaveRequestConstant.REJECTED);
        System.assertNotEquals(null, LeaveRequestConstant.WORK_FROM_HOME);
        System.assertNotEquals(null, LeaveRequestConstant.AUTO_APPROVED);
        System.assertNotEquals(null, LeaveRequestConstant.LOSS_OF_PAY);
        System.assertNotEquals(null, LeaveRequestConstant.ANNUAL_LEAVE);
        System.assertNotEquals(null, LeaveRequestConstant.COMPENSATORY_OFF);
        System.assertNotEquals(null, LeaveRequestConstant.MATERNITY_LEAVE);
        System.assertNotEquals(null, LeaveRequestConstant.PAID_TIMEOFF);
        System.assertNotEquals(null, LeaveRequestConstant.UNPAID_TIMEOFF);
    }
}