@isTest
public class deleteCompOffRecordTest {
    @testsetup
    public static void setup(){
        Id pId = [select id from profile where name='Employee - Resource(Community)'].id;
        user userId =[SELECT id from User  where profileId =:pId AND IsActive = true LIMIT 1];
        Resource_Role__c role = TestDataFactory.createResourceRole(true);
        EMS_LM_Leave__c ee =TestDataFactory.createLeaveType(false);
        ee.EMS_LM_Leave_Type__c ='Loss of Pay';
        Insert ee;
        Office_Location__c ofcRec= TestDataFactory.createOfficeLocation(true);
        Account acc = TestDataFactory.createAccount(true);
        Contact con=  TestDataFactory.createResourceContact(acc.id, false);
        con.EMS_RM_Employee_Id__c = 'CP10235';
        con.LastName ='RRR';
        con.Resource_Role__c = role.Id;
        con.EMS_TM_User__c = userId.Id;
        con.Work_Location__c = ofcRec.Id;
        insert con;
        // user userdata =TestDataFactory.createCommunityUserWithOutAccAndContact(true);
        User userdata = Testdatafactory.createCommunityUserWithAccAndContact(acc.id,con.Id,false);
        SYstem.debug('userREc'+userdata);
        System.debug('conRec'+con);
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = con.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        insert projectRec;        
        SYstem.debug('ProjectREC'+projectRec);
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
        timesheetRec.EMS_TM_Sat__c = 8;
        timesheetRec.EMS_TM_Sun__c =8;
        timesheetRec.EMS_TM_Week__c = System.today();
        insert timesheetRec;
        System.debug('timesheetRec'+timesheetRec);
        
        EMS_LM_Leave_Credit__c compffRec= new EMS_LM_Leave_Credit__c(); 
        compffRec.EMS_LM_Employee__c = con.Id;
        compffRec.CompOff_Week__c = System.today();
        compffRec.EMS_LM_Select_Leave_Type__c ='Compensatory Off';
        insert compffRec;
        
    }
    
    public static testmethod void deletecompOff(){
        test.startTest();
        Contact con=[SELECT Id,EMS_RM_Employee_Id__c FROM Contact WHERE EMS_RM_Employee_Id__c ='CP10235'];
        System.debug('conID'+con);
        EMS_Timesheet__c timeRec=[SELECT Id,EMS_TM_Sun__c,EMS_TM_Sat__c from EMS_Timesheet__c WHERE Resource__c =:con.Id];
        timeRec.EMS_TM_Sat__c=0;
        timeRec.EMS_TM_Sun__c =0;
        update timeRec;
        test.stopTest();
        
        List<EMS_LM_Leave_Credit__c> levaeCredit= [Select Id,EMS_LM_Select_Leave_Type__c from EMS_LM_Leave_Credit__c WHERE EMS_LM_Employee__c =:con.Id];
        System.debug('levaeCredit'+levaeCredit);
        System.assertEquals(1, levaeCredit.size());
    }
    
}