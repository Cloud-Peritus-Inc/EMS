/**
* @author Rohit B
* @date 09/07/2024
* @description Master Trigger for the PM_Configure__c object, which fires on ALL trigger actions to control the order in which they occur.
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger CP_PM_Configure on PM_Configure__c  (before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
    new MetadataTriggerHandler().run();}