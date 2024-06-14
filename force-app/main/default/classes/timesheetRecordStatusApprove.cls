/**
    * @author Ramakrishna 
    * @date 24/01/2023
    * @description  timesheetRecordStatusApprove to check the TimesheetRecord related Project Approval neeed craete any  
    *               record then update the TimesheetRecord Status to Approved.
    *
    *               Test code coverage provided by the following test class:
    *               - timesheetRecordStatusApproveTest
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public class timesheetRecordStatusApprove implements TriggerAction.beforeInsert,TriggerAction.beforeUpdate {   
    
     /**
    * @author Ramakrishna
    * @date 24/01/2023
    * @description BeforeInsert
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void beforeInsert(List<EMS_TM_Timesheet_Record__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordStatusApprove.beforeInsert() : BEGIN');
        timesheetRecAutoUpdate(newList,null);
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordStatusApprove.beforeInsert() : END');       
    }
    
      /**
    * @author Ramakrishna
    * @date 24/01/2023
    * @description BeforeUpdate
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void beforeUpdate(List<EMS_TM_Timesheet_Record__c> newList,List<EMS_TM_Timesheet_Record__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordStatusApprove.beforeUpdate() : BEGIN');
         Map<id,EMS_TM_Timesheet_Record__c> timesheetOldMap = new Map<id,EMS_TM_Timesheet_Record__c>(oldList);
        timesheetRecAutoUpdate(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'timesheetRecordStatusApprove.beforeUpdate() : END');       
    }
    /**
    *   {Purpose} - Method to check the TimesheetRecord Related Project Approval Need or not if not record status updated to Approved. 
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    
    private void timesheetRecAutoUpdate(List<EMS_TM_Timesheet_Record__c> newTimeSheetList,Map<Id,EMS_TM_Timesheet_Record__c> oldMap){
          Set<Id> projectIdSet = new Set<Id>();
        Set<Id> timesheetIdsSet = new Set<Id>();
        for(EMS_TM_Timesheet_Record__c timeSheetRec :newTimeSheetList){ 
            if((oldMap != null && (oldMap.get(timesheetRec.Id).Status__c != timesheetRec.Status__c || 
                                   timesheetRec.EMS_TM_Fri__c != oldMap.get(timesheetRec.Id).EMS_TM_Fri__c ||
                                   timesheetRec.EMS_TM_Mon__c != oldMap.get(timesheetRec.Id).EMS_TM_Mon__c ||
                                   timesheetRec.EMS_TM_Sat__c != oldMap.get(timesheetRec.Id).EMS_TM_Sat__c ||
                                   timesheetRec.EMS_TM_Sun__c != oldMap.get(timesheetRec.Id).EMS_TM_Sun__c ||
                                   timesheetRec.EMS_TM_Thu__c != oldMap.get(timesheetRec.Id).EMS_TM_Thu__c ||
                                   timesheetRec.EMS_TM_Wed__c != oldMap.get(timesheetRec.Id).EMS_TM_Wed__c ||
                                   timesheetRec.EMS_TM_Tue__c != oldMap.get(timesheetRec.Id).EMS_TM_Tue__c 
                                  ))|| oldMap == null){
          ProjectIdSet.add(timeSheetRec.EMS_TM_Project__c);
            if(timeSheetRec.EMS_Timesheet__c != null){
                timesheetIdsSet.add(timeSheetRec.EMS_Timesheet__c);
            }
            }
        }
        Set<Id> projectNewIds = new Set<Id>();
        for(EMS_TM_Project__c projectRec:[SELECT Id,
                                                  Approval_Needed__c 
                                                  FROM EMS_TM_Project__c 
                                                  WHERE Id IN:ProjectIdSet 
                                                  AND Approval_Needed__c ='No']){
            projectNewIds.add(projectRec.Id);
        }
        
        Map<Id,EMS_Timesheet__c> timesheetMap = new Map<Id,EMS_Timesheet__c>();
        for(EMS_Timesheet__c  timeshhetData :[SELECT Id,
                                                       EMS_TM_Status__c 
                                                       FROM EMS_Timesheet__c 
                                                       WHERE Id IN:timesheetIdsSet]){
            timesheetMap.put(timeshhetData.Id,timeshhetData);
                        
        }
         for(EMS_TM_Timesheet_Record__c newtimeSheetRec :newTimeSheetList){ 
             if(projectNewIds.contains(newtimeSheetRec.EMS_TM_Project__c) && newtimeSheetRec.Status__c =='Submitted'){
                 newtimeSheetRec.Status__c='Approved';
             }else{

             }
        }
        
    }
}