public class EMS_EM_MedicalInsuranceController{
    
    @AuraEnabled(cacheable=true)
    public static medicalInsuranceAndBenifites MedicalInsuranceMethod(String contactId){
        List<EMS_EM_Dependents__c> listEmsEmDependents = new List<EMS_EM_Dependents__c>();
        try{
            listEmsEmDependents = [SELECT Id,
                                   IsDeleted, Name, CreatedDate, CreatedById, 
                                   LastModifiedDate, SystemModstamp, LastModifiedById,
                                   EMS_EM_Relationship_to_Nominee__c,
                                   EMS_EM_Date_of_Birth__c, EMS_EM_Contact__c,visiable_to_edit__c 
                                   FROM EMS_EM_Dependents__c Where EMS_EM_Contact__c =:contactId LIMIT 5];
        }Catch(Exception ex){
            System.debug('### Exception Occured With'+ex.getStackTraceString());
            System.debug('### Exception Occured With'+ex.getMessage());
            listEmsEmDependents = null;
        }  
        Id  emsBenefitsId   = [SELECT Id,
                               Name, OwnerId, IsDeleted, CreatedDate, CreatedById, LastModifiedDate, 
                               LastModifiedById, SystemModstamp, 
                               EMS_EM_Valid_From__c, EMS_EM_Nominee__c, EMS_EM_Membership_No__c, 
                               EMS_EM_Relationship__c FROM EMS_EM_Benefits__c 
                               Where EMS_EM_Nominee__c =:contactId Order by createdDate DESC LIMIT 1]?.Id;  
        System.debug('### Received Contact ID' + emsBenefitsId);
        medicalInsuranceAndBenifites wrapper = new medicalInsuranceAndBenifites();
        wrapper.emsBenefitsId = emsBenefitsId;
        wrapper.listEmsEmDependents = listEmsEmDependents;
        return wrapper;
    }
    
    public class medicalInsuranceAndBenifites{
        @AuraEnabled
        public string emsBenefitsId;
        @AuraEnabled
        public List<EMS_EM_Dependents__c> listEmsEmDependents;
    }
    
}