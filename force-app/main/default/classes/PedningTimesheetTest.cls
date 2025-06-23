@isTest
public class PedningTimesheetTest {
    
    @testSetup
    static void setupData(){
        
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        user userId =[SELECT id FROM User  WHERE IsActive = true and profile.name = 'System Administrator' LIMIT 1];          
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        Office_Location__c hydofficlocRec =TestDataFactory.createOfficeLocation('Hyderabad - India',true);
        Office_Location__c usofficlocRec =TestDataFactory.createOfficeLocation('California - USA',true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidtimeof = TestDataFactory.createLeaveType('Paid time off',true);
        EMS_LM_Leave__c unpaidTimeOff = TestDataFactory.createLeaveType('UnPaid time off',true);
        EMS_LM_Leave__c floatingholiday = TestDataFactory.createLeaveType('Floating Holiday',true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =userId.Id;
        INSERT con;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='ramakrishna.papana@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='USA';
        con1.EMS_EM_CA_City__c ='USA';
        con1.EMS_EM_CA_State__c ='LA';
        con1.Work_Location__c = USA.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role.Id;
        con1.EMS_TM_User__c =UserId.Id;
        INSERT con1;
        
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Offshore_Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Approval_Needed__c ='YES';
        INSERT projectRec;        
        System.debug('ProjectREC'+projectRec);
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        assignmentRec.Project_Allocation__c = 1;
        INSERT assignmentRec;  
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Week_Start_Date__c = System.today();
        timesheetRec.Week_End_Date__c = System.today()+6;
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = userId.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =userId.Id;
        timesheetRec.EMS_TM_Status__c='Submitted';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = timesheetRec.User__c;
        lineitem.EMS_TM_Project__c = projectRec.Id;
        lineitem.EMS_TM_Mon__c = 5;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.EMS_TM_Sat__c =0;
        lineitem.EMS_TM_Sun__c =0;
        lineitem.Status__c = 'Submitted';
        lineitem.Timesheet_Approver__c = userId.Id;
        INSERT lineitem;
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c = con1.Id;
        resourceRelationship.Relationship_Type__c = 'Resource Manager';
        insert resourceRelationship;
        
        EMS_TM_Project__c projectRec2 = new EMS_TM_Project__c();
        projectRec2.EMS_TM_StartDate__c = System.today();
        projectRec2.EMS_TM_EndDate__c = System.today() + 10;
        projectRec2.EMS_TM_Status__c = 'ongoing';
        projectRec2.Name = 'project2';
        projectRec2.Project_Manager__c = con.Id;
        projectRec2.Offshore_Project_Manager__c = con.Id;
        projectRec2.Type_Of_Project__c = 'Global Projects';
        projectRec2.Approval_Needed__c = 'YES';
        INSERT projectRec2;
        
        EMS_TM_Assignment__c assignmentRec2 = new EMS_TM_Assignment__c();
        assignmentRec2.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec2.EMS_TM_ProjectName_Asgn__c = projectRec2.Id;
        assignmentRec2.EMS_TM_StartDate_Asgn__c = System.today();
        assignmentRec2.EMS_TM_Billable__c = true;
        assignmentRec2.EMS_TM_AssignedAs__c = 'Administrator';
        assignmentRec2.Project_Allocation__c = 1;
        INSERT assignmentRec2;
        
        EMS_Timesheet__c timesheetRec2 = new EMS_Timesheet__c();
        timesheetRec2.Week_Start_Date__c = weekStart;
        timesheetRec2.Week_End_Date__c = weekEnd;
        timesheetRec2.Resource__c = con.Id;
        timesheetRec2.User__c = userId.Id;
        timesheetRec2.EMS_TM_Sat__c = 0;
        timesheetRec2.EMS_TM_Sun__c = 0;
        timesheetRec2.OwnerId = userId.Id;
        timesheetRec2.EMS_TM_Status__c = 'Submitted';
        timesheetRec2.EMS_TM_Week__c = System.today();
        INSERT timesheetRec2;
        
        EMS_TM_Timesheet_Record__c lineitem2 = new EMS_TM_Timesheet_Record__c();
        lineitem2.EMS_Timesheet__c = timesheetRec2.Id;
        lineitem2.OwnerId = timesheetRec2.User__c;
        lineitem2.EMS_TM_Project__c = projectRec2.Id;
        lineitem2.EMS_TM_Mon__c = 8;
        lineitem2.EMS_TM_Tue__c = 0;
        lineitem2.EMS_TM_Wed__c = 0;
        lineitem2.EMS_TM_Thu__c = 0;
        lineitem2.EMS_TM_Fri__c = 0;
        lineitem2.EMS_TM_Sat__c = 0;
        lineitem2.EMS_TM_Sun__c = 0;
        lineitem2.Status__c = 'Submitted';
        INSERT lineitem2;
        
        //---
        EMS_TM_Project__c projectRec3 = new EMS_TM_Project__c();
        projectRec3.EMS_TM_StartDate__c = System.today();
        projectRec3.EMS_TM_EndDate__c = System.today() + 10;
        projectRec3.EMS_TM_Status__c = 'ongoing';
        projectRec3.Name = 'project2';
        projectRec3.Project_Manager__c = con.Id;
        projectRec3.Offshore_Project_Manager__c = con.Id;
        projectRec3.Type_Of_Project__c = 'Global Projects';
        projectRec3.Approval_Needed__c = 'YES';
        INSERT projectRec3;
        
        EMS_TM_Assignment__c assignmentRec3 = new EMS_TM_Assignment__c();
        assignmentRec3.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec3.EMS_TM_ProjectName_Asgn__c = projectRec3.Id;
        assignmentRec3.EMS_TM_StartDate_Asgn__c = System.today();
        assignmentRec3.EMS_TM_Billable__c = true;
        assignmentRec3.EMS_TM_AssignedAs__c = 'Administrator';
        assignmentRec3.Project_Allocation__c = 1;
        INSERT assignmentRec3;
        
        EMS_Timesheet__c timesheetRec3 = new EMS_Timesheet__c();
        timesheetRec3.Week_Start_Date__c = weekStart;
        timesheetRec3.Week_End_Date__c = weekEnd;
        timesheetRec3.Resource__c = con.Id;
        timesheetRec3.User__c = userId.Id;
        timesheetRec3.EMS_TM_Sat__c = 0;
        timesheetRec3.EMS_TM_Sun__c = 0;
        timesheetRec3.OwnerId = userId.Id;
        timesheetRec3.EMS_TM_Status__c = 'Submitted';
        timesheetRec3.EMS_TM_Week__c = System.today();
        INSERT timesheetRec3;
        
        EMS_TM_Timesheet_Record__c lineitem3 = new EMS_TM_Timesheet_Record__c();
        lineitem3.EMS_Timesheet__c = timesheetRec3.Id;
        lineitem3.OwnerId = timesheetRec3.User__c;
        lineitem3.EMS_TM_Project__c = projectRec2.Id;
        lineitem3.EMS_TM_Mon__c = 0;
        lineitem3.EMS_TM_Tue__c = 8;
        lineitem3.EMS_TM_Wed__c = 0;
        lineitem3.EMS_TM_Thu__c = 0;
        lineitem3.EMS_TM_Fri__c = 0;
        lineitem3.EMS_TM_Sat__c = 0;
        lineitem3.EMS_TM_Sun__c = 0;
        lineitem3.Status__c = 'Submitted';
        INSERT lineitem3;
        
    }
    
    static testMethod void testPendingRecords() {
        user userId =[SELECT id FROM User  WHERE IsActive = true and profile.name = 'System Administrator' LIMIT 1];                  
        System.runAs(userId) {
            Date todayval = system.today(); 
            Date considerDate = todayval.toStartofWeek().addDays(-2);
            Date weekStart = considerDate.toStartofWeek().addDays(1);
            Date weekEnd = considerDate.toStartofWeek().addDays(7);
            
            Resource_Role__c role = TestDataFactory.createResourceRole(true);
            
            Contact con3 = [select id from contact where EMS_RM_Employee_Id__c = 'CP10235'];
            
            EMS_TM_Project__c projectRec2 = new EMS_TM_Project__c();
            projectRec2.EMS_TM_StartDate__c = System.today();
            projectRec2.EMS_TM_EndDate__c = System.today() + 10;
            projectRec2.EMS_TM_Status__c = 'ongoing';
            projectRec2.Name = 'project2';
            projectRec2.Project_Manager__c = con3.Id;
            projectRec2.Offshore_Project_Manager__c = con3.Id;
            projectRec2.Type_Of_Project__c = 'Global Projects';
            projectRec2.Approval_Needed__c = 'YES';
            INSERT projectRec2;
            
            EMS_TM_Assignment__c assignmentRec2 = new EMS_TM_Assignment__c();
            assignmentRec2.EMS_TM_EmployeeName__c = con3.Id;
            assignmentRec2.EMS_TM_ProjectName_Asgn__c = projectRec2.Id;
            assignmentRec2.EMS_TM_StartDate_Asgn__c = System.today();
            assignmentRec2.EMS_TM_Billable__c = true;
            assignmentRec2.EMS_TM_AssignedAs__c = 'Administrator';
            assignmentRec2.Project_Allocation__c = 1;
            INSERT assignmentRec2;
            
            EMS_Timesheet__c timesheetRec2 = new EMS_Timesheet__c();
            timesheetRec2.Week_Start_Date__c = weekStart;
            timesheetRec2.Week_End_Date__c = weekEnd;
            timesheetRec2.Resource__c = con3.Id;
            timesheetRec2.User__c = userId.Id;
            timesheetRec2.EMS_TM_Sat__c = 0;
            timesheetRec2.EMS_TM_Sun__c = 0;
            timesheetRec2.OwnerId = userId.Id;
            timesheetRec2.EMS_TM_Status__c = 'Submitted';
            timesheetRec2.EMS_TM_Week__c = System.today();
            INSERT timesheetRec2;
            
            Test.startTest();
            EMS_TM_Timesheet_Record__c lineitem2 = new EMS_TM_Timesheet_Record__c();
            lineitem2.EMS_Timesheet__c = timesheetRec2.Id;
            lineitem2.OwnerId = timesheetRec2.User__c;
            lineitem2.EMS_TM_Project__c = projectRec2.Id;
            lineitem2.EMS_TM_Mon__c = 8;
            lineitem2.EMS_TM_Tue__c = 0;
            lineitem2.EMS_TM_Wed__c = 0;
            lineitem2.EMS_TM_Thu__c = 0;
            lineitem2.EMS_TM_Fri__c = 0;
            lineitem2.EMS_TM_Sat__c = 0;
            lineitem2.EMS_TM_Sun__c = 0;
            lineitem2.Status__c = 'Submitted';
            INSERT lineitem2;
            
            
            List<PedningTimesheet.WrapperClass> wrapperList = PedningTimesheet.PendingRecords();
            Test.stopTest();
        }
    }
    
    static testMethod void testRecordssize() {
        User userId = [SELECT id FROM User  WHERE IsActive = true LIMIT 1];          
        System.runAs(userId) {
            Test.startTest();
            Integer count = PedningTimesheet.Recordssize();
            Test.stopTest();
            System.assert(count >= 0);
        }
    }
    
    static testMethod void testRejectTimesheetAll() {
        List<EMS_TM_Timesheet_Record__c> tsList = [SELECT Id FROM EMS_TM_Timesheet_Record__c LIMIT 1];
        List<String> ids = new List<String>();
        for (EMS_TM_Timesheet_Record__c ts : tsList) {
            ids.add(ts.Id);
        }
        
        Test.startTest();
        PedningTimesheet.rejecttimesheetsall(ids);
        Test.stopTest();
        List<EMS_TM_Timesheet_Record__c> updated = [SELECT Status__c FROM EMS_TM_Timesheet_Record__c WHERE Id IN :ids];
        System.assertEquals('Rejected', updated[0].Status__c);
    }
    
    static testMethod void testReassignrecord() {
        List<EMS_TM_Timesheet_Record__c> tsList = [SELECT Id FROM EMS_TM_Timesheet_Record__c LIMIT 1];
        Approval.lock(tsList); // Lock for testing
        
        Test.startTest();
        PedningTimesheet.reassignrecord(tsList[0].Id);
        Test.stopTest();
        
        //EMS_TM_Timesheet_Record__c updated = [SELECT Status__c FROM EMS_TM_Timesheet_Record__c WHERE Id = :tsList[0].Id];
    }
    
    static testMethod void testApproveAndRejectSingleRecord() {
        
        User userId = [SELECT id FROM User  WHERE IsActive = true LIMIT 1]; 
        EMS_TM_Timesheet_Record__c ts = [SELECT Id,User__c, EMS_TM_Mon__c FROM EMS_TM_Timesheet_Record__c where EMS_TM_Mon__c = 5 LIMIT 1];
        
        Test.startTest();
        PedningTimesheet.Approvetimesheets(ts.Id);
        Test.stopTest();
    }
    
    static testMethod void testApprovetimesheetsall2() {
        EMS_TM_Timesheet_Record__c ts = [SELECT Id,EMS_TM_Mon__c FROM EMS_TM_Timesheet_Record__c where EMS_TM_Mon__c = 8 LIMIT 1];
        Test.startTest();
        PedningTimesheet.Rejectatimesheets(ts.Id);
        
        Test.stopTest();
    }
    
    static testMethod void testApprovetimesheetsall() {
        List<id> idTest = new List<id>();
        
        EMS_TM_Timesheet_Record__c ts = [SELECT Id,EMS_TM_Tue__c FROM EMS_TM_Timesheet_Record__c where EMS_TM_Tue__c = 8 LIMIT 1];
        idTest.add(ts.id);
        PedningTimesheet.approvetimesheetsall(idTest);
        
    }
    
    static testMethod void testWrapperClassDirectUse() {
        EMS_TM_Project__c proj = [SELECT Id FROM EMS_TM_Project__c LIMIT 1];
        
        PedningTimesheet.WrapperClass wrap = new PedningTimesheet.WrapperClass();
        wrap.Id = 'testId';
        wrap.ProjcetName = 'Test Project';
        wrap.OwnerName = 'Test Owner';
        wrap.TimesheetId = 'ts123';
        wrap.weekStartDate = Date.today();
        wrap.weekenddate = Date.today().addDays(6);
        wrap.Hours = 40;
        wrap.projectid = proj.Id;
        wrap.Timesheetname = 'TS001';
        wrap.OwnerId = '003ABC000000001';
        wrap.Name = 'TestName';
        wrap.NumberOfhours = 40;
        wrap.wfoDays = 5;
        
        System.assertEquals('Test Project', wrap.ProjcetName);
    }  
}