@isTest(seeAllData=True)
public class TestClass_EMS_TM_TimesheetClass {
		
    public static TestMethod void TestingGetAssignmentProject(){
        User us = [select Id, Name, ContactId From User where ContactId!=null and profile.Name='TM Customer Community' and isActive=True Limit 1];
        //Id profileId = [select Id from Profile where profile.Name='TM Customer Community'].Id;
        /*Contact con =new Contact();
        con.FirstName = 'Kamble';
        con.lastname='Sangharsh';
        con.Location__c='India';
        con.EMS_Phone_Number__c = '9504851467';
        insert con;
        
        user us =new user();
        us.FirstName=con.FirstName;
        us.LastName=con.LastName;
        us.Email='ramkumar@gmail.com';
        us.Username='ramkumar123@gmail.com';
        us.Alias='Rkumar'; 
        us.TimeZoneSidKey='America/Los_Angeles';
        us.LocaleSidKey='en_US'; 
        us.EmailEncodingKey='UTF-8'; 
        us.ProfileId = profileId; 
        us.LanguageLocaleKey='en_US';
        us.ContactId=con.Id;
		insert us;*/
        
        list<EMS_TM_Timesheet_Record__c> timesheetRecordList =New list<EMS_TM_Timesheet_Record__c>();
        list<EMS_TM_Timesheet_Record__c> timesheetRecordLists =New list<EMS_TM_Timesheet_Record__c>();
        Date week = date.today();
       
        EMS_TM_Project__c project =New EMS_TM_Project__c();
        project.EMS_TM_StartDate__c=date.newInstance(2023, 1, 1);
        project.EMS_TM_EndDate__c=date.newInstance(2023, 10, 28);
        insert project;
        
                    
        EMS_TM_Assignment__c assignment =New EMS_TM_Assignment__c();
      //  assignment.Name='testone';
        assignment.EMS_TM_StartDate_Asgn__c=date.newInstance(2023, 1, 1);
        assignment.EMS_TM_EndDate_Asgn__c=date.newInstance(2023, 9, 2);
        assignment.EMS_TM_ProjectName_Asgn__c=project.id;
        assignment.EMS_TM_EmployeeName__c =us.ContactId;
        
        EMS_Timesheet__c emstimesheet = new EMS_Timesheet__c();
        emstimesheet.EMS_TM_Status__c='Completed';
        emstimesheet.User__c=us.id; 
        emstimesheet.EMS_TM_Mon__c=8;
        emstimesheet.EMS_TM_Tue__c=8;
        emstimesheet.EMS_TM_Wed__c=8;
        emstimesheet.EMS_TM_Thu__c=8;
        emstimesheet.EMS_TM_Fri__c=8;
        emstimesheet.EMS_TM_Sat__c=8;
        emstimesheet.EMS_TM_Week__c=date.newInstance(2023, 1, 6);
        
        EMS_TM_Timesheet_Record__c timesheetrecord =New EMS_TM_Timesheet_Record__c();
        timesheetrecord.EMS_TM_Mon__c=8;
        timesheetrecord.EMS_TM_Tue__c=8;
        timesheetrecord.EMS_TM_Wed__c=8;
        timesheetrecord.EMS_TM_Thu__c=8;
        timesheetrecord.EMS_TM_Fri__c=8;
        timesheetrecord.EMS_TM_Project__c = project.id;
        timesheetrecord.EMS_Timesheet__c=emstimesheet.id;
        
        EMS_TM_Timesheet_Record__c timesheetrecords =New EMS_TM_Timesheet_Record__c();
        timesheetrecords.EMS_TM_Mon__c=8;
        timesheetrecords.EMS_TM_Tue__c=8;
        timesheetrecords.EMS_TM_Wed__c=8;
        timesheetrecords.EMS_TM_Thu__c=8;
        timesheetrecords.EMS_TM_Fri__c=8;
        timesheetrecords.EMS_TM_Project__c = project.id;
        timesheetrecords.EMS_Timesheet__c=emstimesheet.id;
        timesheetRecordLists.add(timesheetrecords);         
        Test.startTest();
        insert assignment;
        insert emstimesheet; 
        insert timesheetrecord;
        insert timesheetRecordLists;
        EMS_TM_TimesheetClass.getAssignmentProjectWire(week,true,us.Id);
        EMS_TM_TimesheetClass.getAssignmentProject(week,true,us.Id);
        EMS_TM_TimesheetClass.getAssignmentProject(week,false,us.Id);
        EMS_TM_TimesheetClass.saveTimeSheetRecords(timesheetRecordList,emstimesheet);
        EMS_TM_TimesheetClass.renderTimeRecord(timesheetrecords,emstimesheet,emstimesheet.id);
        EMS_TM_TimesheetClass.updateTimeSheetRecords(timesheetRecordList,timesheetRecordList,timesheetRecordLists,emstimesheet);
        Test.stopTest();
    }
    
   /* public static TestMethod void TestingGetTimeSheetData(){
        EMS_TM_Timesheet_Record__c timesheetRecord =new EMS_TM_Timesheet_Record__c();
        timesheetRecord.EMS_TM_Week__c=date.newInstance(2022, 8, 15);
        timesheetRecord.User__c='0053C000004dSn8QAE';
        
        Test.startTest();
        insert timesheetRecord;
        EMS_TM_TimesheetClass.getTimeSheetData(timesheetRecord.EMS_TM_Week__c,timesheetRecord.User__c );
        Test.stopTest();
    }*/
    
    public static TestMethod void TestingGetPreWeekData(){
        User us = [select Id, Name, ContactId From User where ContactId!=null and profile.Name='TM Customer Community' and isActive=True Limit 1];
        Id profileId = [select Id from User where profile.Name='TM Customer Community' and isActive=TRUE Limit 1].Id;        
        EMS_Timesheet__c emstimesheet = new EMS_Timesheet__c();
         EMS_TM_Project__c project =New EMS_TM_Project__c();
        project.EMS_TM_StartDate__c=date.newInstance(2023, 1, 1);
        project.EMS_TM_EndDate__c=date.newInstance(2023, 10, 28);
        insert project;    
        EMS_TM_Assignment__c assignment =New EMS_TM_Assignment__c();
      //  assignment.Name='testone';
        assignment.EMS_TM_StartDate_Asgn__c=date.newInstance(2023, 1, 1);
        assignment.EMS_TM_EndDate_Asgn__c=date.newInstance(2023, 10, 28);
        assignment.EMS_TM_ProjectName_Asgn__c=project.id;
        assignment.EMS_TM_EmployeeName__c =us.ContactId;
        emstimesheet.EMS_TM_Status__c='Completed';
        emstimesheet.User__c=profileId; 
        emstimesheet.EMS_TM_Mon__c=8;
        emstimesheet.EMS_TM_Tue__c=8;
        emstimesheet.EMS_TM_Wed__c=8;
        emstimesheet.EMS_TM_Thu__c=8;
        emstimesheet.EMS_TM_Fri__c=8;
        emstimesheet.EMS_TM_Sat__c=8;
        emstimesheet.EMS_TM_Sun__c=8;
        emstimesheet.EMS_TM_Week__c=date.newInstance(2023, 1, 6);
        insert emstimesheet;
        EMS_Timesheet__c emstimesheet1 = new EMS_Timesheet__c();
        emstimesheet1.EMS_TM_Status__c='Completed';
        emstimesheet1.User__c=profileId; 
        emstimesheet1.EMS_TM_Mon__c=7;
        emstimesheet1.EMS_TM_Tue__c=7;
        emstimesheet1.EMS_TM_Wed__c=7;
        emstimesheet1.EMS_TM_Thu__c=7;
        emstimesheet1.EMS_TM_Fri__c=7;
        emstimesheet1.EMS_TM_Week__c=date.newInstance(2022, 12, 30);
        insert emstimesheet1;
        EMS_Timesheet__c emstimesheet2 = new EMS_Timesheet__c();
        emstimesheet2.EMS_TM_Status__c='Completed';
        emstimesheet2.User__c=profileId; 
        emstimesheet2.EMS_TM_Mon__c=9;
        emstimesheet2.EMS_TM_Tue__c=9;
        emstimesheet2.EMS_TM_Wed__c=9;
        emstimesheet2.EMS_TM_Thu__c=9;
        emstimesheet2.EMS_TM_Fri__c=9;
        emstimesheet2.EMS_TM_Week__c=date.newInstance(2023, 1, 6);
        insert emstimesheet2;
       
        EMS_TM_Timesheet_Record__c timesheetRecord =new EMS_TM_Timesheet_Record__c();
        timesheetRecord.EMS_TM_Week__c=date.newInstance(2023, 1, 10);
        timesheetRecord.User__c=profileId;   
        timesheetRecord.EMS_Timesheet__c=emstimesheet.id;
        timesheetrecord.EMS_TM_Project__c = project.id;
        
        EMS_TM_Timesheet_Record__c timesheetRecord1 =new EMS_TM_Timesheet_Record__c();
        timesheetRecord1.EMS_TM_Week__c=date.newInstance(2022, 12, 15);
        timesheetRecord1.User__c=profileId;   
        timesheetRecord1.EMS_Timesheet__c=emstimesheet1.id;
        
        EMS_TM_Timesheet_Record__c timesheetRecord2 =new EMS_TM_Timesheet_Record__c();
        timesheetRecord2.EMS_TM_Week__c=date.newInstance(2022, 2, 15);
        timesheetRecord2.User__c=profileId;   
        timesheetRecord2.EMS_Timesheet__c=emstimesheet2.id;
        
        Test.startTest();
        insert timesheetRecord;
        EMS_TM_TimesheetClass.getTimeSheetData(timesheetRecord.EMS_TM_Week__c,timesheetRecord.User__c );   
        EMS_TM_TimesheetClass.getTimeSheetData(timesheetRecord1.EMS_TM_Week__c,timesheetRecord1.User__c ); 
        EMS_TM_TimesheetClass.getTimeSheetData(timesheetRecord2.EMS_TM_Week__c,timesheetRecord2.User__c ); 
        EMS_TM_TimesheetClass.getPreWeekData(emstimesheet);
        EMS_TM_TimesheetClass.duplicatetimesheetLWC(emstimesheet);
        /*EMS_TM_TimesheetClass.underWorkingHourDays(emstimesheet);
        EMS_TM_TimesheetClass.underWorkingHourDays(emstimesheet1);
        EMS_TM_TimesheetClass.underWorkingHourDays(emstimesheet2);*/
        EMS_TM_TimesheetClass.renderTimeSheet(emstimesheet);
        EMS_TM_TimesheetClass.reviseTimesheet(emstimesheet);
        Test.stopTest();
    }
}