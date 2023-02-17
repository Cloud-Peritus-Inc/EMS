/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToUpdateAccountOnAppContacts
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToUpdateAccountOnAppContacts_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateAccountOnAppContacts_SCH implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToUpdateAccountOnAppContacts batchExecute = new BatchToUpdateAccountOnAppContacts(); 
      Database.executeBatch(batchExecute,200);
   }
}