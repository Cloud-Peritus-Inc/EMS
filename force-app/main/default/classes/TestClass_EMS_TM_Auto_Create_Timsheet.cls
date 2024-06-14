@istest
public class TestClass_EMS_TM_Auto_Create_Timsheet {
    public static testMethod  void TestClass_EMS_TM_CreateMethod(){
        /*profile adminProfile=[SELECT Id, Name FROM Profile WHERE Name =:'System Administrator'];
         user us =new user();
        us.FirstName='Ram';
        us.LastName='kumar';
        us.Email='ramkumar@gmail.com';
        us.Username='ramkumar123@gmail.com';
        us.Alias='Rkumar'; 
        us.TimeZoneSidKey='America/Los_Angeles';
        us.LocaleSidKey='en_US'; 
        us.EmailEncodingKey='UTF-8'; 
        us.ProfileId=adminProfile.Id; 
        us.LanguageLocaleKey='en_US';
        
        insert us;
        
        EMS_Timesheet__c emstimesheet = new EMS_Timesheet__c();
        emstimesheet.EMS_TM_Status__c='	New';
        emstimesheet.User__c=us.id; 
        emstimesheet.EMS_TM_Mon__c=8;
        emstimesheet.EMS_TM_Tue__c=8;
        emstimesheet.EMS_TM_Wed__c=8;
        emstimesheet.EMS_TM_Thu__c=8;
        emstimesheet.EMS_TM_Fri__c=8;
        emstimesheet.EMS_TM_Sat__c=8;
        emstimesheet.EMS_TM_Week__c=date.newInstance(2022, 8, 26);
         
        insert emstimesheet;
        
        Date today = Date.today();
        Date weekStart = today.toStartofWeek().addDays(1);
        Date weekEnd = today.toStartofWeek().addDays(7);
        String completeWeek = weekStart + ' - ' + weekEnd;*/
        Test.StartTest();
        String sch = '0 0 23 * * ?';
        system.schedule('Test check', sch, new EMS_TM_Auto_Create_Timsheet());
        Test.StopTest();
        
        
    }
}