/**
* @author Subba Kalavala
* @date 10/01/2023
* @description Master Trigger for the Contact object, which fires on ALL Trigger
*              actions to control the order in which they occur.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
*20/01/2023		Sangharsh kamble		LeaveCalculateHandler update annual leave and comoff leave
* N/A           N/A                     N/A
* ====================================================================================================
**/
trigger CP_LeaveRequestTrigger on EMS_LM_Leave_History__c ( before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  new MetadataTriggerHandler().run();
    
    if( Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
    {
    LeaveCalculateHandler.leaveCalculateMethod(Trigger.New); 
    }
}