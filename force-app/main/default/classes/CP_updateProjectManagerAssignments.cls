/**
* @author : Shubham Maske
* @date   : 19/09/2023
* @description : Update the ProjectAssignment records on Update 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 19/09/2023    Shubham Maske           Update the ProjectAssignment records on Update
* ====================================================================================================
**/
public class CP_updateProjectManagerAssignments implements TriggerAction.AfterUpdate {

    public void afterUpdate(List<EMS_TM_Project__c> newList, List<EMS_TM_Project__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'CP_updateProjectManagerAssignments.afterUpdate() : BEGIN');
        Map<Id,EMS_TM_Project__c> oldMap = new Map<Id,EMS_TM_Project__c>(oldList);
        updateProjectManagerFieldValuesHandler(newList,oldMap);
        System.debug(LoggingLevel.DEBUG, 'CP_updateProjectManagerAssignments.afterUpdate() : END');       
    }
    
    /**
*   Purpose - When a Project Manager( either Onshore or Offshore) on a Project record gets replaced by other Project Manager,
*	then the Project Manager 'STATUS' on that Project should 'CLOSED' 
*	STATUS = CLOSED
*	Project END DATE = Date on which the Project Manager got replaced by other PM.(LastModifiedDate)
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   19/09/2023    Shubham Maske         Initial Version
*   ====================================================================================================
**/
    private void updateProjectManagerFieldValuesHandler(List<EMS_TM_Project__c> projectList, Map<Id,EMS_TM_Project__c> oldMap){
        System.debug('INSIDE updateProjectManagerFieldValuesHandler ');
        List<EMS_TM_Assignment__c> assignmentsToUpdate = new List<EMS_TM_Assignment__c>();
        
        for (EMS_TM_Project__c project : projectList) {
            EMS_TM_Project__c oldProject = oldMap.get(project.Id);
            
            // Check if Offshore_Project_Manager__c has changed
            if (project.Offshore_Project_Manager__c != oldProject.Offshore_Project_Manager__c) {
                // Find project assignments with the old Offshore Project Manager
                List<EMS_TM_Assignment__c> assignments = [SELECT Id, EMS_TM_EmployeeName__c, EMS_TM_Status_Asgn__c, EMS_TM_EndDate_Asgn__c
                                                          FROM EMS_TM_Assignment__c
                                                          WHERE EMS_TM_ProjectName_Asgn__c = :project.Id
                                                          AND EMS_TM_EmployeeName__c = :oldProject.Offshore_Project_Manager__c];
                
                for (EMS_TM_Assignment__c assignment : assignments) {
                    assignment.EMS_TM_Status_Asgn__c = 'Closed';
                    assignment.EMS_TM_EndDate_Asgn__c = Date.today();
                    assignmentsToUpdate.add(assignment);
                }
            }
            
            // Check if Project_Manager__c has changed
            if (project.Project_Manager__c != oldProject.Project_Manager__c) {
                // Find project assignments with the old Project Manager
                List<EMS_TM_Assignment__c> assignments = [SELECT Id, EMS_TM_EmployeeName__c, EMS_TM_Status_Asgn__c, EMS_TM_EndDate_Asgn__c
                                                          FROM EMS_TM_Assignment__c
                                                          WHERE EMS_TM_ProjectName_Asgn__c = :project.Id
                                                          AND EMS_TM_EmployeeName__c = :oldProject.Project_Manager__c];
                
                for (EMS_TM_Assignment__c assignment : assignments) {
                    assignment.EMS_TM_Status_Asgn__c = 'Closed';
                    assignment.EMS_TM_EndDate_Asgn__c = Date.today();
                    assignmentsToUpdate.add(assignment);
                }
            }
        }
        System.debug('assignmentsToUpdate  ' +  assignmentsToUpdate);
        // Update assignments
        try{
            if (!assignmentsToUpdate.isEmpty()) {
                update assignmentsToUpdate;
            }
        }
        catch(exception exc){
            LogException.logHandledException(exc, 'CP_updateProjectManagerAssignments', 'updateProjectManagerFieldValuesHandler');
        }
    }
}