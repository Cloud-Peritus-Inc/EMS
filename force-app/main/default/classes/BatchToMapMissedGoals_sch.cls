/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Schedule class to schedule BatchToMapMissedGoals
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToMapMissedGoals_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToMapMissedGoals_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToMapMissedGoals batchExecute = new BatchToMapMissedGoals(); 
      Database.executeBatch(batchExecute,100);
   }
}