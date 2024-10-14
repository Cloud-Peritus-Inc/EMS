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
* 29-01-2024	Shubham MASKE			Updated batch to update goal status based on date value.
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        date dt = Test.isRunningTest() ? system.today().adddays(-10) : system.today().adddays(integer.valueOf(Label.Days_Consider_for_Missed_Goal));
        String GOAL_RECORD_TYPE = 'Goal';
        Id goalRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get(GOAL_RECORD_TYPE).getRecordTypeId();
        //return Database.getQueryLocator([SELECT Id,Status__c,End_Date__c,RecordTypeId FROM Goal__c WHERE Status__c='Active' And RecordTypeId =:goalRecTypeId and End_Date__c>=:dt ]);
        //smaske :[PM_070] : updating query [commented above line as not considering the records based on custom lable]
        return Database.getQueryLocator([SELECT Id,Status__c,Start_Date__c,End_Date__c,RecordTypeId FROM Goal__c WHERE (Status__c='Active' OR Status__c='Missed' OR Status__c='Draft' OR Status__c='In Progress') And RecordTypeId =:goalRecTypeId]);
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
            //smaske :[PM_070] : updating conditions
            system.debug('System.today()'+System.today());
            system.debug('System.today()'+(System.today()-1));
            system.debug('gl.Start_Date__c'+gl.Start_Date__c);
            if(gl.status__c == 'Draft' && gl.Start_Date__c == (System.today()+1)){
                gl.status__c = 'Active';
            }
            if( (gl.status__c == 'In Progress' || gl.status__c == 'Active' || gl.status__c == 'Draft') && gl.End_Date__c < (System.today()+1) ){
                gl.status__c = 'Missed';
            }
        }
         try{
           update goalList;
        }catch(exception ex){
            System.debug('exception ' + ex);
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