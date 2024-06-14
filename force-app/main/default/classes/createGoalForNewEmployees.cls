/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  createGoalForNewEmployees create active goals for users
*
*               Test code coverage provided by the following test class:
*               -createGoalForNewEmployeesTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class createGoalForNewEmployees implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
 
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
    public void afterInsert(List<Contact> newList) {      
        System.debug(LoggingLevel.DEBUG, 'createGoalForNewEmployees.afterInsert() : BEGIN');
        createGoals(newList,null);
        System.debug(LoggingLevel.DEBUG, 'createGoalForNewEmployees.afterInsert() : END');       
    }
    
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
    public void afterUpdate(List<Contact> newList, List<contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'createGoalForNewEmployees.afterUpdate() : BEGIN');
        createGoals(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'createGoalForNewEmployees.afterUpdate() : END');       
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
    public static void createGoals(List<Contact> newlist,Map<Id,Contact> oldMap) {
        List<Contact> orgWideContact = new List<Contact>();
        List<Contact> roleLevelContact = new List<Contact>();
         List<Goal__c> goalList = new List<Goal__c>();
        for(Contact con : newlist){
           contact cold =  oldMap != null ? oldMap.get(con.Id) : null;
            if(con.RecordTypeId==ContactConstant.RESOURCE_RECORDTYPEID && con.EMS_RM_ApplicantStatus_Update__c == 'Active' && con.EMS_TM_User__c != null 
               && (cold == null || con.EMS_RM_ApplicantStatus_Update__c != cold.EMS_RM_ApplicantStatus_Update__c 
                   || con.EMS_TM_User__c != cold.EMS_TM_User__c)){
                orgWideContact.add(con);
            }
            
        }
        system.debug('==orgWideContact==='+orgWideContact);
         date dt = system.today();
        if(!orgWideContact.isEmpty()){
            for(Grid_Configuration__c configRec : [SELECT Id,Description__c,Name,Goal_End_Date__c,Goal_Start_Date__c,Grid_Configuration_Type__c,
                                         Navigation_address__c,is_Navigation_Required__c,Resource_Role__c 
                                         FROM Grid_Configuration__c 
                                         WHERE Grid_Configuration_Type__c = 'Org Level Goal' and Goal_Start_Date__c<=:dt AND Goal_End_Date__c>:dt]){
           for(contact con : orgWideContact){
            Goal__c goal = new Goal__c();
            goal.Resource__c = con.id;
            goal.End_Date__c = configRec.Goal_End_Date__c;
            goal.Goal_Name__c = configRec.Name;
            goal.Description__c = configRec.Description__c;
            goal.is_Navigation_Required__c = configRec.is_Navigation_Required__c;
            goal.Navigation_address__c = configRec.Navigation_address__c;
            goal.Start_Date__c = configRec.Goal_Start_Date__c;
            goal.Status__c = 'Active';
            goal.OwnerId = con.EMS_TM_User__c;
            goalList.add(goal);    
          } 
            
            } 
        }
         system.debug('==goalList==='+goalList);
         try{
           insert goalList; 
        }catch(exception ex){
           LogException.logHandledException(ex, 'createGoalForNewEmployees', 'createGoals');  
        }
        
        
    }

}