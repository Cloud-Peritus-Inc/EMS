/**
* @author Eswar Tangudu
* @date 03/27/2023
* @description Master Trigger for the Onboarding request object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger OnBoardingRequestTrigger on EMS_EM_Onboarding_Request__c ( before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();

}