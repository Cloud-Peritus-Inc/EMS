@isTest
public class BatchToCreateTimesheets_Test {
       @testSetup
    public static void getAdminUser(){
              user adminuser = TestDataFactory.createAdminUser(true);
             adminuser.Manager_Access__c = true;
              adminuser.TA_Admin__c = true;
             adminuser.IT_Admin_Access__c = true;
             UPDATE adminuser;
        
    }
    
    public static testmethod void createTimesheet(){
        user loginedUser =[SELECT id from User  where firstname ='Alan' AND IsActive = true LIMIT 1];
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        insert role;
         Office_Location__c officlocRec =TestDataFactory.createOfficeLocation('Hhyderabad',true);
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
        con.EMS_TM_User__c =loginedUser.Id;
        con.Work_Location__c =officlocRec.Id;
        INSERT con;
       /* System.runAs(loginedUser){
        user userRec = TestDataFactory.createCommunityUserWithAccAndContact(acc.Id,con.Id,true);
        }*/
        System.debug('conData'+con);
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        INSERT projectRec;        
        System.debug('ProjectREC'+projectRec);
        EMS_TM_Project__c projectRec1 = new EMS_TM_Project__c();
        projectRec1.EMS_TM_StartDate__c = System.today();
        projectRec1.EMS_TM_EndDate__c = System.today()+10;
        projectRec1.EMS_TM_Status__c = 'ongoing';
        projectRec1.Name = 'OOO';
        projectRec1.Project_Manager__c = con.Id;
        projectRec1.Type_Of_Project__c ='Global Projects';
        INSERT projectRec1;        
        System.debug('ProjectREC'+projectRec);
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_EndDate_Asgn__c = system.today()+3;
        assignmentRec.EMS_TM_Billable__c = true;
        assignmentRec.Project_Allocation__c=1;
        assignmentRec.EMS_TM_AssignedAs__c='Administrator';
        INSERT assignmentRec;
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
        EMS_TM_Calendar__c holiday2 = new EMS_TM_Calendar__c();
        holiday2.EMS_TM_Calendar_Date__c = System.today()+2;
        holiday2.Office_Location__c =officlocRec.Id;
        holiday2.Location__c ='Usa';
        holiday2.Name ='fff';
        holiday2.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday2);
        EMS_TM_Calendar__c holiday3 = new EMS_TM_Calendar__c();
        holiday3.EMS_TM_Calendar_Date__c = System.today()+3;
        holiday3.Office_Location__c =officlocRec.Id;
        holiday3.Location__c ='Usa';
        holiday3.Name ='fff';
        holiday3.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday3);
        EMS_TM_Calendar__c holiday4 = new EMS_TM_Calendar__c();
        holiday4.EMS_TM_Calendar_Date__c = System.today()+9;
        holiday4.Office_Location__c =officlocRec.Id;
        holiday4.Location__c ='Usa';
        holiday4.Name ='fff';
        holiday4.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday4);
         EMS_TM_Calendar__c holiday5 = new EMS_TM_Calendar__c();
        holiday5.EMS_TM_Calendar_Date__c = System.today()+5;
        holiday5.Office_Location__c =officlocRec.Id;
        holiday5.Location__c ='Usa';
        holiday5.Name ='fff';
        holiday5.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday5);
        INSERT holidayList;
        test.startTest();
        BatchToCreateTimesheets batchExecute = new BatchToCreateTimesheets(); 
        Database.executeBatch(batchExecute);
        test.stopTest();
                  Contact conRec=[SELECT Id,Email,Name,EMS_TM_user__c,(SELECT Id,Week_Start_Date__c,Week_End_Date__c,EMS_TM_Week__c FROM Timesheets__r) 
                        from contact WHERE EMS_RM_Employee_Id__c = 'CP10235'];
      //  System.debug('timesheetRec'+timesheetRec);
        System.assertEquals(1, conRec.Timesheets__r.size());
        System.debug('contactId'+con.Id);
        List<EMS_Timesheet__c> timesheetRec =[SELECT Id from EMS_Timesheet__c WHERE Resource__c =:con.Id];
      
        
    }
    
      public static testMethod void testscheduleclass() {
		Test.StartTest();
		BatchToCreateTimesheets_sch testsche = new BatchToCreateTimesheets_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test BatchToCalculateTheAvaiLeaves Check', sch, testsche );
		Test.stopTest();
	}
    
}