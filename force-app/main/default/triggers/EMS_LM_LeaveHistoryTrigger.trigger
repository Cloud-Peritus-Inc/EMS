trigger EMS_LM_LeaveHistoryTrigger on EMS_LM_Leave_History__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isUpdate){
            List<EMS_LM_Leave_History__c> l = new List<EMS_LM_Leave_History__c>();
            List<EMS_LM_Leave_History__c> lApproved = new List<EMS_LM_Leave_History__c>();
            List<EMS_LM_Leave_History__c> lCancelled = new List<EMS_LM_Leave_History__c>();
            Map<Id, EMS_LM_Leave_History__c> oldMap = new Map<Id, EMS_LM_Leave_History__c>(Trigger.oldMap);
            for(EMS_LM_Leave_History__c e: Trigger.new){
                if(e.EMS_LM_Status__c != oldMap.get(e.Id).EMS_LM_Status__c){
                    l.add(e);
                }
                if(e.EMS_LM_Status__c == 'Approved' && oldMap.get(e.Id).EMS_LM_Status__c != 'Approved'){
                    lApproved.add(e);
                } 
                if(e.EMS_LM_Status__c == 'Cancelled' && oldMap.get(e.Id).EMS_LM_Status__c == 'Approved'){
                    lCancelled.add(e);    
                } 
            }
            if(l.size()>0){
                EMS_LM_LeaveBalance_Update.utilizedLeaveBalanceCalculation(l);
            }
            if(lApproved.size()>0){
                //EMS_LM_TimesheetCreation.EMS_LM_TimesheetCreation(lApproved);
                
            }
            if(lCancelled.size()>0){
                //EMS_LM_TimesheetCreation.EMS_LM_TimesheetDeletion(lCancelled);                
            }
        }
    }
}