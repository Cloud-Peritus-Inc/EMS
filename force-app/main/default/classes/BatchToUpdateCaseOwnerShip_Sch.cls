/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  Schedule class to schedule BatchToUpdateCaseOwnerShip
*              
*       
*               Test code coverage provided by the following test class:
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateCaseOwnerShip_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToUpdateCaseOwnerShip batchExecute = new BatchToUpdateCaseOwnerShip(); 
      Database.executeBatch(batchExecute,10);
   }
}