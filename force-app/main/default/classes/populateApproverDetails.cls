/**
* @author Subba Kalavala
* @date 10/01/2023
* @description  populateApproverDetails Class to populat the approver details
*
*               Test code coverage provided by the following test class:
*               - populateApproverDetailsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class populateApproverDetails implements TriggerAction.BeforeInsert{
    /**
* @author Subba Kalavala
* @date 10/01/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'populateApproverDetails.beforeInsert() : BEGIN');
        populateApporverValuesOnLR(newList);
        System.debug(LoggingLevel.DEBUG, 'populateApproverDetails.beforeInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to populate the approver details on leave request after insert 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public static void populateApporverValuesOnLR(List<EMS_LM_Leave_History__c> newlist) {
        set<Id> contactIdSet = new set<Id>();
        Map<Id,Contact> resourceMap = new Map<Id,Contact>();
        for(EMS_LM_Leave_History__c newRec : newlist){
            contactIdSet.add(newRec.EMS_LM_Contact__c);
        }
        system.debug('====contactIdSet===='+contactIdSet);
        Map<Id,Id> resourceHiearchyMap = new Map<Id,Id>(); 
        for(contact conRec : [SELECT Id, LeaveApprover__c, LeaveApprover__r.LeaveApprover__c,LeaveApprover__r.LeaveApprover__r.LeaveApprover__c,Override_the_standard_level_of_approval__c, Level_of_Approval__c 
							  FROM Contact 
							  WHERE Id IN :contactIdSet
							 ]){
            System.debug('#### conRec '+ conRec);
            resourceHiearchyMap.put(conRec.Id,conRec.LeaveApprover__c); // Level 1
            contactIdSet.add(conRec.LeaveApprover__c);
            if(conRec.LeaveApprover__r.LeaveApprover__c != null){
                contactIdSet.add(conRec.LeaveApprover__r.LeaveApprover__c);
                resourceHiearchyMap.put(conRec.LeaveApprover__c,conRec.LeaveApprover__r.LeaveApprover__c); // Level 2   
            }
            if(conRec.LeaveApprover__r.LeaveApprover__r.LeaveApprover__c != null){
                contactIdSet.add(conRec.LeaveApprover__r.LeaveApprover__r.LeaveApprover__c);
                resourceHiearchyMap.put(conRec.LeaveApprover__r.LeaveApprover__c,conRec.LeaveApprover__r.LeaveApprover__r.LeaveApprover__c); // Level 3   
            }
        }
        
        
        if(!contactIdSet.isEmpty()){
            resourceMap = new Map<ID, Contact>([SELECT Id,Name,Override_the_standard_level_of_approval__c,Level_of_Approval__c,Resource_Role__c,Resource_Role__r.Name,Resource_Role__r.Level_of_Approval__c,Resource_Role__r.Auto_Approve__c,EMS_TM_User__c,EMS_TM_User__r.FirstName, EMS_TM_User__r.LastName,
                                                (SELECT Id,Resource_Reports_To__c,Resource_Reports_To_User__c FROM Resource_Resource_Relationships__r WHERE Resource_Reports_To_User__c != null AND Relationship_Type__c INCLUDES ('Leave Approver'))
                                                FROM Contact Where Id IN:contactIdSet]); 
        }
        system.debug('====resourceMap===='+resourceMap);
        for(EMS_LM_Leave_History__c newRec : newlist){
            System.debug('### newRec 1' +newRec);
            System.debug('### here 1');
            if(resourceMap.containsKey(newRec.EMS_LM_Contact__c) && newRec.EMS_LM_Leave_Type_Name__c != LeaveRequestConstant.WORK_FROM_HOME){
                System.debug('### here 2');
                contact conRes = resourceMap.get(newRec.EMS_LM_Contact__c);
                newRec.Level_of_Approval__c = conRes.Override_the_standard_level_of_approval__c ? conRes.Level_of_Approval__c : conRes.Resource_Role__r.Level_of_Approval__c;
                newRec.EMS_LM_Auto_Approve__c = conRes.Resource_Role__r.Auto_Approve__c;
                System.debug('### true ' +newRec.EMS_LM_Auto_Approve__c);
                System.debug('### newRec.Level_of_Approval__c '+ newRec.Level_of_Approval__c);
                system.debug('====conRes.Resource_Role__r.Level_of_Approval__c===='+conRes.Resource_Role__r.Level_of_Approval__c);
                system.debug('====cnewRec.Level_of_Approval__c===='+newRec.Level_of_Approval__c);
                system.debug('### newRec.EMS_LM_Auto_Approve__c ' + newRec.EMS_LM_Auto_Approve__c);
                System.debug('### conRes.Resource_Resource_Relationships__r.size()' + conRes.Resource_Resource_Relationships__r.size());
                if(newRec.Level_of_Approval__c > 0 && conRes.Resource_Resource_Relationships__r.size() > 0 && !newRec.EMS_LM_Auto_Approve__c){
                    System.debug('### 1');
                    String appManager1 = resourceHiearchyMap.containsKey(conRes.Id)? resourceHiearchyMap.get(conRes.Id) : null;
                    String appManager2 = null;
                    String appManager3 = null;
                    if(newRec.Level_of_Approval__c == 1){
                        newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                        newRec.EMS_LM_Status__c = LeaveRequestConstant.PENDING;
                        //newRec.EMS_LM_Current_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__r.LastName : null;
                        System.debug('### newRec ' +newRec);
                    }else if(newRec.Level_of_Approval__c == 2 && appManager1 != null){
                        appManager2 = resourceHiearchyMap.containsKey(appManager1)? resourceHiearchyMap.get(appManager1) : null;
                        newRec.EMS_LM_2nd_Approver__c = resourceMap.containsKey(appManager2) ? resourceMap.get(appManager2).EMS_TM_User__c : null;
                        newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                        newRec.EMS_LM_Status__c = LeaveRequestConstant.APPROVER_2_WAITING;
                        //newRec.EMS_LM_Current_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__r.FirstName : null;
                    }else if(newRec.Level_of_Approval__c == 3 && appManager2 != null){
                        appManager3 = resourceHiearchyMap.containsKey(appManager2)? resourceHiearchyMap.get(appManager2) : null; 
                        newRec.Approver_3__c = resourceMap.containsKey(appManager3) ? resourceMap.get(appManager3).EMS_TM_User__c : null;
                    }           
                }// Added by Pavan Regarding Auto Approve
                
                else if(newRec.EMS_LM_Auto_Approve__c) {
                    System.debug('### here 3' + newRec.EMS_LM_Auto_Approve__c);
                    User usr = [SELECT Id, FirstName, LastName FROM USER WHERE ID =:LeaveRequestConstant.LOGGEDIN_USERID];
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.AUTO_APPROVED;
                    newRec.EMS_LM_Auto_Approve__c = true;
                    newRec.EMS_LM_Approved_On__c = system.today();
                    newRec.EMS_LM_Current_Approver__c = usr.FirstName + usr.LastName;
                }
                // Added by Pavan Regarding WFH
            } else if (resourceMap.containsKey(newRec.EMS_LM_Contact__c) && newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME) {
                contact conRes = resourceMap.get(newRec.EMS_LM_Contact__c);
                newRec.Level_of_Approval__c = conRes.Override_the_standard_level_of_approval__c ? conRes.Level_of_Approval__c : conRes.Resource_Role__r.Level_of_Approval__c;
                System.debug('### newRec.Level_of_Approval__c ' + newRec.Level_of_Approval__c);
                String appManager1 = resourceHiearchyMap.containsKey(conRes.Id)? resourceHiearchyMap.get(conRes.Id) : null;
                String appManager2 = null;
                String appManager3 = null;
                if(newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c <= 3 && newRec.Level_of_Approval__c == 2){
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.PENDING;
                    newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                    //newRec.EMS_LM_Current_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__r.FirstName : null;                  
                }else if (newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c > 3 && newRec.Level_of_Approval__c == 2) {
                    appManager2 = resourceHiearchyMap.containsKey(appManager1)? resourceHiearchyMap.get(appManager1) : null;
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.APPROVER_2_WAITING;
                    newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                    newRec.EMS_LM_2nd_Approver__c = resourceMap.containsKey(appManager2) ? resourceMap.get(appManager2).EMS_TM_User__c : null; 
                    //newRec.EMS_LM_Current_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__r.FirstName : null;
                }else if (newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.Level_of_Approval__c == 1) {
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.PENDING;
                    newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null; 
                    //newRec.EMS_LM_Current_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__r.LastName : null;                  
                } else /*if (newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.Level_of_Approval__c == 0)*/ {
                    User usr = [SELECT Id, FirstName, LastName FROM USER WHERE ID =:LeaveRequestConstant.LOGGEDIN_USERID];
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.AUTO_APPROVED;
                    newRec.EMS_LM_Auto_Approve__c = true;
                    newRec.EMS_LM_Current_Approver__c = usr.FirstName + usr.LastName;
                    newRec.EMS_LM_Approved_On__c = system.today();
                }
            }
        }
    } 
}