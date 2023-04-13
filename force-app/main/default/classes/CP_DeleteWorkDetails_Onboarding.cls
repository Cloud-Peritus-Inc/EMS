/**
* @author Mukesh Rawat
* @date 31/03/2023
* @description  CP_DeleteWorkDetails_Onboarding Class to Delete Work Details when the Do you have work Experience is No
*
*               Test code coverage provided by the following test class:
*               - CP_DeleteWorkDetails_OnboardingTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class CP_DeleteWorkDetails_Onboarding implements TriggerAction.AfterUpdate{
    /**
* @author Mukesh Rawat
* @date 31/03/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void AfterUpdate(List<EMS_EM_Onboarding_Request__c> newList,List<EMS_EM_Onboarding_Request__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'CP_DeleteWorkDetails_Onboarding.afterUpdate() : BEGIN');
        deleteWorkDetailsWhenWorkIsNo(newList);
        System.debug(LoggingLevel.DEBUG, 'CP_DeleteWorkDetails_Onboarding.afterUpdate() : END');       
    }
    
    
    /**
*   {Purpose} - Method to restrict the same date leaves 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void deleteWorkDetailsWhenWorkIsNo(List<EMS_EM_Onboarding_Request__c> newlist) {
        List<EMS_EM_Additional_Detail__c> detailsToDelete = new List<EMS_EM_Additional_Detail__c>();
        List<ContentDocumentLink> documentsToDelete = new List<ContentDocumentLink>();
        
        for (EMS_EM_Onboarding_Request__c request : newlist) {
            // check if Do_you_have_work_experience__c has been updated to 'No'
            if (request.Do_you_have_work_experience__c == 'No') {
                // query for EMS_EM_Additional_Detail__c records with RecordType Name = 'Work Details' that are related to the current EMS_EM_Onboarding_Request__c record
                List<EMS_EM_Additional_Detail__c> relatedDetails = [SELECT Id, 
                                                                    RecordTypeId 
                                                                    FROM EMS_EM_Additional_Detail__c 
                                                                    WHERE Onboarding_Request__c = :request.Id AND RecordType.Name = 'Work Details'];
                detailsToDelete.addAll(relatedDetails);
                
                // query for ContentDocumentLink records that are related to the current EMS_EM_Onboarding_Request__c record and the filename contains "Work_Details_"
                List<ContentDocumentLink> relatedDocuments = [SELECT Id 
                                                              FROM ContentDocumentLink 
                                                              WHERE LinkedEntityId = :request.Id AND ContentDocument.Title LIKE 'Work_Details_%'];
                documentsToDelete.addAll(relatedDocuments);
            }
        }
        // delete the related EMS_EM_Additional_Detail__c records with RecordType Name = 'Work Details'
        delete detailsToDelete;
        // delete the related ContentDocumentLink records where the filename contains "Work_Details_"
        delete documentsToDelete;
    }
    
}