/**
* @author Mukesh Rawat
* @date 23/04/2024
* @description  Schedule class to schedule BirthdayChecker in IST Time
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
global class BirthdayCheckerIST_Sch implements Schedulable{
	global void execute(SchedulableContext sc) {
      BirthdayChecker batchExecute = new BirthdayChecker('Hyderabad - India'); 
      Database.executeBatch(batchExecute,10);
   }
}