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
        restrictAssCreationForClosedProjects(newList);
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
    private void restrictAssCreationForClosedProjects(List<EMS_LM_Leave_History__c> newlist) {
        set<Id> contactIdSet = new set<Id>();
        Map<Id,Contact> resourceMap = new Map<Id,Contact>();
        for(EMS_LM_Leave_History__c newRec : newlist){
                contactIdSet.add(newRec.EMS_LM_Contact__c);
           }
         system.debug('====contactIdSet===='+contactIdSet);
        Map<Id,Id> resourceHiearchyMap = new Map<Id,Id>(); 
        for(contact conRec : [SELECT Id,ReportsToId,ReportsTo.ReportsToId,ReportsTo.ReportsTo.ReportsToId FROM Contact WHERE Id IN:contactIdSet]){
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
           resourceMap = new Map<ID, Contact>([SELECT Id,Name,Resource_Role__c,Resource_Role__r.Name,Resource_Role__r.Level_of_Approval__c,EMS_TM_User__c, 
                                               (SELECT Id,Resource_Reports_To__c,Resource_Reports_To_User__c FROM Resource_Resource_Relationships__r WHERE Resource_Reports_To_User__c != null) 
                                               FROM Contact Where Id IN:contactIdSet]); 
        }
        system.debug('====resourceMap===='+resourceMap);
        for(EMS_LM_Leave_History__c newRec : newlist){
            if(resourceMap.containsKey(newRec.EMS_LM_Contact__c)){
               contact conRes = resourceMap.get(newRec.EMS_LM_Contact__c);
               newRec.Level_of_Approval__c = conRes.Resource_Role__r.Level_of_Approval__c; 
                system.debug('====conRes.Resource_Role__r.Level_of_Approval__c===='+conRes.Resource_Role__r.Level_of_Approval__c);
                system.debug('====cnewRec.Level_of_Approval__c===='+newRec.Level_of_Approval__c);
                if(newRec.Level_of_Approval__c > 0 && conRes.Resource_Resource_Relationships__r.size() > 0){
                    String appManager1 = resourceHiearchyMap.containsKey(conRes.Id)? resourceHiearchyMap.get(conRes.Id) : null;
                    String appManager2 = null;
                    String appManager3 = null;
                    if(newRec.Level_of_Approval__c == 1){
                      newRec.EMS_LM_Approver__c = resourceMap.containsKey(appManager1) ? resourceMap.get(appManager1).EMS_TM_User__c : null;
                    }else if(newRec.Level_of_Approval__c == 2 && appManager1 != null){
                      appManager2 = resourceHiearchyMap.containsKey(appManager1)? resourceHiearchyMap.get(appManager1) : null;
                      newRec.EMS_LM_2nd_Approver__c = resourceMap.containsKey(appManager2) ? resourceMap.get(appManager2).EMS_TM_User__c : null;
                    }else if(newRec.Level_of_Approval__c == 3 && appManager2 != null){
                      appManager3 = resourceHiearchyMap.containsKey(appManager2)? resourceHiearchyMap.get(appManager2) : null; 
                      newRec.Approver_3__c = resourceMap.containsKey(appManager3) ? resourceMap.get(appManager3).EMS_TM_User__c : null;
                    } 
                }
            }
        } 
    }
}