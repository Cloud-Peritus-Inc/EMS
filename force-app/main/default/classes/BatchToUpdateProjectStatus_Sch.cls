/**
* @author Shubham Maske
* @date 25/09/2023
* @description  BatchToUpdateProjectStatus_Sch schedular class for BatchToUpdateProjectStatus
*               Test code coverage provided by the following test class:
*               - BatchToUpdateProjectStatusTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateProjectStatus_Sch implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Instantiate the batch class
        BatchToUpdateProjectStatus batchClass = new BatchToUpdateProjectStatus();
        // Start the batch job
        Database.executeBatch(batchClass);
    }
}