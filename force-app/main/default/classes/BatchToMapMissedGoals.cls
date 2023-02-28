/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToMapMissedGoals Batch to update the goals to missed
*              
*               Schedule class 
*               - BatchToMapMissedGoals_sch
*               Test code coverage provided by the following test class:
*               - BatchToMapMissedGoals_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToMapMissedGoals implements Database.Batchable<sObject> {
 /**
* @author Subba
* @date 22/01/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        date dt = system.today().adddays(integer.valueOf(Label.Days_Consider_for_Missed_Goal));
        return Database.getQueryLocator([SELECT Id,Status__c FROM Goal__c WHERE Status__c='Active' and End_Date__c>=:dt ]);
    }
    
    /**
* @author Subba
* @date 22/01/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void execute(Database.BatchableContext BC, List<Goal__c> goalList) {
        for(Goal__c gl : goalList){
            gl.status__c = 'Missed';
        }
         try{
           update goalList;
        }catch(exception ex){
           LogException.logHandledException(ex, 'BatchToCreateGoalsForRes', 'execute');  
        }
    }
    
          /**
* @author Subba
* @date 22/01/2023
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