/**
* @author Sangharsh Kamble
* @date 17/03/2023
* @description  WorkfromHomepopulateApproverDetails Class to populat the approver details and change status when duration of work from home change
*
*               Test code coverage provided by the following test class:
*               - WorkfromHomepopulateApproverDetailsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class WorkfromHomepopulateApproverDetails implements TriggerAction.BeforeUpdate{
      /** 
* @author Sangharsh kamble
* @date 17/03/2023
* @description Before Update 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeUpdate(List<EMS_LM_Leave_History__c> newList , List<EMS_LM_Leave_History__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'populateApproverDetails.beforeUpdate() : BEGIN');
        WorkfromHomepopulateApporver(newList,new Map<Id,EMS_LM_Leave_History__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'populateApproverDetails.beforeUpdate() : END');       
    }
    /**
*   {Purpose} - Method to populate the status details on leave request after update 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
	
    public void WorkfromHomepopulateApporver(List<EMS_LM_Leave_History__c> newlist,Map<Id,EMS_LM_Leave_History__c> oldleaveMap) {
      //  Map<Id,List<EMS_LM_Leave_History__c>> oldleaveMap = new Map<Id,List<EMS_LM_Leave_History__c>>();
       //  Map<Id,EMS_LM_Leave_History__c> oldleaveMap = new Map<Id,EMS_LM_Leave_History__c>();
        set<Id> contactIdSet = new set<Id>();
        Map<Id,Contact> resourceMap = new Map<Id,Contact>();
        for(EMS_LM_Leave_History__c newRec : newlist){
            contactIdSet.add(newRec.EMS_LM_Contact__c);
        }
        system.debug('====contactIdSet===='+contactIdSet);
        Map<Id,Id> resourceHiearchyMap = new Map<Id,Id>(); 
        for(contact conRec : [SELECT Id,ReportsToId,ReportsTo.ReportsToId,ReportsTo.ReportsTo.ReportsToId,Override_the_standard_level_of_approval__c,Level_of_Approval__c FROM Contact WHERE Id IN:contactIdSet]){
            System.debug('#### conRec '+ conRec);
            resourceHiearchyMap.put(conRec.Id,conRec.ReportsToId); // Level 1
            contactIdSet.add(conRec.ReportsToId);
            if(conRec.ReportsTo.ReportsToId != null){
                contactIdSet.add(conRec.ReportsTo.ReportsToId);
                resourceHiearchyMap.put(conRec.ReportsToId,conRec.ReportsTo.ReportsToId); // Level 2   
            }
            if(conRec.ReportsTo.ReportsTo.ReportsToId != null){
                contactIdSet.add(conRec.ReportsTo.ReportsTo.ReportsToId);
                resourceHiearchyMap.put(conRec.ReportsTo.ReportsToId,conRec.ReportsTo.ReportsTo.ReportsToId); // Level 3   
            }
        }
        
        
        if(!contactIdSet.isEmpty()){
            resourceMap = new Map<ID, Contact>([SELECT Id,Name,Override_the_standard_level_of_approval__c,Level_of_Approval__c,Resource_Role__c,Resource_Role__r.Name,Resource_Role__r.Level_of_Approval__c,Resource_Role__r.Auto_Approve__c,EMS_TM_User__c,EMS_TM_User__r.FirstName, EMS_TM_User__r.LastName,
                                                (SELECT Id,Resource_Reports_To__c,Resource_Reports_To_User__c FROM Resource_Resource_Relationships__r WHERE Resource_Reports_To_User__c != null) 
                                                FROM Contact Where Id IN:contactIdSet]); 
        }
        system.debug('====resourceMap===='+resourceMap);
        for(EMS_LM_Leave_History__c newRec : newlist){
            System.debug('### newRec 1' +newRec);
            System.debug('### here 1');
             if (resourceMap.containsKey(newRec.EMS_LM_Contact__c) && newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c != oldleaveMap.get(newRec.Id).EMS_LM_Leave_Duration__c) {
                contact conRes = resourceMap.get(newRec.EMS_LM_Contact__c);
                newRec.Level_of_Approval__c = conRes.Override_the_standard_level_of_approval__c ? conRes.Level_of_Approval__c : conRes.Resource_Role__r.Level_of_Approval__c;
                System.debug('### newRec.Level_of_Approval__c ' + newRec.Level_of_Approval__c);
                String appManager1 = resourceHiearchyMap.containsKey(conRes.Id)? resourceHiearchyMap.get(conRes.Id) : null;
                String appManager2 = null;
                String appManager3 = null;
                if(newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c <= 3 && newRec.Level_of_Approval__c == 2){
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.PENDING;
                    newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                }else if (newRec.EMS_LM_Leave_Type_Name__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c > 3 && newRec.Level_of_Approval__c == 2) {
                    appManager2 = resourceHiearchyMap.containsKey(appManager1)? resourceHiearchyMap.get(appManager1) : null;
                    newRec.EMS_LM_Status__c = LeaveRequestConstant.APPROVER_2_WAITING;
                    newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                    newRec.EMS_LM_2nd_Approver__c = resourceMap.containsKey(appManager2) ? resourceMap.get(appManager2).EMS_TM_User__c : null; 
                } 
                } 
            }
        }
}