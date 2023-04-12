public without sharing class managerSeeEmployeeRec {
    
    @AuraEnabled(cacheable=true)
    public static List<User> serchUser(Id userId){
        System.debug('userID'+userId);
        Contact conRec =[Select Id,
                         EMS_TM_user__c 
                         FROM Contact 
                         WHERE EMS_TM_user__c =:userId];
        System.debug('conRec'+conRec);
        Set<Id> userIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Resource_Resource_Relationship__c relationShipRec :[SELECT Resource__r.EMS_TM_user__c,
                                                                Resource__c,
                                                                Resource_Reports_To__c 
                                                                FROM Resource_Resource_Relationship__c
                                                                WHERE Resource_Reports_To__c =:conRec.Id]){
                                                                    userIds.add(relationShipRec.Resource__r.EMS_TM_user__c);
                                                                    contactIds.add(relationShipRec.Resource__c);
                                                                }
        System.debug('contactIds'+contactIds+'>..>>>>'+userIds.size());
        for(Resource_Resource_Relationship__c relationShipempRec :[SELECT Resource__r.EMS_TM_user__c,
                                                                   Resource__c,
                                                                   Resource_Reports_To__c 
                                                                   FROM Resource_Resource_Relationship__c
                                                                   WHERE Resource_Reports_To__c IN:contactIds]){
                                                                       userIds.add(relationShipempRec.Resource__r.EMS_TM_user__c);
                                                                       
                                                                   }
                        System.debug('contactIds>..>>>>'+userIds.size());
                        List<User> userList = new List<User>();
                        
                        for(User userRec: [Select Id,
                                           Name 
                                           FROM User 
                                           WHERE Id IN:userIds]){
                                               userList.add(userRec);
                                           }
                        
                        System.debug('userList'+userList);
                        try{
                            return userList;
                        }catch(Exception e){
                            String errorOccuredWith = e.getMessage();
                            throw new AuraHandledException(errorOccuredWith);
                        }
    }
}