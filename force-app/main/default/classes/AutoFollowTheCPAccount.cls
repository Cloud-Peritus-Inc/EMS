/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  AutoFollowTheCPAccount create active goals for users
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
public without sharing class AutoFollowTheCPAccount implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
 
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
        System.debug(LoggingLevel.DEBUG, 'AutoFollowTheCPAccount.afterInsert() : BEGIN');
        AutoFollow(newList,null);
        System.debug(LoggingLevel.DEBUG, 'AutoFollowTheCPAccount.afterInsert() : END');       
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
        System.debug(LoggingLevel.DEBUG, 'AutoFollowTheCPAccount.afterUpdate() : BEGIN');
        AutoFollow(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'AutoFollowTheCPAccount.afterUpdate() : END');       
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
    public void AutoFollow(List<Contact> newlist,Map<Id,Contact> oldMap) {
        List<Contact> filteredContacts = new List<Contact>();
        List<EntitySubscription> subscriptions = new List <EntitySubscription>();
        for(Contact con : newlist){
           contact cold =  oldMap != null ? oldMap.get(con.Id) : null;
            if(con.RecordTypeId==ContactConstant.RESOURCE_RECORDTYPEID && con.EMS_TM_User__c != null 
               && (cold == null || con.EMS_TM_User__c != cold.EMS_TM_User__c)){
                   filteredContacts.add(con); 
            }   
        }
       
        if(!filteredContacts.isEmpty()){
            List<Network> networkList = [SELECT id, name FROM Network where name = 'Grid'];
            List<Account> accList = [SELECT Id FROM Account WHERE Name = 'Cloud Peritus Inc' LIMIT 1];
            if(!accList.isEmpty() && !networkList.isEmpty()){
                for(Contact con : filteredContacts){
                    if(con.AccountId == accList[0].Id){
                    subscriptions.add(new EntitySubscription(NetworkId=networkList[0].Id,ParentId = con.AccountId,SubscriberId = con.EMS_TM_User__c )); 
                    }
                }
            }
        }
        
        try{
           insert subscriptions; 
        }catch(exception ex){
           LogException.logHandledException(ex, 'AutoFollowTheCPAccount', 'AutoFollow');  
        }
        
    }
    

}