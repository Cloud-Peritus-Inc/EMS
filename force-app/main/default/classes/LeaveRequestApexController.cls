/**
* @author Pavan
* @date 10/01/2023
* @description  Getting the Leave Request Pending data based on the loggedIn user
*            
*
*               Test code coverage provided by the following test class:
*               - LeaveRequestApexControllerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

public without sharing class LeaveRequestApexController {
    
        /**
*   {Purpose} - Method used to display leave request data based on the loggedIn approver user.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public class LeaveRequestStatus {
    @AuraEnabled
        public List<EMS_LM_Leave_History__c> pendingList;
        @AuraEnabled
        public List<EMS_LM_Leave_History__c> approver2List;
        @AuraEnabled	
        public List<EMS_LM_Leave_History__c> approver3List;
	}
    
    @AuraEnabled(cacheable=true)
    public static LeaveRequestStatus getLeaveReqData(){
        LeaveRequestStatus leaveReqStatus = new LeaveRequestStatus();
       
         List<EMS_LM_Leave_History__c> leaveRequestPendingList = new List<EMS_LM_Leave_History__c>();
         List<EMS_LM_Leave_History__c> leaveRequestApprover2List = new List<EMS_LM_Leave_History__c>();
         List<EMS_LM_Leave_History__c> leaveRequestApprover3List = new List<EMS_LM_Leave_History__c>();
         for (EMS_LM_Leave_History__c emsLmLeave : [SELECT Id,
                                                            EMS_LM_Contact__r.LastName,
                                                            EMS_LM_Reason__c,
                                                            EMS_LM_Leave_Start_Date__c,
                                                            EMS_LM_Leave_End_Date__c,
                                                            EMS_LM_Leave_Duration__c,
                                                            EMS_LM_Approver__c,
                                                   	        EMS_LM_2nd_Approver__c,
                                                   			Approver_3__c,
                                                            EMS_LM_Status__c
                                                   FROM EMS_LM_Leave_History__c
                                                   WHERE (EMS_LM_Approver__c =:LeaveRequestConstant.LOGGEDIN_USERID
                                                   OR EMS_LM_2nd_Approver__c =:LeaveRequestConstant.LOGGEDIN_USERID
                                                   OR Approver_3__c =:LeaveRequestConstant.LOGGEDIN_USERID)
                                                   AND EMS_LM_Status__c !=: LeaveRequestConstant.APPROVED
                                                   AND EMS_LM_Status__c !=: LeaveRequestConstant.REJECTED
                                                   AND EMS_LM_Status__c !=: LeaveRequestConstant.CANCELLED]){
           if (LeaveRequestConstant.LOGGEDIN_USERID == emsLmLeave.EMS_LM_Approver__c && emsLmLeave.EMS_LM_Status__c == LeaveRequestConstant.PENDING) {
               	leaveRequestPendingList.add(emsLmLeave); //Approver 1
           }
           if (LeaveRequestConstant.LOGGEDIN_USERID == emsLmLeave.EMS_LM_2nd_Approver__c && emsLmLeave.EMS_LM_Status__c == LeaveRequestConstant.APPROVER_2_WAITING) {
               	leaveRequestApprover2List.add(emsLmLeave); //Approver 2
           }
           if (LeaveRequestConstant.LOGGEDIN_USERID == emsLmLeave.Approver_3__c && emsLmLeave.EMS_LM_Status__c == LeaveRequestConstant.APPROVER_3_WAITING) {
               	leaveRequestApprover3List.add(emsLmLeave); //Approver 3
           }
    }
        leaveReqStatus.pendingList = leaveRequestPendingList;
        leaveReqStatus.approver2List = leaveRequestApprover2List;
        leaveReqStatus.approver3List = leaveRequestApprover3List;
        System.debug('### leaveReqStatus' + leaveReqStatus);
        return leaveReqStatus;
    }
}