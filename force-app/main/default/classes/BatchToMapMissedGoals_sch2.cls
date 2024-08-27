/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  Schedule class to schedule BatchToMapMissedGoals
*              
*       
*               Test code coverage provided by the following test class:
*               - BatchToMapMissedGoals_Test
Sngharsh : this schedule class is for Contacts with NON-INDIA location
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToMapMissedGoals_sch2 implements Schedulable{
global void execute(SchedulableContext sc) {
      BatchToMapMissedGoals2 batchExecute = new BatchToMapMissedGoals2(); 
      Database.executeBatch(batchExecute,100);
   }
}