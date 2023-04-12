/**
* @author RK
* @date 19/01/2023
* @description Master Trigger for the Assignment object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class updateActiveAssignmentOnContact implements TriggerAction.AfterDelete{
    
    /**
* @author RK 
* @date 19/01/2023
* @description After Delete 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterDelete(List<EMS_TM_Assignment__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'updateActiveAssignmentOnContact.afterDelete() : BEGIN');
        System.debug(LoggingLevel.DEBUG, 'updateActiveAssignmentOnContact.afterDelete() : END');       
    }
    /**
* @author RK 
* @date 19/01/2023
* @description After Delete 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/ 
    private void activeAssignmentCountOnContact(List<EMS_TM_Assignment__c> newAssignment){
        
        Set<Id> contactIds = new Set<Id>();
        for(EMS_TM_Assignment__c assignmentRec : newAssignment){
            contactIds.add(assignmentRec.EMS_TM_EmployeeName__c);
        }
        
         List<EMS_TM_Assignment__c> assignLists = [SELECT Id,
                                                           EMS_TM_Status_Asgn__c,
                                                           EMS_TM_EmployeeName__c
                                                           FROM EMS_TM_Assignment__c 
                                                           WHERE EMS_TM_EmployeeName__c IN :contactIds 
                                                           AND EMS_TM_Status_Asgn__c = 'Active'];
        
        map<Id,List<EMS_TM_Assignment__c>> assignMap = new map<Id,List<EMS_TM_Assignment__c>>();
        for(EMS_TM_Assignment__c assignmentRec:assignLists){
            if(assignMap.containsKey(assignmentRec.EMS_TM_EmployeeName__c)){
               
                assignMap.get(assignmentRec.EMS_TM_EmployeeName__c).add(assignmentRec);
            }else{
                assignMap.put(assignmentRec.EMS_TM_EmployeeName__c,new List<EMS_TM_Assignment__c>{assignmentRec});
            }
            
                       
        }
        
        for(Contact contactRec :[SELECT Id, 
                                         Current_Active_Assignments__c 
                                         FROM Contact 
                                         WHERE Id IN :contactIds]){
                                             if(assignMap.containskey(contactRec.Id)){
                                                 
                                             //   contactRec.Current_Active_Assignments__c = assignMap.get(contactRec.Id);
                                             }
                                             
            
        }
        
    }
    
}