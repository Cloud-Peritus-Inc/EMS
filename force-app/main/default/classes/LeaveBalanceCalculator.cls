public class LeaveBalanceCalculator {
 public static Integer calculateLeaveBalance(Date joinDate) {
       Integer x = getMonthQuarter(joinDate);
       Integer leaveBalance = 0;
       if (joinDate.day() <= 15) {
           leaveBalance = (x/6)*5;
       } else {
           leaveBalance = (x/6)*5/2;
       }
       return leaveBalance;
   }

   private static Integer getMonthQuarter(Date date1) {
       Integer month = date1.month();
       if (month >= 1 && month <= 3) {
           return 6;
       } else if (month > = 4 && month <= 6) {
           return 5;
       } else if (month >= 7 && month <= 9) {
           return 4;
       } else {
           return 3;
       }
   }
}