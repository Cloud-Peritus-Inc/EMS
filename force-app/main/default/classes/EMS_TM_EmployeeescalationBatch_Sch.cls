/**
* @author Ramakrishna papana
* @date 2/22/2023
* @description  Schedule class to schedule EMS_TM_EmployeeescalationBatch
*              
*       
*               Test code coverage provided by the following test class:
*               - EMS_TM_EmployeeescalationBatch_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class EMS_TM_EmployeeescalationBatch_Sch implements Schedulable{    
    global void execute(SchedulableContext SC) {
      EMS_TM_EmployeeescalationBatch bacthexecute = new EMS_TM_EmployeeescalationBatch();
 	database.executebatch(bacthexecute,10);
    }
    

}