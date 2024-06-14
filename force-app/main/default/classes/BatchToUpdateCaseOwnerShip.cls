/**
* @author Subba Kalavala
* @date 2/10/2023
* @description  BatchToUpdateCaseOwnerShip Batch to update the case ownership 
*              
*               Schedule class 
*               - BatchToCreateOnboardingTasksOnDOJ_SCH
*               Test code coverage provided by the following test class:
*               - BatchToCreateOnboardingTasksOnDOJ_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToUpdateCaseOwnerShip implements Database.Batchable<sObject> {
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
        Datetime dt;
        if(Test.isRunningTest()){
            dt = system.now();
        }else{
           dt = system.now().addminutes(-5); 
        }
        return Database.getQueryLocator([SELECT Id,ContactId,Contact.Resource_Manager__r.EMS_TM_User__c,Contact.Resource_Manager__c,
                                         Contact.ReportsToId,
                                         Contact.ReportsTo.EMS_TM_User__c,Request_Sub_Type__c,type
                                         FROM CASE 
                                         WHERE CreatedDate >= :dt]);
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
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        Map<String,Id> queueMap = new Map<String,Id>(); 
        for(Group grp : [SELECT Id,Name FROM Group WHERE Type = 'Queue']){
            queueMap.put(grp.Name,grp.id);
        }
        for (Case cnew : caseList) {
             Id ResourceManager = cnew.Contact.Resource_Manager__c;
             Id ReportingManager = cnew.Contact.ReportsToId;
            if(cnew.Type != null){
                if(cnew.Type == 'Problem' || cnew.Type == 'Others'){
                    if(queueMap.containsKey('Grid Support')){
                        cnew.OwnerId =  queueMap.get('Grid Support'); 
                    } 
                }else if(cnew.Type == 'Change Of Details'){
                    if(queueMap.containsKey('HR Executive Queue')){
                        cnew.OwnerId =  queueMap.get('HR Executive Queue'); 
                    } 
                }else if(cnew.Type == 'Resignation'){
                    system.debug('ResourceManager'+ResourceManager);
                    cnew.Case_Assignee__c = ResourceManager != null ? ResourceManager : ReportingManager;
                }else if(cnew.Type == 'Request for Special Leaves'){
                    if(ReportingManager != null && (cnew.Request_Sub_Type__c == 'Paternity' || cnew.Request_Sub_Type__c == 'Marriage' || cnew.Request_Sub_Type__c == '	Bereavement Leave' || cnew.Request_Sub_Type__c == 'Comp off')){
                        cnew.Case_Assignee__c = ReportingManager;
                    }
                } 
            }
        }
         
       try{
            if(caseList.size()>0){
                
               update caseList;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToUpdateCaseOwnerShip', 'execute');        
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