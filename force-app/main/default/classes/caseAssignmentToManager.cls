/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  caseAssignmentToManager Class to update the ownership of the case.
*
*               Test code coverage provided by the following test class:
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class caseAssignmentToManager implements TriggerAction.BeforeInsert {
    /**
* @author Subba Kalavala
* @date 2/22/2023
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<Case> newList) {      
        System.debug(LoggingLevel.DEBUG, 'caseAssignmentToManager.beforeInsert() : BEGIN');
        updateOwnership(newList);
        System.debug(LoggingLevel.DEBUG, 'caseAssignmentToManager.beforeInsert() : END');       
    }
       /**
*   {Purpose} - Method to assign the Owner 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void updateOwnership(List<Case> newlist) {
       Map<String,Contact> contactWithManager = new Map<String,contact>();
    
       set<Id> contactIds = new set<Id>();
       List<Case> filteredCase = new List<Case>();
        for(Case casenew : newlist){
            if(casenew.Type == 'Apply Resignation' || casenew.Type == 'Request for Special Leaves'){
              filteredCase.add(casenew);
              contactIds.add(casenew.ContactId);
            }
        }
        if(!filteredCase.isEmpty()){
            for(Contact con : [SELECT Id,Resource_Manager__c,Resource_Manager__r.EMS_TM_User__c,ReportsToId,ReportsTo.EMS_TM_User__c 
                               FROM Contact 
                               WHERE Id IN:contactIds
                                AND RecordTypeid =: contactConstant.RESOURCE_RECORDTYPEID]){
               contactWithManager.put(con.id,con); 
            }
            
            for(Case cnew : filteredCase){
                if(contactWithManager.containsKey(cnew.ContactId)){
                    Id ResourceManager = contactWithManager.get(cnew.ContactId).Resource_Manager__r.EMS_TM_User__c;
                    Id ReportingManager = contactWithManager.get(cnew.ContactId).ReportsTo.EMS_TM_User__c;
                    if(cnew.Request_Sub_Type__c == 'Offboarding' && (ReportingManager != null || ResourceManager != null)){
                        cnew.OwnerId = ResourceManager != null ? ResourceManager : ReportingManager;
                    }else if(ReportingManager != null && (cnew.Request_Sub_Type__c == 'Paternity' || cnew.Request_Sub_Type__c == 'Marriage' || cnew.Request_Sub_Type__c == '	Bereavement Leave' || cnew.Request_Sub_Type__c == 'Comp off')){
                        cnew.OwnerId = ReportingManager;
                    }
                }
            }
        }
    }
}