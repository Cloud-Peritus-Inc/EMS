@isTest
public class EMS_LM_LeaveBalanceTest {
  @istest
    public static void Leavebalancetest(){
        user testuser1;
        user testuser2;
         EMS_LM_Leave__c   annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
         EMS_LM_Leave__c    loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
         EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
         EMS_LM_Leave__c     compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
         EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
         EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
         EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
         EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
                  contact con=TestdataFactory.createResourceContact(true);
       

        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
           testuser1=Testdatafactory.createCommunityUserWithAccAndContact(con.Accountid,con.id,true);

        }
        EMS_LM_LeaveBalance.getLeaveBalance(testuser1.id);
       
        
        
        
}
}