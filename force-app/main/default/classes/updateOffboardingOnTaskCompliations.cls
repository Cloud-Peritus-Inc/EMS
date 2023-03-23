/**
* @author Subba
* @date 10/02/2023
* @description  updateOffboardingOnTaskCompliations Whenever task is completed, tasks checklist should be checked in respective offboarding.
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
public without sharing class updateOffboardingOnTaskCompliations implements TriggerAction.AfterUpdate{
	/**
    * @author Subba
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
         System.debug(LoggingLevel.DEBUG, 'updateOffboardingOnTaskCompliations.afterUpdate() : BEGIN');
         updateOffboardingRec(newList, new Map<Id,Task> (oldList));
         System.debug(LoggingLevel.DEBUG, 'updateOffboardingOnTaskCompliations.afterUpdate() : END');       
     }
    
    private void updateOffboardingRec(List<Task> taskList, Map<Id, Task> oldList){
        set<Id> offboardingIds = new set<Id>();
        List<Off_boarding_Request__c> offboardingUpdate = new List<Off_boarding_Request__c>();
        for(Task t : taskList){
            if(t.Status == 'Completed' && t.WhatId != null && t.Status != oldList.get(t.Id).Status 
               && t.WhatId.getSObjectType() == Off_boarding_Request__c.sObjectType 
               && t.Onboarding_UniqueKey__c != null){
               offboardingIds.add(t.WhatId);
            }
        }
        
        if(!offboardingIds.isEmpty()){
           Map<Id,Task> offWithTaskMap = new Map<Id,Task>();
            for(Task tnew : [SELECT Id,Status,WhatId FROM Task WHERE WhatId IN:offboardingIds AND Status != 'Completed' ]){
              offWithTaskMap.put(tnew.WhatId,tnew);  
            }
            
            for(Id offid : offboardingIds){
                if(!offWithTaskMap.containsKey(offid)){
                   offboardingUpdate.add(new Off_boarding_Request__c(id=offid,status__c= 'Offboarding Tasks Completed')); 
                }
            }
            
        }
        
        try{
          update offboardingUpdate;  
        }catch(exception excp){
           	LogException.logHandledException(excp, 'updateOffboardingOnTaskCompliations', 'updateOffboardingRec');   
        }
        
    }
}