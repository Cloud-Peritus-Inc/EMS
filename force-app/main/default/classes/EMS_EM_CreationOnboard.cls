/**
* @author Rakshitha 
* @date 27/01/2023
* @description  Create Onboard Record from onboarding form 
*
*               Test code coverage provided by the following test class:
*               - EMS_EM_CreationOnboardTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/


public without Sharing class EMS_EM_CreationOnboard {
    
    public string contactId;
    public class relatedFile {
        public String PathOnClient;
        public String Title;
        public Blob VersionData;
    }
    public static string onboardformId;
    
    
    @AuraEnabled
    public static onboardingDetails createGuest(EMS_EM_Onboarding_Request__c newRecord, ems_EM_Additional_Detail__c newaddRecord,
                                                List<Object> files) {
                                                    if(String.isBlank(newRecord.Id)){
                                                        string contactId; 
                                                        insert newRecord;  
                                                        contactId = newRecord.Id; 
                                                        
                                                        newaddRecord.Onboarding_Request__c = newRecord.Id;
                                                        insert newaddRecord;
                                                        
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
                                                        onboardingDetails WrapperDetails = new onboardingDetails();                                                  
                                                        WrapperDetails.onboarding = newRecord;
                                                        WrapperDetails.additionalDetails = newaddRecord;
                                                        return WrapperDetails;
                                                    } else if(String.isNotBlank(newRecord.Id)){
                                                        onboardingDetails wrapperOnBoarding = updateonboardingDetails(newRecord, newaddRecord, files);
                                                        return wrapperOnBoarding;
                                                    }else{
                                                        return null;
                                                    }                                             
                                                }
    
    
    @AuraEnabled
    public static onboardingDetails updateonboardingDetails(EMS_EM_Onboarding_Request__c newRecord, 
                                                            ems_EM_Additional_Detail__c newaddRecord,
                                                            List<Object> files){
                                                                string contactId; 
                                                                Update newRecord;  
                                                                contactId = newRecord.Id;  
                                                                newaddRecord.Onboarding_Request__c = newRecord.Id;
                                                                Update newaddRecord;
                                                                
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
                                                                onboardingDetails WrapperDetails = new onboardingDetails();                                                  
                                                                WrapperDetails.onboarding = newRecord;
                                                                WrapperDetails.additionalDetails = newaddRecord;
                                                                return WrapperDetails;
                                                                
                                                            }
    
    
    
    @AuraEnabled
    public static void sendEmail( String subject,String recordId,String body) {  
        Messaging.reserveSingleEmailCapacity(1);
        try{
            List<String> toAddress=new List<String>();
            //Employee 
            for(user us:[SELECT Id, Name, Email FROM User WHERE UserRole.Name = 'Project Manager']){
                toAddress.add(us.Email);
            }
            
            messaging.SingleEmailMessage mail = new messaging.SingleEmailMessage();                
            mail.setToAddresses(toAddress);
            mail.setReplyTo('no-reply@xooa.com');
            mail.setSenderDisplayName('Cloud Peritus');
            mail.setSubject(subject);           
            mail.setHtmlBody(body);
            Messaging.sendEmail(new List<messaging.SingleEmailMessage> {mail});
        }
        catch (exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static EMS_EM_Onboarding_Request__c getUserOnboardInfo(String recordId){
        
        EMS_EM_Onboarding_Request__c onboardlist=[Select EMS_EM_First_Name__c,EMS_EM_Last_Name__c,Do_you_have_work_experience__c,Name,EMS_EM_Gender__c,Phone_Number__c, Trailblazer_ID_or_Public_URL__c,ContactId1__c,
                                                  EMS_EM_Phone_Number__c,EMS_EM_DOB__c,Status__c,EMS_EM_Personal_Email__c, 
                                                  EMS_EM_AadhaarNo__c,EMS_EM_PanNo__c,EMS_EM_PassportNo__c,EMS_EM_UAN_Number__c,EMS_EM_Nationality__c,Permanent_Address_Line_1__c,Permanent_Address_Line_2__c,
                                                  Current_Address_Line_1__c,Current_Address_Line_2__c,EMS_EM_CA_State__c,EMS_EM_PA_State__c,EMS_EM_CA_Zip__c,EMS_EM_PA_Zip__c,EMS_EM_CA_City__c,EMS_EM_PA_City__c,
                                                  EMS_EM_Education__c,EMS_EM_Education1__c,EMS_EM_Education2__c,EMS_EM_Education3__c,
                                                  EMS_EM_Education4__c,EMS_EM_Education5__c,EMS_EM_Degree__c,EMS_EM_Degree1__c,EMS_EM_Degree2__c,EMS_EM_Degree3__c,EMS_EM_Degree4__c,EMS_EM_Degree5__c,
                                                  EMS_EM_IName__c,EMS_EM_IName1__c,EMS_EM_IName2__c,EMS_EM_IName3__c,EMS_EM_IName4__c,EMS_EM_IName5__c,
                                                  EMS_EM_Field_of_Study__c,EMS_EM_Field_of_Study1__c,EMS_EM_Field_of_Study2__c,EMS_EM_Field_of_Study3__c,EMS_EM_Field_of_Study4__c,EMS_EM_Field_of_Study5__c,
                                                  EMS_EM_GDate__c,EMS_EM_GDate1__c,EMS_EM_GDate2__c,EMS_EM_GDate3__c,EMS_EM_GDate4__c,EMS_EM_GDate5__c,
                                                  EMS_EM_Job_Title__c,EMS_EM_Job_Title1__c,EMS_EM_Job_Title2__c,EMS_EM_Job_Title3__c,EMS_EM_Job_Title4__c,EMS_EM_Job_Title5__c,
                                                  EMS_EM_Previous_Company_Name__c,EMS_EM_Previous_Company_Name1__c,EMS_EM_Previous_Company_Name2__c,EMS_EM_Previous_Company_Name3__c,EMS_EM_Previous_Company_Name4__c,EMS_EM_Previous_Company_Name5__c,
                                                  EMS_EM_From_Date__c,EMS_EM_From_Date1__c,EMS_EM_From_Date2__c,EMS_EM_From_Date3__c,EMS_EM_From_Date4__c,EMS_EM_From_Date5__c,
                                                  EMS_EM_To_Date__c,EMS_EM_To_Date1__c,EMS_EM_To_Date2__c,EMS_EM_To_Date3__c,EMS_EM_To_Date4__c,EMS_EM_To_Date5__c,
                                                  EMS_EM_Previous_Company_HR_EmailId__c,EMS_EM_Certification_Name__c,EMS_EM_Certification_Name2__c,EMS_EM_Certification_Name3__c,EMS_EM_Certification_Name4__c,EMS_EM_Certification_Name5__c,EMS_EM_Certification_Name6__c,
                                                  EMS_EM_Certification_Name7__c,EMS_EM_Certification_Name8__c,EMS_EM_Certification_Name9__c,EMS_EM_Certification_Name10__c,EMS_EM_Certification_Name11__c,EMS_EM_Certification_Name12__c,
                                                  EMS_EM_Certification_Name13__c,EMS_EM_Certification_Name14__c,EMS_EM_Certification_Name15__c,EMS_EM_Certification_Name16__c,EMS_EM_Certification_Name17__c,EMS_EM_Certification_Name18__c,
                                                  EMS_EM_Certification_Name19__c,Personal_Details_Value_Filled__c,Identify_Details_Value_Filled__c,Address_Details_Value_Filled__c,Other_Certifications_Value_Filled__c, Education_Details_Filled__c, Work_Details_Filled__c
                                                  from EMS_EM_Onboarding_Request__c where Id=:recordId];
        
        return onboardlist;
        
    }
    
    @AuraEnabled
    public static onboardingDetails getonOnboardformInfo(String onboardEmailid){
        System.debug('onboarding email => '+onboardEmailid);
        if(String.isNotBlank(onboardEmailid)){
            try{
                onboardingDetails WrapperDetails = new onboardingDetails();                                                  
                WrapperDetails.onboarding = returnOnboardingDetailsBasedOnEmail(onboardEmailid);
                WrapperDetails.additionalDetails = returnAdditionalgDetailsBasedOnRecordId(WrapperDetails.onboarding.Id);
                WrapperDetails.contentDocumentLink = returnFiles(WrapperDetails.onboarding.Id,  WrapperDetails.additionalDetails.Id);
                WrapperDetails.gridConfiguration = [SELECT Id, Name, CreatedDate, Description__c, Grid_Configuration_Type__c  FROM Grid_Configuration__c where Grid_Configuration_Type__c = 'Company Information - Pre-Onboarding' Limit 1];
                return WrapperDetails; 
            }Catch(Exception ex){
                System.debug('### Exception' + ex.getMessage());
                System.debug('### Exception' + ex.getStackTraceString());
                return null;
            }
            
        }
        else{
            return null;
        }
        
    }
    
   
    @AuraEnabled
    public static EMS_EM_Onboarding_Request__c returnOnboardingDetailsBasedOnRecordId(String onboardingRecordId){
        Map<String, Schema.SObjectField> fieldMap = EMS_EM_Onboarding_Request__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> listOfOnboardingFieldNames = new List<String>(setFieldNames);
        List<EMS_EM_Onboarding_Request__c> onBoardingDetailsList = Database.query('SELECT ' + String.join(listOfOnboardingFieldNames, ',') + ' FROM EMS_EM_Onboarding_Request__c Where Id =:onboardingRecordId');
        return onBoardingDetailsList[0];
    }
    @AuraEnabled
    public static ems_EM_Additional_Detail__c returnAdditionalgDetailsBasedOnRecordId(String additionalDetailsRecordId){
        Map<String, Schema.SObjectField> fieldMap = ems_EM_Additional_Detail__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> listOfAdditionalFieldNames = new List<String>(setFieldNames);
        List<ems_EM_Additional_Detail__c> additionalDetailsList = Database.query('SELECT ' + String.join(listOfAdditionalFieldNames, ',') + ' FROM ems_EM_Additional_Detail__c Where Onboarding_Request__c =:additionalDetailsRecordId');
        return additionalDetailsList[0];
    }
    @AuraEnabled
    public static EMS_EM_Onboarding_Request__c returnOnboardingDetailsBasedOnEmail(String onboardingEmail){
        Map<String, Schema.SObjectField> fieldMap = EMS_EM_Onboarding_Request__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> listOfOnboardingFieldNames = new List<String>(setFieldNames);
        List<EMS_EM_Onboarding_Request__c> onBoardingDetailsList = Database.query('SELECT ' + String.join(listOfOnboardingFieldNames, ',') + ' FROM EMS_EM_Onboarding_Request__c Where EMS_EM_Personal_Email__c =:onboardingEmail');
        return onBoardingDetailsList[0];
    }
    @AuraEnabled
    public static EMS_EM_Onboarding_Request__c returnOnboardingDetailsBasedOnContactId(String onboardingContactId){
        Map<String, Schema.SObjectField> fieldMap = EMS_EM_Onboarding_Request__c.sObjectType.getDescribe().fields.getMap();
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> listOfOnboardingFieldNames = new List<String>(setFieldNames);
        List<EMS_EM_Onboarding_Request__c> onBoardingDetailsList = Database.query('SELECT ' + String.join(listOfOnboardingFieldNames, ',') + ' FROM EMS_EM_Onboarding_Request__c Where ContactId__c =:onboardingContactId');
        return onBoardingDetailsList[0];
    }
    
    
    public static List<ContentDocument> returnFiles(String onBoardingRecordId, string additionalRecordId){
        
        try{
            Set<Id> documentIdsSet = new Set<Id>();
            if (String.isNotBlank(onBoardingRecordId)) {
                For (ContentDocumentLink content : [SELECT Id, 
                                                    LinkedEntityId, 
                                                    ContentDocumentId 
                                                    FROM ContentDocumentLink 
                                                    Where LinkedEntityId =:onBoardingRecordId]){
                                                        
                                                        documentIdsSet.add(content.ContentDocumentId);
                                                    }
            }
            if(String.isNotBlank(additionalRecordId)){
                
                for (ContentDocumentLink content: [SELECT Id, 
                                                   LinkedEntityId, 
                                                   ContentDocumentId 
                                                   FROM ContentDocumentLink 
                                                   Where LinkedEntityId =:additionalRecordId]) {
                                                       documentIdsSet.add(content.ContentDocumentId); 
                                                   }
                
                if(documentIdsSet.isEmpty()){
                    return null;
                }
                
            }
            return [SELECT Id, 
                    Title, 
                    ContentSize, 
                    FileType, 
                    PublishStatus, 
                    LatestPublishedVersionId, 
                    CreatedDate,         
                    FileExtension FROM ContentDocument  
                    Where Id In :documentIdsSet];
        }catch(Exception ex){
            System.debug('### Exception' + ex.getMessage());
            System.debug('### Exception' + ex.getStackTraceString());
            return null;
        }
        
    }
    
    public class onboardingDetails{
        @AuraEnabled
        public EMS_EM_Onboarding_Request__c onboarding;
        @AuraEnabled
        public ems_EM_Additional_Detail__c additionalDetails;
        @AuraEnabled
        public List<ContentDocument> contentDocumentLink;
        @AuraEnabled
        public Grid_Configuration__c  gridConfiguration;
        
        public onboardingDetails(){
            onboarding = new EMS_EM_Onboarding_Request__c();
            additionalDetails = new ems_EM_Additional_Detail__c();
            contentDocumentLink = new List<ContentDocument>();
            gridConfiguration = new Grid_Configuration__c();
        }
    }
    
    @AuraEnabled( cacheable = true )
    public static List<Certifications__c> fetchCertifications(String recordId) {
        return [SELECT Id, 
                Onboarding_Request__c, 
                Contact__c, 
                Other__c,
                Certification_Name__c, 
                Completion_Date__c, Type__c 
                FROM Certifications__c WHERE Onboarding_Request__c =:recordId AND Type__c = 'Certification' LIMIT 20];
    }
    
    @AuraEnabled
    public static string dmlOnCertifications(Object data, String removeCertificationIds) {
        List<Certifications__c> updateCertifications = (List<Certifications__c>) JSON.deserialize(JSON.serialize(data), List<Certifications__c>.class);
        List<Certifications__c> deleteCertifications = new List<Certifications__c>();
        
        if(String.isNotBlank(removeCertificationIds)){
            List<Id> CertificationIds = removeCertificationIds.split(',');
            deleteCertifications = [SELECT Id FROM Certifications__c WHERE Id IN :CertificationIds];
        }
        
        try {
            if(updateCertifications != null && !updateCertifications.isEmpty()){
                upsert updateCertifications;
            }
            
            if(deleteCertifications != null && !deleteCertifications.isEmpty()){    
                delete deleteCertifications;
            }
            return 'Success: Contact(s) upsert/delete successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
        // return '';
    }
    
    // For Education Details
    @AuraEnabled( cacheable = true )
    public static List<ems_EM_Additional_Detail__c> fetchEducation(String recordId) {
        Id EduRecordTypeId = Schema.SObjectType.ems_EM_Additional_Detail__c.getRecordTypeInfosByName().get('Education Details').getRecordTypeId();
        return [SELECT Id, 
                Onboarding_Request__c, 
                ContactId__c, 
                RecordType.Name, 
                EMS_EM_Education__c,
                EMS_EM_Degree__c,
                EMS_EM_Field_of_Study__c,
                EMS_EM_IName__c,
                EMS_EM_GDate__c,
                EMS_EM_Job_Title__c,
                EMS_EM_From_Date__c,
                EMS_EM_To_Date__c,
                EMS_EM_Previous_Company_Name__c,
                EMS_EM_Previous_Company_HR_EmailId__c
                FROM ems_EM_Additional_Detail__c WHERE Onboarding_Request__c =:recordId  AND RecordType.Name IN ('Education Details', 'Work Details') ORDER BY createddate ASC];
    }
    
    @AuraEnabled
    public static string dmlOnEducation(Object data, String removeEducationIds) {
        List<ems_EM_Additional_Detail__c> updateEducations = (List<ems_EM_Additional_Detail__c>) JSON.deserialize(JSON.serialize(data), List<ems_EM_Additional_Detail__c>.class);
        List<ems_EM_Additional_Detail__c> deleteEducations = new List<ems_EM_Additional_Detail__c>();
        
        if(String.isNotBlank(removeEducationIds)){
            List<Id> EducationsIds = removeEducationIds.split(',');
            deleteEducations = [SELECT Id FROM ems_EM_Additional_Detail__c WHERE Id IN :EducationsIds];
        }
        
        try {
            if(updateEducations != null && !updateEducations.isEmpty()){
                upsert updateEducations;
            }
            
            if(deleteEducations != null && !deleteEducations.isEmpty()){    
                delete deleteEducations;
            }
            return 'Success: Education(s) upsert/delete successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
    }
    
     @AuraEnabled
    public static String saveFiles(String recordId, String filedata) {
        try {
            if(String.isNotBlank(FileData)) {
                List<FileDataWP> files = (List<FileDataWP>) JSON.deserialize(filedata, List<FileDataWP>.class);
                System.debug(files);
 
                List<ContentVersion> cvList = new List<ContentVersion>();
                for(FileDataWP file : files) {
                    ContentVersion conVer = new ContentVersion();
                    conVer.ContentLocation = 'S'; // S = Salesforce, E = External Files
                    conVer.VersionData = EncodingUtil.base64Decode(file.fileContent);
                    conVer.Title = file.fileName;
                    conVer.PathOnClient = file.fileName;
                    cvList.add(conVer);
                }
                Insert cvList;
 
                List<ContentDocumentLink> cdList = new List<ContentDocumentLink>();
                for(ContentVersion cv : [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cvList]) {
                    ContentDocumentLink conDocLink = New ContentDocumentLink();
                    conDocLink.LinkedEntityId = recordId;
                    conDocLink.ContentDocumentId = cv.ContentDocumentId;
                    conDocLink.Visibility = 'AllUsers';
                    conDocLink.shareType = 'V'; // V = Viewer, C = Collaborator, I = Inferred
                    cdList.add(conDocLink);
                }
                Insert cdList;        
            } else {
                return 'record Id is Blank';
            }
            return 'success';
        } catch (Exception ex) {
            System.debug(ex.getMessage() + ' -> ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
 
    public class FileDataWP {
        public String fileName;
        public String fileContent;
    }
    
    
    
}
