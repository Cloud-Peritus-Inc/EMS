/**
* @author Jaswanthi Maganti
* @date 20/03/2023
* @description  Schedule class to schedule BatchToSendWorkAnniversaryEmail  
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

	global class BatchToSendWorkAnniversaryEmail_sch implements Schedulable {
		global void execute(SchedulableContext sc) {
    
      	// Create an instance of the batch class
      BatchToSendWorkAnniversaryEmail batchExecute = new BatchToSendWorkAnniversaryEmail(); 
    	// Execute the batch class
      Database.executeBatch(batchExecute,10);
    
}
}