@isTest
public class deleteCompOffRecordTest {
    @isTest
    public static void setup(){
        User userData = [SELECT Id,
                                  Name 
                                  FROM User 
                                  WHERE IsActive = True LIMIT 1];
    contact contactRec = new contact();
        contactRec.LastName = 'rk';
        contactRec.Official_Mail__c ='rama@rama.com';
        contactRec.Phone = '9652901075';
        contactRec.EMS_Phone_Number__c = '9652901075';
        contactRec.RecordTypeId = ContactConstant.RESOURCE_RECORDTYPEID;
        contactRec.EMS_EM_JD__c = system.today();
        contactRec.EMS_TM_User__c = userData.Id;
        insert contactRec;               
        EMS_TM_Project__c projectRec = new EMS_TM_Project__c();
        projectRec.EMS_TM_StartDate__c = System.today();
        projectRec.EMS_TM_EndDate__c = System.today()+10;
        projectRec.EMS_TM_Status__c = 'ongoing';
        projectRec.Name = 'project1';
        projectRec.Project_Manager__c = contactRec.Id;
        projectRec.Type_Of_Project__c ='Client Projects';
        insert projectRec;        

        EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
        assignmentRec.EMS_TM_EmployeeName__c = contactRec.Id;
        assignmentRec.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec.EMS_TM_Billable__c = true;
        insert assignmentRec;
        EMS_TM_Assignment__c assignmentRec1 = new EMS_TM_Assignment__c();
        assignmentRec1.EMS_TM_EmployeeName__c = contactRec.Id;
        assignmentRec1.EMS_TM_ProjectName_Asgn__c = projectRec.Id;
        assignmentRec1.EMS_TM_StartDate_Asgn__c = system.today();
        assignmentRec1.EMS_TM_Billable__c = true;
        insert assignmentRec1; 

        //SELECT Id, enddate__c, startweek__c, User__c,EMS_TM_Week__c, EMS_TM_Sun__c, EMS_TM_Sat__c FROM EMS_Timesheet__c
        //SELECT Id, EMS_LM_Employee__c, EMS_LM_Leave_Type__c, CompOff_Week__c, Leave_Type_Name__c, EMS_LM_Select_Leave_Type__c, 
        //EMS_LM_Leaves_Credited__c, EMS_LM_Leave_Credited_Date__c FROM EMS_LM_Leave_Credit__c
         
      /*  EMS_Timesheet__c timesheetRec = new EMS_Timesheet__c();
        //timesheetRec.startweek__c = System.today();
       // timesheetRec.enddate__c = System.today()+3;
        timesheetRec.User__c = userData.Id;
        timesheetRec.EMS_TM_Sat__c = 8;
        timesheetRec.EMS_TM_Sun__c =8;
        timesheetRec.EMS_TM_Week__c = System.today();
        timesheetRec.User__c = userData.Id;
        insert timesheetRec;
        System.debug('timesheetRec'+timesheetRec);
         EMS_LM_Leave_Credit__c compffRec= new EMS_LM_Leave_Credit__c();
        
        compffRec.EMS_LM_Employee__c = contactRec.Id;
        compffRec.CompOff_Week__c = System.today();
        compffRec.EMS_LM_Select_Leave_Type__c ='Compensatory Off';
        insert compffRec;*/
                
    }
    
}