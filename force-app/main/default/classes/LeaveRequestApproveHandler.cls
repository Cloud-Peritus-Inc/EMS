/**
* @author Pavan
* @date 11/01/2023
* @description  To update the leave request status and Aprrover comments
*            
*
*               Test code coverage provided by the following test class:
*               - LeaveRequestApproveHandlerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class LeaveRequestApproveHandler {
            /**
*   {Purpose} - Method used to update leave request status to Approved, Approver 1 Pending, Approver 2 Pending.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled
    public static void updateApproveStatusAndComments(String leaveRequestId , String comments){
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
                                                             Approver_3__r.FirstName,
                                                       	     EMS_LM_Approved_On__c
                                                       FROM EMS_LM_Leave_History__c
                                                       WHERE Id =:leaveRequestId]) {
            //Approver 1
            if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.EMS_LM_Approver__c) {
                System.debug('### APP 1');
            	leaveReqStatus.EMS_LM_Status__c = String.isNotBlank(leaveReqStatus.EMS_LM_2nd_Approver__c) ? LeaveRequestConstant.APPROVER_3_WAITING : LeaveRequestConstant.APPROVED;
            	leaveReqStatus.Approver_1_Approved_Comments__c = comments;
                leaveReqStatus.EMS_LM_Current_Approver__c = String.isNotBlank(leaveReqStatus.EMS_LM_2nd_Approver__c) ? leaveReqStatus.EMS_LM_2nd_Approver__r.LastName + ' ' +  leaveReqStatus.EMS_LM_2nd_Approver__r.FirstName : leaveReqStatus.EMS_LM_Approver__r.LastName + ' ' + leaveReqStatus.EMS_LM_Approver__r.FirstName;
                if(leaveReqStatus.EMS_LM_Status__c == LeaveRequestConstant.APPROVED ) {
                   leaveReqStatus.EMS_LM_Approved_On__c	 = System.today();
                }
            	updatedLeaveReqList.add(leaveReqStatus); 
            }
            //Approver 2
            else if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.EMS_LM_2nd_Approver__c && leaveReqStatus.EMS_LM_Status__c != LeaveRequestConstant.APPROVER_2_WAITING ) {
                System.debug('### APP 2');
                leaveReqStatus.EMS_LM_Status__c = String.isNotBlank(leaveReqStatus.Approver_3__c) ? LeaveRequestConstant.APPROVER_4_WAITING: LeaveRequestConstant.APPROVED;
                leaveReqStatus.Approver_2_Approved_Comments__c = comments;
                leaveReqStatus.EMS_LM_Current_Approver__c = String.isNotBlank(leaveReqStatus.Approver_3__c) ? leaveReqStatus.Approver_3__r.LastName + leaveReqStatus.Approver_3__r.FirstName : leaveReqStatus.EMS_LM_2nd_Approver__r.LastName + ' ' +  leaveReqStatus.EMS_LM_2nd_Approver__r.FirstName ;
                if(leaveReqStatus.EMS_LM_Status__c == LeaveRequestConstant.APPROVED ) {
                   leaveReqStatus.EMS_LM_Approved_On__c	 = System.today();
                }
                updatedLeaveReqList.add(leaveReqStatus); 
            }
            //Approver 3
            else if (LeaveRequestConstant.LOGGEDIN_USERID == leaveReqStatus.Approver_3__c) {
                System.debug('### APP 3');
                leaveReqStatus.EMS_LM_Status__c = LeaveRequestConstant.APPROVED;
                leaveReqStatus.Approver_3_Approved_Comments__c = comments;
                leaveReqStatus.EMS_LM_Current_Approver__c = String.isNotBlank(leaveReqStatus.Approver_3__c) ? leaveReqStatus.Approver_3__r.LastName + leaveReqStatus.Approver_3__r.FirstName : NUll;
                updatedLeaveReqList.add(leaveReqStatus); 
            }
        }
        System.debug('updatedLeaveReq Before Update' +updatedLeaveReqList);
        try{
           update updatedLeaveReqList;
           System.debug('updatedLeaveReq' +updatedLeaveReqList);
        }
            catch(Exception ex){
                //LogException.logHandledException(ex);
                System.debug('### Exception ' + ex.getMessage());
            }
    }
    
            /**
*   {Purpose} - Method used for bulk updation of leave request status to Approved, Approver 1 Pending, Approver 2 Pending.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled
    public static void bulkLeaveReqApproval(List<Id> bulkleaveReqId, String comments) {
        System.debug('### bulkleaveReqId ' + bulkleaveReqId);
        System.debug('### Comments ' + comments);
        List<EMS_LM_Leave_History__c> bulkupdatedLeaveReqList = new List<EMS_LM_Leave_History__c>();        
        for (EMS_LM_Leave_History__c bulkleaveReqApproval : [SELECT Id,
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
                                                                    Approver_3__r.FirstName,
                                                       	            EMS_LM_Approved_On__c
                                                             FROM EMS_LM_Leave_History__c
                                                             WHERE Id =:bulkleaveReqId]) {
           System.debug('### bulkleaveReqApproval');
          //Approver 1
            if (LeaveRequestConstant.LOGGEDIN_USERID == bulkleaveReqApproval.EMS_LM_Approver__c) {
            	bulkleaveReqApproval.EMS_LM_Status__c = String.isNotBlank(bulkleaveReqApproval.EMS_LM_2nd_Approver__c) ? LeaveRequestConstant.APPROVER_3_WAITING : LeaveRequestConstant.APPROVED;
            	bulkleaveReqApproval.Approver_1_Approved_Comments__c = comments;
                bulkleaveReqApproval.EMS_LM_Current_Approver__c = String.isNotBlank(bulkleaveReqApproval.EMS_LM_2nd_Approver__c) ? bulkleaveReqApproval.EMS_LM_2nd_Approver__r.LastName + ' ' +  bulkleaveReqApproval.EMS_LM_2nd_Approver__r.FirstName : bulkleaveReqApproval.EMS_LM_Approver__r.LastName + ' ' + bulkleaveReqApproval.EMS_LM_Approver__r.FirstName;
                if(bulkleaveReqApproval.EMS_LM_Status__c == LeaveRequestConstant.APPROVED ) {
                   bulkleaveReqApproval.EMS_LM_Approved_On__c	 = System.today();
                }               
            	bulkupdatedLeaveReqList.add(bulkleaveReqApproval); 
            }
            //Approver 2
            else if (LeaveRequestConstant.LOGGEDIN_USERID == bulkleaveReqApproval.EMS_LM_2nd_Approver__c && bulkleaveReqApproval.EMS_LM_Status__c != LeaveRequestConstant.APPROVER_2_WAITING) {
                bulkleaveReqApproval.EMS_LM_Status__c = String.isNotBlank(bulkleaveReqApproval.Approver_3__c) ? LeaveRequestConstant.APPROVER_4_WAITING: LeaveRequestConstant.APPROVED;
                bulkleaveReqApproval.Approver_2_Approved_Comments__c = comments;
                bulkleaveReqApproval.EMS_LM_Current_Approver__c = String.isNotBlank(bulkleaveReqApproval.Approver_3__c) ? bulkleaveReqApproval.Approver_3__r.LastName + bulkleaveReqApproval.Approver_3__r.FirstName : bulkleaveReqApproval.EMS_LM_2nd_Approver__r.LastName + ' ' +  bulkleaveReqApproval.EMS_LM_2nd_Approver__r.FirstName ;
                if(bulkleaveReqApproval.EMS_LM_Status__c == LeaveRequestConstant.APPROVED ) {
                   bulkleaveReqApproval.EMS_LM_Approved_On__c	 = System.today();
                }
                bulkupdatedLeaveReqList.add(bulkleaveReqApproval); 
            }
            //Approver 3
            else if (LeaveRequestConstant.LOGGEDIN_USERID == bulkleaveReqApproval.Approver_3__c) {
                bulkleaveReqApproval.EMS_LM_Status__c = LeaveRequestConstant.APPROVED ;
                bulkleaveReqApproval.Approver_3_Approved_Comments__c = comments;
                bulkleaveReqApproval.EMS_LM_Current_Approver__c = String.isNotBlank(bulkleaveReqApproval.Approver_3__c) ? bulkleaveReqApproval.Approver_3__r.LastName + bulkleaveReqApproval.Approver_3__r.FirstName : Null;
                bulkupdatedLeaveReqList.add(bulkleaveReqApproval); 
            }
        }
        System.debug('### bulkupdatedLeaveReqList Before Update' +bulkupdatedLeaveReqList);
        try{
           update bulkupdatedLeaveReqList;
           System.debug('### bulkupdatedLeaveReqList' +bulkupdatedLeaveReqList);
        }
            catch(Exception ex){
                //LogException.logHandledException(ex);
                System.debug('### Exception ' + ex.getMessage());
            }
       }
        
    }