/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToNotifyPendingApps
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToNotifyPendingApps_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToNotifyPendingApps_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToNotifyPendingApps batchExecute = new BatchToNotifyPendingApps(); 
      Database.executeBatch(batchExecute,10);
   }
}