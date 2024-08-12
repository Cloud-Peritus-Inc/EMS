global class BatchToCreateScoringForAwards implements Database.Batchable<sObject>, Database.Stateful {
    private Map<String,Reward_And_Recognition__c> recordHistoryMap = new  Map<String,Reward_And_Recognition__c>();
    global Database.QueryLocator start(Database.BatchableContext BC) {
         Id nomRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Nominations').getRecordTypeId();
         return Database.getQueryLocator([SELECT Id,Status__c,Award_Type__c,Resource__c,Primary_Nomination__c,
                                          Secondary_Nomination__c,Recognization_By__c,Recognization_By__r.Name,Reason_for_award__c 
                                          FROM Reward_And_Recognition__c WHERE Status__c = 'Nominated'
                                          and Processed__c = false and Nomination_Submitted__c = true
                                          and RecordTypeId=:nomRecordTypeId and Type__c = 'Annual Award']);
    }
    global void execute(Database.BatchableContext BC, List<Reward_And_Recognition__c> rrList) {
       Fiscal_Year__c currentFY = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c where Start_Date__c = THIS_FISCAL_YEAR Order BY Start_Date__c ASC];
        //smaske : PM_Def_056 : storing records in nominationsUpdate to update the Processed__c checkbox to true
        List<Reward_And_Recognition__c> nominationsUpdate = new List<Reward_And_Recognition__c>(); 
        
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
            rr.Processed__c = true;
            nominationsUpdate.add(rr);
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
        
        Id scoringRecordTypeId = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByName().get('Scoring').getRecordTypeId();
        //fetch scoring records only for current fiscal year via lookup : currentFY
        for(Reward_And_Recognition__c score : [SELECT Id,Award_Type__c,Resource__c,Fiscal_Year__c,of_Primary_Nominations__c,of_Secondary_Nominations__c FROM Reward_And_Recognition__c WHERE Resource__c IN:contactIds and  RecordTypeId=:scoringRecordTypeId and Status__c = 'Review In Progress' and Fiscal_Year__c =: currentFY.Id ] ){
           String uniqueKey = score.Resource__c+';'+score.Award_Type__c; 
            recordHistoryMap.put(uniqueKey,score);
            System.debug('====score record===='+score);
            System.debug('====recordHistoryMap===='+recordHistoryMap);            
        }
        system.debug(recordHistoryMap.size()+'===recordHistoryMap===='+recordHistoryMap);
        
        for(String award : awardresourceWithNomnMap.keySet()){
            system.debug('===award===='+award);
             Map<String,List<Reward_And_Recognition__c>> resMap = awardresourceWithNomnMap.get(award);
            system.debug('===resMap===='+resMap);
            for(String resource : resMap.keySet()){
                 system.debug('===resource Id===='+resMap);
                Decimal noOfPrimary = 0;
                Decimal noOfSecondary = 0;
                String amendComments = '';
                String amendRec = '';
                for(Reward_And_Recognition__c noms : resMap.get(resource)){
                    if(noms.Primary_Nomination__c){
                        noOfPrimary++;
                    }else if(noms.Secondary_Nomination__c){
                        noOfSecondary++;
                    }
                    if(amendComments != null){
                      String resourcestring = '<b>'+noms.Recognization_By__r.Name+' :</b> <br/>';
                      amendComments = amendComments+'<br/>'+resourcestring + noms.Reason_for_award__c;  
                    }else{
                      String resourcestring = '<b>'+noms.Recognization_By__r.Name+' :</b> <br/>';
                      amendComments = resourcestring + noms.Reason_for_award__c;
                       
                    }
                    if(amendRec != null){
                      String resourcestring = '<b>'+noms.Recognization_By__r.Name+'</b> <br/>';
                      amendRec = amendRec+resourcestring;  
                    }else{
                      String resourcestring = '<b>'+noms.Recognization_By__r.Name+'</b> <br/>';
                      amendRec = resourcestring ;
                       
                    }
                }
                 String uniqueKey = resource+';'+award; 
                  if(recordHistoryMap.containsKey(uniqueKey)){
                      Reward_And_Recognition__c scrr = recordHistoryMap.get(uniqueKey);
                      system.debug('===scrr existing scoring=='+scrr);
                      scrr.of_Primary_Nominations__c =  scrr.of_Primary_Nominations__c+noOfPrimary;
                      scrr.of_Secondary_Nominations__c = scrr.of_Secondary_Nominations__c+noOfSecondary;
                      scrr.Reason_for_award__c = '<br/>'+amendComments;
                      scrr.Recognization_By_Text__c = '<br/>'+amendRec;  
                      recordHistoryMap.put(uniqueKey,scrr);
                  }else{
                     Reward_And_Recognition__c scrr = new Reward_And_Recognition__c();
                      scrr.RecordTypeId = scoringRecordTypeId;
                      scrr.Status__c = 'Review In Progress';
                      scrr.Resource__c = resource;
                      scrr.Award_Type__c = award;
                      scrr.of_Primary_Nominations__c = noOfPrimary;
                      scrr.of_Secondary_Nominations__c = noOfSecondary;
                      scrr.Reason_for_award__c = amendComments;
                      scrr.Fiscal_Year__c = CurrentFY.Id;
                      scrr.Recognization_By_Text__c = amendRec; 
                      recordHistoryMap.put(uniqueKey,scrr); 
                  }
 
            }
            
        }
        
        try{
            if(nominationsUpdate.size() > 0){
                system.debug('==nominationsUpdate.values===='+ nominationsUpdate.toString() ); 
                update nominationsUpdate;
            }
        }catch(exception ex){
           LogException.logHandledException(ex, 'BatchToCreateKRAforQuaterly', 'execute');  
        }
                                
    }
    
    global void finish(Database.BatchableContext BC) {
        try{
            system.debug('==recordHistoryMap.values===='+recordHistoryMap.values()); 
            upsert recordHistoryMap.values();
        }catch(exception ex){
           LogException.logHandledException(ex, 'BatchToCreateKRAforQuaterly', 'finish');  
        }
        
    }
}