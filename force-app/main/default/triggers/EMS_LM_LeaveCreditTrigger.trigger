trigger EMS_LM_LeaveCreditTrigger on EMS_LM_Leave_Credit__c (after insert) {
    if(trigger.isAfter && trigger.isInsert){
        EMS_LM_LeaveBalance_Update.availableLeaveBalanceCalculation(trigger.new);
    }
}