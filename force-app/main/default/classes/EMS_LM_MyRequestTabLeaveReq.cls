/**
* @author Pavan
* @date 01/02/2023
* @description  Getting the Leave Request data for my Request Tab based on the loggedIn user.
*            
*
*               Test code coverage provided by the following test class:
*               - EMS_LM_MyRequestTabLeaveReqTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

public without Sharing class EMS_LM_MyRequestTabLeaveReq {
    
	/**
*   {Purpose} - This method returns a list of leave history records based on the search criteria for the my request tab
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
public static List<EMS_LM_Leave_History__c> getLMHistory(String startDateStr, String endDateStr, List<String> statusValues, List<String> typeValues) {
    List<EMS_LM_Leave_History__c> leaveHistoryList = new List<EMS_LM_Leave_History__c>();
    String query = 'SELECT Id, EMS_LM_Leave_Type__r.Name, EMS_LM_Leave_Start_Date__c, EMS_LM_Current_Approver__c, ' + 
                   'EMS_LM_Leave_End_Date__c, EMS_LM_Leave_Duration__c, EMS_LM_Reason__c, EMS_LM_Status__c, EMS_LM_Approved_On__c, EMS_LM_Contact__R.Name ' + 
                   'FROM EMS_LM_Leave_History__c ';
    
    User currentUser = [SELECT Id, ContactId, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    String userContactId = currentUser.ContactId;
    
    if (userContactId == null) {
        Contact matchingContact = [SELECT Id FROM Contact WHERE Official_Mail__c = :currentUser.Email AND EMS_TM_User__c = :currentUser.Id LIMIT 1];
        if (matchingContact != null) {
            userContactId = matchingContact.Id;
        }
    }
    
    query += 'WHERE EMS_LM_Contact__c = :userContactId ';
    
    if (startDateStr != null && startDateStr != '') {
        Date startDate = Date.valueOf(startDateStr.split(' ')[0]); 
        query += 'AND EMS_LM_Leave_Start_Date__c >= :startDate ';    
    }
    
    if (endDateStr != null && endDateStr != '') {
        Date endDate = Date.valueOf(endDateStr.split(' ')[0]); 
        query += 'AND EMS_LM_Leave_End_Date__c <= :endDate ';
    } 
    Set<String> allowedStatusValues = new Set<String>{'Pending', 'Approver 1 Pending', 'Approver 2 Pending', 'Approved', 'Rejected', 'Cancelled', 'Auto Approved'};
    if (!allowedStatusValues.containsAll(statusValues)) {
        query = query;
        System.debug('### statusValues null' + statusValues);
    } else if (statusValues != null && statusValues.size() > 0) {
        query += ' AND EMS_LM_Status__c IN :statusValues';
        System.debug('## here statusValues ' + query);
    }else {
        System.debug(' hello nothing status');
    }

     Set<String> allowedTypeValues = new Set<String>{'Annual Leave', 'Work From Home', 'Loss of Pay', 'Paternity Leave', 'Bereavement Leave', 'Maternity Leave', 'Compensatory Off'};
    if (!allowedTypeValues.containsAll(typeValues) ) {
        System.debug('### hereer');
        query = query;
        System.debug('### typeValues null'+ typeValues);
    }else if (typeValues != null && typeValues.size() > 0){
        system.debug('heree');
        query += ' AND EMS_LM_Leave_Type_Name__c IN :typeValues ';
        System.debug('## here typeValues ' + query);
    }else {
        System.debug('### hello nothing types');
    }

    System.debug('## TypeValues: ' + typeValues);

    query = query + ' ORDER BY CreatedDate DESC, EMS_LM_Leave_Type_Name__c ASC';    
    	system.debug('Final query: ' + query);
    	System.debug('### StartDate: ' + startDateStr);
    	System.debug('### EndDate: ' + endDateStr);
    	System.debug('### StatusValues: ' + statusValues);
    	System.debug('## TypeValues: ' + typeValues);
        try { 
        leaveHistoryList = Database.query(query);
        system.debug('Leave history list size: ' + leaveHistoryList);
            }
        catch(Exception e){
            system.debug(e.getMessage());
        }    
        return leaveHistoryList;  
    }  
                /**
*   {Purpose} - Method used to show default pending or approver 1 pending records on My Request tab.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
	
	NOTE: NO NEED TEST CLASS NOT USING THIS METHOD IN CURRENT SCOPE(Enhancement)
**/
    
  /*  @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> defaultMyRequestData(){
        user usr =[Select Id, ContactId, Email from user where Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        List<EMS_LM_Leave_History__c> myLeaveReq = [SELECT Id,
                                                    	   EMS_LM_Leave_Type_Name__c,
                                                    	   EMS_LM_Leave_Start_Date__c,
                                                    	   EMS_LM_Current_Approver__c, 
                                                    	   EMS_LM_Leave_End_Date__c,
                                                    	   EMS_LM_Leave_Duration__c,
                                                    	   EMS_LM_Reason__c,
                                                    	   EMS_LM_Status__c,
                                                           EMS_LM_Approved_On__c,
                                                    	   EMS_LM_Contact__c,
                                                    	   EMS_LM_Auto_Approve__c,
                                                    	   CreatedDate,
                                                    	   CreatedById
                                                    FROM EMS_LM_Leave_History__c
                                                    WHERE EMS_LM_Contact__c =:usr.ContactId
                                                    AND (EMS_LM_Status__c =: LeaveRequestConstant.PENDING 
                                                    OR  EMS_LM_Status__c =: LeaveRequestConstant.APPROVER_2_WAITING
                                                    OR EMS_LM_Status__c =: LeaveRequestConstant.AUTO_APPROVED)
                                                    ORDER BY CreatedDate DESC, EMS_LM_Leave_Type_Name__c ASC
                                                    ];
        return myLeaveReq;
    }*/
}