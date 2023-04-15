trigger EMS_EM_OnboardingRequestTrigger on EMS_EM_Onboarding_Request__c (after insert,after update) {
    for(EMS_EM_Onboarding_Request__c ert : trigger.new){
        system.debug('=====ert===='+ert);
    }
}