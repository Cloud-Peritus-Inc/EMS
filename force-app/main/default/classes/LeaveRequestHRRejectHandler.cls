/**
* @author Pavan
* @date 11/01/2023
* @description  To update the leave request status to Rejected for admim view tab.
*            
*
*               Test code coverage provided by the following test class:
*               -LeaveRequestHRRejectHandlerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class LeaveRequestHRRejectHandler {
                /**
*   {Purpose} - Method used to update leave request status to Rejected.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled
    public static void updateRejectStatus(String leaveRequestId , String comments){
        System.debug('### LeaveRequestId ' + leaveRequestId);
        System.debug('### Comments ' + comments);
        
        User usr = [SELECT Id, 
                           Hr_Access__c,
                           LastName,
                           FirstName
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID]; 
      if (usr.Hr_Access__c = true) {
        List<EMS_LM_Leave_History__c> leaveReqList = new List<EMS_LM_Leave_History__c>();
        for (EMS_LM_Leave_History__c leaveReqStatus : [SELECT Id,
                                                    		 EMS_LM_Status__c,
                                                             EMS_LM_Approver__c,
                                                       		 EMS_LM_Current_Approver__c,
                                                       		 EMS_LM_Remarks__c,
                                                             EMS_LM_Approved_On__c
                                                        FROM EMS_LM_Leave_History__c
                                                        WHERE Id =: leaveRequestId]) {
                                                                
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.EMS_LM_Current_Approver__c = usr.FirstName + ' ' + usr.LastName;
                leaveReqStatus.EMS_LM_Remarks__c = comments;
                leaveReqStatus.EMS_LM_Approved_On__c= System.today();                                       
                leaveReqList.add(leaveReqStatus); 
                                                                
           }
            System.debug('updatedLeaveReq Before Update' + leaveReqList);
        try{
           update leaveReqList;
           System.debug('updatedLeaveReq' + leaveReqList);
        }
            catch(Exception ex){
                //LogException.logHandledException(ex);
                LogException.logHandledException(ex, 'LeaveRequestHRRejectHandler', 'updateRejectStatus');
                System.debug('### Exception ' + ex.getMessage());
 
         }
      }
        
    }
    
                /**
*   {Purpose} - Method used for bulk rejection of leave request status for bulk Rejection.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
         @AuraEnabled
    public static void bulkLeaveReqReject(List<Id> bulkleaveReqId, String comments) {
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
        for (EMS_LM_Leave_History__c bulkleaveReqReject : [SELECT Id,
                                                             EMS_LM_Status__c,
                                                             EMS_LM_Approver__c,
                                                       		 EMS_LM_Current_Approver__c, 
                                                       	     EMS_LM_Approved_On__c,
                                                      		 EMS_LM_Remarks__c
                                                       FROM EMS_LM_Leave_History__c
                                                       WHERE Id =: bulkleaveReqId]){                                              
                  bulkleaveReqReject.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                  bulkleaveReqReject.EMS_LM_Approved_On__c	 = System.today();
                  bulkleaveReqReject.EMS_LM_Current_Approver__c = usr.FirstName + ' ' + usr.LastName;
                  bulkleaveReqReject.EMS_LM_Remarks__c = comments;
                  bulkLeaveReqList.add(bulkleaveReqReject); 
               }
        	System.debug('bulkupdatedLeaveReq Before Update' + bulkLeaveReqList);
        try{
           update bulkLeaveReqList;
           System.debug('bulkupdatedLeaveReq' + bulkLeaveReqList);
        }
            catch(Exception ex){
                //LogException.logHandledException(ex);
                LogException.logHandledException(ex, 'LeaveRequestHRRejectHandler', 'bulkLeaveReqReject');
                System.debug('### Exception ' + ex.getMessage());
        	}
    
    	}
	}
}