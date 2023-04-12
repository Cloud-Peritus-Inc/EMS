/**
* @author Rohit Bhupati
* @date 10/02/2023
* @description  Schedule class to schedule  BatchToForwordLeaveBalanceToNextYear This batch Schedules on Jan1st Every Year to forword Leave Balance
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



global class BatchToForwordLeaveBalanceToNextYear_sch implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Create an instance of the batch class
        BatchToForwordLeaveBalanceToNextYear ForwordLeaves = new BatchToForwordLeaveBalanceToNextYear();
        // Execute the batch class
        Database.executeBatch(ForwordLeaves);
    }
    
}