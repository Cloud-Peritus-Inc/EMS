/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToCreatePostOnboardingTasks
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToCreatePostOnboardingTasks_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreatePostOnboardingTasks_SCH implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCreatePostOnboardingTasks batchExecute = new BatchToCreatePostOnboardingTasks(); 
      Database.executeBatch(batchExecute,5);
   }
}