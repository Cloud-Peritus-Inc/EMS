/**
* @author RK and SAI
* @date 10/01/2023
* @description Master Trigger for the Assignment object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger CP_AssignementTrigger on EMS_TM_Assignment__c (before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();
}