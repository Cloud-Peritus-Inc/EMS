@IsTest
public class BatchtoUpdateLeavesInTimesheet_Test {
 /*  @testSetup
    public static void setupData(){
        
    }*/
    
    public static testmethod void createTimesheet(){
        date todaydate = system.today();
        Date considerDate = todaydate.toStartofWeek();
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7); 
        user loginedUser =[SELECT id from User  where IsActive = true LIMIT 1];
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        role.Level_of_Approval__c =1;
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
        con.EMS_LM_No_Of_Leaves_Credit__c =10;
        INSERT con;
               // EMS_LM_Leave_History__c leavedata =TestDataFactory.createLeaveRequest(con.id, leavestart, leaveend, annualtype.id, true, 'Approved');
        List<EMS_TM_Calendar__c> holidayList = new List<EMS_TM_Calendar__c>();
        EMS_TM_Calendar__c holiday = new EMS_TM_Calendar__c();
        holiday.EMS_TM_Calendar_Date__c = System.today();
        holiday.Office_Location__c =officlocRec.Id;
        holiday.Location__c ='Usa';
        holiday.Name ='fff';
        holiday.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday);
        INSERT holidayList;
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
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today()+1;
        assignmentRec.EMS_TM_Billable__c = true;
        INSERT assignmentRec;
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = loginedUser.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =loginedUser.Id;
        timesheetRec.EMS_TM_Status__c='Saved';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        test.startTest();
        EMS_LM_Leave_History__c leave1 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(1), system.today().adddays(1), annualtype.id,true, 'Approved');
        EMS_LM_Leave_History__c leave2 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(-1), system.today().adddays(-1), annualtype.id,true, 'Approved');
        EMS_LM_Leave_History__c leave3 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(2), system.today().adddays(2), annualtype.id,true, 'Approved');
         List<EMS_LM_Leave_History__c> updatelev =[Select id,EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_End_Date__c,EMS_LM_Status__c,EMS_LM_Leave_Type__c 
                              from EMS_LM_Leave_History__c where id =:leave1.Id or id =:leave2.Id or id =:leave3.Id];
        list<EMS_LM_Leave_History__c> updatelist = new list<EMS_LM_Leave_History__c>();
        for(EMS_LM_Leave_History__c lr :updatelev){
                    lr.EMS_LM_Status__c ='Approved';
        }             

        UPDATE updatelist;
        BatchtoUpdateLeavesInTimesheet batchExecute = new BatchtoUpdateLeavesInTimesheet(); 
        Database.executeBatch(batchExecute);
        test.stopTest();
        List<EMS_TM_Timesheet_Record__c> lineitem =[SELECT id from EMS_TM_Timesheet_Record__c];
       // System.assertEquals(1, lineitem.size());
        
    }
    public static testmethod void createTimesheet1(){
        date todaydate = system.today();
        Date considerDate = todaydate.toStartofWeek();
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7); 
        date leavestart =  todaydate.addDays(1);
        date leaveend =  todaydate.addDays(1);
        user loginedUser =[SELECT id from User  where IsActive = true LIMIT 1];
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        role.Level_of_Approval__c =1;
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
        con.EMS_LM_No_Of_Leaves_Credit__c =10;
        INSERT con;
               // EMS_LM_Leave_History__c leavedata =TestDataFactory.createLeaveRequest(con.id, leavestart, leaveend, annualtype.id, true, 'Approved');
        List<EMS_TM_Calendar__c> holidayList = new List<EMS_TM_Calendar__c>();
        EMS_TM_Calendar__c holiday = new EMS_TM_Calendar__c();
        holiday.EMS_TM_Calendar_Date__c = System.today();
        holiday.Office_Location__c =officlocRec.Id;
        holiday.Location__c ='Usa';
        holiday.Name ='fff';
        holiday.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday);
        INSERT holidayList;
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
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today()+1;
        assignmentRec.EMS_TM_Billable__c = true;
        INSERT assignmentRec;
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = loginedUser.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =loginedUser.Id;
        timesheetRec.EMS_TM_Status__c='Saved';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        
        test.startTest();
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = loginedUser.id;
        lineitem.EMS_TM_ProjectTask__c = 'Paid time-off';
        lineitem.EMS_TM_Project__c = projectRec1.Id;
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.Status__c = 'Saved';
        INSERT lineitem;
          EMS_LM_Leave_History__c leave1 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(1), system.today().adddays(1), annualtype.id,true, 'Approved');
        EMS_LM_Leave_History__c leave2 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(-2), system.today().adddays(-1), annualtype.id,true, 'Approved');
        EMS_LM_Leave_History__c leave3 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(2), system.today().adddays(2), annualtype.id,true, 'Approved');
         List<EMS_LM_Leave_History__c> updatelev =[Select id,EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_End_Date__c,EMS_LM_Status__c,EMS_LM_Leave_Type__c 
                              from EMS_LM_Leave_History__c where id =:leave1.Id or id =:leave2.Id or id =:leave3.Id];
        list<EMS_LM_Leave_History__c> updatelist = new list<EMS_LM_Leave_History__c>();
        for(EMS_LM_Leave_History__c lr :updatelev){
                    lr.EMS_LM_Status__c ='Approved';
        }             

        UPDATE updatelist;
        BatchtoUpdateLeavesInTimesheet batchExecute = new BatchtoUpdateLeavesInTimesheet(); 
        Database.executeBatch(batchExecute);
        test.stopTest();
                List<EMS_TM_Timesheet_Record__c> lineitem1 =[SELECT id from EMS_TM_Timesheet_Record__c];
        //System.assertEquals(1, lineitem1.size());
    }
        public static testmethod void createTimesheet3(){
        date todaydate = system.today();
        Date considerDate = todaydate.toStartofWeek();
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7); 
        date leavestart =  todaydate.addDays(1);
        date leaveend =  todaydate.addDays(1);
        user loginedUser =[SELECT id from User  where IsActive = true LIMIT 1];
        Resource_Role__c role = TestDataFactory.createResourceRole(false);
        role.Name ='Sr Project Manager';
        role.Level_of_Approval__c =1;
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
        con.EMS_LM_No_Of_Leaves_Credit__c =10;
        INSERT con;
        List<EMS_TM_Calendar__c> holidayList = new List<EMS_TM_Calendar__c>();
        EMS_TM_Calendar__c holiday = new EMS_TM_Calendar__c();
        holiday.EMS_TM_Calendar_Date__c = System.today().adddays(1);
        holiday.Office_Location__c =officlocRec.Id;
        holiday.Location__c ='Usa';
        holiday.Name ='fff';
        holiday.EMS_TM_Type_Of_Holiday__c ='National';
        holidayList.add(holiday);
        INSERT holidayList;
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
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today()+1;
        assignmentRec.EMS_TM_Billable__c = true;
        INSERT assignmentRec;
        EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        timesheetRec.Resource__c = con.Id;
        timesheetRec.User__c = loginedUser.Id;
        timesheetRec.EMS_TM_Sat__c = 0;
        timesheetRec.EMS_TM_Sun__c =0;
        timesheetRec.OwnerId =loginedUser.Id;
        timesheetRec.EMS_TM_Status__c='Saved';
        timesheetRec.Week_Start_Date__c = weekStart;
        timesheetRec.Week_End_Date__c = weekEnd;
        timesheetRec.EMS_TM_Week__c = System.today();
        INSERT timesheetRec;
        
        test.startTest();
        EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
        lineitem.EMS_Timesheet__c = timesheetRec.Id;
        lineitem.OwnerId = loginedUser.id;
        lineitem.EMS_TM_ProjectTask__c = 'Paid time-off';
        lineitem.EMS_TM_Project__c = projectRec1.Id;
        lineitem.EMS_TM_Mon__c = 0;
        lineitem.EMS_TM_Wed__c = 0;
        lineitem.EMS_TM_Tue__c = 0;
        lineitem.EMS_TM_Thu__c = 0;
        lineitem.EMS_TM_Fri__c = 0;
        lineitem.Status__c = 'Saved';
        INSERT lineitem;
          EMS_LM_Leave_History__c leave1 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(1), system.today().adddays(1), annualtype.id,true, 'Approved');
        EMS_LM_Leave_History__c leave2 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(-1), system.today().adddays(-1), annualtype.id,true, 'Approved');
        EMS_LM_Leave_History__c leave3 =TestDataFactory.createLeaveRequest(con.id, system.today().adddays(2), system.today().adddays(2), annualtype.id,true, 'Approved');
         List<EMS_LM_Leave_History__c> updatelev =[Select id,EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_End_Date__c,EMS_LM_Status__c,EMS_LM_Leave_Type__c 
                              from EMS_LM_Leave_History__c where id =:leave1.Id or id =:leave2.Id or id =:leave3.Id];
        list<EMS_LM_Leave_History__c> updatelist = new list<EMS_LM_Leave_History__c>();
        for(EMS_LM_Leave_History__c lr :updatelev){
                    lr.EMS_LM_Status__c ='Approved';
        }             

        UPDATE updatelist;
        BatchtoUpdateLeavesInTimesheet batchExecute = new BatchtoUpdateLeavesInTimesheet(); 
        Database.executeBatch(batchExecute);
        test.stopTest();
        }
      public static testMethod void testscheduleclass() {
		Test.StartTest();
          EMS_LM_Leave__c annualtype = TestDataFactory.createLeaveType('Annual Leave',true);
		BatchtoUpdateLeavesInTimesheet_sch testsche = new BatchtoUpdateLeavesInTimesheet_sch();
		String sch = '0 0 23 * * ?';
		system.schedule('Test batchtoupdate leave Check', sch, testsche );
		Test.stopTest();
	}
    
}