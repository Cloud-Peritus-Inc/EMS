/**
* @author Suneel & RK
* @date 3/17/2023
* @description  Test class for EMS_TM_TimesheetClass.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

@isTest
public class TestClass_EMS_TM_TimesheetClass {
    /*  @testSetup
public static void getAdminUser(){
user adminuser = TestDataFactory.createAdminUser(true);
adminuser.Manager_Access__c = true;
adminuser.TA_Admin__c = true;
adminuser.IT_Admin_Access__c = true;
UPDATE adminuser;



public static TestMethod void TestingGetAssignmentProject(){
user adminuser = TestDataFactory.createAdminUser(true);
adminuser.Manager_Access__c = true;
adminuser.TA_Admin__c = true;
adminuser.IT_Admin_Access__c = true;
UPDATE adminuser;
System.runAs(adminuser){
Date todayval = system.today(); 
Date considerDate = todayval.toStartofWeek().addDays(-2);
Date weekStart = considerDate.toStartofWeek().addDays(1);
Date weekEnd = considerDate.toStartofWeek().addDays(7);
user userId =[SELECT id FROM User WHERE IsActive = true AND Hr_Access__c=True LIMIT 1];

Resource_Role__c role = TestDataFactory.createResourceRole(false);
role.Name ='Sr Project Manager';
INSERT role;

Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
EMS_LM_Leave__c paidtimeoff=TestDataFactory.createLeaveType('Paid time off',true);
List<EMS_TM_Calendar__c> holidayList = new List<EMS_TM_Calendar__c>();
EMS_TM_Calendar__c holiday = new EMS_TM_Calendar__c();
holiday.EMS_TM_Calendar_Date__c = System.today();
holiday.Office_Location__c =officlocRec.Id;
holiday.Location__c ='Usa';
holiday.Name ='fff';
holiday.EMS_TM_Type_Of_Holiday__c ='National';
holidayList.add(holiday);
EMS_TM_Calendar__c holiday1 = new EMS_TM_Calendar__c();
holiday1.EMS_TM_Calendar_Date__c = System.today()+1;
holiday1.Office_Location__c =officlocRec.Id;
holiday1.Location__c ='Usa';
holiday1.Name ='fff';
holiday1.EMS_TM_Type_Of_Holiday__c ='National';
holidayList.add(holiday1);
INSERT holiday1;
Account acc = TestDataFactory.createAccount(true);
Contact con=  TestDataFactory.createResourceContact(acc.id, false);
con.EMS_RM_Employee_Id__c = 'CP10235';
con.EMS_RM_ApplicantStatus_Update__c ='Active';
con.EMS_Phone_Number__c ='0123456789';
con.EMS_EM_CAddress_Line_1__c ='Hyd';
con.EMS_EM_CA_City__c ='Hyd';
con.EMS_EM_CA_State__c ='AP';
con.Email ='rk@rk.com';
con.Work_Location__c = officlocRec.Id;
con.Timesheet_NoNeed__c =false;
//con.Resource_Role__c = role.Id;
con.EMS_TM_User__c =userId.Id;
con.EMS_LM_No_Of_Leaves_Credit__c = 10;
INSERT con;
EMS_LM_Leave_History__c leaveRec = new EMS_LM_Leave_History__c();
leaveRec.EMS_LM_Leave_Type__c = annualtype.Id;
leaveRec.EMS_LM_Contact__c = con.Id;
leaveRec.EMS_LM_Status__c ='Approved';
leaveRec.EMS_LM_Leave_Start_Date__c = System.today();
leaveRec.EMS_LM_Leave_End_Date__c =System.today()+1;
INSERT leaveRec;
EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
projectRec.EMS_TM_StartDate__c = System.today();
projectRec.EMS_TM_EndDate__c = System.today()+10;
projectRec.EMS_TM_Status__c = 'ongoing';
projectRec.Name = 'project1';
projectRec.Project_Manager__c = con.Id;
projectRec.Type_Of_Project__c ='Client Projects';
INSERT projectRec;        
System.debug('ProjectREC'+projectRec);
EMS_TM_Assignment__c assignmentRec;

assignmentRec = new EMS_TM_Assignment__c();
assignmentRec.EMS_TM_EmployeeName__c = con.Id;
assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
assignmentRec.EMS_TM_EndDate_Asgn__c = system.today()+3;
assignmentRec.EMS_TM_Status_Asgn__c ='Active';
assignmentRec.EMS_TM_Billable__c = true;
assignmentRec.EMS_TM_AssignedAs__c='Administrator';
assignmentRec.Project_Allocation__c=1;
INSERT assignmentRec;
}
system.runAs(adminuser){
EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
timesheetRec.Week_Start_Date__c = System.today();
timesheetRec.Week_End_Date__c = System.today()+6;
timesheetRec.Resource__c = con.Id;
timesheetRec.User__c = userId.id;
timesheetRec.EMS_TM_Sat__c = 0;
timesheetRec.EMS_TM_Sun__c =0;
timesheetRec.OwnerId =userId.id;
timesheetRec.EMS_TM_Status__c='Submitted';
timesheetRec.Week_Start_Date__c = weekStart;
timesheetRec.Week_End_Date__c = weekEnd;
timesheetRec.EMS_TM_Week__c = System.today();
INSERT timesheetRec;
EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
lineitem.EMS_Timesheet__c = timesheetRec.Id;
lineitem.OwnerId = userId.id;
lineitem.Assignment__c = assignmentRec.Id;
lineitem.EMS_TM_Project__c = assignmentRec.EMS_TM_ProjectName_Asgn__c;
lineitem.EMS_TM_Thu__c = 0;
lineitem.EMS_TM_Fri__c = 0;
lineitem.Status__c = 'Submitted';
INSERT lineitem;
List<EMS_TM_Timesheet_Record__c> lineitemlist = new List<EMS_TM_Timesheet_Record__c>();
EMS_TM_Timesheet_Record__c lineitem1 = new EMS_TM_Timesheet_Record__c();
lineitem1.EMS_Timesheet__c = timesheetRec.Id;
lineitem1.OwnerId = timesheetRec.User__c;
lineitem1.Assignment__c = assignmentRec.Id;
lineitem1.EMS_TM_Project__c = assignmentRec.EMS_TM_ProjectName_Asgn__c;
lineitem1.EMS_TM_Thu__c = 0;
lineitem1.EMS_TM_Fri__c = 0;
lineitem1.Status__c = 'Saved';
lineitemlist.add(lineitem1);
List<EMS_TM_Timesheet_Record__c> lineitemlis1 = new List<EMS_TM_Timesheet_Record__c>();
List<EMS_TM_Timesheet_Record__c> lineitemlist2 = new List<EMS_TM_Timesheet_Record__c>();
test.startTest();
EMS_TM_TimesheetClass.getAssignmentProjectWire(weekStart,true,userId.Id);
//  EMS_TM_TimesheetClass.getPreWeekData(timesheetRec);
EMS_TM_TimesheetClass.duplicatetimesheetLWC(timesheetRec);
EMS_TM_TimesheetClass.renderTimeSheet(timesheetRec);
EMS_TM_TimesheetClass.renderTimeRecord(lineitem,timesheetRec,timesheetRec.Id);
EMS_TM_TimesheetClass.reviseTimesheet(timesheetRec);
EMS_TM_TimesheetClass.getTimesheetHours();
EMS_TM_TimesheetClass.saveTimeSheetRecords(lineitemlist,timesheetRec);
EMS_TM_TimesheetClass.updateTimeSheetRecords(lineitemlis1,lineitemlist,lineitemlist2,timesheetRec);
EMS_TM_TimesheetClass.returnProjectTypemap();
EMS_TM_TimesheetClass.returnProjectTasks();
test.stopTest();
}
}*/
    @testSetup static void methodName(){
        
        Profile pf= [Select Id from profile where Name='System Administrator']; 
        UserRole obj=new UserRole(Name= 'ABC'); 
        insert obj; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        
        User user=new User(firstname = 'ABC', 
                           lastName = 'XYZ', 
                           email = uniqueName + '@test' + orgId + '.org', 
                           Username = uniqueName + '@test' + orgId + '.org', 
                           EmailEncodingKey = 'ISO-8859-1', 
                           Alias = uniqueName.substring(18, 23), 
                           TimeZoneSidKey = 'America/Los_Angeles', 
                           LocaleSidKey = 'en_US', 
                           LanguageLocaleKey = 'en_US', 
                           ProfileId = pf.Id, 
                           UserRoleId = obj.Id,Hr_Access__c =true,Manager_Access__c=True); 
        insert user;
        system.runAs(user){ 
            EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
            EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
            EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
            EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
            EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
            EMS_LM_Leave__c paidtimeoff=TestDataFactory.createLeaveType('Paid time off',true);
            Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
            
            Date todayval = system.today(); 
            Date considerDate = todayval.toStartofWeek().addDays(-2);
            Date weekStart = considerDate.toStartofWeek().addDays(1);
            Date weekEnd = considerDate.toStartofWeek().addDays(7);
            
            EMS_TM_Calendar__c holCalendar = new EMS_TM_Calendar__c();
            holCalendar.Name = 'Christmas';
            holCalendar.EMS_TM_Calendar_Date__c = weekEnd;
            holCalendar.EMS_TM_Type_Of_Holiday__c = 'Regional';
            holCalendar.Office_Location__c = officlocRec.Id;
            holCalendar.Location__c = 'India';
            Insert holCalendar;
            
            Account acc = TestDataFactory.createAccount(true);
            Contact con=  TestDataFactory.createResourceContact(acc.id, false);
            con.EMS_RM_Employee_Id__c = 'CP10235';
            con.EMS_RM_ApplicantStatus_Update__c ='Active';
            con.EMS_Phone_Number__c ='0123456789';
            con.EMS_EM_CAddress_Line_1__c ='Hyd';
            con.EMS_EM_CA_City__c ='Hyd';
            con.EMS_EM_CA_State__c ='AP';
            con.Email ='rk@rk.com';
            con.Work_Location__c = officlocRec.Id;
            con.Timesheet_NoNeed__c =false;
            //con.Resource_Role__c = role.Id;
            con.EMS_TM_User__c =user.Id;
            con.EMS_LM_No_Of_Leaves_Credit__c = 10;
            INSERT con;
            
            System.debug(' con user ' +  con.EMS_TM_User__c);
            System.debug(' User ContactId ' +  user.ContactId);
            
            EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
            projectRec.EMS_TM_StartDate__c = System.today();
            projectRec.EMS_TM_EndDate__c = System.today()+10;
            projectRec.EMS_TM_Status__c = 'Ongoing';
            projectRec.Name = 'project1';
            projectRec.Project_Manager__c = con.Id;
            projectRec.Offshore_Project_Manager__c = con.Id;
            projectRec.Type_Of_Project__c ='Client Projects';
            INSERT projectRec;        
            System.debug('ProjectREC'+projectRec);
            
            //smaske: Updating Test data for creating Task records assocaited with a Project
            List<Project_Task__c> taskListToCreate = new List<Project_Task__c>();
            Project_Task__c Task1 = new Project_Task__c();
            Task1.Name = 'Development';
            Task1.Project_Name__c = projectRec.Id;
            Project_Task__c Task2 = new Project_Task__c();
            Task2.Name = 'Integration';
            Task2.Project_Name__c = projectRec.Id;
            taskListToCreate.add(Task1);
            taskListToCreate.add(Task2);
            INSERT taskListToCreate;
                        
            
            EMS_TM_Assignment__c assignmentRec;
            assignmentRec = new EMS_TM_Assignment__c();
            assignmentRec.EMS_TM_EmployeeName__c = con.Id;
            assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
            assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
            assignmentRec.EMS_TM_EndDate_Asgn__c = system.today()+3;
            assignmentRec.EMS_TM_Status_Asgn__c ='Active';
            assignmentRec.EMS_TM_Billable__c = true;
            assignmentRec.EMS_TM_AssignedAs__c='Administrator';
            assignmentRec.Project_Allocation__c=1;
            INSERT assignmentRec;
            
             EMS_TM_Assignment__c assignmentRec2;
            assignmentRec2 = new EMS_TM_Assignment__c();
            assignmentRec2.EMS_TM_EmployeeName__c = con.Id;
            assignmentRec2.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
            assignmentRec2.EMS_TM_StartDate_Asgn__c = system.today();
            assignmentRec2.EMS_TM_EndDate_Asgn__c = null;
            assignmentRec2.EMS_TM_Status_Asgn__c ='Active';
            assignmentRec2.EMS_TM_Billable__c = true;
            assignmentRec2.EMS_TM_AssignedAs__c='Administrator';
            assignmentRec2.Project_Allocation__c=1;
            INSERT assignmentRec2;
            
            //Creating leave request
            EMS_LM_Leave_Credit__c LeaveData = new EMS_LM_Leave_Credit__c();
            LeaveData.EMS_LM_Employee__c  = con.Id;
            LeaveData.EMS_LM_Leave_Type__c = annualtype.Id;
            LeaveData.EMS_LM_Leaves_Credited__c = 5.0;
            LeaveData.EMS_LM_Leave_Credited_Date__c = system.today();
            INSERT LeaveData;
            
            //Creating leave request
            
            EMS_LM_Leave_History__c Leave1 = new EMS_LM_Leave_History__c();
            Leave1.EMS_LM_Contact__c = con.Id;
             Leave1.EMS_LM_Reason__c = 'demo';
            Leave1.EMS_LM_Status__c = 'Approved';
            Leave1.EMS_LM_Leave_Start_Date__c = system.today();
            Leave1.EMS_LM_Leave_End_Date__c = system.today()+1;
            Leave1.EMS_LM_Leave_Type__c = annualtype.Id;
            Leave1.EMS_LM_Day__c = 'Full Day';
            Insert Leave1;
            
            EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
            timesheetRec.Resource__c = con.Id;
            timesheetRec.User__c = user.id;
            timesheetRec.EMS_TM_Sat__c = 0;
            timesheetRec.EMS_TM_Sun__c =0;
            timesheetRec.OwnerId =user.id;
            timesheetRec.EMS_TM_Status__c='Submitted';
            timesheetRec.Week_Start_Date__c = weekStart;
            timesheetRec.Week_End_Date__c = weekEnd;
            timesheetRec.EMS_TM_Week__c = weekEnd;
            INSERT timesheetRec;
            
            //smaske: Updating Test data for creating current week and prev week timesheet and timesheetlineitem records.
            EMS_Timesheet__c timesheetRec2 = new EMS_Timesheet__c();
            timesheetRec2.Resource__c = con.Id;
            timesheetRec2.User__c = user.id;
            timesheetRec2.EMS_TM_Sat__c = 0;
            timesheetRec2.EMS_TM_Sun__c =0;
            timesheetRec2.OwnerId =user.id;
            timesheetRec2.EMS_TM_Status__c='Submitted';
            timesheetRec2.Week_Start_Date__c = weekStart - 7;
            timesheetRec2.Week_End_Date__c = weekEnd - 7;
            timesheetRec2.EMS_TM_Week__c = weekEnd - 7;
            INSERT timesheetRec2;
            
            EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
            lineitem.EMS_Timesheet__c = timesheetRec.Id;
            lineitem.OwnerId = user.id;
            lineitem.User__c = user.id;
            lineitem.Assignment__c = assignmentRec.Id;
            lineitem.EMS_TM_Project__c = assignmentRec.EMS_TM_ProjectName_Asgn__c;
            lineitem.EMS_TM_Thu__c = 0;
            lineitem.EMS_TM_Fri__c = 0;
            lineitem.Status__c = 'Submitted';
            INSERT lineitem;
            
            List<EMS_TM_Timesheet_Record__c> lineitemlist = new List<EMS_TM_Timesheet_Record__c>();
            EMS_TM_Timesheet_Record__c lineitem1 = new EMS_TM_Timesheet_Record__c();
            lineitem1.EMS_Timesheet__c = timesheetRec2.Id;
            lineitem1.OwnerId = user.id;
            lineitem1.User__c = user.id;
            lineitem1.Assignment__c = assignmentRec.Id;
            lineitem1.EMS_TM_Project__c = assignmentRec.EMS_TM_ProjectName_Asgn__c;
            lineitem1.EMS_TM_Thu__c = 0;
            lineitem1.EMS_TM_Fri__c = 0;
            lineitem1.Status__c = 'Submitted';
            lineitemlist.add(lineitem1);
            Insert lineitemlist;
            
            System.debug(' timesheetRec1 ' +  timesheetRec + ' ' +  lineitem);
            System.debug(' timesheetRec2 ' +  timesheetRec2 + ' ' + lineitem1); 
            
            List<EMS_TM_Timesheet_Record__c> lineitemlis1 = new List<EMS_TM_Timesheet_Record__c>();
            List<EMS_TM_Timesheet_Record__c> lineitemlist2 = new List<EMS_TM_Timesheet_Record__c>();
            test.startTest();
            EMS_TM_TimesheetClass.getAssignmentProjectWire(weekStart,true,user.Id);
            EMS_TM_TimesheetClass.getPreWeekData(timesheetRec);
            EMS_TM_TimesheetClass.duplicatetimesheetLWC(timesheetRec);
            EMS_TM_TimesheetClass.renderTimeSheet(timesheetRec);
            EMS_TM_TimesheetClass.renderTimeRecord(lineitem,timesheetRec,timesheetRec.Id);
            EMS_TM_TimesheetClass.reviseTimesheet(timesheetRec);
            EMS_TM_TimesheetClass.getTimesheetHours();
            EMS_TM_TimesheetClass.saveTimeSheetRecords(lineitemlist,timesheetRec);
            EMS_TM_TimesheetClass.updateTimeSheetRecords(lineitemlis1,lineitemlist,lineitemlist2,timesheetRec);
            EMS_TM_TimesheetClass.returnProjectTypemap();
            EMS_TM_TimesheetClass.returnProjectTasks();
            EMS_TM_TimesheetClass.getTimeSheetData(weekEnd,user.id);
            EMS_TM_TimesheetClass.reviseTimesheet(timesheetRec2);
            test.stopTest();
        }
    }
    @istest
    public static void projectstask(){
        
        EMS_TM_TimesheetClass.returnProjectTasks();
        EMS_TM_TimesheetClass.returnProjectTypemap();
        EMS_TM_TimesheetClass.resourcerole();
        EMS_TM_TimesheetClass.getTimesheetHours();
    }
    
    
}