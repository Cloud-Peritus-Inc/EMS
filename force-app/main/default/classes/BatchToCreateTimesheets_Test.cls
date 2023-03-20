@isTest
public class BatchToCreateTimesheets_Test {
    
    public static testmethod void createTimesheet(){
         Id p = [select id from profile where name='Employee - Resource(Community)'].id;
        user loginedUser =[SELECT id from User  where profileId =:p AND IsActive = true LIMIT 1];
         EMS_LM_Leave__c loptype = TestDataFactory.createLeaveType('Loss of Pay',true);
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c leaveRec =TestDataFactory.createLeaveType(false);
        leaveRec.EMS_LM_Leave_Type__c ='Loss of Pay';
        INSERT leaveRec;
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
        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = con.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        INSERT assignmentRec;  
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