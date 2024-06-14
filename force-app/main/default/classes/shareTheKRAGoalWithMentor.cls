/**
* @author Subba Kalavala
* @date 8/13/2023
* @description  shareTheKRAGoalWithMentor share the KRA Goal With Mentor
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
public without sharing class shareTheKRAGoalWithMentor implements TriggerAction.AfterInsert {
    
/**
* @author Subba Kalavala
* @date 8/13/2023
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterInsert(List<Goal__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'shareTheKRAGoalWithMentor.afterInsert() : BEGIN');
        shareTheRecord(newList);
        System.debug(LoggingLevel.DEBUG, 'shareTheKRAGoalWithMentor.afterInsert() : END');       
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
    public void shareTheRecord(List<Goal__c> newlist) {
        Set<Id> resourceIdSet = new Set<Id>();
        Map<Id,Id> resourceWithMentor = new Map<Id,Id>();
         Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        for(Goal__c gl : newlist){
            if(gl.Resource__c != null && gl.RecordTypeId ==kraRecordTypeId){
                resourceIdSet.add(gl.Resource__c);
            }
        }
        
        if(!resourceIdSet.isEmpty()){
            for(Contact con : [SELECT Id,EMS_TM_User__c,(SELECT Id,Resource_Reports_To__c,Resource_Reports_To__r.EMS_TM_User__c FROM Resource_Resource_Relationships__r WHERE Relationship_Type__c  INCLUDES('Mentor') AND Resource_Reports_To__r.EMS_TM_User__c != null ) FROM Contact WHERE Id IN:resourceIdSet]){
                if(!con.Resource_Resource_Relationships__r.isEmpty()){
                    Resource_Resource_Relationship__c  reports = con.Resource_Resource_Relationships__r[0];
                    resourceWithMentor.put(con.Id,reports.Resource_Reports_To__r.EMS_TM_User__c);
                }
            } 
        }
        
        List<Goal__Share> goalShare = new List<Goal__Share>();
         for(Goal__c gl : newlist){
            if(gl.Resource__c != null && gl.RecordTypeId ==kraRecordTypeId){
                if(resourceWithMentor.containsKey(gl.Resource__c)){
                   Goal__Share gShare = new Goal__Share();
                    gShare.ParentId = gl.Id;
                    gShare.UserOrGroupId = resourceWithMentor.get(gl.Resource__c);
                    gShare.AccessLevel = 'Edit ';
                    
                }
            }
        }
    }

}