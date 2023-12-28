/**
 * Description: This Apex class represents a controller for Fetching/Updating Goal__c objects of PULSE record type.
 * Author: Shubham Maske
 * Created Date: November 6, 2023
 * Version: 1.0
 * 
 * Change Log:
 * - Version 1.0 (November 6, 2023): Initial implementation.
 */

public without sharing class pulseKraRecordFromController {
    public pulseKraRecordFromController() {

    }

    /**
     * Description: Fetch a Goal__c record by its ID.
     * 
     * @param recordId The ID of the Goal__c record to retrieve.
     * @return A Goal__c record matching the provided ID, or null if not found.
     * 
     * @throws AuraHandledException if an error occurs during the query execution.
     */

    @AuraEnabled(cacheable=true)
    public static Goal__c fetchPulseRecord(Id recordId){
        Goal__c pulseRecord = new Goal__c();
        try {
            if(recordId != null){
                pulseRecord = [Select Id,Name,Status__c,Resource__r.Name from Goal__c WHERE Id =: recordId]; 
            }else {
                return null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return pulseRecord;
    }

    /**
     * Description: Update a Goal__c record.
     * 
     * @param pulseRecord The Goal__c record to be updated.
     * @return The updated Goal__c record.
     * 
     * @throws AuraHandledException if an error occurs during the update operation.
     */
    @AuraEnabled
    public static Goal__c updatePulseRecord(Goal__c pulseRecord){
        try {
            Update pulseRecord;
            return pulseRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}