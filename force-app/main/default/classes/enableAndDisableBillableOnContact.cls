/**
    * @author RK & SAI
    * @date 10/01/2023
    * @description  enableAndDisableBillableOnContact to check the Active & Billable  on assignments for Employees at the time of craete or update any  
    *               record then update the Contact and inbilling check box will be true.
    *
    *               Test code coverage provided by the following test class:
    *               - enableAndDisableBillableOnContactTest
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public without sharing class enableAndDisableBillableOnContact implements TriggerAction.AfterUpdate,TriggerAction.AfterInsert{
    /**
    * @author RK & SAI
    * @date 10/01/2023 
    * @description After Update 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterUpdate(List<EMS_TM_Assignment__c> newList,List<EMS_TM_Assignment__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'enableAndDisableBillableOnContact.afterUpdate() : BEGIN');
        Map<id,EMS_TM_Assignment__c> assignmentOldMap = new Map<id,EMS_TM_Assignment__c>(oldList);
        enableAndDisableBillable(newList,assignmentOldMap);
        System.debug(LoggingLevel.DEBUG, 'enableAndDisableBillableOnContact.afterUpdate() : END');       
    }
    
   /**
    * @author RK & SAI
    * @date 10/01/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterInsert(List<EMS_TM_Assignment__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'enableAndDisableBillableOnContact.afterInsert() : BEGIN');
        enableAndDisableBillable(newList,Null);
        System.debug(LoggingLevel.DEBUG, 'enableAndDisableBillableOnContact.afterInsert() : END');       
    }
    
    /**
    *   {Purpose} - Method to check the Active & Billable  on assignments for Employees at the time of craete or update any  
    *               record then update the Contact and inbilling check box will be true. 
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
        
    private void enableAndDisableBillable(List<EMS_TM_Assignment__c> newAssignment,Map<Id,EMS_TM_Assignment__c> oldMap){

        Set<id> contactIds = new Set<id>();
        for(EMS_TM_Assignment__c assignRec: newAssignment){
            if((oldMap != null && (oldMap.get(assignRec.id).EMS_TM_Status_Asgn__c != assignRec.EMS_TM_Status_Asgn__c || oldMap.get(assignRec.id).EMS_TM_Billable__c != assignRec.EMS_TM_Billable__c)) || oldmap ==null ){
                contactIds.add(assignRec.EMS_TM_EmployeeName__c);                
            }
        }
        Set<Id> updatedAssignmentContactIds  = new Set<Id>();
        for(EMS_TM_Assignment__c assignRecord : [SELECT id,
                                                          EMS_TM_EmployeeName__c,
                                                          EMS_TM_Status_Asgn__c,
                                                          EMS_TM_Billable__c 
                                                          FROM EMS_TM_Assignment__c 
                                                          WHERE EMS_TM_Status_Asgn__c = 'Active' 
                                                          AND EMS_TM_Billable__c = true 
                                                          AND EMS_TM_EmployeeName__c IN : contactIds]){                                                            
                                                            updatedAssignmentContactIds.add(assignRecord.EMS_TM_EmployeeName__c);                                                                                                                
                                                         }
        list<contact> updatedConList = new list<contact>();
        for(contact contactRec :[SELECT Id, 
                                          Official_Mail__c, 
                                          EMS_TM_In_Billing__c 
                                          FROM Contact 
                                          WHERE id IN:contactIds ]){                                     
                                             if (updatedAssignmentContactIds.contains(contactRec.Id)){                                           
                                                 contactRec.EMS_TM_In_Billing__c = true;                                                
                                             }
                                             else{                                                
                                                 contactRec.EMS_TM_In_Billing__c = false ;
                                             }                                             
                                             updatedConList.add(contactRec);
                               		  	  }
                                           try{
                                                    if(!updatedConList.isEmpty()){
                                                        update updatedConList;
                                                    }
                                               }catch(Exception e){
                                                LogException.logHandledException(e, 'enableAndDisableBillableOnContact', 'enableAndDisableBillable');
                                               }
    }
    
}