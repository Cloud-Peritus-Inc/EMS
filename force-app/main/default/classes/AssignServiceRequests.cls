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
        //Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, Id> RRRMap = new Map<Id, Id>();
        //smaske : LMS_007 : 11/oct/2024 : not using contactMap and using Resource_Resource_Relationship__c for fetching Resource Manager
        /*for(contact con :[SELECT Id, ReportsToId,Resource_Manager__c,Resource_Manager__r.EMS_TM_User__c,ReportsTo.EMS_TM_User__c 
                          FROM Contact 
                          WHERE Id IN :contactIds 
                          ]){
            contactMap.put(con.Id,con);
        }*/
        
        for(Resource_Resource_Relationship__c RRR :[SELECT Id,Resource__c,Resource_Reports_To__c,Relationship_Type__c 
                          FROM Resource_Resource_Relationship__c 
                          WHERE Resource__c IN :contactIds AND Relationship_Type__c INCLUDES('Resource Manager')
                          ]){
            RRRMap.put(RRR.Resource__c,RRR.Resource_Reports_To__c);
        }
       system.debug('==contactMap===='+RRRMap);
        for (Case cnew : newlist) {
            Id ResourceManager = null;
             Id ReportingManager = null;
            if(RRRMap.containsKey(cnew.ContactId)){
               ResourceManager =  RRRMap.get(cnew.ContactId);
            }
            
            /*if(contactMap.containsKey(cnew.ContactId)){
               ReportingManager =  contactMap.get(cnew.ContactId);
            }*/
            
            if(cnew.Type != null){
                if(cnew.Type == 'Technical Issues' || cnew.Type == 'Others'){
                    if(queueMap.containsKey(Label.Default_Grid_Support_Request_Owner)){
                        cnew.Case_Assignee__c =  queueMap.get(Label.Default_Grid_Support_Request_Owner); 
                    } 
                }else if(cnew.Type == 'Change Of Details'){
                    SYstem.debug('QueueContact outside if'+queueMap.get(Label.Default_HR_Support_Request_Owner));
                    if(queueMap.containsKey(Label.Default_HR_Support_Request_Owner)){
                        SYstem.debug('QueueContact inside if'+queueMap.get(Label.Default_HR_Support_Request_Owner));
                        cnew.Case_Assignee__c =  queueMap.get(Label.Default_HR_Support_Request_Owner); 
                    } 
                }else if(cnew.Type == 'Resignation'){
                    cnew.Case_Assignee__c = ResourceManager != null ? ResourceManager : ReportingManager;
                }else if(cnew.Type == 'Special Leaves'){
                    //smaske : 24/Sep/2024 : Replacing Default_Grid_Support_Request_Owner with Default_HR_Support_Request_Owner as Bhuvana requested that she should recieve the email alert and assignment.
                    if(queueMap.containsKey(Label.Default_HR_Support_Request_Owner) && (cnew.Request_Sub_Type__c == 'Paternity' || cnew.Request_Sub_Type__c == 'Marriage' || cnew.Request_Sub_Type__c == 'Bereavement' || cnew.Request_Sub_Type__c == 'Compensatory Off')){
                        cnew.Case_Assignee__c = queueMap.get(Label.Default_HR_Support_Request_Owner);
                    }
                    else if(cnew.Request_Sub_Type__c == 'Maternity'){
                        cnew.Case_Assignee__c =  queueMap.get(Label.Default_HR_Support_Request_Owner);
                    }
                } 
            }
            system.debug('==cnew==='+cnew);
        }
        
        
    } 
}