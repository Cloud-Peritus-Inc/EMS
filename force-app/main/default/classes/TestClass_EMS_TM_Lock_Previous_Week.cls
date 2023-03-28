@istest
public class TestClass_EMS_TM_Lock_Previous_Week {
      public static testMethod void testschedule() {
		Test.StartTest();
        profile adminProfile=[SELECT Id, Name FROM Profile WHERE Name =:'System Administrator'];
        user us =new user();
        us.FirstName='Ram';
        us.LastName='kumar';
        us.Email='ramkumar@gmail.com';
        us.Username='ramkumar123@gmail.com.hxgdfvikhfdc';
        us.Alias='Rkumar'; 
        us.TimeZoneSidKey='America/Los_Angeles';
        us.LocaleSidKey='en_US'; 
        us.EmailEncodingKey='UTF-8'; 
        us.ProfileId=adminProfile.Id; 
        us.LanguageLocaleKey='en_US';
        insert us;
        EMS_Timesheet__c emsts = new EMS_Timesheet__c();
        emsts.EMS_TM_Status__c='	New';
        emsts.User__c=us.id; 
        emsts.EMS_TM_Mon__c=8;
        emsts.EMS_TM_Tue__c=8;
        emsts.EMS_TM_Wed__c=8;
        emsts.EMS_TM_Thu__c=8;
        emsts.EMS_TM_Fri__c=8;
        emsts.EMS_TM_Sat__c=8;
        emsts.EMS_TM_Week__c=date.newInstance(2022, 8, 26);
        insert emsts;
        String sch = '0 0 23 * * ?';
        EMS_TM_Lock_Previous_Week tsc = new EMS_TM_Lock_Previous_Week();
        system.schedule('Test status', sch, tsc );
		EMS_TM_Lock_Previous_Week testsche = new EMS_TM_Lock_Previous_Week();		
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}
    /*public static testmethod void GetTimeSheetDataTestMethod(){ 
         Date today = Date.today();
        EMS_Timesheet__c timesheet;
        insert timesheet;
    List<EMS_Timesheet__c> timesheetList = [SELECT Id, EMS_TM_Status__c, EMS_TM_Week__c
                                                FROM EMS_Timesheet__c
                                                WHERE EMS_TM_Week__c < :today
                                                AND EMS_TM_Status__c <> :EMS_TM_GlobalConstants.STATUS_SUBMITTED];
              
 Test.startTest();
        timesheet =  [SELECT Id, EMS_TM_Status__c, EMS_TM_Week__c
                                                FROM EMS_Timesheet__c
                                                WHERE EMS_TM_Week__c < :today
                                                AND EMS_TM_Status__c <> :EMS_TM_GlobalConstants.STATUS_SUBMITTED];

		TestClass_EMS_TM_Lock_Previous_Week.GetTimeSheetDataTestMethod();     
        Test.stopTest();
     system.assertEquals( timesheet.EMS_TM_Status__c, EMS_TM_GlobalConstants.STATUS_LOCKED); 
}*/
}