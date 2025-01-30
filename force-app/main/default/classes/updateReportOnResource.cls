/**
* @author Subba Kalavala
* @date 10/01/2023
* @description  updateReportOnResource Class to populat the Reports TO value on Contact
*
*               Test code coverage provided by the following test class:
*               - updateReportOnResourceTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class updateReportOnResource implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate {
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
    public void AfterInsert(List<Resource_Resource_Relationship__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'updateReportOnResource.AfterInsert() : BEGIN');
        populateTheReportsTo(newList);
        System.debug(LoggingLevel.DEBUG, 'updateReportOnResource.AfterInsert() : END');       
    }
    
    public void AfterUpdate(List<Resource_Resource_Relationship__c> newList, List<Resource_Resource_Relationship__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'updateReportOnResource.AfterUpdate() : BEGIN');
        populateTheReportsTo(newList);
        System.debug(LoggingLevel.DEBUG, 'updateReportOnResource.AfterUpdate() : END');       
    }
    
    
    /**
    *   {Purpose} - Method to populate the Reports to Value 
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    private void populateTheReportsTo(List<Resource_Resource_Relationship__c> newlist) {
        List<Contact> contactUpdate = new List<Contact>();
        
        for (Resource_Resource_Relationship__c newRec : newlist) {
            System.debug('RelationshipRecord :::' + newRec.Relationship_Type__c);
            
            if (newRec.Resource_Reports_To__c != null) {
                Contact contactToUpdate = new Contact(Id=newRec.Resource__c);
                
                // Check if 'Leave Approver' is in the multi-select picklist
                if (newRec.Relationship_Type__c.contains('Leave Approver')) {
                    contactToUpdate.LeaveApprover__c = newRec.Resource_Reports_To__c;
                }
                
                // Check if 'Resource Manager' is in the multi-select picklist
                if (newRec.Relationship_Type__c.contains('Resource Manager')) {
                    contactToUpdate.ReportsToId = newRec.Resource_Reports_To__c;
                }
                                
                // Add the updated contact to the list
                contactUpdate.add(contactToUpdate);
            }
        }
        
        try{
           TriggerBase.bypass('Contact');
           System.debug('contactUpdate :::' +  contactUpdate);
           // Perform the update
            if (!contactUpdate.isEmpty()) {
                update contactUpdate;
            }
            System.debug('contactUpdate :::' +  contactUpdate);
           TriggerBase.clearBypass('Contact');
        }catch(exception ex){
          LogException.logHandledException(ex, 'updateReportOnResource', 'populateTheReportsTo');  
        }
        
        
    }
}