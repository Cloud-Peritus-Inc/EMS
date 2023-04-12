/**
* @author Eswar
* @date 10/02/2023
* @description  Whenever task is completed, tasks checklist should be checked in respective contact.
*
*               Test code coverage provided by the following test class:
*               - CP_TasksChecklistUpdateTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class CP_TasksChecklistUpdate implements TriggerAction.AfterUpdate{
	/**
    * @author Eswar
    * @date 10/02/2023
    * @description After Update
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterUpdate(List<Task> newList, List<Task> oldList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_TasksChecklistUpdate.afterUpdate() : BEGIN');
         updateContactRec(newList, new Map<Id,Task> (oldList));
         System.debug(LoggingLevel.DEBUG, 'CP_TasksChecklistUpdate.afterUpdate() : END');       
     }
    
    private void updateContactRec(List<Task> taskList, Map<Id, Task> oldList){
        Map<string,set<String>> taskWithUniqueKeyMap = new Map<string,set<String>>();
        for(Task t : taskList){
            if(t.Status == 'Completed' && t.WhoId != null && t.Status != oldList.get(t.Id).Status && t.Onboarding_UniqueKey__c != null){
                if(taskWithUniqueKeyMap.containsKey(t.Onboarding_UniqueKey__c)){
                    taskWithUniqueKeyMap.get(t.Onboarding_UniqueKey__c).add(t.WhoId);
                }else{
                    taskWithUniqueKeyMap.put(t.Onboarding_UniqueKey__c,new Set<String>{t.WhoId});
                }
            }
        }
         Map<Id,Contact> finalContactMap = new Map<Id,Contact>();
        system.debug('taskWithUniqueKeyMap map => '+taskWithUniqueKeyMap);
        
        if(!taskWithUniqueKeyMap.isEmpty()){
            Map<String,Preonboarding_Task_Mapping__mdt> metadataMap = new Map<String,Preonboarding_Task_Mapping__mdt>();
            for(Preonboarding_Task_Mapping__mdt  preOn : [SELECT Id, Unique_Identifier__c ,Task_Subject__c ,Contact_API__c  FROM Preonboarding_Task_Mapping__mdt WHERE Onboarding_Task__c = 'Pre' ]){
                metadataMap.put(preOn.Unique_Identifier__c,preOn);
            }
            
            for(String str : taskWithUniqueKeyMap.keySet()){
                if(metadataMap.containsKey(str)){
                    for(String conId : taskWithUniqueKeyMap.get(str)){
                        if(finalContactMap.containsKey(conId)){
                            finalContactMap.get(conId).put(metadataMap.get(str).Contact_API__c,true);
                        }else{
                            Contact conNew = new Contact();
                            conNew.put('Id',conId);
                            conNew.put(metadataMap.get(str).Contact_API__c,true);
                            finalContactMap.put(conId,conNew);
                        }
                    }
                }
            }
            
        }
        try{
            update finalContactMap.values();
        }catch(exception ex){
            //Log the exception
            system.debug('===ex==='+ex);
        }
    }
}