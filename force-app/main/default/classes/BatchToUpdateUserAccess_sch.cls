/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Schedule class to schedule BatchToUpdateUserAccess
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToUpdateUserAccess_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateUserAccess_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToUpdateUserAccess batchExecute = new BatchToUpdateUserAccess(); 
      Database.executeBatch(batchExecute,10);
   }
}