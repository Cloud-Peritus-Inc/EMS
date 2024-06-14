public class UpdateCompOffrecord implements TriggerAction.AfterUpdate{
    
     public void afterUpdate(List<EMS_Timesheet__c> newList,List<EMS_Timesheet__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'UpdateCompOffrecord.afterUpdate() : BEGIN');
        Map<id,EMS_Timesheet__c> timesheetOldMap = new Map<id,EMS_Timesheet__c>(oldList);
        //updatedcompOffRecord(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'UpdateCompOffrecord.afterUpdate() : END');       
    }
    public static void updatedcompOffRecord(List<EMS_Timesheet__c> newTimesheetList,Map<Id,EMS_Timesheet__c> oldTimesheetMap){
        SYstem.debug('*newTimesheetList'+newTimesheetList);
        SYstem.debug('*oldTimesheetMap'+oldTimesheetMap);
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Date> resourecTimesheetList = new Map<Id,Date>();
        Map<String,Decimal> compoffUpadteValues = new Map<String,Decimal>();
        for(EMS_Timesheet__c timesheetRec:newTimesheetList){
            if((timesheetRec.EMS_TM_Sat__c != oldTimesheetMap.get(timesheetRec.Id).EMS_TM_Sat__c||
               timesheetRec.EMS_TM_Sun__c != oldTimesheetMap.get(timesheetRec.Id).EMS_TM_Sun__c)  
               && timesheetRec.EMS_TM_Status__c =='Submitted' && timesheetRec.Resource__c != NULL
              ){
                  
                  contactIds.add(timesheetRec.Resource__c);
                  resourecTimesheetList.put(timesheetRec.Resource__c,timesheetRec.Week_Start_Date__c);
                  String Key = timesheetRec.Resource__c+''+timesheetRec.Week_Start_Date__c;
                  SYstem.debug('**Key'+key);
                  compoffUpadteValues.put(Key,(timesheetRec.EMS_TM_Sat__c+timesheetRec.EMS_TM_Sun__c));
              }
            
        }
        SYstem.debug('resourecTimesheetList'+resourecTimesheetList);
        System.debug('compoffUpadteValues'+compoffUpadteValues);
        
        List<EMS_LM_Leave_Credit__c> updatedLeaveCredtlist = new List<EMS_LM_Leave_Credit__c>();
        for(EMS_LM_Leave_Credit__c leaveCredtRec:[Select Id 
                                                           FROM EMS_LM_Leave_Credit__c 
                                                           WHERE EMS_LM_Employee__c IN :resourecTimesheetList.keyset()
                                                           AND CompOff_Week__c IN: resourecTimesheetList.values()]){
                          String key = leaveCredtRec.EMS_LM_Employee__c+''+leaveCredtRec.CompOff_Week__c;
                                                               System.debug('***key'+key);
                                                               if(compoffUpadteValues.containsKey(key)){
                                                                   SYstem.debug('Key IF');
                                                                leaveCredtRec.EMS_LM_Leaves_Credited__c =compoffUpadteValues.get(key)/8;   
                                                               }
                                                               updatedLeaveCredtlist.add(leaveCredtRec);
            
        }
        try{
            If(!updatedLeaveCredtlist.IsEmpty()){
            Update updatedLeaveCredtlist;
        }           
        }catch(Exception e){
            LogException.logHandledException(e, 'UpdateCompOffrecord', 'UpdateCompOffrecord');
         System.debug('UpdateCompOffrecord'+e.getMessage());  
         System.debug('UpdateCompOffrecord'+e.getLineNumber());
        }
         
        
    }

}