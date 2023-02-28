/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToCreateTimesheets Batch to send  
*              
*               Schedule class 
*               - BatchToCreateTimesheets_sch
*               Test code coverage provided by the following test class:
*               - BatchToCreateTimesheets_Test 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global without sharing class BatchToCreateTimesheets implements Database.Batchable<sObject> {
global date weekStart ;
global date weekEnd ;    
    
  global  BatchToCreateTimesheets(){
        date todaydate = system.today();
        Date considerDate = todaydate.toStartofWeek();
        this.weekStart = considerDate.toStartofWeek().addDays(1);
        this.weekEnd = considerDate.toStartofWeek().addDays(7); 
    }
 /**
* @author Subba
* @date 22/01/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        date dt = system.today();
        return Database.getQueryLocator([SELECT Id,Email,Name,EMS_TM_user__c,
                                         (SELECT Id,EMS_TM_ProjectName_Asgn__c,EMS_TM_EmployeeName__c,EMS_TM_AssignedAs__c FROM Assignments__r 
                                         	WHERE EMS_TM_StartDate_Asgn__c <=:dt AND EMS_TM_EndDate_Asgn__c >=:dt ),
                                         (SELECT Id,Week_Start_Date__c,Week_End_Date__c,EMS_TM_Week__c FROM Timesheets__r 
                                          WHERE Week_Start_Date__c >=:weekStart AND Week_End_Date__c<=:weekEnd  )
                                         FROM Contact 
                                         WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                                          AND EMS_RM_ApplicantStatus_Update__c = 'Active' AND Timesheet_NoNeed__c = false  ]);
    }


/**
* @author Subba
* @date 22/01/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
       
       List<EMS_Timesheet__c> timesheetList = new List<EMS_Timesheet__c>();
       List<EMS_TM_Timesheet_Record__c> timesheetlineItemsList = new List<EMS_TM_Timesheet_Record__c>();
       List<Contact> filteredList = new List<Contact>();
        for(Contact conRec : conList){
            if(conRec.Timesheets__r.isEmpty() && !conRec.Assignments__r.isEmpty()){
                filteredList.add(conRec);
                EMS_Timesheet__c timesheet = new EMS_Timesheet__c();
                timesheet.Resource__c = conRec.Id;
                timesheet.User__c = conRec.EMS_TM_user__c;
                timesheet.EMS_TM_Sun__c = 0;
                timesheet.EMS_TM_Mon__c = 0;
                timesheet.EMS_TM_Tue__c = 0;
                timesheet.EMS_TM_Wed__c = 0;
                timesheet.EMS_TM_Thu__c = 0;
                timesheet.EMS_TM_Fri__c = 0;
                timesheet.EMS_TM_Sat__c = 0;
                timesheet.EMS_TM_Status__c = EMS_TM_GlobalConstants.STATUS_SAVED;
                timesheet.Week_Start_Date__c = this.weekStart;
                timesheet.Week_End_Date__c = this.weekEnd;
                timesheet.EMS_TM_Week__c = this.weekStart;
                timesheet.OwnerId = conRec.EMS_TM_user__c;
                
                timesheetList.add(timesheet);
            }
        }
        system.debug('===timesheetList==='+timesheetList);
        database.insert(timesheetList,false);
        
        Map<Id,EMS_Timesheet__c> timesheetMap = new Map<Id,EMS_Timesheet__c>();
        
        for(EMS_Timesheet__c etc : timesheetList){
            system.debug('==etc==='+etc);
            timesheetMap.put(etc.Resource__c,etc);
        }
       
        //Insert the records for an assignment.
        for(Contact con : filteredList){
            if(timesheetMap.containsKey(con.id)){
                system.debug('==con.Assignments__r==='+con.Assignments__r);
            for(EMS_TM_Assignment__c assignments : con.Assignments__r){
                EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
                lineitem.EMS_Timesheet__c = timesheetMap.get(con.id).Id;
                lineitem.OwnerId = timesheetMap.get(con.id).OwnerId;
                lineitem.EMS_TM_ProjectTask__c = assignments.EMS_TM_AssignedAs__c;
                lineitem.Assignment__c = assignments.Id;
                lineitem.EMS_TM_Project__c = assignments.EMS_TM_ProjectName_Asgn__c;
                lineitem.EMS_TM_Mon__c = 0;
                lineitem.EMS_TM_Wed__c = 0;
                lineitem.EMS_TM_Tue__c = 0;
                lineitem.EMS_TM_Thu__c = 0;
                lineitem.EMS_TM_Fri__c = 0;
                lineitem.Status__c = 'Saved';
                timesheetlineItemsList.add(lineitem);
                
            }
            }
        }
        system.debug('=====timesheetlineItemsList===='+timesheetlineItemsList);
        try{
            insert timesheetlineItemsList;
        }catch(exception ex){
            system.debug('=====ex===='+ex);
            LogException.logHandledException(ex, 'BatchToCreateTimesheets', 'execute');
        }
        
    }
    
      /**
* @author Subba
* @date 22/01/2023
* @description process the failures.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void finish(Database.BatchableContext BC) {
        
    }
    

}