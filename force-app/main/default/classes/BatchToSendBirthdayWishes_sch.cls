/**
* @author Jaswanthi Maganti
* @date 20/03/2023
* @description  Schedule class to schedule BatchToSendBirthdayWishes  
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


global class BatchToSendBirthdayWishes_sch  implements Schedulable {
      
	global void execute(SchedulableContext sc) {
        
        // Create an instance of the batch class
        BatchToSendBirthdayWishes batchExecute = new BatchToSendBirthdayWishes(); 
        // Execute the batch class
      	Database.executeBatch(batchExecute,10);
   }
}