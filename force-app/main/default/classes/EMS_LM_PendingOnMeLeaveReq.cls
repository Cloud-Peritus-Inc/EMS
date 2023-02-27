/**
* @author Pavan
* @date 01/02/2023
* @description  Getting the Leave Request data for my Request Tab based on the loggedIn user.
*            
*
*               Test code coverage provided by the following test class:
*               - LeaveHistoryApexControllerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

public class EMS_LM_PendingOnMeLeaveReq {
    
                /**
*   {Purpose} - This method returns a list of leave history records based on the search criteria for the my pending on me tab
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> getPendingLeaveHistory(String employeeName, String startDateStr, String endDateStr, List<String> statusValues, List<String> typeValues) {
    List<EMS_LM_Leave_History__c> leaveHistoryList = new List<EMS_LM_Leave_History__c>();
    
    String query = 'SELECT Id, EMS_LM_Leave_Type_Name__c, EMS_LM_Leave_Start_Date__c, EMS_LM_Current_Approver__c, EMS_LM_Leave_End_Date__c, EMS_LM_Leave_Duration__c, EMS_LM_Reason__c, EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Contact__R.Name, EMS_LM_Approver__c, EMS_LM_2nd_Approver__c FROM EMS_LM_Leave_History__c';
    String currentUserId = UserInfo.getUserId();
    //query += ' WHERE (EMS_LM_Approver__c = :currentUserId OR EMS_LM_2nd_Approver__c = :currentUserId)';
    
    if (startDateStr != null && startDateStr != '') {
        Date startDate = Date.valueOf(startDateStr.split(' ')[0]); 
        query += ' WHERE EMS_LM_Leave_Start_Date__c >= :startDate ';    
    }
    
    if (endDateStr != null && endDateStr != '') {
        Date endDate = Date.valueOf(endDateStr.split(' ')[0]);
        if (query.contains('WHERE')) {
          query += ' AND EMS_LM_Leave_End_Date__c <= :endDate ';  
        }else {
          query += ' WHERE EMS_LM_Leave_End_Date__c <= :endDate ';  
        }       
    } 
    
    if (employeeName != null && employeeName != '') {  
        String employeeNameWithWildcards = '%' + employeeName + '%';
        if (query.contains('WHERE')) {
            query += ' AND EMS_LM_Contact__R.Name LIKE :employeeNameWithWildcards';
        }else {
           	query += ' WHERE EMS_LM_Contact__R.Name LIKE :employeeNameWithWildcards'; 
        }
    }
    
    Set<String> allowedStatusValues = new Set<String>{'Pending', 'Approver 1 pending', 'Approver 2 Pending', 'Approved', 'Rejected', 'Cancelled', 'Auto Approved'};
    if (!allowedStatusValues.containsAll(statusValues)) {
        query = query;
        System.debug('### statusValues null' + statusValues);
    } else if (query.contains('WHERE')) {
        query += ' AND EMS_LM_Status__c IN :statusValues';
        System.debug('## here statusValues ' + query);
    }else {
       query += ' WHERE EMS_LM_Status__c IN :statusValues'; 
    }

    Set<String> allowedTypeValues = new Set<String>{'Annual Leave', 'Work from Home', 'Loss of Pay', 'Paternity Leave', 'Bereavement Leave', 'Maternity Leave', 'Compensatory Off'};
    if (!allowedTypeValues.containsAll(typeValues)) {
        query = query;
    } else if(query.contains('WHERE')) {
        query += ' AND EMS_LM_Leave_Type_Name__c IN :typeValues ';
        System.debug('## here typeValues ' + query);
    }else {
       query += ' WHERE EMS_LM_Leave_Type_Name__c IN :typeValues'; 
    }
        
    query += ' AND (EMS_LM_Approver__c = :currentUserId OR EMS_LM_2nd_Approver__c = :currentUserId)';
    query += ' ORDER BY CreatedDate DESC, EMS_LM_Leave_Type_Name__c ASC ';
    System.debug('### Final QUERY ' + query);
    try { 
        leaveHistoryList = Database.query(query);
    } catch (Exception e) {
        System.debug(e.getMessage());
    }    
    return leaveHistoryList;  
}
 
 /**
*   {Purpose} - Method used to show default pending or approver 1 pending records on Pending on me tab.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> pendingOnMeLeaveReq(){
        List<EMS_LM_Leave_History__c> mypendingReq = [SELECT Id,
                                                     	     EMS_LM_Leave_Type_Name__c,
                                                      		 EMS_LM_Leave_Start_Date__c,
                                                             EMS_LM_Current_Approver__c, 
            												 EMS_LM_Leave_End_Date__c,
                                                      		 EMS_LM_Leave_Duration__c,
                                                      		 EMS_LM_Reason__c,
                                                      		 EMS_LM_Status__c,
                                                      		 EMS_LM_Approved_On__c,
                                                      	     EMS_LM_Contact__r.Name,
                                                             EMS_LM_Approver__c,
                                                             EMS_LM_2nd_Approver__c
                                                       FROM EMS_LM_Leave_History__c
                                                       WHERE (EMS_LM_Approver__c =:LeaveRequestConstant.LOGGEDIN_USERID
                                                       OR EMS_LM_2nd_Approver__c =:LeaveRequestConstant.LOGGEDIN_USERID)
                                                       AND (EMS_LM_Status__c =: LeaveRequestConstant.PENDING 
                                                       OR  EMS_LM_Status__c =: LeaveRequestConstant.APPROVER_2_WAITING)
                                                       AND EMS_LM_Leave_Type_Name__c != NULL
                                                       ORDER BY EMS_LM_Leave_Type_Name__c ASC, CreatedDate DESC
                                                     		 ];
        return mypendingReq;
    }   

}