/**
    * @author Ramakrishna 
    * @date 07/02/2023
    * @description  timesheet Submitted update TimesheetRecord submitted except approved records.
    *
    *               Test code coverage provided by the following test class:
    *               - timesheetRecordSubmittedTest
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public class timesheetRecordSubmitted implements TriggerAction.AfterUpdate,TriggerAction.AfterInsert{
          /**
    * @author Ramakrishna
    * @date 07/02/2023
    * @description After Update 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterUpdate(List<EMS_timesheet__c> newList,List<EMS_timesheet__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordSubmitted.afterUpdate() : BEGIN');
        Map<id,EMS_timesheet__c> timesheetOldMap = new Map<id,EMS_timesheet__c>(oldList);
        updateTimeRectoSubmitted(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordSubmitted.afterUpdate() : END');       
    }
    
   /**
    * @author Ramakrishna
    * @date 07/02/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterInsert(List<EMS_timesheet__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordSubmitted.afterInsert() : BEGIN');
       // updateTimeRectoSubmitted(newList,Null);
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordSubmitted.afterInsert() : END');       
    }
    /**
    * @author Ramakrishna
    * @date 07/02/2023
    * @description In this method update TimesheetRecord submitted except approved records.
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    private static void updateTimeRectoSubmitted(List<EMS_timesheet__c> newList,map<Id,EMS_timesheet__c> oldmap){
        Set<Id> timesheetIdSet = new Set<Id>();
        
        for(EMS_timesheet__c t : newList){
            if((oldMap != null && oldMap.get(t.Id).EMS_TM_Status__c != t.EMS_TM_Status__c && t.EMS_TM_Status__c == 'Submitted' ) || 
               (oldmap ==null && t.EMS_TM_Status__c == 'Submitted')){
                     timesheetIdSet.add(t.Id);
                }
        }
        List<EMS_TM_Timesheet_Record__c> updatedTimesheetRecList = new List<EMS_TM_Timesheet_Record__c>();
        for(EMS_TM_Timesheet_Record__c et :[SELECT Id,
                                            		Status__c,
                                            		EMS_TM_Project__r.Approval_Needed__c 
                                            		FROM EMS_TM_Timesheet_Record__c 
                                            		WHERE EMS_Timesheet__c IN:timesheetIdSet]){
            if(et.Status__c !='Approved'){
                et.Status__c ='Submitted';
                updatedTimesheetRecList.add(et);
            }
        }
        
        try{
            update updatedTimesheetRecList;
        }catch(Exception e){
            System.debug('status'+e.getMessage());
            LogException.logHandledException(e, 'timesheetRecordSubmitted', 'timesheetRecordSubmitted');
        }
        
    }
}