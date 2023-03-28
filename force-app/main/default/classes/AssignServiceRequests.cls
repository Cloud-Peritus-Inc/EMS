/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  AssignServiceRequests Class to assign case owners
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
public without sharing class AssignServiceRequests  implements TriggerAction.BeforeInsert{
    
    /**
* @author Subba Kalavala
* @date 2/22/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<Case> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : BEGIN');
        assignTheOwnerToQueue(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to assign the service request
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void assignTheOwnerToQueue(List<Case> newlist) {
        Map<String,Id> queueMap = new Map<String,Id>();
        Set<String> defalutOwners = new Set<String>();
        Set<Id> contactIds = new Set<Id>();
        defalutOwners.add(Label.Default_Grid_Support_Request_Owner);
        defalutOwners.add(Label.Default_HR_Support_Request_Owner);
        for (Case cnew : newlist) {
            contactIds.add(cnew.contactId);
        }

        for(User grp : [SELECT Id,Name,contactId,Email FROM User WHERE Email IN : defalutOwners and contactId != null]){
            queueMap.put(grp.Email,grp.contactId);
        }
        System.debug('**queueMap'+queueMap);
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        for(contact con :[SELECT Id, ReportsToId,Resource_Manager__c,Resource_Manager__r.EMS_TM_User__c,ReportsTo.EMS_TM_User__c 
                          FROM Contact 
                          WHERE Id IN :contactIds 
                          ]){
            contactMap.put(con.Id,con);
        }
       system.debug('==contactMap===='+contactMap);
        for (Case cnew : newlist) {
            Id ResourceManager = null;
             Id ReportingManager = null;
            if(contactMap.containsKey(cnew.ContactId)){
               ResourceManager =  contactMap.get(cnew.ContactId).Resource_Manager__c;
            }
            if(contactMap.containsKey(cnew.ContactId)){
               ReportingManager =  contactMap.get(cnew.ContactId).ReportsToId;
            }
            
            if(cnew.Type != null){
                if(cnew.Type == 'Problem' || cnew.Type == 'Others'){
                    if(queueMap.containsKey(Label.Default_Grid_Support_Request_Owner)){
                        cnew.Case_Assignee__c =  queueMap.get(Label.Default_Grid_Support_Request_Owner); 
                    } 
                }else if(cnew.Type == 'Change Of Details'){
                    SYstem.debug('QueueContact'+queueMap.get(Label.Default_HR_Support_Request_Owner));
                    if(queueMap.containsKey(Label.Default_HR_Support_Request_Owner)){
                        cnew.Case_Assignee__c =  queueMap.get(Label.Default_HR_Support_Request_Owner); 
                    } 
                }else if(cnew.Type == 'Resignation'){
                    cnew.Case_Assignee__c = ResourceManager != null ? ResourceManager : ReportingManager;
                }else if(cnew.Type == 'Special Leaves'){
                    if(ReportingManager != null && (cnew.Request_Sub_Type__c == 'Paternity' || cnew.Request_Sub_Type__c == 'Marriage' || cnew.Request_Sub_Type__c == '	Bereavement Leave' || cnew.Request_Sub_Type__c == 'Comp off')){
                        cnew.Case_Assignee__c = ReportingManager;
                    }
                } 
            }
            system.debug('==cnew==='+cnew);
        }
        
        
    } 
}