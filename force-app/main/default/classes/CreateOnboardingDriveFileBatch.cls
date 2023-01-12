public class CreateOnboardingDriveFileBatch implements Database.Batchable<ContentDocumentLink>, Database.allowscallouts {
    public List<ContentDocumentLink> ContentDocumentLinkList;
    public CreateOnboardingDriveFileBatch(list<ContentDocumentLink> ContentDocumentLinkList){
        this.ContentDocumentLinkList = ContentDocumentLinkList;
    }
    public Iterable<ContentDocumentLink> start(Database.BatchableContext BC){
        return ContentDocumentLinkList;
    }
    
    public void execute(Database.BatchableContext BC, List<ContentDocumentLink> scope){
        try {
            ContentDocumentLink conDoculink = scope[0];
            String folderId = '';
            if ( conDoculink.LinkedEntityId != null && ( String.valueOf(conDoculink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('EMS_EM_Onboarding_Request__c'))) {
                list<EMS_EM_Onboarding_Request__c> RequestList = [ Select Id, 
                                                                  Google_Drive_ID__c 
                                                                  from EMS_EM_Onboarding_Request__c
                                                                  where Id =:conDoculink.LinkedEntityId  
                                                                  and Google_Drive_ID__c != null limit 1 ];
                
                if (RequestList != null && !RequestList.isEmpty()) {
                    folderId = RequestList[0].Google_Drive_ID__c;
                }
            }
            else if ( conDoculink.LinkedEntityId != null && String.valueOf(conDoculink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('ems_EM_Additional_Detail__c')) {
                list<ems_EM_Additional_Detail__c> RequestList = [ Select Id, 
                                                                 Onboarding_Request__c,
                                                                 Onboarding_Request__r.Google_Drive_ID__c 
                                                                 from ems_EM_Additional_Detail__c
                                                                 where Id =:conDoculink.LinkedEntityId  
                                                                 and 
                                                                 Onboarding_Request__r.Google_Drive_ID__c != null limit 1 ];
                if ( RequestList != null && !RequestList.isEmpty()) {
                    folderId = RequestList[0].Onboarding_Request__r.Google_Drive_ID__c;
                }
            }
            List<ContentVersion> ContentVersionlist = [ Select Id, 
                                                       ContentDocumentId, 
                                                       Title, 
                                                       VersionData, 
                                                       ContentSize, 
                                                       FileType, 
                                                       IsMajorVersion
                                                       from ContentVersion
                                                       where ContentDocumentId =:conDoculink.ContentDocumentId ];
            
            if ( folderId != null && folderId != '' && ContentVersionlist != null && !ContentVersionlist.isEmpty() ){
                HttpResponse response = CreateDriveMainFolder.uploadFile( ContentVersionlist[0], folderId);
                if ( response != null && response.getStatusCode() == 200) {
                    map<String,object> rawResponse = new map<String,object>();
                    rawResponse = ( map<String,object> )JSon.deserializeUntyped( response.getBody() );
                    System.debug('====rawResponse[0====='+rawResponse);
                }
            }
        } catch(exception ex) {
            system.debug('Exception===>'+ex.getLineNumber()+ex.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){  
    }
}