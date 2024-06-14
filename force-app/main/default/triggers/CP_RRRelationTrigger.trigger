/**
* @author Subba Kalavala
* @date 10/01/2023
* @description Master Trigger for the Resource RelationShip object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger CP_RRRelationTrigger on Resource_Resource_Relationship__c  ( before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();
}