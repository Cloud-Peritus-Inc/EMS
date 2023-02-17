public without sharing class LeaveRequestHRApproveHandler {
    
    @AuraEnabled
  public static void updateLeaveStatus( String leaveRequestId, String comments){
       System.debug( '### LeaveRequestId' + leaveRequestId);
      System.debug( '### Comments ' + comments);
      
        User usr = [SELECT Id, 
                           Hr_Access__c,
                           LastName,
                           FirstName
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID]; 
      System.debug('#### usr ' + usr);
      if (usr.Hr_Access__c = true) {
        List<EMS_LM_Leave_History__c> leaveReqList = new  List<EMS_LM_Leave_History__c>();
        for(EMS_LM_Leave_History__c  leaveReqStatus: [SELECT Id,
                                                             EMS_LM_Status__c,
                                                             EMS_LM_Approver__c,
                                                       		 EMS_LM_Approver__r.LastName,
                                                       	     EMS_LM_Approver__r.FirstName,
                                                       		 EMS_LM_Current_Approver__c, 
                                                       	     EMS_LM_Approved_On__c,
                                                      		 EMS_LM_Remarks__c
                                                       FROM EMS_LM_Leave_History__c
                                                       WHERE Id =: leaveRequestId]){                                              
                  leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.APPROVED;
                  leaveReqStatus.EMS_LM_Approved_On__c	 = System.today();
                  leaveReqStatus.EMS_LM_Current_Approver__c = usr.LastName + ' ' + usr.FirstName;
                  leaveReqStatus.EMS_LM_Remarks__c = comments;
                  leaveReqList.add(leaveReqStatus); 
              }
        System.debug('updatedLeaveReq Before Update' + leaveReqList);
        try{
           update leaveReqList;
           System.debug('updatedLeaveReq' + leaveReqList);
        }
            catch(Exception ex){
                //LogException.logHandledException(ex);
                System.debug('### Exception ' + ex.getMessage());
        	}
   		}
	}
    
     @AuraEnabled
    public static void bulkLeaveReqApproval(List<Id> bulkleaveReqId, String comments) {
        System.debug('### bulkleaveReqId ' + bulkleaveReqId);
        System.debug('### Comments ' + comments);
        
                User usr = [SELECT Id, 
                           Hr_Access__c,
                           LastName,
                           FirstName
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID]; 
        
      if (usr.Hr_Access__c = true) {
        List<EMS_LM_Leave_History__c> bulkLeaveReqList = new List<EMS_LM_Leave_History__c>();        
        for (EMS_LM_Leave_History__c bulkleaveReqApproval : [SELECT Id,
                                                             EMS_LM_Status__c,
                                                             EMS_LM_Approver__c,
                                                       		 EMS_LM_Approver__r.LastName,
                                                       	     EMS_LM_Approver__r.FirstName,
                                                       		 EMS_LM_Current_Approver__c, 
                                                       	     EMS_LM_Approved_On__c,
                                                      		 EMS_LM_Remarks__c
                                                       FROM EMS_LM_Leave_History__c
                                                       WHERE Id =: bulkleaveReqId]){                                              
                  bulkleaveReqApproval.EMS_LM_Status__c = LeaveRequestConstant.APPROVED;
                  bulkleaveReqApproval.EMS_LM_Approved_On__c= System.today();
                  bulkleaveReqApproval.EMS_LM_Current_Approver__c = usr.LastName + ' ' + usr.FirstName;
                  bulkleaveReqApproval.EMS_LM_Remarks__c = comments;
                  bulkLeaveReqList.add(bulkleaveReqApproval); 
               }
        	System.debug('bulkupdatedLeaveReq Before Update' + bulkLeaveReqList);
        try{
           update bulkLeaveReqList;
           System.debug('bulkupdatedLeaveReq' + bulkLeaveReqList);
        }
            catch(Exception ex){
                //LogException.logHandledException(ex);
                System.debug('### Exception ' + ex.getMessage());
        	}
    
    }
    }
}