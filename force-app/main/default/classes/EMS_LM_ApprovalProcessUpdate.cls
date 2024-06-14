public with sharing class EMS_LM_ApprovalProcessUpdate {

/*This Class id used in LWC(eMS_LM_LeaveHistory, eMS_LM_LeaveHistory_AdminView, eMS_LM_LeaveHistory_PendingOnMe) wire to Recall, Approve and Reject the Reiaed Leave Request*/

    // This method called in LWC(eMS_LM_LeaveHistory) action to recall the raised Leave Request
    @AuraEnabled
    Public static void recallApproval(Id recId)   
    {      
        String s = recId; 
        system.debug(s);
        ProcessInstanceWorkitem piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :s LIMIT 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed');       
        req.setWorkitemId(piwi.Id);
        Approval.process(req,false);
    }


    // This method called in LWC(eMS_LM_LeaveHistory_AdminView, eMS_LM_LeaveHistory_PendingOnMe) action to Approve the raised Leave Request by Approvers
    @AuraEnabled
    Public static void approveApproval(Id recId)   
    {      
        String s = recId; 
        system.debug(s);
        ProcessInstanceWorkitem piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :s LIMIT 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Approve');       
        req.setWorkitemId(piwi.Id);
        Approval.process(req,false);
    }

    // This method called in LWC(eMS_LM_LeaveHistory_AdminView, eMS_LM_LeaveHistory_PendingOnMe) action to Reject the raised Leave Request by Approvers
    @AuraEnabled
    Public static void rejectApproval(Id recId)   
    {      
        String s = recId; 
        system.debug(s);
        ProcessInstanceWorkitem piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :s LIMIT 1];
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Reject');       
        req.setWorkitemId(piwi.Id);
        Approval.process(req,false);
    }  
}