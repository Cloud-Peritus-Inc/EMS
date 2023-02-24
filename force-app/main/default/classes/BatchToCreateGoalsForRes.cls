/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToCreateGoalsForRes Batch to create goals  
*              
*               Schedule class 
*               - BatchToCreateTimesheets_sch
*               Test code coverage provided by the following test class:
*               - BatchToCreateTimesheets_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreateGoalsForRes implements Database.Batchable<sObject> {
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
        
        date dt = system.today();
        return Database.getQueryLocator([SELECT Id,Description__c,Name,Goal_End_Date__c,Goal_Start_Date__c,Grid_Configuration_Type__c,
                                         Navigation_address__c,is_Navigation_Required__c,Resource_Role__c 
                                         FROM Grid_Configuration__c 
                                         WHERE Goal_Start_Date__c=:dt AND (Grid_Configuration_Type__c = 'Org Level Goal' OR Grid_Configuration_Type__c = 'Resource Role Level Goal')]);
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
    global void execute(Database.BatchableContext BC, List<Grid_Configuration__c> configList) {
        List<Goal__c> goalList = new List<Goal__c>();
        Grid_Configuration__c configRec = configList[0];
        List<Contact> conList = new List<Contact>();
        if(configRec.Grid_Configuration_Type__c == 'Org Level Goal'){
            conList = [SELECT Id FROM Contact WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID AND is_Resource_Active__c = true AND Timesheet_NoNeed__c = false ];
        }else if(configRec.Grid_Configuration_Type__c == 'Resource Role Level Goal'){
            conList = [SELECT Id FROM Contact
                       WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                       AND is_Resource_Active__c = true 
                       AND Timesheet_NoNeed__c = false
                       AND Resource_Role__c =:configRec.Resource_Role__c];  
        }
        
         for(Contact con : conList){
            Goal__c goal = new Goal__c();
            goal.Resource__c = con.id;
            goal.End_Date__c = configRec.Goal_End_Date__c;
            goal.Goal_Name__c = configRec.Name;
            goal.Description__c = configRec.Description__c;
            goal.is_Navigation_Required__c = configRec.is_Navigation_Required__c;
            goal.Navigation_address__c = configRec.Navigation_address__c;
            goal.Start_Date__c = configRec.Goal_Start_Date__c;
            goal.Status__c = 'Active';
           goalList.add(goal);
        }
        
        try{
           insert goalList; 
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