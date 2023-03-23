/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToCreateOnboardingTasksOnDOJ
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToCreateOnboardingTasksOnDOJ_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreateOffboardingRequest_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCreateOffboardingRequest batchExecute = new BatchToCreateOffboardingRequest(); 
      Database.executeBatch(batchExecute,10);
   }
}