/**
* @author Subba Kalavala
* @date 11/10/2023
* @description  UpdateTheNomsBasedOnScoring Class to update all the nominations based on score result
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
public without sharing class UpdateTheNomsBasedOnScoring implements TriggerAction.AfterUpdate{
   /**
* @author Subba Kalavala
* @date 
* @description AfterUpdate
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<Reward_And_Recognition__c> newList, List<Reward_And_Recognition__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'UpdateTheNomsBasedOnScoring.beforeUpdate() : BEGIN');
        updateTheNoms(newList,new Map<Id,Reward_And_Recognition__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'UpdateTheNomsBasedOnScoring.beforeUpdate() : END');       
    }

/**
*   {Purpose} - Method
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void updateTheNoms(List<Reward_And_Recognition__c> newlist, Map<Id,Reward_And_Recognition__c> oldMap) {
          Id scoringRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Scoring').getRecordTypeId();
          Id nomRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Nominations').getRecordTypeId();
          set<Id> resourceId = new set<Id>();
          Map<String,Reward_And_Recognition__c> resWithRecord = new Map<String,Reward_And_Recognition__c>();
          for(Reward_And_Recognition__c newRec :  newlist){
              Reward_And_Recognition__c oldRec = oldMap.get(newRec.Id);
              if(newRec.recordTypeId == scoringRecordTypeId && (newRec.Status__c == 'Winner' || newRec.Status__c == 'Lost') && (newRec.Status__c != oldRec.Status__c)){
                 String uniqueKey = newRec.Resource__c+';'+newRec.Award_Type__c;
                 resWithRecord.put(uniqueKey,newRec);
                 resourceId.add(newRec.Resource__c);
              }
          }
         system.debug('====resWithRecord==='+resWithRecord);
            List<Reward_And_Recognition__c> updateNomsDML = new List<Reward_And_Recognition__c>();
            if(!resourceId.isEmpty()){
                for(Reward_And_Recognition__c newRec :  [SELECT Id,Status__c,Award_Type__c,Resource__c,Primary_Nomination__c, Secondary_Nomination__c,Recognization_By__c,Recognization_By__r.Name,Reason_for_award__c 
                 FROM Reward_And_Recognition__c WHERE Status__c = 'Nominated'
                 and RecordTypeId=:nomRecordTypeId and Type__c = 'Annual Award' and Resource__c IN:resourceId]){
                     String uniqueKey = newRec.Resource__c+';'+newRec.Award_Type__c; 
                     system.debug('====uniqueKey==='+uniqueKey);
                       system.debug('====resWithRecord.get(uniqueKey)==='+resWithRecord.containsKey(uniqueKey));
                     if(resWithRecord.containsKey(uniqueKey)){
                     Reward_And_Recognition__c scoring = resWithRecord.get(uniqueKey);
                     if(scoring.Status__c == 'Winner' && scoring.Resource__c == newRec.Resource__c && scoring.Award_Type__c == newRec.Award_Type__c){
                        newRec.Status__c = 'Winner';
                        newRec.Comments__c =  scoring.Comments__c;
                        updateNomsDML.add(newRec);
                     }else if(scoring.Status__c == 'Lost' && scoring.Resource__c == newRec.Resource__c && scoring.Award_Type__c == newRec.Award_Type__c){
                        newRec.Status__c = 'Lost';
                       // newRec.Comments__c =  scoring.Comments__c; 
                        newRec.Lost_Reason__c = scoring.Lost_Reason__c;
                         updateNomsDML.add(newRec);
                     }
                     }
                }
            }
        
         try{
           update updateNomsDML; 
        }catch(exception ex){
           LogException.logHandledException(ex, 'UpdateTheNomsBasedOnScoring', 'UpdateTheNomsBasedOnScoring');  
        }
        
    }
}