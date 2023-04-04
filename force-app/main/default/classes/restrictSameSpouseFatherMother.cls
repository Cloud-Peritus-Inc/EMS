/**
* @author Mukesh Rawat
* @date 3/2/2023
* @description  restrictSameSpouseFatherMother Class to restrict the duplicate Spouse And Father And Mother
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
public without sharing class restrictSameSpouseFatherMother implements TriggerAction.BeforeInsert{
    /**
* @author Mukesh Rawat
* @date 3/2/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<Family_Information__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictSameSpouseFatherMother.beforeInsert() : BEGIN');
        restrictTheDuplicateRalationship(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictSameSpouseFatherMother.beforeInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to restrict the same date leaves 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void restrictTheDuplicateRalationship(List<Family_Information__c> newlist) {
        // Get the set of contact Ids for the records being inserted
        Set<Id> contactIds = new Set<Id>();
        for (Family_Information__c fi : newlist) {
            contactIds.add(fi.Resource__c);
        }
        System.debug('======resourcId========'+contactIds);
        
        // Query for existing Family Information records for the same contact with the same Relationships value
        Map<Id, Set<String>> existingRelationships = new Map<Id, Set<String>>();
        for (Family_Information__c fi : [SELECT Resource__c, Relationships__c FROM Family_Information__c WHERE Resource__c IN :contactIds AND Relationships__c IN ('Spouse', 'Father', 'Mother')]) {
            if (!existingRelationships.containsKey(fi.Resource__c)) {
                existingRelationships.put(fi.Resource__c, new Set<String>());
            }
            existingRelationships.get(fi.Resource__c).add(fi.Relationships__c);
        }
        System.debug('======existingRelationships========'+existingRelationships);
        
        // Check the Relationships values for the records being inserted and prevent duplicates     
        for (Family_Information__c fi : newlist) {
            if (fi.Relationships__c != null && (fi.Relationships__c == 'Spouse' || fi.Relationships__c == 'Father' || fi.Relationships__c == 'Mother')) {
                if (existingRelationships.containsKey(fi.Resource__c) && existingRelationships.get(fi.Resource__c).contains(fi.Relationships__c)) {
                    fi.addError('Family member already exists with the same relationship.');
                } 
            }
        }
    }
}