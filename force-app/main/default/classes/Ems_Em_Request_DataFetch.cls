public inherited sharing class Ems_Em_Request_DataFetch {
    @AuraEnabled(Cacheable = true)
    public static List<EMS_EM_Request__c> getRequestHistory(){
        return [SELECT Id, EMS_EM_Request_Type__c, EMS_EM_Raised_On__c, EMS_EM_Request_Status__c, Approver__c, What_do_you_want_to_change__c, EMS_EM_Add_Education__c  FROM EMS_EM_Request__c
                WHERE OwnerId=:UserInfo.getUserID() 
               order by CreatedDate desc];
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<EMS_EM_Request__c> getRequestByStatus( String statusType){
         System.debug('Status Type called');
           
        return [SELECT Id, EMS_EM_Request_Type__c, EMS_EM_Raised_On__c, EMS_EM_Request_Status__c, Approver__c  FROM EMS_EM_Request__c
                WHERE OwnerId=:UserInfo.getUserID() AND EMS_EM_Request_Status__c =:statusType
               order by CreatedDate desc];
    }
    
    @AuraEnabled(cacheable=true)
        public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
        }

}