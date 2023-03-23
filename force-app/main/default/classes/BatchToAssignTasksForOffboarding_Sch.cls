/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToAssignTasksForOffboarding
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToAssignTasksForOffboarding_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToAssignTasksForOffboarding_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToAssignTasksForOffboarding batchExecute = new BatchToAssignTasksForOffboarding(); 
      Database.executeBatch(batchExecute,10);
   }
}