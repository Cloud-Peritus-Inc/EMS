/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Schedule class to schedule BatchToNotifyTCForPM
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToNotifyTCForPM_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreateGoalsForRes_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCreateGoalsForRes batchExecute = new BatchToCreateGoalsForRes(); 
      Database.executeBatch(batchExecute,1);
   }
}