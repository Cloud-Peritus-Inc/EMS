global class BatchToUpdatePridcation  implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
         Id scoringRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Scoring').getRecordTypeId();
         return Database.getQueryLocator([SELECT Id,Award_Type__c,Resource__c FROM Reward_And_Recognition__c WHERE RecordTypeId=:scoringRecordTypeId and Status__c = 'Review In Progress']);
    }
    global void execute(Database.BatchableContext BC, List<Reward_And_Recognition__c> RRList) {
         set<String> resources = new set<String>();
         Map<Id,Reward_And_Recognition__c> scoringUpdateMap = new Map<Id,Reward_And_Recognition__c>();
         List<Reward_And_Recognition__c> filtered = new List<Reward_And_Recognition__c>();
         Reward_And_Recognition__c rrawrd = RRList[0];
          for(Reward_And_Recognition__c rr : [SELECT Id,Award_Type__c,Resource__c,Resource__r.Not_Eligible_For_Annual_Awards__c,Status__c,System_Predicted_Status__c FROM Reward_And_Recognition__c WHERE Award_Type__c =:rrawrd.Award_Type__c  and Status__c = 'Review In Progress']){
            resources.add(rr.Resource__c); 
             scoringUpdateMap.put(rr.Id,rr);
             if(rr.Resource__r.Not_Eligible_For_Annual_Awards__c){
              scoringUpdateMap.get(rr.Id).Status__c = 'Not Qualified';  
              scoringUpdateMap.get(rr.Id).System_Predicted_Status__c = 'Potential Winner';
              scoringUpdateMap.get(rr.Id).Lost_Reason__c = 'Resource is not eligiable for annual awards.';               
            }
          }
          
        Map<Id,Contact> contacMap = new Map<Id,Contact>([SELECT Id,EMS_EM_JD__c,EMS_EM_Exp__c,Not_Eligible_For_Annual_Awards__c,(Select Id FROM Rewards_And_Recognitions__r WHERE Status__c = 'Winner') FROM Contact WHERE Id IN:resources]);
        Decimal totalNoms = 0;
        String winner = null;
        for(Reward_And_Recognition__c rr : [SELECT Id,Award_Type__c,Resource__c,Comments__c,of_Total_Nominations__c FROM Reward_And_Recognition__c WHERE Award_Type__c =:rrawrd.Award_Type__c  
                                            and Status__c = 'Review In Progress' and Resource__r.Not_Eligible_For_Annual_Awards__c=false ORDER BY of_Primary_Nominations__c DESC]){
            contact resou = contacMap.get(rr.Resource__c);
            Integer oOfdayFromJoining = (resou.EMS_EM_JD__c).daysBetween(System.today()) ;
            if(rr.Award_Type__c == 'Rising Star' && resou.EMS_EM_Exp__c != null && ( resou.EMS_EM_Exp__c > 3 || oOfdayFromJoining < 180 ) ){
               scoringUpdateMap.get(rr.Id).Status__c = 'Not Qualified';  
               scoringUpdateMap.get(rr.Id).System_Predicted_Status__c = 'Potential Winner';
               scoringUpdateMap.get(rr.Id).Lost_Reason__c = 'Resource might have more then 3 years of exp or less than 6 months to cloudperitus.'; 
                continue;
            }
            if(rr.of_Total_Nominations__c > totalNoms){
                totalNoms = rr.of_Total_Nominations__c;
                winner = rr.id;
              scoringUpdateMap.get(rr.Id).System_Predicted_Status__c = 'Potential Winner'; //smaske:[03-July-2024]: Changing "Might Winner" with "Less likely to win" for PM_102 , //smaske:[PM_Def_007] : 'Less likely to win' changed to 'Potential Winner'
              scoringUpdateMap.get(rr.Id).Comments__c = 'Resource got more nomination when compared to other Contenders.'; 
            }else{
              scoringUpdateMap.get(rr.Id).System_Predicted_Status__c = 'Less likely to win'; //smaske:[PM_Def_007] :updating 'Most Likely Winner' to "Less likely to win"
              scoringUpdateMap.get(rr.Id).Comments__c = 'Resource got less nomination when compared to other Contenders.';  
            }     
            
         }
        
        
        
        try{
            update scoringUpdateMap.values();
                     
        }catch(exception ex){
           LogException.logHandledException(ex, 'BatchToCreateKRAforQuaterly', 'execute');  
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}