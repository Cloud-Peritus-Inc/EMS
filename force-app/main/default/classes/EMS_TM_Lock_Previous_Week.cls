/**
* @author Suneel
* @date 04/04/2023
* @description  EMS_TM_Lock_Previous_Week Batch to send  
*              
*               Schedule class 
*               - EMS_TM_Lock_Previous_Week_sch
*               Test code coverage provided by the following test class:
*               - TestClass_EMS_TM_Lock_Previous_Week 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class EMS_TM_Lock_Previous_Week implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        date dt = system.today();
        return Database.getQueryLocator([SELECT Id, EMS_TM_Status__c, EMS_TM_Week__c
                                                FROM EMS_Timesheet__c
                                                WHERE Week_End_Date__c <:dt
                                                AND EMS_TM_Status__c !='Submitted' 
                                                AND EMS_TM_Status__c !='Approved']);
    }
    
    global void execute(Database.BatchableContext BC, List<EMS_Timesheet__c> timesheetList) {
        
        List<EMS_Timesheet__c> updatedTimesheetList = new List<EMS_Timesheet__c>();
         for (EMS_Timesheet__c timesheet : timesheetList) {
            timesheet.EMS_TM_Status__c = 'Locked';
             updatedTimesheetList.add(timesheet);
        }
        try{
            Update updatedTimesheetList;
        }catch(exception ex){
            system.debug('=====ex===='+ex);
            LogException.logHandledException(ex, 'EMS_TM_Lock_Previous_Week', 'execute');
        }        
    }
          /**
* @author Suneel
* @date 04/04/2023
* @description process the failures.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void finish(Database.BatchableContext BC) {
        
    }
  
}