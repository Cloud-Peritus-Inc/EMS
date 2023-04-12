@isTest
public class timesheetRecordStatusApproveTest {
    
    public static testmethod void timesheetLineItemApprove(){
      Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
       // Id p = [SELECT id FROM profile WHERE name='Employee - Resource(Community)'].id;
        user userId =[SELECT id FROM User  WHERE IsActive = true LIMIT 1];          
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
        EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        EMS_LM_Leave__c bretype = TestDataFactory.createLeaveType('Maternity Leave',true);
        EMS_LM_Leave__c compofftype = TestDataFactory.createLeaveType('Compensatory Off',true);
        EMS_LM_Leave__c workfromhome = TestDataFactory.createLeaveType('Work From Home',true);
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
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        projectRec.Approval_Needed__c ='NO';
        INSERT projectRec;        
        System.debug('ProjectREC'+projectRec);
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
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
        lineitem.Assignment__c = assignmentRec.Id;
        lineitem.EMS_TM_Project__c = assignmentRec.EMS_TM_ProjectName_Asgn__c;
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.EMS_TM_Sat__c =0;
        lineitem.EMS_TM_Sun__c =0;
        lineitem.Status__c = 'Submitted';
        INSERT lineitem;
        
        test.startTest();
          EMS_TM_Timesheet_Record__c timeLineItem =[SELECT Id,EMS_TM_Mon__c,EMS_TM_Wed__c,EMS_TM_Fri__c FROM EMS_TM_Timesheet_Record__c LIMIT 1];
        timeLineItem.EMS_TM_Fri__c =4;
        UPDATE timeLineItem;
         EMS_TM_Timesheet_Record__c timeLineItem2 =[SELECT Id,EMS_TM_Mon__c,EMS_TM_Wed__c,EMS_TM_Fri__c FROM EMS_TM_Timesheet_Record__c LIMIT 1];
        timeLineItem2.EMS_TM_Mon__c =2;
        UPDATE timeLineItem2;
         EMS_TM_Timesheet_Record__c timeLineItem3 =[SELECT Id,EMS_TM_Mon__c,EMS_TM_Wed__c,EMS_TM_Fri__c FROM EMS_TM_Timesheet_Record__c LIMIT 1];
        timeLineItem3.EMS_TM_Wed__c =2;
        UPDATE timeLineItem3;
        test.stopTest();
        EMS_TM_Timesheet_Record__c timeLineItem1 =[SELECT Id,Status__c FROM EMS_TM_Timesheet_Record__c LIMIT 1];
        System.assertEquals('Approved', timeLineItem1.Status__c);

    }

}