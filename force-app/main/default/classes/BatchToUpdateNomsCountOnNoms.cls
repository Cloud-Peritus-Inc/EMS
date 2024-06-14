global class BatchToUpdateNomsCountOnNoms implements Database.Batchable<sObject> {
    
     global Database.QueryLocator start(Database.BatchableContext BC) {
         Id nomRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Nominations').getRecordTypeId();
         return Database.getQueryLocator([SELECT Id,Status__c,Award_Type__c,Resource__c,Primary_Nomination__c,
                                          Secondary_Nomination__c,Recognization_By__c,Recognization_By__r.Name,Reason_for_award__c 
                                          FROM Reward_And_Recognition__c WHERE Status__c = 'Nominated'
                                          and RecordTypeId=:nomRecordTypeId and Type__c = 'Annual Award']);
     }
    
     global void execute(Database.BatchableContext BC, List<Reward_And_Recognition__c> rrList) {
          Map<String, List<Reward_And_Recognition__c>>  awardWithNomnMap = new Map<String, List<Reward_And_Recognition__c>>();
          Map<String, Map<String,List<Reward_And_Recognition__c>>>  awardresourceWithNomnMap = new Map<String, Map<String,List<Reward_And_Recognition__c>>>();
         set<Id> contactIds = new set<Id>();
            for(Reward_And_Recognition__c rr : rrList){
                contactIds.add(rr.Resource__c);
                if(awardWithNomnMap.containsKey(rr.Award_Type__c)){
                    awardWithNomnMap.get(rr.Award_Type__c).add(rr);
                }else{
                    awardWithNomnMap.put(rr.Award_Type__c, new List<Reward_And_Recognition__c>{rr});  
                } 
            }
        system.debug(awardWithNomnMap.size()+'===awardWithNomnMap===='+awardWithNomnMap);
         system.debug(contactIds.size()+'===contactIds===='+contactIds);
        
         for(String award : awardWithNomnMap.keySet()){
                Map<String,List<Reward_And_Recognition__c>> tempMap = new Map<String,List<Reward_And_Recognition__c>>();
                for(Reward_And_Recognition__c res : awardWithNomnMap.get(award)){
                    if(tempMap.containsKey(res.Resource__c)){
                     tempMap.get(res.Resource__c).add(res);   
                    }else{
                     tempMap.put(res.Resource__c, new List<Reward_And_Recognition__c>{res});  
                    } 
                }
                awardresourceWithNomnMap.put(award,tempMap);
           } 
         system.debug(awardresourceWithNomnMap.size()+'===awardresourceWithNomnMap===='+awardresourceWithNomnMap);
         
         
        
     }
    
     global void finish(Database.BatchableContext BC) {
        
     }
    
    
    
    

}