trigger EMS_EM_OnboardingRequestTrigger on EMS_EM_Onboarding_Request__c (after insert,after update,before delete) {
     if(trigger.isafter && trigger.isinsert)
          {
           OnboardingRequestTriggerHandler.createDriveFornewRequest(trigger.new);   
     }
    
    If(trigger.isAfter && trigger.isUpdate){
       EMS_EM_aplicantConvertResource.createContact(Trigger.New,Trigger.oldMap);
    }
     If(trigger.isBefore && trigger.isDelete){
       restrictHRFrmDeletingOB.restHRDelete(Trigger.old);
    }
     If(trigger.isAfter && trigger.isUpdate){
        // eMS_EM_UpdateContentDocumentLink.update_eMS_EM_ContentDocumentLink(Trigger.New);
    }
}