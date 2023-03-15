/**
* @author Pavan
* @date 10/01/2023
* @description  Getting the latest 5 Leave Request data based on the loggedIn user.
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
public Without Sharing class LeaveManagementApexController {
    /**
*   {Purpose} - Method used to display latest 5 leave request data based on the loggedIn User.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> getLeaveRequest(){
        User usrConId = [SELECT Id, ContactId__c,Hr_Access__c FROM User WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        List<EMS_LM_Leave_History__c> leaveReqList = [SELECT Id,
                                                            EMS_LM_Contact__c,
                                                            EMS_LM_Leave_Start_Date__c,
                                                            EMS_LM_Leave_End_Date__c,
                                                            CreatedDate,
                                                            EMS_LM_Status__c
                                                      FROM EMS_LM_Leave_History__c
                                                      WHERE EMS_LM_Contact__c =:usrConId.ContactId__c
                                                      ORDER BY CreatedDate DESC  LIMIT 5];
        return leaveReqList;
    }

/**
*   {Purpose} - Method used to display ALL leave request data to HR.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> getLeaveRequestHr(){
        List<EMS_LM_Leave_History__c> leaveReqListHr = [SELECT Id,
                                                                EMS_LM_Contact__c,
                                                                EMS_LM_Leave_Start_Date__c,
                                                                EMS_LM_Leave_End_Date__c,
                                                                CreatedDate,
                                                                EMS_LM_Status__c
                                                      FROM EMS_LM_Leave_History__c
                                                      ORDER BY CreatedDate ];
        return leaveReqListHr;
    }
    /**
*   {Purpose} - Method used to display current leave balance based upon loggedIn user.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable = true)
    public static Contact leaveBanlance(){
        User usrConId = [SELECT Id, ContactId FROM User WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        List<Contact> empLeaveBalance = [SELECT Id,
                                          EMS_LM_No_Of_Availble_Leaves__c
                                   FROM Contact
                                   WHERE Id =:usrConId.ContactId LIMIT 1 ];
        return empLeaveBalance.isEmpty() ? null : empLeaveBalance[0];
    }
    
    /**
*   {Purpose} - Method used to handle the cancle leave request data based on the loggedIn user.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled
    public static void cancleLeaveRequest(String leaveReqCancelId) {
        System.debug('### leaveReqCancelId ' + leaveReqCancelId);
        List<EMS_LM_Leave_History__c> updateCancelLeaveReqList = new List<EMS_LM_Leave_History__c>();
        for(EMS_LM_Leave_History__c leaveReqcancle : [SELECT Id,
                                                             EMS_LM_Status__c
                                                      FROM EMS_LM_Leave_History__c
                                                      WHERE Id =:leaveReqCancelId
                                                   ]) {
                                                   		leaveReqcancle.EMS_LM_Status__c = LeaveRequestConstant.CANCELLED;
                                                        updateCancelLeaveReqList.add(leaveReqcancle);
                                                   } 
        
        System.debug('### Before updateCancelLeaveReqList  '+ updateCancelLeaveReqList);
        update updateCancelLeaveReqList;
        System.debug('### updateCancelLeaveReqList  '+ updateCancelLeaveReqList);
    }
}