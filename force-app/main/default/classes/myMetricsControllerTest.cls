/**
* @author Mukesh Rawat 
* @date 01/03/2024
* @description  Test class for myMetricsController

* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
@isTest
public class myMetricsControllerTest {
    @testSetup
    static void setupTestData() {
         EMS_LM_Leave__c  annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c wfhtype = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10234';
        con.Resource_Role__c = role.Id;
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10235';
        con1.Resource_Role__c = role.Id;
        con1.Email = 'testEmail+test1@cloudperitus.com';
        con.EMS_RM_ApplicantStatus_Update__c = 'Active';
        insert con1;
        
        User u = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,false);
        u.Username = 'absc@admin.com';
        Insert u;
       // User u1 = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con1.Id,true);
        
        TriggerBase.bypass('Contact');
        con.EMS_TM_User__c = u.Id;
        con.Resource_Role__c = role.Id;
        update con;
        TriggerBase.clearBypass('Contact');
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c=con.Id;
        resourceRelationship.Relationship_Type__c = 'Mentor';
        insert resourceRelationship;
        
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today()-10;
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'Ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Offshore_Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        INSERT projectRec; 
        
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today()-10;
        assignmentRec.EMS_TM_EndDate_Asgn__c = system.today()+10;
        assignmentRec.EMS_TM_Status_Asgn__c ='Active';
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c='Administrator';
        assignmentRec.Project_Allocation__c=1;
        assignmentRec.Offshore_PM_Configure__c= false;
        assignmentRec.Onshore_PM_Configure__c=false;
        INSERT assignmentRec;
        
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = u.id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =u.id;
        timesheetRec.EMS_TM_Status__c='Submitted';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = weekEnd;
        INSERT timesheetRec;
        
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = u.id;
        lineitem.User__c = u.id;
        lineitem.Assignment__c = assignmentRec.Id;
        lineitem.EMS_TM_Project__c = assignmentRec.EMS_TM_ProjectName_Asgn__c;
        lineitem.EMS_TM_Mon__c=16;
        lineitem.EMS_TM_Tue__c=16;
        lineitem.EMS_TM_Wed__c=16;
        lineitem.EMS_TM_Thu__c = 16;
        lineitem.EMS_TM_Fri__c = 16;
        lineitem.Status__c = 'Submitted';
        INSERT lineitem;
        
        
       // Fiscal_Year__c FiscalYear = Testdatafactory.createFiscalYear(true);
        Fiscal_Year__c fy = Testdatafactory.createFiscalYear(false);
        Period currentFiscalYearPeriod = [SELECT FiscalYearSettings.Name, FullyQualifiedLabel, StartDate, EndDate  FROM Period WHERE Type = 'Year' AND StartDate = THIS_FISCAL_YEAR LIMIT 1];
        fy.Start_Date__c = currentFiscalYearPeriod.StartDate;
        fy.End_Date__c = currentFiscalYearPeriod.EndDate;
        Insert fy;
        Fulfillment__c full = Testdatafactory.createFulfillment(con.Id,false);
        full.Fiscal_Year__c = fy.Id;
        full.Resource__c = con.Id;
        Insert full;
        Goal__c Kra = Testdatafactory.createKRARecords(con.Id, con1.Id, full, true);
        List<Grid_Configuration__c> gridConfigs = TestDataFactory.createGridConfigurationKraData(role.Id, true);
        Goal__c Pulse = TestDataFactory.createPulseRecords(con.Id, con1.Id, full.id, true);
        
        //create Questions Records
        List<PM_Configure__c> Questions =  TestDataFactory.createPMConfigQuestionRec(role.Id,true);
    }
    public static testMethod void testClassForMyMetricsController() {
        Contact con=[Select id from Contact where EMS_RM_Employee_Id__c='CP10234' limit 1];
        Contact con1=[Select id from Contact where EMS_RM_Employee_Id__c='CP10235' limit 1];
        Fiscal_Year__c fy =[Select id from Fiscal_Year__c limit 1];
        system.debug('fy-->'+fy);
        Resource_Role__c role =[Select id from Resource_Role__c limit 1];
        User u =[Select Id,ContactId from User where Username = 'absc@admin.com'];
        //User u1 =[Select Id,ContactId from User where Username != 'absc@admin.com' limit 1];
        system.debug('u-->'+u);
        Fulfillment__c full =[Select id from Fulfillment__c limit 1];
        EMS_TM_Project__c projectRec =[Select Id,Name from EMS_TM_Project__c where Name = 'project1'];
        EMS_TM_Assignment__c assignmentRec =[Select Id,Name from EMS_TM_Assignment__c limit 1];
        
        Test.startTest();
       myMetricsController.getTheCurrentFY();
        myMetricsController.datawrapper result = myMetricsController.getTheCompanyKRA();
        myMetricsController.getResourceKRAs(con.Id, fy.Id);
        myMetricsController.getAllRoleKRAs(role.Id);
        myMetricsController.createKraPulseRecords(u.ContactId, full.Id);
        myMetricsController.getKraPulseRecords(u.ContactId, fy.Id);
        myMetricsController.getMenteeProjectAssigne(u.ContactId);
        myMetricsController.createPMAnswerConfigureForManager(u.ContactId, con1.Id, projectRec.Id, assignmentRec.Id);
        myMetricsController.allowSendingKraRequestToOtherPm(con1.Id,projectRec.Id);
        system.runAs(u){
            myMetricsController.getAllKRAs('');
            myMetricsController.getAllKRAs(fy.Id);
        }
        Test.stopTest();
    }
    
}