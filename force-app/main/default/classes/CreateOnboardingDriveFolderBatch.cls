public class CreateOnboardingDriveFolderBatch implements Database.Batchable<EMS_EM_Onboarding_Request__c>, Database.allowscallouts {
    
    public list<EMS_EM_Onboarding_Request__c> RequestList;
    public CreateOnboardingDriveFolderBatch(list<EMS_EM_Onboarding_Request__c> RequestList){
        this.RequestList = RequestList;
    }
    
    public Iterable<EMS_EM_Onboarding_Request__c> start(Database.BatchableContext BC){
        return RequestList;
    }
    
    public void execute(Database.BatchableContext BC, List<EMS_EM_Onboarding_Request__c> scope){
        Id ffId = scope[0].Id;
        EMS_EM_Onboarding_Request__c Request = [select id,EMS_EM_Name__c,Is_Inegration_Needed__c, Google_Drive_ID__c from EMS_EM_Onboarding_Request__c where id =:ffId];
        
        if(request.EMS_EM_Name__c != null && request.EMS_EM_Name__c != '' && request.Google_Drive_ID__c==null){
            CreateDriveMainFolder.createOnboardRequestFolderinDrive(Request.EMS_EM_Name__c);
        }
    }
    
    public void finish(Database.BatchableContext BC){  
    }
    
}