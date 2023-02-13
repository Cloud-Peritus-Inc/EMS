/**
    * @author Ramakrishna 
    * @date 09/02/2023
    * @description  editTimeshhetwhenRejected  to check weather any one the timesheetRecord is related timesheet 
    *               when we will give edit access for Timesheet.
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
public class editTimeshhetwhenRejected implements TriggerAction.AfterUpdate{
    
          /**
    * @author Ramakrishna
    * @date 09/02/2023
    * @description After Update 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterUpdate(List<EMS_TM_Timesheet_Record__c> newList,List<EMS_TM_Timesheet_Record__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordSubmitted.afterUpdate() : BEGIN');
        Map<id,EMS_TM_Timesheet_Record__c> timesheetOldMap = new Map<id,EMS_TM_Timesheet_Record__c>(oldList);
        wheathertimesheetRejctedupdatetimesheet(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordSubmitted.afterUpdate() : END');       
    }
     /**
    * @author Ramakrishna
    * @date 09/02/2023
    * @description In this method update Timesheet when timesheetRecord is rejected.
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public static void wheathertimesheetRejctedupdatetimesheet(List<EMS_TM_Timesheet_Record__c> newTimeSheetList,Map<Id,EMS_TM_Timesheet_Record__c> oldMap){        
        Set<Id> timeSheeIds = new Set<Id>();
        for(EMS_TM_Timesheet_Record__c timesheetRec:newTimeSheetList){            
            if(timesheetRec.EMS_Timesheet__c != null && oldMap.get(timesheetRec.Id).Status__c != timesheetRec.Status__c){
                timeSheeIds.add(timesheetRec.EMS_Timesheet__c);
            }            
        }
        Set<Id> timesheetUpdatedIds = new Set<Id>();
        for(EMS_TM_Timesheet_Record__c timesheetRec:[SELECT Id, 
                                                     		EMS_Timesheet__c, 
                                                     		Status__c 
                                                     		FROM EMS_TM_Timesheet_Record__c
                                                    		WHERE EMS_Timesheet__c IN:timeSheeIds 
                                                            AND Status__c ='Rejected']){
                                timesheetUpdatedIds.add(timesheetRec.EMS_Timesheet__c);                            
            
        }
        List<EMS_Timesheet__c> updatedTimesheetList = new List<EMS_Timesheet__c>();        
        for(EMS_Timesheet__c timeRec :[SELECT Id, 
                                       			EMS_TM_Status__c 
                                       			FROM EMS_Timesheet__c
                                      			WHERE Id IN:timeSheeIds]){
                                                if (timesheetUpdatedIds.contains(timeRec.Id)){                                           
                                                 timeRec.EMS_TM_Status__c ='Saved';                                                
                                             }
                                                    updatedTimesheetList.add(timeRec);            
        }
        try{
            if(!updatedTimesheetList.isEmpty()){
                update updatedTimesheetList;
            }
        }catch(Exception e){
            LogException.logHandledException(e, 'editTimeshhetwhenRejected', 'wheathertimesheetRejctedupdatetimesheet');
        }        
    }
}