/**
    * @author Ramakrishna 
    * @date 27/01/2023
    * @description  deleteCompOffRecord to check the TimesheetRecord weekend values updated to null then delete the   
    *               comOffRecord related to timesheet.
    *
    *               Test code coverage provided by the following test class:
    *               - deleteCompOffRecordTest
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public class deleteCompOffRecord implements TriggerAction.AfterUpdate{
       /**
    * @author Ramakrishna
    * @date 27/01/2023
    * @description After Update 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterUpdate(List<EMS_Timesheet__c> newList,List<EMS_Timesheet__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'deleteCompOffRecord.afterUpdate() : BEGIN');
        Map<id,EMS_Timesheet__c> timesheetOldMap = new Map<id,EMS_Timesheet__c>(oldList);
        deleteCompoff(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'deleteCompOffRecord.afterUpdate() : END');       
    }
    /**
    *   {Purpose} - Method to check the TimesheetRecord weekend values updated to null then delete the   
    *               comOffRecord related to timesheet 
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    private void deleteCompoff(List<EMS_Timesheet__c> newTimesheetList,Map<Id,EMS_Timesheet__c> oldTimesheetMap){
        Map<Id,Date> newtimesheetMap = new Map<Id,Date>();
        for(EMS_Timesheet__c timesheetRec:newTimesheetList){
            if((timesheetRec.EMS_TM_Sat__c != oldTimesheetMap.get(timesheetRec.Id).EMS_TM_Sat__c && timesheetRec.EMS_TM_Sat__c ==0)||
               (timesheetRec.EMS_TM_Sun__c != oldTimesheetMap.get(timesheetRec.Id).EMS_TM_Sun__c && timesheetRec.EMS_TM_Sun__c ==0)
              ) {
                 newtimesheetMap.put(timesheetRec.User__c,timesheetRec.startweek__c);
            }
        }
        System.debug('newtimesheetMap'+newtimesheetMap);
        Map<Id,Date> contactMap = new Map<Id,Date>();
        for(Contact contactRec:[SELECT Id,EMS_TM_User__c from contact WHERE EMS_TM_User__c IN: newtimesheetMap.keyset()]){
            if(contactRec.EMS_TM_User__c != null){
                contactMap.put(contactRec.Id,newtimesheetMap.get(contactRec.EMS_TM_User__c));
            }           
        }
        System.debug('contactMap'+contactMap);
        List<EMS_LM_Leave_Credit__c> compOffList =[Select Id 
                                                           FROM EMS_LM_Leave_Credit__c 
                                                           WHERE EMS_LM_Employee__c IN :contactMap.keyset()
                                                           AND CompOff_Week__c IN: contactMap.values()];  
        System.debug('compOffList'+compOffList);
        try{
            if(!compOffList.IsEmpty()){
                delete compOffList;
            }            
        }catch(Exception e){
            LogException.logHandledException(e, 'deleteCompOffRecord', 'deleteCompoff');
         System.debug('Deletecompoff'+e.getMessage());  
         System.debug('Deletecompoff'+e.getLineNumber());
        }
    }
}