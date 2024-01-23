/**
* @author Shubham Maske
* @date 25/09/2023
* @description  BatchToUpdateProjectStatus Batch to update the Project Status based on End Date
				If project endate is less than today and its status is still in "Active" or "Ongoing",
				should the project Status be changes to "Closed" automatically once the end date is less than todays date.
*              
*               Schedule class 
*               - BatchToUpdateProjectStatus_Sch
*               Test code coverage provided by the following test class:
*               - BatchToUpdateProjectStatusTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateProjectStatus implements Database.Batchable<sObject> {
	
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query for projects that meet the criteria
        String query = 'SELECT Id, EMS_TM_EndDate__c, EMS_TM_Status__c,Project_Manager__c,Offshore_Project_Manager__c FROM EMS_TM_Project__c WHERE EMS_TM_EndDate__c < TODAY AND EMS_TM_Status__c = \'Ongoing\' AND Project_Manager__r.Id != NULL AND Offshore_Project_Manager__r.Id != NULL'  ;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<EMS_TM_Project__c> scope) {
        List<EMS_TM_Project__c> projectsToUpdate = new List<EMS_TM_Project__c>();

        // Iterate through the records and update the fields
        for (EMS_TM_Project__c project : scope) {
            project.EMS_TM_Status__c = 'Completed';
            project.EMS_TM_EndDate__c = Date.today();
            projectsToUpdate.add(project);
        }

        // Update the records with error handling
        try {
            if (!projectsToUpdate.isEmpty()) {
                update projectsToUpdate;
            }
        } Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToUpdateProjectStatus', 'execute');        
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        // Your finish logic, if any, goes here
    }
    
    
}