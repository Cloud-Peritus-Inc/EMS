public class OnboardingRequestTriggerHandler {
    public static void createDriveFornewRequest(list<EMS_EM_Onboarding_Request__c> newRequestList){
        List<EMS_EM_Onboarding_Request__c> RequestList = new List<EMS_EM_Onboarding_Request__c>();
        for(EMS_EM_Onboarding_Request__c request : newRequestList){
            if(request.EMS_EM_Name__c != null && request.EMS_EM_Name__c != '' && request.Google_Drive_ID__c==null){
                RequestList.add(request); 
            }
        }
        if(!RequestList.isEmpty()){
            Database.executeBatch(new CreateOnboardingDriveFolderBatch(RequestList), 1); 
        }
    }
}