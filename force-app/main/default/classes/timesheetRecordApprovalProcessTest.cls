/**
* @author Suneel
* @date 2/23/2023
* @description  
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 19/09/2023    Shubham Maske           Update for the Approval Process 
* ====================================================================================================
**/

@isTest
public class timesheetRecordApprovalProcessTest {
    @isTest
    public static  void timesheetLineItemApproval(){
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
       // Id p = [SELECT id FROM profile WHERE name='Employee - Resource(Community)'].id;
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];          
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        insert role;
        
        //Work Location
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
        
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Work_Location__c = HYD.Id;
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =userId.Id;
        INSERT con;
        
        Contact con1=  TestDataFactory.createResourceContact(acc.id, false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='ramakrishna.papana@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='Hyd';
        con1.EMS_EM_CA_City__c ='Hyd';
        con1.EMS_EM_CA_State__c ='AP';
        con1.Work_Location__c = HYD.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role.Id;
        con1.EMS_TM_User__c =UserId.Id;
        INSERT con1;
        
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con1.Id;
        projectRec.Offshore_Project_Manager__c = con1.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Approval_Needed__c ='Yes';
        INSERT projectRec;
        
        EMS_TM_Project__c globalProjectRec = new EMS_TM_Project__c();
        globalProjectRec.EMS_TM_StartDate__c = System.today();
        globalProjectRec.EMS_TM_EndDate__c = System.today()+10;
        globalProjectRec.EMS_TM_Status__c = 'ongoing';
        globalProjectRec.Name = 'project1';
        globalProjectRec.Project_Manager__c = con1.Id;
        globalProjectRec.Offshore_Project_Manager__c = con1.Id;
        globalProjectRec.Type_Of_Project__c ='Global Projects';
        globalProjectRec.Approval_Needed__c ='Yes';
        INSERT globalProjectRec;        
        System.debug('ProjectREC'+projectRec);
        
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        assignmentRec.Project_Allocation__c = 11;
        INSERT assignmentRec;
        
        EMS_TM_Assignment__c globalAssignmentRec = new EMS_TM_Assignment__c();
        globalAssignmentRec.EMS_TM_EmployeeName__c = con.Id;
        globalAssignmentRec.EMS_TM_ProjectName_Asgn__c = globalProjectRec.Id;
        globalAssignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        globalAssignmentRec.EMS_TM_Billable__c = true;
        globalAssignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        globalAssignmentRec.Project_Allocation__c = 11;
        //uncommenting below 1 line
        //INSERT globalAssignmentRec;

        
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Week_Start_Date__c = System.today();
        timesheetRec.Week_End_Date__c = System.today()+6;
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = userId.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =userId.Id;
        timesheetRec.EMS_TM_Status__c='Saved';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = timesheetRec.User__c;
        //uncommenting below 1 line
       	lineitem.Assignment__c = assignmentRec.Id;
        lineitem.EMS_TM_Project__c = projectRec.Id;
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.Status__c = 'Saved';
        INSERT lineitem;
        
        EMS_TM_Timesheet_Record__c glineitem = new EMS_TM_Timesheet_Record__c();
        glineitem.EMS_Timesheet__c = timesheetRec.Id;
        glineitem.OwnerId = timesheetRec.User__c;
        //uncommenting below 1 line
        lineitem.Assignment__c = assignmentRec.Id;
        glineitem.EMS_TM_Project__c = globalProjectRec.Id;
        glineitem.EMS_TM_Mon__c = 0;
        glineitem.EMS_TM_Wed__c = 0;
        glineitem.EMS_TM_Tue__c = 0;
        glineitem.EMS_TM_Thu__c = 0;
        glineitem.EMS_TM_Fri__c = 0;
        glineitem.Status__c = 'Saved';
        INSERT glineitem;
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c = con1.Id;
        resourceRelationship.Relationship_Type__c='Mentor';
        insert resourceRelationship;
        test.startTest();
        List<EMS_TM_Timesheet_Record__c> timesheetLineRecs =[SELECT Id,Status__c FROM EMS_TM_Timesheet_Record__c];
        timesheetLineRecs[0].Status__c ='Submitted';
        timesheetLineRecs[1].Status__c ='Submitted';
        UPDATE timesheetLineRecs;
        test.stopTest();
        List<EMS_TM_Timesheet_Record__c> timesheetLineRecs2 = [SELECT Id,Status__c 
                                                               FROM EMS_TM_Timesheet_Record__c];
        System.debug('timesheetLineRecs2'+timesheetLineRecs2);
        System.assertEquals('Submitted', timesheetLineRecs2[0].Status__c);
        
       /* ProcessInstance objProcessInstance = [SELECT Id,TargetObjectId,Status, CreatedDate FROM ProcessInstance 
                                              WHERE TargetObjectId = :timesheetLineRecs2[0].Id];
        System.debug('objProcessInstance'+objProcessInstance);*/
        
    }  
    
    @isTest
    public static  void timesheetLineItemApproval2(){
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
       // Id p = [SELECT id FROM profile WHERE name='Employee - Resource(Community)'].id;
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];          
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        insert role;
        
        //Work Location
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
        
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='USA';
        con.EMS_EM_CA_City__c ='USA';
        con.EMS_EM_CA_State__c ='LA';
        con.Work_Location__c = USA.Id;
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =userId.Id;
        INSERT con;
        
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
        projectRec.Project_Manager__c = con1.Id;
        projectRec.Offshore_Project_Manager__c = con1.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Approval_Needed__c ='Yes';
        INSERT projectRec;
        
        EMS_TM_Project__c globalProjectRec = new EMS_TM_Project__c();
        globalProjectRec.EMS_TM_StartDate__c = System.today();
        globalProjectRec.EMS_TM_EndDate__c = System.today()+10;
        globalProjectRec.EMS_TM_Status__c = 'ongoing';
        globalProjectRec.Name = 'project1';
        globalProjectRec.Project_Manager__c = con1.Id;
        globalProjectRec.Offshore_Project_Manager__c = con1.Id;
        globalProjectRec.Type_Of_Project__c ='Global Projects';
        globalProjectRec.Approval_Needed__c ='Yes';
        INSERT globalProjectRec;        
        System.debug('ProjectREC'+projectRec);
        
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        assignmentRec.Project_Allocation__c = 11;
        INSERT assignmentRec;
        
        EMS_TM_Assignment__c globalAssignmentRec = new EMS_TM_Assignment__c();
        globalAssignmentRec.EMS_TM_EmployeeName__c = con.Id;
        globalAssignmentRec.EMS_TM_ProjectName_Asgn__c = globalProjectRec.Id;
        globalAssignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        globalAssignmentRec.EMS_TM_Billable__c = true;
        globalAssignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        globalAssignmentRec.Project_Allocation__c = 11;
        //uncommenting below 1 line
        //INSERT globalAssignmentRec;

        
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Week_Start_Date__c = System.today();
        timesheetRec.Week_End_Date__c = System.today()+6;
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = userId.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =userId.Id;
        timesheetRec.EMS_TM_Status__c='Saved';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = timesheetRec.User__c;
        //uncommenting below 1 line
       	lineitem.Assignment__c = assignmentRec.Id;
        lineitem.EMS_TM_Project__c = projectRec.Id;
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.Status__c = 'Saved';
        INSERT lineitem;
        
        EMS_TM_Timesheet_Record__c glineitem = new EMS_TM_Timesheet_Record__c();
        glineitem.EMS_Timesheet__c = timesheetRec.Id;
        glineitem.OwnerId = timesheetRec.User__c;
        //uncommenting below 1 line
        lineitem.Assignment__c = assignmentRec.Id;
        glineitem.EMS_TM_Project__c = globalProjectRec.Id;
        glineitem.EMS_TM_Mon__c = 0;
        glineitem.EMS_TM_Wed__c = 0;
        glineitem.EMS_TM_Tue__c = 0;
        glineitem.EMS_TM_Thu__c = 0;
        glineitem.EMS_TM_Fri__c = 0;
        glineitem.Status__c = 'Saved';
        INSERT glineitem;
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Resource_Reports_To__c = con1.Id;
        resourceRelationship.Relationship_Type__c='Mentor';
        insert resourceRelationship;
        test.startTest();
        List<EMS_TM_Timesheet_Record__c> timesheetLineRecs =[SELECT Id,Status__c FROM EMS_TM_Timesheet_Record__c];
        timesheetLineRecs[0].Status__c ='Submitted';
        timesheetLineRecs[1].Status__c ='Submitted';
        UPDATE timesheetLineRecs;
        test.stopTest();
        List<EMS_TM_Timesheet_Record__c> timesheetLineRecs2 = [SELECT Id,Status__c 
                                                               FROM EMS_TM_Timesheet_Record__c];
        System.debug('timesheetLineRecs2'+timesheetLineRecs2);
        System.assertEquals('Submitted', timesheetLineRecs2[0].Status__c);
               
    }
    
    @isTest
    public static  void timesheetLineItemApproval3(){
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
       // Id p = [SELECT id FROM profile WHERE name='Employee - Resource(Community)'].id;
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];        
        
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        insert role;
        
        //Work Location
        Office_Location__c HYD = new Office_Location__c();
        HYD.Name = 'Hyderabad - India';
        HYD.Address__c = 'Jubilee Hills. Road No 36';
        HYD.Country__c = 'India';
        HYD.Timezone__c = 'Asia/Kolkata';
        INSERT HYD;
        
        Office_Location__c USA = new Office_Location__c();
        USA.Name = 'California - USA';
        USA.Country__c = 'United States of America';
        USA.Address__c = '3000 Executive Parkway Suite 215, San Ramon, CA 94583 USA';
        USA.Timezone__c = 'America/Los_Angeles';
        INSERT USA;
        
        
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        Account acc = TestDataFactory.createAccount(true);
        
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='USA';
        con.EMS_EM_CA_City__c ='USA';
        con.EMS_EM_CA_State__c ='LA';
        con.Work_Location__c = USA.Id;
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c =userId.Id;
        INSERT con;
        
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
        
        User testUser = new User(
            ContactId = con1.Id,
            FirstName = 'John',
            IsActive = true,
            LastName = 'Doe',
            Alias = 'jdoe',
            Email = 'testUser@cloudperitus.com',
            Username = 'jdoe@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Employee - Operations(Community)'].Id, // Replace with the desired Profile
            TimeZoneSidKey = 'America/New_York', // Set the desired timezone
            LocaleSidKey = 'en_US', // Set the desired locale
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Offshore_Project_Manager__c = con1.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Approval_Needed__c ='Yes';
        INSERT projectRec;
        
        EMS_TM_Project__c globalProjectRec = new EMS_TM_Project__c();
        globalProjectRec.EMS_TM_StartDate__c = System.today();
        globalProjectRec.EMS_TM_EndDate__c = System.today()+10;
        globalProjectRec.EMS_TM_Status__c = 'ongoing';
        globalProjectRec.Name = 'project1';
        globalProjectRec.Project_Manager__c = con.Id;
        globalProjectRec.Offshore_Project_Manager__c = con1.Id;
        globalProjectRec.Type_Of_Project__c ='Global Projects';
        globalProjectRec.Approval_Needed__c ='Yes';
        INSERT globalProjectRec;        
        System.debug('ProjectREC'+projectRec);
        
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        assignmentRec.Project_Allocation__c = 11;
        INSERT assignmentRec;
        
        EMS_TM_Assignment__c globalAssignmentRec = new EMS_TM_Assignment__c();
        globalAssignmentRec.EMS_TM_EmployeeName__c = con.Id;
        globalAssignmentRec.EMS_TM_ProjectName_Asgn__c = globalProjectRec.Id;
        globalAssignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        globalAssignmentRec.EMS_TM_Billable__c = true;
        globalAssignmentRec.EMS_TM_AssignedAs__c = 'Administrator';
        globalAssignmentRec.Project_Allocation__c = 11;
        //uncommenting below 1 line
        //INSERT globalAssignmentRec;

        
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Week_Start_Date__c = System.today();
        timesheetRec.Week_End_Date__c = System.today()+6;
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = userId.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =userId.Id;
        timesheetRec.EMS_TM_Status__c='Saved';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = timesheetRec.User__c;
        //uncommenting below 1 line
       	lineitem.Assignment__c = assignmentRec.Id;
        lineitem.EMS_TM_Project__c = globalProjectRec.Id;
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.Status__c = 'Saved';
        INSERT lineitem;
        
        EMS_TM_Timesheet_Record__c glineitem = new EMS_TM_Timesheet_Record__c();
        glineitem.EMS_Timesheet__c = timesheetRec.Id;
        glineitem.OwnerId = timesheetRec.User__c;
        //uncommenting below 1 line
        lineitem.Assignment__c = assignmentRec.Id;
        glineitem.EMS_TM_Project__c = globalProjectRec.Id;
        glineitem.EMS_TM_Mon__c = 0;
        glineitem.EMS_TM_Wed__c = 0;
        glineitem.EMS_TM_Tue__c = 0;
        glineitem.EMS_TM_Thu__c = 0;
        glineitem.EMS_TM_Fri__c = 0;
        glineitem.Status__c = 'Saved';
        INSERT glineitem;
        
        Resource_Resource_Relationship__c resourceRelationship = new Resource_Resource_Relationship__c();
        resourceRelationship.Resource__c = con.Id;
        resourceRelationship.Relationship_Type__c='Mentor';
        resourceRelationship.Resource_Reports_To__c = con1.Id;
        insert resourceRelationship;
        test.startTest();
        List<EMS_TM_Timesheet_Record__c> timesheetLineRecs =[SELECT Id,Status__c FROM EMS_TM_Timesheet_Record__c];
        timesheetLineRecs[0].Status__c ='Submitted';
        timesheetLineRecs[1].Status__c ='Submitted';
        UPDATE timesheetLineRecs;
        test.stopTest();
        List<EMS_TM_Timesheet_Record__c> timesheetLineRecs2 = [SELECT Id,Status__c 
                                                               FROM EMS_TM_Timesheet_Record__c];
        System.debug('timesheetLineRecs2'+timesheetLineRecs2);
        System.assertEquals('Submitted', timesheetLineRecs2[0].Status__c);
               
    }
    
}
