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
    @testSetup
    public static void getAdminUser(){
              user adminuser = TestDataFactory.createAdminUser(true);
             adminuser.Manager_Access__c = true;
              adminuser.TA_Admin__c = true;
             adminuser.IT_Admin_Access__c = true;
             UPDATE adminuser;
        
    }
		
    public static TestMethod void TestingGetAssignmentProject(){
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        user userId =[SELECT id,profileId,Profile.Name FROM User  WHERE IsActive = true AND firstname ='Alan'];          
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        INSERT role;
        Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
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
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =userId.Id;
        con.EMS_LM_No_Of_Leaves_Credit__c = 10;
        INSERT con;
       /* EMS_LM_Leave_History__c leaveRec = new EMS_LM_Leave_History__c();
        leaveRec.EMS_LM_Leave_Type__c = annualtype.Id;
        leaveRec.EMS_LM_Contact__c = con.Id;
        leaveRec.EMS_LM_Status__c ='Approved';
        leaveRec.EMS_LM_Leave_Start_Date__c = System.today();
        leaveRec.EMS_LM_Leave_End_Date__c =System.today()+1;
        INSERT leaveRec;*/
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
        System.runAs(userId){
         assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Status_Asgn__c ='Active';
        assignmentRec.EMS_TM_Billable__c = true;
        INSERT assignmentRec;
        }
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
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
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
        lineitem1.EMS_TM_Mon__c = 0;
        lineitem1.EMS_TM_Wed__c = 0;
        lineitem1.EMS_TM_Tue__c = 0;
        lineitem1.EMS_TM_Thu__c = 0;
        lineitem1.EMS_TM_Fri__c = 0;
        lineitem1.Status__c = 'Saved';
        lineitemlist.add(lineitem1);
        List<EMS_TM_Timesheet_Record__c> lineitemlis1 = new List<EMS_TM_Timesheet_Record__c>();
        List<EMS_TM_Timesheet_Record__c> lineitemlist2 = new List<EMS_TM_Timesheet_Record__c>();
        test.startTest();
        EMS_TM_TimesheetClass.getAssignmentProjectWire(weekStart,true,userId.Id);
        EMS_TM_TimesheetClass.getPreWeekData(timesheetRec);
        EMS_TM_TimesheetClass.duplicatetimesheetLWC(timesheetRec);
        EMS_TM_TimesheetClass.renderTimeSheet(timesheetRec);
        EMS_TM_TimesheetClass.renderTimeRecord(lineitem,timesheetRec,timesheetRec.Id);
        EMS_TM_TimesheetClass.reviseTimesheet(timesheetRec);
        EMS_TM_TimesheetClass.getTimesheetHours();
        EMS_TM_TimesheetClass.saveTimeSheetRecords(lineitemlist,timesheetRec);
        EMS_TM_TimesheetClass.updateTimeSheetRecords(lineitemlis1,lineitemlist,lineitemlist2,timesheetRec);
        test.stopTest();
    }
    
    

}