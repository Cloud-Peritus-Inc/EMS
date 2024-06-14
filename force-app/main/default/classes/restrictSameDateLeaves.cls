/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  restrictSameDateLeaves Class to restrict the duplicate leaves
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
public without sharing class restrictSameDateLeaves implements TriggerAction.BeforeInsert{
    /**
* @author Subba Kalavala
* @date 2/22/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : BEGIN');
        restrictTheLeave(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to restrict the same date leaves 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void restrictTheLeave(List<EMS_LM_Leave_History__c> newlist) {
        set<String> resourcId = new set<String>();
        list<Date> startDate = new list<Date>();
        list<Date> endDate = new list<Date>();
        for(EMS_LM_Leave_History__c his : newlist){
            
            
                resourcId.add(his.EMS_LM_Contact__c);
           		startDate.add(his.EMS_LM_Leave_Start_Date__c);
           		endDate.add(his.EMS_LM_Leave_End_Date__c);
           
        }
         System.debug('======resourcId========'+resourcId);
         System.debug('======startDate========'+startDate);
         System.debug('======endDate========'+endDate);
        Map<Id,EMS_LM_Leave_History__c> resourceWithLeaves = new Map<Id,EMS_LM_Leave_History__c>();
        for(EMS_LM_Leave_History__c leave : [SELECT Id,EMS_LM_Status__c,EMS_LM_Contact__c,EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_End_Date__c FROM EMS_LM_Leave_History__c 
                                             WHERE EMS_LM_Status__c !='Cancelled' AND EMS_LM_Status__c !='Rejected' AND EMS_LM_Contact__c IN:resourcId AND 
                                            ((EMS_LM_Leave_Start_Date__c = :endDate AND EMS_LM_Leave_End_Date__c = :startDate) OR
                                             (EMS_LM_Leave_Start_Date__c IN :startDate OR EMS_LM_Leave_End_Date__c IN :endDate) OR (EMS_LM_Leave_Start_Date__c IN :endDate OR
                                             EMS_LM_Leave_End_Date__c IN :startDate))]){
            resourceWithLeaves.put(leave.EMS_LM_Contact__c,leave);
        }
    
       System.debug('======resourceWithLeaves========'+resourceWithLeaves);
        
        for(EMS_LM_Leave_History__c his : newlist){
            if(resourceWithLeaves.containsKey(his.EMS_LM_Contact__c)){
               his.addError('You already have a submitted leave request on the selected date(s). Consider applying for leave on some other dates.'); 
            }
        }
    }
}