/**
* @author Pavan
* @date 01/02/2023
* @description  Getting the Leave Request data for my Request Tab and Pending on Me Tab based on the loggedIn user.
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

	/**
*   {Purpose} - This method returns a list of leave history records based on the search criteria for the my request tab
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
public without Sharing class LeaveHistoryApexController {
                /**
*   {Purpose} - Method used to get Leave Types based on the LoggedIn user.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static List<String> getLeaveTypesForUser(Id userId) {
        System.debug('### userId' + userId);
        List<String> leaveTypes = new List<String>();
        if(userId != null) {
            User user = [SELECT Id,
                         ContactId, 
                         Email 
                         FROM User 
                         WHERE Id = :userId];
            try {
                if(user.ContactId != null) {
                    Set<String> uniqueLeaveTypes = new Set<String>();
                    for(EMS_LM_Leave_Credit__c credit : [SELECT Id,
                                                         	    EMS_LM_Leave_Type__c,
                                                                Leave_Type_Name__c
                                                         FROM EMS_LM_Leave_Credit__c 
                                                         WHERE EMS_LM_Employee__c = :user.ContactId 
                                                         ORDER BY Leave_Type_Name__c ASC]) {
                                                             uniqueLeaveTypes.add(credit.Leave_Type_Name__c);
                                                         }
                    for(String leaveType : uniqueLeaveTypes) {
                        leaveTypes.add(leaveType);
                    }
                    System.debug('### leaveTypes ' + leaveTypes);
                }
                else {
                    Set<String> uniqueLeaveTypes = new Set<String>();
                    Contact contact = [SELECT Id 
                                       FROM Contact 
                                       WHERE Official_Mail__c = :user.Email 
                                       AND EMS_TM_User__c = :userId];
                    
                    for(EMS_LM_Leave_Credit__c credit : [SELECT Id,
                                                         		EMS_LM_Leave_Type__c,
                                                         		Leave_Type_Name__c 
                                                         FROM EMS_LM_Leave_Credit__c 
                                                         WHERE EMS_LM_Employee__c = :contact.Id 
                                                         ORDER BY Leave_Type_Name__c ASC]) {
                                                             uniqueLeaveTypes.add(credit.Leave_Type_Name__c);
                                                         }
                    for(String leaveType : uniqueLeaveTypes) {
                        leaveTypes.add(leaveType);
                    }
                }
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
        }
        return leaveTypes;
    }
    
                /**
*   {Purpose} - Method used to get the Level of approval and Auto-Approval data to show the leave status based on the level of approval.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static IntBolleanWrapper userLevelOfApproval(){
        IntBolleanWrapper returnValues = new IntBolleanWrapper();
        Contact con = [SELECT Id, 
                              Resource_Role__c, 
                              Resource_Role__r.Level_of_Approval__c, 
                              Resource_Role__r.Auto_Approve__c, 
                              EMS_TM_User__c 
                       FROM Contact 
                       WHERE EMS_TM_User__c =: LeaveRequestConstant.LOGGEDIN_USERID];
        System.debug('### con '  + con);
        System.debug('### con '  + con.Resource_Role__r.Level_of_Approval__c);
        System.debug('### con '  + con.Resource_Role__r.Auto_Approve__c);
        returnValues.levelOfApproval = con.Resource_Role__r.Level_of_Approval__c;
        returnValues.autoApproval = con.Resource_Role__r.Auto_Approve__c;
        System.debug('### returnValues ' + returnValues);
        return returnValues;        
    }
    
    public class IntBolleanWrapper {
        @AuraEnabled
        Public  Decimal levelOfApproval {get; set;}
        @AuraEnabled
        public  Boolean autoApproval {get; set;}
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
    public static Integer getLoggedInUserResReportsSize () {
        User usr = [SELECT Id, 
						   contactId__c
                    FROM User
                    WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        
        List <Resource_Resource_Relationship__c> rrrList = [ SELECT Id, 
            														Resource__c, 
            														Resource_Reports_To__c,
            														Resource_Reports_To_User__c, 
            														Reports_To_Role__c
            												 FROM Resource_Resource_Relationship__c 
                                                             WHERE Resource_Reports_To_User__c != null 
                                                             AND  Resource_Reports_To__c =: usr.ContactId__c 
                                             				];
        Integer intList = rrrList.size();        
		return intList;
        }
}