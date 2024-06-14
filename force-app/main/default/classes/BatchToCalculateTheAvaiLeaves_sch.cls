/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToCalculateTheAvailableLeaves
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToCalculateTheAvalLeavesTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCalculateTheAvaiLeaves_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCalculateTheAvailableLeaves batchExecute = new BatchToCalculateTheAvailableLeaves(); 
      Database.executeBatch(batchExecute,10);
   }
}