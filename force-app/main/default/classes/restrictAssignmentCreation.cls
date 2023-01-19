/**
* @author SAI
* @date 10/01/2023
* @description  restrictAssignmentCreation Class to when Project status as a Commpleate
*               then need restric the Assignment
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
public class restrictAssignmentCreation implements TriggerAction.BeforeInsert{

    public void beforeInsert(List<EMS_TM_Assignment__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictAssignmentCreation.afterInsert() : BEGIN');
        restrictAssCreationForClosedProjects(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictAssignmentCreation.afterInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to restrict the project manager not to craete any assignments for Inactive Projects
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    private void restrictAssCreationForClosedProjects(List<EMS_TM_Assignment__c> assigndata) {
    
        set<id> projectIds = new set<id>();        
        Map<id,EMS_TM_Project__c> projMap = new Map<id,EMS_TM_Project__c>();
        for(EMS_TM_Assignment__c assign : assigndata ){
            if(assign.EMS_TM_ProjectName_Asgn__c != null ){
                projectIds.add(assign.EMS_TM_ProjectName_Asgn__c); 
            }
        }
        
         for(EMS_TM_Project__c projectRec : [SELECT id, EMS_TM_Status__c 
                                                FROM EMS_TM_Project__c 
                                                WHERE id IN :projectIds
                                                AND EMS_TM_Status__c = 'Completed']){
            projMap.put(projectRec.Id,projectRec);                                        
          }
        
         for(EMS_TM_Assignment__C assignL :assigndata ){
             if(projMap.containsKey(assignL.EMS_TM_ProjectName_Asgn__c)){
               assignL.addError(Label.Error_Message_For_Assignment_Restriction);  
             } 
         }
        
    }
}