/**
* @author Ramakrishna
* @date 09/02/2023
* @description Master Trigger for the Opportunity object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger CP_opportunity on Opportunity (before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
    new MetadataTriggerHandler().run();}