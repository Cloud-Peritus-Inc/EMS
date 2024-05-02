/**
* @author Mukesh Rawat
* @date 23/04/2024
* @description  Schedule class to schedule BirthdayChecker in PST Time
*              
*       
*               Test code coverage provided by the following test class:
*               - BirthdayCheckerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BirthdayCheckerPST_Sch implements Schedulable {
	global void execute(SchedulableContext sc) {
      BirthdayChecker batchExecute = new BirthdayChecker('California - USA'); 
      Database.executeBatch(batchExecute,10);
   }
}