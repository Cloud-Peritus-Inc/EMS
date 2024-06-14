@isTest
public class PrepopulateManagersnamesClassTest {
 @isTest
    public static void populatingthemanagersMethodTest(){
         Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
      
        Account acc=TestDataFactory.createAccount('Cloud Peritus',True);
        
        //Contact con=TestDataFactory.createResourceContact(acc.Id,True);
        
        
        
        Office_Location__c ofcHyd=TestDataFactory.createOfficeLocation('Hyderabad',True);
       Office_Location__c ofcUSA=TestDataFactory.createOfficeLocation('USA',True);
             
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
        EMS_LM_Leave__c paidTimeOff = TestDataFactory.createLeaveType('Paid time off',true);
        
        
        
        Resource_Role__c role1=TestDataFactory.createResourceRole('Project Manager',True);
        Resource_Role__c role2=TestDataFactory.createResourceRole('Offshore Project Manager',True);
        
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1]; 
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.EMS_RM_ApplicantStatus_Update__c ='Active';
        con.EMS_Phone_Number__c ='0123456789';
        con.EMS_EM_CAddress_Line_1__c ='Hyd';
        con.EMS_EM_CA_City__c ='Hyd';
        con.EMS_EM_CA_State__c ='AP';
        con.Work_Location__c = ofcHyd.Id;
        con.Timesheet_NoNeed__c =false;
        con.Resource_Role__c = role2.Id;
        con.EMS_TM_User__c =userId.Id;
        INSERT con;
        //user communityuser1=TestDataFactory.createCommunityUserWithAccAndContact(acc.Id,con.id,true);
        //user communityuser2=TestDataFactory.createCommunityUser2WithAccAndContact(acc.Id,con.id,true);
        Contact con1=TestDataFactory.createResourceContact(acc.Id,false);
        con1.EMS_RM_Employee_Id__c = 'CP10236';
        con1.Email='ramakrishna.papana@cloudperitus2.com';
        con1.EMS_RM_ApplicantStatus_Update__c ='Active';
        con1.EMS_Phone_Number__c ='0123456789';
        con1.EMS_EM_CAddress_Line_1__c ='Hyd';
        con1.EMS_EM_CA_City__c ='Hyd';
        con1.EMS_EM_CA_State__c ='AP';
        con1.Work_Location__c = ofcHyd.Id;
        con1.Timesheet_NoNeed__c =false;
        con1.Resource_Role__c = role1.Id;
        con1.EMS_TM_User__c =userId.Id;
        INSERT con1;
        Resource_Resource_Relationship__c resourcereport1=TestDataFactory.createRRR(con.id,True,con1.Id);
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
        globalProjectRec.Project_Manager__c = con1.Id;
        globalProjectRec.Offshore_Project_Manager__c = con1.Id;
        globalProjectRec.Type_Of_Project__c ='Global Projects';
        globalProjectRec.Approval_Needed__c ='Yes';
        INSERT globalProjectRec; 
        
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
        
    
    }
    
    
}