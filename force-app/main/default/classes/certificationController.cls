public class certificationController {
    
    @AuraEnabled( cacheable = true )
    public static List<Certifications__c> fetchCertifications(String recordId) {
        return [SELECT Id, 
                Onboarding_Request__c, 
                Contact__c, 
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
    
    @AuraEnabled( cacheable = true )
    public static List<ems_EM_Additional_Detail__c> fetchEducation(String recordId) {
        Id EduRecordTypeId = Schema.SObjectType.ems_EM_Additional_Detail__c.getRecordTypeInfosByName().get('Education Details').getRecordTypeId();
        return [SELECT Id, 
                Onboarding_Request__c, 
                ContactId__c, 
                RecordTypeId, 
                EMS_EM_Education__c,
                EMS_EM_Degree__c,
                EMS_EM_Field_of_Study__c,
                EMS_EM_IName__c,
                EMS_EM_GDate__c
                FROM ems_EM_Additional_Detail__c WHERE Onboarding_Request__c =:recordId AND RecordTypeId =: EduRecordTypeId LIMIT 20];
    }
    
    @AuraEnabled
    public static string dmlOnEducation(Object data, String removeCertificationIds) {
        List<ems_EM_Additional_Detail__c> updateCertifications = (List<ems_EM_Additional_Detail__c>) JSON.deserialize(JSON.serialize(data), List<ems_EM_Additional_Detail__c>.class);
        List<ems_EM_Additional_Detail__c> deleteCertifications = new List<ems_EM_Additional_Detail__c>();
        
        if(String.isNotBlank(removeCertificationIds)){
            List<Id> CertificationIds = removeCertificationIds.split(',');
            deleteCertifications = [SELECT Id FROM ems_EM_Additional_Detail__c WHERE Id IN :CertificationIds];
        }
        
        try {
            if(updateCertifications != null && !updateCertifications.isEmpty()){
                upsert updateCertifications;
            }
            
            if(deleteCertifications != null && !deleteCertifications.isEmpty()){    
                delete deleteCertifications;
            }
            return 'Success: Education(s) upsert/delete successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
        // return '';
    }
    @AuraEnabled
    public static void uploadFiles(List<String> fileContents, List<String> fileNames) {
        List<ContentVersion> fileVersions = new List<ContentVersion>();
        
        for (Integer i = 0; i < fileContents.size(); i++) {
            String fileContent = fileContents.get(i);
            String fileName = fileNames.get(i);
            
            ContentVersion fileVersion = new ContentVersion(
                Title = fileName,
                PathOnClient = fileName,
                VersionData = EncodingUtil.base64Decode(fileContent)
            );
            
            fileVersions.add(fileVersion);
        }
        
        insert fileVersions;
    }
    
}