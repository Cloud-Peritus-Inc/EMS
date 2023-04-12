/**
* @author Rohit Bhupati
* @date 10/02/2023
* @description  Schedule class to schedule  BatchToAdd5LeavesEveryQuarter Its to add Leaves 1st of Every Month 
*              
*       
*            
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/



global class BatchToAdd5LeavesEveryQuarter_sch implements Schedulable{

    global void execute(SchedulableContext sc) {
        // Create an instance of the batch class
        BatchToAdd5LeavesEveryQuarter Add5Leaves = new BatchToAdd5LeavesEveryQuarter();
        // Execute the batch class
        Database.executeBatch(Add5Leaves);
    }
    
}