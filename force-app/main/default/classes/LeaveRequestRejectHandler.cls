/**
* @author Pavan
* @date 11/01/2023
* @description  To update the leave request status to Rejected and Rejected comments
*            
*
*               Test code coverage provided by the following test class:
*               -
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class LeaveRequestRejectHandler {
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
    public static void updateRejecteStatusAndComments(String leaveRequestId , String comments){
        System.debug('### leaveRequestId ' + leaveRequestId);
        System.debug('### Comments ' + comments);
        List<EMS_LM_Leave_History__c> updatedLeaveReqList = new List<EMS_LM_Leave_History__c>();
        for (EMS_LM_Leave_History__c leaveReqStatus : [SELECT Id,
                                                    		EMS_LM_Status__c,
                                                    		Approver_1_Approved_Comments__c,
                                                    		Approver_2_Approved_Comments__c,
                                                    		Approver_3_Approved_Comments__c,
                                                            EMS_LM_Approver__c,
                                                       	 	 EMS_LM_Approver__r.LastName,
                                                       	     EMS_LM_Approver__r.FirstName,
                                                             EMS_LM_2nd_Approver__c,
                                                       		 EMS_LM_2nd_Approver__r.LastName,
                                                       	     EMS_LM_2nd_Approver__r.FirstName,
                                                       		 EMS_LM_Current_Approver__c,
                                                             Approver_3__c,
                                                             Approver_3__r.LastName,
                                                             Approver_3__r.FirstName
                                                    FROM EMS_LM_Leave_History__c
                                                    WHERE Id =:leaveRequestId]) {
           if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.EMS_LM_Approver__c) {
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.Approver_1_Approved_Comments__c = comments;
                leaveReqStatus.EMS_LM_Current_Approver__c = leaveReqStatus.EMS_LM_Approver__r.LastName + ' ' + leaveReqStatus.EMS_LM_Approver__r.FirstName ;
                updatedLeaveReqList.add(leaveReqStatus); 
            }else if(LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.EMS_LM_2nd_Approver__c) {
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.Approver_2_Approved_Comments__c = comments;
                leaveReqStatus.EMS_LM_Current_Approver__c = leaveReqStatus.EMS_LM_2nd_Approver__r.LastName + ' ' + leaveReqStatus.EMS_LM_2nd_Approver__r.FirstName ;
                updatedLeaveReqList.add(leaveReqStatus); 
            }else if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.Approver_3__c){
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.Approver_3_Approved_Comments__c = comments;
                leaveReqStatus.EMS_LM_Current_Approver__c = leaveReqStatus.Approver_3__r.LastName + ' ' + leaveReqStatus.Approver_3__r.FirstName ;
                updatedLeaveReqList.add(leaveReqStatus); 
            }
        }
        System.debug('### updatedLeaveReq Before Update' +updatedLeaveReqList);
        try{
            update updatedLeaveReqList;
            System.debug('### updatedLeaveReq' +updatedLeaveReqList);
        }
        catch(Exception ex){
            System.debug('### Exception' + ex.getMessage());
        }
        
    }
    
                /**
*   {Purpose} - Method used for bulk rejection of leave request status to Approced.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled
    public static void bulkLeaveReqReject(List<Id> bulkRejectId, String comments){
        System.debug('### bulkRejectId ' + bulkRejectId);
        System.debug('### Comments ' + comments);
        List<EMS_LM_Leave_History__c> bulkupdatedLeaveReqList = new List<EMS_LM_Leave_History__c>();
        for (EMS_LM_Leave_History__c leaveReqStatus : [SELECT Id,
                                                    		EMS_LM_Status__c,
                                                    		Approver_1_Rejection_Comments__c,
                                                    		Approver_2_Rejection_Comments__c,
                                                    		Approver_3_Rejection_Comments__c,
                                                     		EMS_LM_Approver__c,
                                                     		EMS_LM_2nd_Approver__c,
                                                            Approver_3__c
                                                    FROM EMS_LM_Leave_History__c
                                                    WHERE Id =:bulkRejectId]) {
           if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.EMS_LM_Approver__c) {
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.Approver_1_Rejection_Comments__c = comments;
                bulkupdatedLeaveReqList.add(leaveReqStatus); 
            }else if(LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.EMS_LM_2nd_Approver__c) {
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.Approver_2_Rejection_Comments__c = comments;
                bulkupdatedLeaveReqList.add(leaveReqStatus); 
            }else if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.Approver_3__c){
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.REJECTED;
                leaveReqStatus.Approver_3_Rejection_Comments__c = comments;
                bulkupdatedLeaveReqList.add(leaveReqStatus); 
            }
        }
        System.debug('### updatedLeaveReq Before Update' +bulkupdatedLeaveReqList);
        try{
            update bulkupdatedLeaveReqList;
            System.debug('### bulkupdatedLeaveReqList' +bulkupdatedLeaveReqList);
        }
        catch(Exception ex){
            System.debug('### Exception' + ex.getMessage());
        } 
    }
}