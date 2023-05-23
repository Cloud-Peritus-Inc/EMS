/**
* @author Naga Karpurapu
* @date 18/05/2023
* @description Master Trigger for the Resource Request object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger ResourceTrigger on Resource_Request__c (before insert,
                                                after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
 ) {
 new MetadataTriggerHandler().run();
}