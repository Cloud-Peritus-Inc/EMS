/**
    * @author RamaKrishna P
    * @date 30/01/2023
    * @description  EMS_TM_Auto_Create_Timsheet to check the current week employee doesnt have timesheet automatically 
    * 				create timesheet for Employee.
    *
    *               Test code coverage provided by the following test class:
    *               - 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
global class EMS_TM_Auto_Create_Timsheet implements Schedulable {
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
    global void execute(SchedulableContext cnt) {
        
        List<Id> newTimesheetUsers = new List<Id>();
        List<Id> timesheetUsers = new List<Id>();
        List<EMS_Timesheet__c> newTimeSheets = new List<EMS_Timesheet__c>();
        
        Date today = Date.today();
        Date weekStart = today.toStartofWeek().addDays(1);
        Date weekEnd = today.toStartofWeek().addDays(7);
        String completeWeek = weekStart + ' - ' + weekEnd;
        Set<Id> userIds = new Set<Id>();
        for(Contact ContactRec:[SELECT Id,
                                        EMS_TM_user__C,
                                        EMS_Domain_Technology__c 
                                        FROM Contact
                                        WHERE Timesheet_NoNeed__c = false
                                        AND RecordtypeId =:ContactConstant.RESOURCE_RECORDTYPEID]){
                                    if(ContactRec.EMS_TM_User__c != Null){
                                        userIds.add(ContactRec.EMS_TM_User__c);  
                                    }                                   
                                }
        for (EMS_Timesheet__c timesheet : [SELECT Id,
                                                   User__c, 
                                                   EMS_TM_Week__c
                                                   FROM EMS_Timesheet__c
                                                   WHERE EMS_TM_Week__c = :weekStart]) {
            timesheetUsers.add(timesheet.user__c);
        }
        
        for (User userRec : [SELECT Id 
                                  FROM User 
                                  WHERE Id IN:userIds 
                                  AND isActive = true]) {
                              if (!(timesheetUsers.contains(userRec.Id))) {
                                  newTimesheetUsers.add(userRec.Id);
                              }
                          }
        
        for (Id userId : newTimesheetUsers) {
            EMS_Timesheet__c timesheet = new EMS_Timesheet__c();
            timesheet.EMS_TM_Sun__c                         = 0;
            timesheet.EMS_TM_Mon__c                         = 0;
            timesheet.EMS_TM_Tue__c                         = 0;
            timesheet.EMS_TM_Wed__c                         = 0;
            timesheet.EMS_TM_Thu__c                         = 0;
            timesheet.EMS_TM_Fri__c                         = 0;
            timesheet.EMS_TM_Sat__c                         = 0;
            timesheet.EMS_TM_Week__c                        = weekStart;
            timesheet.EMS_TM_Status__c                      = EMS_TM_GlobalConstants.STATUS_SAVED;
            timesheet.User__c                               = userId;
            timesheet.EMS_TM_Status__c                      = 'New';
            timesheet.Week_Start_Date__c	                = weekStart;
            timesheet.Week_End_Date__c	                    = weekEnd;
            timesheet.OwnerId                               = userId;
            newTimeSheets.add(timesheet);
        }
        
        try{
            Database.insert(newTimeSheets, false);
        }catch(Exception e){
            LogException.logHandledException(e, 'EMS_TM_Auto_Create_TimsheetSchedule', 'EMS_TM_Auto_Create_TimsheetSchedule');
        }
    }
}