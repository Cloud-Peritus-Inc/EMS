/**
* @author Ramakrishna
* @date 24/01/2023
* @description Master Trigger for the TimesheetRecord object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger CP_TimesheetRecordTrigger on EMS_TM_Timesheet_Record__c (before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();
}