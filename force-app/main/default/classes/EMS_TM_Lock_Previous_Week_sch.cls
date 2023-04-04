/**
* @author Suneel
* @date 04/04/2023
* @description  Schedule class to schedule EMS_TM_Lock_Previous_Week
*              
*       
*               Test code coverage provided by the following test class:
*               - TestClass_EMS_TM_Lock_Previous_Week
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class EMS_TM_Lock_Previous_Week_sch implements Schedulable{
    
    global void execute(SchedulableContext sc) {
      EMS_TM_Lock_Previous_Week batchExecute = new EMS_TM_Lock_Previous_Week(); 
      Database.executeBatch(batchExecute,10);
   }

}