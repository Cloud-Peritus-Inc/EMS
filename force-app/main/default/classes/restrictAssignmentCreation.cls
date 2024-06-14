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
*   {Purpose} - Method to restrict the project manager not to create any assignments for Inactive Projects
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
        
        User loggedInUser = [SELECT Id,Profile.Name,TA_Admin__c FROM User Where Id=:Userinfo.getUserId()];
        System.debug(' loggedInUser  :: ' + loggedInUser.TA_Admin__c + ' ===== ' + loggedInUser.Profile.Name + ' ----- ' + loggedInUser.Id);

        for(EMS_TM_Project__c projectRec : [SELECT id, EMS_TM_Status__c,Project_Manager__c,Project_Manager__r.EMS_TM_User__c,
                                            Offshore_Project_Manager__c,Offshore_Project_Manager__r.EMS_TM_User__c
                                            FROM EMS_TM_Project__c 
                                            WHERE id IN :projectIds
                                           ]){
                                               projMap.put(projectRec.Id,projectRec);                                        
                                           }
        
        for(EMS_TM_Assignment__C assignL :assigndata ){
            
            if(projMap.containsKey(assignL.EMS_TM_ProjectName_Asgn__c)){
                if(projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).EMS_TM_Status__c == 'Completed'){
                    assignL.addError(Label.Error_Message_For_Assignment_Restriction); 
                }else{
                    
                    if ( (loggedInUser.Profile.Name != 'System Administrator') && (loggedInUser.Profile.Name != 'Employee - HR(Community)') && (loggedInUser.TA_Admin__c != true))  {
                        System.debug('Project Manager 1 ' + projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).Project_Manager__r.EMS_TM_User__c);
                        System.debug('Project Manager 2 ' + projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).Offshore_Project_Manager__r.EMS_TM_User__c);
                        System.debug(projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).Project_Manager__r.EMS_TM_User__c != loggedInUser.id);
                        System.debug(projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).Offshore_Project_Manager__r.EMS_TM_User__c != loggedInUser.id);
                        
                        if (projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).Project_Manager__r.EMS_TM_User__c != loggedInUser.id &&
                            projMap.get(assignL.EMS_TM_ProjectName_Asgn__c).Offshore_Project_Manager__r.EMS_TM_User__c != loggedInUser.id) {
                                assignL.addError('Admin or respective Project Manager is allowed to assign the resource to the project');
                            }
                    } 
                }
            }
            
        }
    }
}