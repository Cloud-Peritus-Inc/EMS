global class ApprovalProcessController {
   @AuraEnabled
    Public static ProcessInstanceWorkitem recallApproval(Id recId)   
    {   
        String s = recId; 
        system.debug(s);
        List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
                                        FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :s LIMIT 1];
        system.debug('SOQL Query --------------------------------->'+s);
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Removed');       
        req.setWorkitemId(piwi[0].Id);
        Approval.process(req,false);
        return piwi[0];
    }
}