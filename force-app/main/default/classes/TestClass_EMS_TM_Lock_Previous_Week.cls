@istest
public class TestClass_EMS_TM_Lock_Previous_Week {
        @testSetup
    public static void getAdminUser(){
              user adminuser = TestDataFactory.createAdminUser(false);
             adminuser.TA_Admin__c = true;
             adminuser.Timesheet_Admin__c =true;
             Insert adminuser;
        
    }
      public static testMethod void testschedule() {
            User adminUser = [Select Id From User Where firstname ='Alan' AND IsActive = true Limit 1];
		Test.StartTest();
        EMS_Timesheet__c emsts = new EMS_Timesheet__c();
        emsts.EMS_TM_Status__c='New';
        emsts.User__c=adminuser.id; 
        emsts.EMS_TM_Mon__c=8;
        emsts.EMS_TM_Tue__c=8;
        emsts.EMS_TM_Wed__c=8;
        emsts.EMS_TM_Thu__c=8;
        emsts.EMS_TM_Fri__c=8;
        emsts.EMS_TM_Sat__c=8;
        emsts.EMS_TM_Week__c=System.today()-5;
         emsts.Week_End_Date__c = System.today()-5;
        insert emsts;
          EMS_TM_Lock_Previous_Week batchExecute = new EMS_TM_Lock_Previous_Week(); 
        Database.executeBatch(batchExecute);
		Test.stopTest();
          EMS_Timesheet__c timesheetRec =[SELECT Id,EMS_TM_Status__c FROM EMS_Timesheet__c LIMIT 1];
          System.assertEquals('Locked', timesheetRec.EMS_TM_Status__c);
          
	}
    public static testMethod void testscheduleclass() {
		Test.StartTest();
		EMS_TM_Lock_Previous_Week_sch testsche = new EMS_TM_Lock_Previous_Week_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}

}