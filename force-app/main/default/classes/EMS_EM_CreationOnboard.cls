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
        
        EMS_EM_Onboarding_Request__c onboardlist=[Select EMS_EM_First_Name__c,EMS_EM_Last_Name__c,EMS_EM_Father__c,Name,EMS_EM_Mother__c,EMS_EM_Gender__c,Phone_Number__c,
                                                  EMS_EM_Phone_Number__c,EMS_EM_DOB__c,EMS_EM_Mstatus__c,EMS_EM_Spouse__c,EMS_EM_DOW__c,Status__c,EMS_EM_BG__c,EMS_EM_Personal_Email__c, 
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
                                                  EMS_EM_Certification_Name19__c,Personal_Details_Value_Filled__c,Identify_Details_Value_Filled__c,Address_Details_Value_Filled__c,Other_Certifications_Value_Filled__c
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
    public static ems_EM_Additional_Detail__c getonOnboardAdditionalInfo(String getContactid){     
        
        if(getContactid!=Null){
            ems_EM_Additional_Detail__c onboardAdditionallist=[SELECT Id,EMS_EM_Job_Title5__c, EMS_EM_Degree__c, EMS_EM_Degree1__c, 
                                                               EMS_EM_Degree2__c, EMS_EM_Degree3__c, EMS_EM_Degree4__c, EMS_EM_Degree5__c,
                                                               EMS_EM_Education1__c, EMS_EM_Education2__c, EMS_EM_Education3__c, 
                                                               EMS_EM_Education4__c, EMS_EM_Education5__c, EMS_EM_Education__c, 
                                                               EMS_EM_Field_of_Study1__c, EMS_EM_Field_of_Study2__c, EMS_EM_Field_of_Study3__c, 
                                                               EMS_EM_Field_of_Study4__c, EMS_EM_Field_of_Study5__c, EMS_EM_Field_of_Study__c, 
                                                               EMS_EM_GDate2__c, EMS_EM_GDate1__c, EMS_EM_GDate3__c, EMS_EM_GDate4__c, 
                                                               EMS_EM_GDate5__c, EMS_EM_GDate__c, EMS_EM_IName1__c, EMS_EM_IName2__c, 
                                                               EMS_EM_IName3__c, EMS_EM_IName4__c, EMS_EM_IName5__c, EMS_EM_IName__c, 
                                                               EMS_EM_From_Date1__c, EMS_EM_From_Date2__c, EMS_EM_From_Date3__c, 
                                                               EMS_EM_From_Date4__c, EMS_EM_From_Date5__c, EMS_EM_From_Date__c, 
                                                               EMS_EM_Job_Title1__c, EMS_EM_Job_Title2__c, EMS_EM_Job_Title3__c, 
                                                               EMS_EM_Job_Title4__c, EMS_EM_Job_Title__c, EMS_EM_To_Date1__c, 
                                                               EMS_EM_To_Date3__c, EMS_EM_To_Date2__c, EMS_EM_To_Date4__c, EMS_EM_To_Date5__c, 
                                                               EMS_EM_To_Date__c, EMS_EM_Previous_Company_HR_EmailId__c, 
                                                               EMS_EM_Previous_Company_Name1__c, EMS_EM_Previous_Company_Name2__c,
                                                               EMS_EM_Previous_Company_Name3__c, EMS_EM_Previous_Company_Name4__c,
                                                               EMS_EM_Previous_Company_Name5__c, EMS_EM_Previous_Company_Name__c,Education_Details_Filled__c,Work_Details_Filled__c, 
                                                               Onboarding_Request__c, ContactId__c FROM ems_EM_Additional_Detail__c 
                                                               where ContactId__c=:getContactid];
            
            return onboardAdditionallist;
        }else{
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
    
    @AuraEnabled
    public static List<Certifications__c> createRecords(List<Certifications__c> certifications) {
        insert certifications;

        return certifications;
    }
    
    
}