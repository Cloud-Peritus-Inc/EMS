/**
* @author Mukesh Rawat
* @date 23/04/2024
* @description  Schedule class to schedule WorkAnniversaryChecker in PST Time
*              
*       
*               Test code coverage provided by the following test class:
*               - WorkAnniversaryCheckerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class WorkAnniversaryCheckerPST_sch implements Schedulable {
	global void execute(SchedulableContext sc) {
      WorkAnniversaryChecker batchExecute = new WorkAnniversaryChecker('California - USA'); 
      Database.executeBatch(batchExecute,10);
   }
}