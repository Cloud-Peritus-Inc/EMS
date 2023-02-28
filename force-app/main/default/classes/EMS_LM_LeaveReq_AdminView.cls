/**
* @author Pavan
* @date 01/02/2023
* @description  Getting the Leave Request data for my Admin View Tab based if the loggedIn user is HR.
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
public class EMS_LM_LeaveReq_AdminView {
    
                /**
*   {Purpose} - This method returns a list of leave history records based on the search criteria for the admin view tab
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> getAdminLeaveHistory(
    String employeeName, 
    String startDate, 
    String endDate, 
    List<String> typeValues, 
    List<String> statusValues
) {
    List<EMS_LM_Leave_History__c> leaveHistories = new List<EMS_LM_Leave_History__c>();
    
    String query = 'SELECT Id, EMS_LM_Leave_Type_Name__c, EMS_LM_Leave_Start_Date__c, EMS_LM_Final_Approver__c, ' + 
        'EMS_LM_Leave_End_Date__c, EMS_LM_Leave_Duration__c, EMS_LM_Reason__c, EMS_LM_Status__c, EMS_LM_Approved_On__c, ' +
        'EMS_LM_Contact__R.Name, EMS_LM_Current_Approver__c FROM EMS_LM_Leave_History__c WHERE CreatedDate != NULL ';
    
    if (startDate != '' && startDate != null) {
        Date startDateValue = Date.valueOf(startDate);
        query = query + ' AND EMS_LM_Leave_Start_Date__c >= :startDateValue';    
    }
    
    if (endDate != '' && endDate != null) {
        Date endDateValue = Date.valueOf(endDate);
        query = query + ' AND EMS_LM_Leave_End_Date__c <= :endDateValue';            
    }
    
    if (employeeName != null && employeeName != '') {  
        String employeeNameWithWildcards = '%' + employeeName + '%';
        query += ' AND EMS_LM_Contact__R.Name LIKE :employeeNameWithWildcards';
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
        
    query = query + ' ORDER BY CreatedDate DESC, EMS_LM_Leave_Type_Name__c ASC ';
    	System.debug('### Final QUERY ' +query );
    	System.debug('### StartDate: ' + startDate);
    	System.debug('### EndDate: ' + endDate);
    	System.debug('### StatusValues: ' + statusValues);
    	System.debug('## TypeValues: ' + typeValues);
      try{ 
         leaveHistories = Database.query(query);
         system.debug(leaveHistories);
      }
      catch(Exception e){
         system.debug(e.getMessage());
      }    
      return leaveHistories;
	}

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
    public static List<EMS_LM_Leave_History__c> defaultAdminViewData () {
        List<EMS_LM_Leave_History__c> adminViewData = [Select Id, 
                                                       		  EMS_LM_Leave_Type_Name__c,
                                                              EMS_LM_Leave_Start_Date__c,
                                                              EMS_LM_Final_Approver__c, 
      														  EMS_LM_Leave_End_Date__c,
                                                       		  EMS_LM_Leave_Duration__c,
                                                              EMS_LM_Reason__c,EMS_LM_Status__c,
                                                              EMS_LM_Approved_On__c,
                                                              EMS_LM_Contact__R.Name 
                                                       From EMS_LM_Leave_History__c
                                                       WHERE (EMS_LM_Status__c =: LeaveRequestConstant.PENDING
                                                       OR EMS_LM_Status__c =: LeaveRequestConstant.APPROVER_2_WAITING)
                                                       ORDER BY CreatedDate DESC, EMS_LM_Leave_Type_Name__c ASC
                                                       ];
        System.debug('### adminViewData ' + adminViewData);
        return adminViewData;
    }
}