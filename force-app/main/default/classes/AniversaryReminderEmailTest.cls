@istest
public class AniversaryReminderEmailTest {
    @istest
    public static void anniversaymailtest(){
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
         EMS_LM_Leave__c     wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        account acc=TestDataFactory.createAccount('Test cloud',True);
        contact con=TestDataFactory.createResourceContact(acc.Id,false);
        con.LastName= 'Test cloudn2';
        con.EMS_RM_Employee_Id__c='TST-0010';
        con.EMS_LM_No_Of_Maternity_Leaves_Credit__c = 0;
        con.EMS_LM_No_Of_Leaves_Credit__c = 10;
        con.EMS_EM_JD__c= System.today().addYears(-1);
        con.EMS_RM_ApplicantStatus_Update__c='Active';
        insert con;
        Test.startTest();
        AniversaryReminderEmail vop=new AniversaryReminderEmail();
        database.executeBatch(vop);
        Test.stopTest();
    }
      @istest
        public static void scduleingjobs(){
            Test.StartTest();
            AniversaryReminderEmail testsche = new AniversaryReminderEmail();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, testsche );
            Test.stopTest();
        }        
    }