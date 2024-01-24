/**
* @author Subba Kalavala
* @date 11/10/2023
* @description  UpdateTheScoresForWinner Class to update all the Scoring as Lost for other awards
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
public without sharing class UpdateTheScoresForWinner implements TriggerAction.AfterUpdate{
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
        System.debug(LoggingLevel.DEBUG, 'UpdateTheScoresForWinner.beforeUpdate() : BEGIN');
        updateTheScoring(newList,new Map<Id,Reward_And_Recognition__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'UpdateTheScoresForWinner.beforeUpdate() : END');       
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
    public void updateTheScoring(List<Reward_And_Recognition__c> newlist, Map<Id,Reward_And_Recognition__c> oldMap) {
          Id scoringRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Scoring').getRecordTypeId();
          set<Id> resourceId = new set<Id>();
          set<String> considerAwards = new set<String>();
          set<Id> rrIds = new set<Id>();
          Map<String,Reward_And_Recognition__c> resWithRecord = new Map<String,Reward_And_Recognition__c>();
          for(Reward_And_Recognition__c newRec :  newlist){
              Reward_And_Recognition__c oldRec = oldMap.get(newRec.Id);
              if(newRec.recordTypeId == scoringRecordTypeId && newRec.Status__c == 'Winner' && (newRec.Status__c != oldRec.Status__c)){
                 String uniqueKey = newRec.Resource__c;
                 resWithRecord.put(uniqueKey,newRec);
                 rrIds.add(newRec.Id);
                 considerAwards.add(newRec.Award_Type__c);
                 resourceId.add(newRec.Resource__c);
              }
          }
         system.debug('===rrIds======'+rrIds);
         system.debug('===resourceId======'+resourceId);
            Map<id,Reward_And_Recognition__c> updateNomsDML = new Map<Id,Reward_And_Recognition__c>();
            
            if(!resourceId.isEmpty()){
                for(Reward_And_Recognition__c newRec :  [SELECT Id,Status__c,Award_Type__c,Resource__c,Primary_Nomination__c, Secondary_Nomination__c,Recognization_By__c,Recognization_By__r.Name,Reason_for_award__c 
                 FROM Reward_And_Recognition__c WHERE Status__c = 'Review In Progress' and Id NOT IN:rrIds
                 and RecordTypeId=:scoringRecordTypeId and Resource__c IN:resourceId]){
                     String uniqueKey = newRec.Resource__c; 
                     Reward_And_Recognition__c Winnerscoring = resWithRecord.get(uniqueKey);
                     system.debug('====Winnerscoring==='+Winnerscoring);
                      system.debug(newRec.Resource__c+'====Winnerscoring==='+Winnerscoring.Resource__c);
                     if(Winnerscoring.Status__c == 'Winner' && Winnerscoring.Resource__c == newRec.Resource__c){
                        newRec.Status__c = 'Lost';
                        newRec.System_Predicted_Status__c = 'Looser';
                       // newRec.Comments__c =  Winnerscoring.Comments__c; 
                        newRec.Lost_Reason__c = 'This resource already a winner for award : '+Winnerscoring.Award_Type__c;
                        updateNomsDML.put(newRec.Id,newRec);
                     }
                }
            }
        
        if(!considerAwards.isEmpty()){
             for(Reward_And_Recognition__c newRec :  [SELECT Id,Status__c,Award_Type__c,Resource__c,Primary_Nomination__c, Secondary_Nomination__c,Recognization_By__c,Recognization_By__r.Name,Reason_for_award__c 
                 FROM Reward_And_Recognition__c WHERE Status__c = 'Review In Progress' and Id NOT IN:rrIds
                  and RecordTypeId=:scoringRecordTypeId and Award_Type__c IN:considerAwards]){
                      if(updateNomsDML.containsKey(newRec.id)){
                        updateNomsDML.get(newRec.id).Status__c = 'Lost';
                        updateNomsDML.get(newRec.id).System_Predicted_Status__c = 'Looser';
                        updateNomsDML.get(newRec.id).Lost_Reason__c = 'One of the contender for this award has been marked as winner.';
                       
                      }else{
                        newRec.Status__c = 'Lost';
                        newRec.System_Predicted_Status__c = 'Looser';
                        newRec.Lost_Reason__c = 'One of the contender for this award has been marked as winner.';
                        updateNomsDML.put(newRec.Id,newRec); 
                      }
                  }
        }        
        
        
         try{
           update updateNomsDML.values(); 
        }catch(exception ex){
           LogException.logHandledException(ex, 'UpdateTheScoresForWinner', 'UpdateTheScoresForWinner');  
        }
        
        
    }
}