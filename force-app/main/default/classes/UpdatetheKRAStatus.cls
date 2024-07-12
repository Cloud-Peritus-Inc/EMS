public class UpdatetheKRAStatus implements TriggerAction.AfterUpdate {
    
    public void afterUpdate(List<PM_Configure__c> newList, List<PM_Configure__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : BEGIN');
        UpdatetheGoalKraStatus(newList,new Map<Id,PM_Configure__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : END');       
    }
    
    public void UpdatetheGoalKraStatus(List<PM_Configure__c> newlist,Map<Id,PM_Configure__c> oldMap) {
        
        
        Set<Id> kraIdSet = new set<Id>();
        List<Goal__c> updatedGoalList = new List<Goal__c>();
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();

        for(PM_Configure__c pmConfig: newlist){
            if(pmConfig.RecordTypeID == AnswerRecordTypeId && pmConfig.Status__c != oldMap.get(pmConfig.Id).Status__c && pmConfig.Status__c =='Submitted'){
                system.debug('Entered Kra Goal-----'+pmConfig);
                kraIdSet.add(pmConfig.KRA__c);
            }
        }
        Map<Id,Integer> duplicatepmConfigMap = new Map<Id,Integer>();
        Map<Id,Integer> duplicatepmConfigMap2 = new Map<Id,Integer>();
        
        if(!kraIdSet.isEmpty()){  
            for(Goal__c goalRec : [SELECT Id,
                                   Name,
                                   RecordType.Name,
                                   (SELECT Id,
                                    Name
                                    from PM_Answer_Configure__r ) from Goal__C
                                   where  Id=:kraIdSet  and recordtypeId =: kraRecordTypeId])
            {      
                duplicatepmConfigMap.Put(goalRec.Id,goalRec.PM_Answer_Configure__r.size()); 
                system.debug('duplicatepmConfigMap---'+duplicatepmConfigMap);           
            }  
        }
        
        for(Goal__c goalrecord : [SELECT Id,
                                  name,
                                  RecordType.name,
                                  (SELECT Id,
                                   name,
                                   KRA__c,
                                   Status__c
                                   from PM_Answer_Configure__r where Status__c ='Submitted' ) from Goal__C
                                  where  Id=:kraIdSet  and recordtypeId =: kraRecordTypeId ]){
                                      duplicatepmConfigMap2.Put(goalrecord.Id,goalrecord.PM_Answer_Configure__r.Size());
                                      system.debug('duplicatepmConfigMap2---'+duplicatepmConfigMap2);    
                                  }
        
        if (!duplicatepmConfigMap.isEmpty() && !duplicatepmConfigMap2.isEmpty()) {           
            for (Goal__c goalrecordId : [SELECT Id,
                                         Name,
                                         Status__c
                                         FROM Goal__c
                                         WHERE Id IN: kraIdSet ]) 
            {
                if (!duplicatepmConfigMap.isEmpty() && !duplicatepmConfigMap2.isEmpty()) {
                    
                    System.debug('### duplicatepmConfigMap------' + duplicatepmConfigMap.get(goalrecordId.Id));
                    System.debug('### duplicatepmConfigMap2-----' + duplicatepmConfigMap2.get(goalrecordId.Id));
                    if (duplicatepmConfigMap.get(goalrecordId.Id) == duplicatepmConfigMap2.get(goalrecordId.Id)) {
                        goalrecordId.Status__c ='KRA Inreview';
                        updatedGoalList.add(goalrecordId);
                    }
                }
            }
        }
        
        if(!updatedGoalList.isEmpty()){
            try{
                system.debug('updatedGoalList-----'+updatedGoalList);
                update updatedGoalList;
            }
            catch(Exception e){
                system.debug('Error----'+e.getmessage());
            }
        }
        
    }
    
}