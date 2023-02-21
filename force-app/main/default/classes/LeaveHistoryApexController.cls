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

public without Sharing class LeaveHistoryApexController {
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> getLMHistory(String stdate, String eddate, List<String> statusValues, List<String> typeValues){
        List<EMS_LM_Leave_History__c> lh = new List<EMS_LM_Leave_History__c>();
        String query = 'Select Id, EMS_LM_Leave_Type_Name__c,EMS_LM_Leave_Start_Date__c,EMS_LM_Current_Approver__c,' + 
            'EMS_LM_Leave_End_Date__c,EMS_LM_Leave_Duration__c,EMS_LM_Reason__c,EMS_LM_Status__c,EMS_LM_Approved_On__c,EMS_LM_Contact__R.Name From EMS_LM_Leave_History__c ';
        String userId = UserInfo.getUserId();
        user u =[Select id, ContactId, Email from user where id = :userId];
        string cid = '';
        if(u.ContactId != null){
            cid = u.ContactId;
            query = query + ' where EMS_LM_Contact__c = :cid ';
        }
        if(u.ContactId == null){
            Contact c = [select Id from Contact where Official_Mail__c=:u.Email AND EMS_TM_User__c = :userId Limit 1];
            cid = c.Id;
            query = query + ' where EMS_LM_Contact__c = :cid ';    
        }
        if(stdate !='' && stdate != null){
            Date d = date.valueOf(stdate);
            query = query + ' AND EMS_LM_Leave_Start_Date__c >= :d';    
        }
        if(eddate !='' && eddate != null){
            Date d1 = date.valueOf(eddate);
            query = query + ' AND EMS_LM_Leave_End_Date__c <= :d1';
        } 
        if(statusValues.size() > 0){
            query = query + ' AND EMS_LM_Status__c IN :statusValues';
        } 
        if(typeValues.size() > 0){
            query = query + ' AND EMS_LM_Leave_Type_Name__c IN :typeValues';
        }
        system.debug(query);  
        query = query + ' ORDER BY CreatedDate DESC Limit 5'; 
        try{ 
            lh = Database.query(query);
            system.debug('### leave History ' + lh);
        }
        catch(Exception e){
            system.debug(e.getMessage());
        }    
        return lh;  
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
    @AuraEnabled(Cacheable=true)
    public static List<EMS_LM_Leave_History__c> getPendingLeaveHistory(String name,String stdate, String eddate, List<String> statusValues, List<String> typeValues){
        List<EMS_LM_Leave_History__c> lh = new List<EMS_LM_Leave_History__c>();
        String query = 'Select Id, EMS_LM_Leave_Type_Name__c,EMS_LM_Leave_Start_Date__c,EMS_LM_Current_Approver__c,' + 
            'EMS_LM_Leave_End_Date__c,EMS_LM_Leave_Duration__c,EMS_LM_Reason__c,EMS_LM_Status__c,EMS_LM_Approved_On__c,EMS_LM_Contact__R.Name From EMS_LM_Leave_History__c ';
        //String userId = UserInfo.getUserId();
        user usr =[Select id, ContactId, Email from user where id = :LeaveRequestConstant.LOGGEDIN_USERID];
        string cid = '';
        if(usr.Id != null){
            cid = usr.Id;
            query = query + ' where (EMS_LM_Approver__c = :cid OR EMS_LM_2nd_Approver__c = :cid) ';
        }
        system.debug(query); 
        if(stdate !='' && stdate != null) {
            Date d = date.valueOf(stdate);
            query = query + ' AND EMS_LM_Leave_Start_Date__c >= :d';    
        }
        system.debug(query); 
        if(eddate !='' && eddate != null) {
            Date d1 = date.valueOf(eddate);
            query = query + ' AND EMS_LM_Leave_End_Date__c <= :d1';
        } 
        system.debug(query); 
        if(statusValues.size() > 0) {
            query = query + ' AND EMS_LM_Status__c IN :statusValues';
        } 
        system.debug(query); 
        if(name !='' && name != null) {  
            String name1 = '%'+name+'%';
            system.debug(name1);
            query = query + ' AND EMS_LM_Contact__R.Name Like \'%' + name + '%\'';
        }
        if(typeValues.size() > 0) {
            query = query + ' AND EMS_LM_Leave_Type_Name__c IN :typeValues';
        }
        system.debug(query);  
        //query = query + ' ORDER BY CreatedDate DESC Limit 5';
        
        system.debug(query);      
        try{ 
            lh = Database.query(query);
            system.debug(lh);
        }
        catch(Exception e) {
            system.debug(e.getMessage());
        }    
        return lh;  
    }
    
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
                                                         EMS_LM_Select_Leave_Type__c 
                                                         FROM EMS_LM_Leave_Credit__c 
                                                         WHERE EMS_LM_Employee__c = :user.ContactId 
                                                         ORDER BY EMS_LM_Select_Leave_Type__c ASC]) {
                                                             uniqueLeaveTypes.add(credit.EMS_LM_Select_Leave_Type__c);
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
                                                         EMS_LM_Select_Leave_Type__c 
                                                         FROM EMS_LM_Leave_Credit__c 
                                                         WHERE EMS_LM_Employee__c = :contact.Id 
                                                         ORDER BY EMS_LM_Select_Leave_Type__c ASC]) {
                                                             uniqueLeaveTypes.add(credit.EMS_LM_Select_Leave_Type__c);
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
*   {Purpose} - Method used to show default pending or approver 1 pending records on My Request tab.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    
    @AuraEnabled(Cacheable=true)
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
                                                    ORDER BY CreatedDate DESC Limit 5
                                                    ];
        return myLeaveReq;
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
                                                      	     EMS_LM_Contact__r.Name
                                                       FROM EMS_LM_Leave_History__c
                                                       WHERE (EMS_LM_Approver__c =:LeaveRequestConstant.LOGGEDIN_USERID
                                                       OR EMS_LM_2nd_Approver__c =:LeaveRequestConstant.LOGGEDIN_USERID)
                                                       AND (EMS_LM_Status__c =: LeaveRequestConstant.PENDING 
                                                       OR  EMS_LM_Status__c =: LeaveRequestConstant.APPROVER_2_WAITING)
                                                       ORDER BY CreatedDate DESC Limit 5
                                                     		 ];
        return mypendingReq;
    }
    
    
}