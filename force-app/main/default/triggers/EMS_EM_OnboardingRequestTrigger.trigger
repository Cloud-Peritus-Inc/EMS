trigger EMS_EM_OnboardingRequestTrigger on EMS_EM_Onboarding_Request__c (after insert,after update) {
     if(trigger.isafter && trigger.isinsert)
          {
           OnboardingRequestTriggerHandler.createDriveFornewRequest(trigger.new);   
     }
    
    If(trigger.isAfter && trigger.isUpdate){
       EMS_EM_aplicantConvertResource.createContact(Trigger.New,Trigger.oldMap);
    }
    
}