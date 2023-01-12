public class ContentDocumentLinkTriggerHandler {
    public static void createDriveFile(list<ContentDocumentLink> newContentDocumentLinkList){
        List<ContentDocumentLink> ContentDocumentLinkList = new List<ContentDocumentLink>();
        for (ContentDocumentLink contentDocumentLink : newContentDocumentLinkList){
            if (contentDocumentLink.LinkedEntityId !=null && ( String.valueOf(contentDocumentLink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('EMS_EM_Onboarding_Request__c')))
            {
                ContentDocumentLinkList.add(contentDocumentLink); 
            }else if (contentDocumentLink.LinkedEntityId != null && String.valueOf(contentDocumentLink.LinkedEntityId.getSObjectType()).equalsIgnoreCase('ems_EM_Additional_Detail__c')){ 
                ContentDocumentLinkList.add(contentDocumentLink);
            }
            
        }
        if (!ContentDocumentLinkList.isEmpty()) {
            Database.executeBatch(new CreateOnboardingDriveFileBatch(ContentDocumentLinkList), 1); 
        }
    }
}