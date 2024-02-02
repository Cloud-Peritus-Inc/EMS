/**
* @author Subba Kalavala
* @date 11/10/2023
* @description  UpdateTheNominatedCountOnNoms Class to update all the Primary and Secondary Counts on Original Noms
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
public without sharing class UpdateTheNominatedCountOnNoms implements TriggerAction.AfterInsert{
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
    public void AfterInsert(List<Reward_And_Recognition__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'UpdateTheNominatedCountOnNoms.AfterInsert() : BEGIN');
        updateTheCounts(newList);
        System.debug(LoggingLevel.DEBUG, 'UpdateTheNominatedCountOnNoms.AfterInsert() : END');       
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
    public void updateTheCounts(List<Reward_And_Recognition__c> newlist) {
        Map<String, Reward_And_Recognition__c>  scoringWithNomnMap = new Map<String, Reward_And_Recognition__c>();
        set<Id> resourceIds = new set<Id>();
         set<String> awardsIds = new set<String>();
        List<Reward_And_Recognition__c> updateRR = new List<Reward_And_Recognition__c>();
        Id scoringRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Scoring').getRecordTypeId();
        
         for(Reward_And_Recognition__c score : newlist ){
             if(score.Resource__c != null && score.Award_Type__c != null && score.RecordTypeId == scoringRecordTypeId && score.Status__c == 'Review In Progress'){
               String uniqueKey = score.Resource__c+';'+score.Award_Type__c;
               resourceIds.add(score.Resource__c);
                awardsIds.add(score.Award_Type__c);
               scoringWithNomnMap.put(uniqueKey,score);
             }
        }
        
        if(!scoringWithNomnMap.isEmpty()){
             Id nomRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Nominations').getRecordTypeId();
            for(Reward_And_Recognition__c rr : [SELECT Id,Status__c,Award_Type__c,Resource__c,Primary_Nomination__c,
                                          Secondary_Nomination__c,Recognization_By__c,Recognization_By__r.Name,Reason_for_award__c 
                                          FROM Reward_And_Recognition__c WHERE Status__c = 'Nominated' and Resource__c != null and Award_Type__c != null 
                                          and RecordTypeId=:nomRecordTypeId and Type__c = 'Annual Award']){             
              String uniqueKey = rr.Resource__c+';'+rr.Award_Type__c;
                if(scoringWithNomnMap.containsKey(uniqueKey)){
                      rr.of_Primary_Nominations__c = scoringWithNomnMap.get(uniqueKey).of_Primary_Nominations__c;
                      rr.of_Secondary_Nominations__c = scoringWithNomnMap.get(uniqueKey).of_Secondary_Nominations__c;
                    updateRR.add(rr);
                }
             
            }
            
        }
        try{
            update updateRR;
        }catch(exception ex){
           LogException.logHandledException(ex, 'UpdateTheNominatedCountOnNoms', 'UpdateTheNominatedCountOnNoms');  
        } 
        
        
        
        
      }
      
}