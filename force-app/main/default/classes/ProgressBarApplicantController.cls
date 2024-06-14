public class ProgressBarApplicantController {
    
    @AuraEnabled(cacheable = true)
    public static List<EMS_EM_Onboarding_Request__c> fetchOnboardingRecords(String onboardingId){
        return[SELECT Id, 
                    Personal_Details_Value_Filled__c, 
                    Identify_Details_Value_Filled__c, 
                    Address_Details_Value_Filled__c,
                    Other_Certifications_Value_Filled__c,
                    Work_Details_Filled__c,
                    Education_Details_Filled__c
                    FROM EMS_EM_Onboarding_Request__c 
                    WHERE Id =: onboardingId ];
    }

    /*@AuraEnabled(cacheable = true)
    public static List<ems_EM_Additional_Detail__c> fetchAdditionalDetailRecords(String additionalDetailId){
        return[SELECT Id, 
                    Work_Details_Filled__c, 
                    Education_Details_Filled__c,
                    Onboarding_Request__r.Id
                    FROM ems_EM_Additional_Detail__c 
                    WHERE Onboarding_Request__r.Id =: additionalDetailId ]; 
    }*/
    
}