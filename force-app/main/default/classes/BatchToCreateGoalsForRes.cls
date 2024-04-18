/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToCreateGoalsForRes Batch to create goals  
*              
*               Schedule class 
*               - BatchToCreateGoalsForRes
*               Test code coverage provided by the following test class:
*               - BatchToCreateGoalsForRes_Test
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
        
        //date dt = Test.isRunningTest() ? system.today().adddays(1) : system.today() ;
        date dt =  system.today().adddays(1);
        system.debug('33');
        system.debug(dt);
       
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
        system.debug('53');
        system.debug(configList);
        List<Goal__c> goalList = new List<Goal__c>();
        Grid_Configuration__c configRec = configList[0];
        
        List<Contact> conList = new List<Contact>();
        if(configRec.Grid_Configuration_Type__c == 'Org Level Goal'){
            conList = [SELECT Id,EMS_TM_User__c FROM Contact WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID AND EMS_RM_ApplicantStatus_Update__c = 'Active' AND Timesheet_NoNeed__c = false AND EMS_TM_User__c != null AND EMS_TM_User__r.isactive = true];
           system.debug('61');
            system.debug(conList);
        }else if(configRec.Grid_Configuration_Type__c == 'Resource Role Level Goal'){
            conList = [SELECT Id,EMS_TM_User__c FROM Contact
                       WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                       AND EMS_RM_ApplicantStatus_Update__c = 'Active'
                       AND Timesheet_NoNeed__c = false
                       AND Resource_Role__c =:configRec.Resource_Role__c AND EMS_TM_User__c != null AND EMS_TM_User__r.isactive = true];  
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
            goal.OwnerId = con.EMS_TM_User__c;
            //smaske : [UAT_052] :  Updating Type for "Org Level Goal" 
           	goal.Type__c = 'Org Level Goal';
           goalList.add(goal);
        }
        
        try{
           insert goalList; 
            system.debug(goalList.size());
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