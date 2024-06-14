/**
* @author Suneel & Rakshitha
* @date 10/01/2023
* @description  whenever project status is completed assignments status of the corresponding  
*               also be closed
*
*               Test code coverage provided by the following test class:
*               - CP_ProjectStatusUpdateTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_ProjectStatusUpdate implements TriggerAction.AfterUpdate{
    /**
* @author Suneel/Rakshitha
* @date 10/01/2023
* @description After Update 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<EMS_TM_Project__c> newList, List<EMS_TM_Project__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'CP_ProjectStatusUpdate.afterUpdate() : BEGIN');
        Map<Id,EMS_TM_Project__c> oldMap = new Map<Id,EMS_TM_Project__c>(oldList);
        assignmentStatusUpdate(newList,oldMap);
        System.debug(LoggingLevel.DEBUG, 'CP_ProjectStatusUpdate.afterUpdate() : END');       
    }
    /**
*{Purpose} - Method to change the assignments status 
whenever project status is updated
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    private void assignmentStatusUpdate(List<EMS_TM_Project__c> projectList, Map<Id,EMS_TM_Project__c> oldMap){
        Set<id> projectIds = new set<id>();
        Map<Id,EMS_TM_Project__c> projectMap = new Map<Id,EMS_TM_Project__c>();
        for (EMS_TM_Project__c proj : projectList){
            if(proj.EMS_TM_Status__c == 'Completed' && proj.EMS_TM_Status__c != oldMap.get(proj.Id).EMS_TM_Status__c){
                projectIds.add(proj.Id); projectMap.put(proj.Id,proj);
            }   
        }
        System.debug('projectIds'+projectIds);
        List<EMS_TM_Assignment__c> assignList = new List<EMS_TM_Assignment__c>();
        for (EMS_TM_Assignment__c assignData: [SELECT Id, 
                                               EMS_TM_ProjectName_Asgn__c, 
                                               EMS_TM_Status_Asgn__c,
                                               EMS_TM_EndDate_Asgn__c
                                               FROM EMS_TM_Assignment__c 
                                               WHERE EMS_TM_ProjectName_Asgn__c IN:projectMap.keyset() 
                                               AND EMS_TM_Status_Asgn__c != 'Closed' ]){
                                                   assignData.EMS_TM_Status_Asgn__c ='Closed' ;
                                                   assignData.EMS_TM_EndDate_Asgn__c = projectMap.get(assignData.EMS_TM_ProjectName_Asgn__c).EMS_TM_EndDate__c;
                                                   assignList.add(assignData);   
                                               }
        System.debug('assignList'+assignList);
        try{
            if (!assignList.isEmpty()){
                update assignList;
            }
        }
        catch(exception exc){
            LogException.logHandledException(exc, 'CP_ProjectStatusUpdate', 'assignmentStatusUpdate');
        }
    }
}