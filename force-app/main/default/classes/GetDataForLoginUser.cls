/**
* @author Mukesh Rawat 
* @date 8/02/2023
* @description  Getting Grid Configuration Data and Login User Data Using Methods
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

public without Sharing class GetDataForLoginUser {
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    
    @AuraEnabled
    public static contact getUserContactInfo(Id userId){
        user u =[Select id,
                 name,
                 Contactid 
                 FROM user where id =: userId  AND Contactid != null];
        System.debug('userid'+U);
        
        contact contactDetails =[SELECT Lastname,
                                 Name,
                                 Firstname,
                                 EMS_EM_Gender__c,
                                 EMS_Phone_Number__c,
                                 Personal_Email__c,
                                 EMS_EM_DOB__c,
                                 EMS_EM_BG__c,
                                 EMS_EM_Nationality__c,
                                 EMS_EM_AadhaarNo__c,
                                 EMS_EM_PanNo__c,
                                 EMS_EM_PassportNo__c,
                                 EMS_EM_PFno__c,
                                 EMS_Driving_License_No__c,
                                 EMS_RM_Employee_Id__c,
                                 Resource_Manager__c,
                                 Designation__c,
                                 EMS_RM_Current_Job_Role__c,
                                 //Department
                                 EMS_Employee_Type__c,
                                 EMS_EM_OLocation__c,
                                 AccountId,
                                 Location__c,
                                 Official_Mail__c,
                                 Work_Experience__c,
                                 EMS_EM_HR_Assigned__c,
                                 EMS_EM_JD__c,
                                 EMS_EM_PP__c,
                                 EMS_RM_Notice_Period__c,
                                 EMS_EM_CAddress_Line_1__c,
                                 EMS_EM_PAddress_Line_1__c,
                                 EMS_EM_CAddress_Line_2__c,
                                 EMS_EM_PAddress_Line_2__c,
                                 EMS_EM_CA_State__c,
                                 EMS_EM_PA_State__c,
                                 EMS_EM_CA_City__c,
                                 EMS_EM_PA_City__c,
                                 EMS_EM_CA_Zip__c,
                                 EMS_EM_PA_Zip__c,
                                 Do_you_have_a_vehicle__c,
                                 Vehicle_Number__c,
                                 Vehicle_Type__c,
                                 Post_Onboarding_Confirm__c
                                 From Contact where id =: u.contactid];
        
        return contactDetails;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PayRoll__c> getPayrollInfo(string conId){
        return [SELECT Id, 
                Name,
                Beneficiary_Name__c,
                Bank_Name__c,
                Branch__c,
                Beneficiary_Account_Number__c,
                IFSC_Routing_Number__c,
                Contact__c
                From PayRoll__c where Contact__c =: conId];
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Grid_Configuration__c> WelcomeAboardData() {
        return [SELECT Id, 
                Name, 
                CreatedDate, 
                Description__c, 
                Grid_Configuration_Type__c 
                FROM Grid_Configuration__c where Grid_Configuration_Type__c = 'Welcome aboard' Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Grid_Configuration__c> CompanyGridData() {
        return [SELECT Id, 
                Name, 
                CreatedDate, 
                Description__c, 
                Grid_Configuration_Type__c 
                FROM Grid_Configuration__c where Grid_Configuration_Type__c = 'Company Information - EMP- Onboarding' Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Grid_Configuration__c> pfFormsid() {
        return [SELECT Id, 
                Name, 
                CreatedDate, 
                Description__c, 
                Grid_Configuration_Type__c 
                FROM Grid_Configuration__c where Grid_Configuration_Type__c = 'PF Forms' Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Grid_Configuration__c> Documentsdata() {
        return [SELECT Id, 
                Name, 
                CreatedDate, 
                Description__c, 
                Grid_Configuration_Type__c 
                FROM Grid_Configuration__c where Grid_Configuration_Type__c = 'Documents' Limit 1];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Grid_Configuration__c> CompanyPoliciesdata() {
        return [SELECT Id, 
                Name, 
                CreatedDate, 
                Description__c, 
                Grid_Configuration_Type__c 
                FROM Grid_Configuration__c where Grid_Configuration_Type__c = 'Company Policies' Limit 1];
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
    
    @AuraEnabled(cacheable=true)
    public static String getLoginURL(){
        String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        User userRecord = [Select Id, AccountId, ContactId FROM User Where Id = :UserInfo.getUserId()];
        if(userRecord.ContactId != null){
            baseUrl = getExperienceURL();
        }
        return baseUrl;
    }
    
    public static String getExperienceURL(){
        String baseUrl = Network.getLoginUrl(Network.getNetworkId());
        baseURL =  baseURL.replace('/s/login', '');
        baseURL =  baseURL.replace('/s/Login', '');
        baseURL =  baseURL.replace('/login', '');
        baseURL =  baseURL.replace('/Login', '');
        return baseURL;
    }
    
    @AuraEnabled
    public static Contact updateContact( Contact newRecord,String ConRecordid,  PayRoll__c newPayroll, List<Object> files) {
        
        newRecord.Id=ConRecordid;
        update newRecord;
        
        newPayroll.Contact__c =newRecord.Id;
        
        if (newPayroll.Contact__c != null) {
            List<PayRoll__c> existingPayrolls = [SELECT Id FROM PayRoll__c WHERE Contact__c = :newRecord.Id LIMIT 1];
            
            if (existingPayrolls.size() > 0) {
                newPayroll.Id = existingPayrolls[0].Id;
                update newPayroll;
            } else {
                insert newPayroll;
            }
        } else {
            insert newPayroll;
        }
        
        List<ContentVersion> relatedDocuments = new List<ContentVersion>();
        for (Object file : files) {
            system.debug('the file'+file);
            String fileJson = JSON.serialize(file);
            relatedFile relatedDocument = (relatedFile) JSON.deserialize(fileJson, relatedFile.class);
            ContentVersion contentVersionFile = new ContentVersion();
            contentVersionFile.PathOnClient = relatedDocument.PathOnClient;
            contentVersionFile.Title = relatedDocument.Title;
            contentVersionFile.FirstPublishLocationId= newRecord.Id;
            contentVersionFile.VersionData = relatedDocument.VersionData;
            relatedDocuments.add(contentVersionFile);
            system.debug('contentVersionFile-->'+contentVersionFile);
        }
        Database.saveResult[] srFiles = Database.insert(relatedDocuments);
        return newRecord;
        
    }
    
    @AuraEnabled
    public static PayRoll__c updatepayroll( String ConRecordid,  PayRoll__c newPayroll, String PayrollId) {
        
        newPayroll.Id = PayrollId;
        newPayroll.Contact__c = ConRecordid;
        update newPayroll;
        return newPayroll;    
    }
    
    @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> getRelatedFilesByRecordIdForPayForms(String recordId) {
   
         Map<Id, ContentDocumentLink> contentDocumentLinks = new Map<Id, ContentDocumentLink>([ SELECT Id, LinkedEntityId, ContentDocumentId
                                                                                               FROM ContentDocumentLink
                                                                                               WHERE LinkedEntityId =:recordId ]);
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : contentDocumentLinks.keySet()];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
 
        Map<Id, ContentDocument> contentDocuments = new Map<Id, ContentDocument>([ SELECT Id, Title, FileExtension
                                                                                   FROM ContentDocument
                                                                                   WHERE Id IN: getContentDocumentIds(contentDocumentLinks.values()) ]);
 
        Map<Id, List<ContentDocument>> documentIdToContentDocumentsList = prepareDocumentIdToContentDocumentListMap(contentDocumentLinks.values(), contentDocuments);
 
       return prepareDocumentWrapperResponse(documentIdToContentDocumentsList, mapIdTitle);  
    }    
    
    @AuraEnabled
    public static ContentDistribution getContentDistributionForFile(Id contentDocumentId){
 
        ContentVersion contentVersion = [ SELECT Id, ContentDocumentId, IsMajorVersion, IsLatest
                                          FROM ContentVersion 
                                          WHERE ContentDocumentId =: contentDocumentId
                                            AND IsLatest = true
                                          LIMIT 1 ];
 
        List<ContentDistribution> contentDistribution = [ SELECT Id, Name, ContentDownloadUrl, ContentVersionId 
                                                          FROM ContentDistribution 
                                                          WHERE ContentVersionId =: contentVersion.Id ];
        if (!contentDistribution.isEmpty()) {
            return contentDistribution[0];
        }
        // else create new contentDistribution
        ContentDistribution newContentDistribution = new ContentDistribution( Name = contentVersion.ContentDocumentId,
                                                                              ContentVersionId = contentVersion.Id,
                                                                              PreferencesAllowViewInBrowser = true );
        insert newContentDistribution;
 
        return  [ SELECT Id, Name, ContentDownloadUrl, ContentDocumentId 
                  FROM ContentDistribution 
                  WHERE Id =: newContentDistribution.Id 
                  LIMIT 1 ];
    }
 
    private static List<Id> getContentDocumentIds(List<ContentDocumentLink> contentDocumentsLinks) {
        List<Id> contentDocumentsIds = new List<Id>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentsLinks) {
            contentDocumentsIds.add(contentDocumentLink.ContentDocumentId);
        }
        return contentDocumentsIds;
    }
 
    private static Map<Id, List<ContentDocument>> prepareDocumentIdToContentDocumentListMap(List<ContentDocumentLink> contentDocumentsLinks, Map<Id, ContentDocument> contentDocuments) {
        Map<Id, List<ContentDocument>> documentIdToContentDocumentsList = new Map<Id, List<ContentDocument>>();
        for (ContentDocumentLink contentDocumentLink : contentDocumentsLinks) {
            List<ContentDocument> currentContentDocumentList = documentIdToContentDocumentsList.get(contentDocumentLink.LinkedEntityId);
            if (currentContentDocumentList == null) {
                currentContentDocumentList = new List<ContentDocument>();
            } 
            currentContentDocumentList.add(
                contentDocuments.get(contentDocumentLink.ContentDocumentId)
            );
            documentIdToContentDocumentsList.put(contentDocumentLink.LinkedEntityId, currentContentDocumentList);
        }
        return documentIdToContentDocumentsList;
    }
 
    private static List<DocumentWrapper> prepareDocumentWrapperResponse(Map<Id, List<ContentDocument>> documentIdToContentDocumentsList, Map<ID, String> fileWithTitle) {
        List<DocumentWrapper> documentsAndFiles = new List<DocumentWrapper>();
 
        for (Id documentId : documentIdToContentDocumentsList.keySet()) {
           List<FileWrapper> filwWrap = new List<FileWrapper>();
            for (ContentDocument contentDocument : documentIdToContentDocumentsList.get(documentId)) {
                FileWrapper fileWrapper = new FileWrapper();
                fileWrapper.id = contentDocument.Id;
                fileWrapper.name = contentDocument.Title;
                fileWrapper.fileExtension = contentDocument.FileExtension;
                filwWrap.add(fileWrapper);
            }
            
             DocumentWrapper documentWrapper = new DocumentWrapper();
            documentWrapper.id = documentId;
            documentWrapper.name = fileWithTitle.get(documentId);
            documentWrapper.description = fileWithTitle.get(documentId);
            documentWrapper.files = filwWrap;
            documentsAndFiles.add(documentWrapper);
        }
 
        return documentsAndFiles;
    }
    
    
    public class DocumentWrapper {
    @AuraEnabled
    public Id id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public List<FileWrapper> files;
}
    
     
    public class FileWrapper {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String fileExtension;
    }
    
}