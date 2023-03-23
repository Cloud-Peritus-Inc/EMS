/**
* @author Subba Kalavala
* @date 2/10/2023
* @description  BatchToCreateOffboardingRequest Batch to create the offboarding request based on Case 
*              
*               Schedule class 
*               - BatchToCreateOffboardingRequest_sch
*               Test code coverage provided by the following test class:
*               - BatchToCreateOffboardingRequest_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreateOffboardingRequest implements Database.Batchable<sObject> {
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
        Date dt;
        if(Test.isRunningTest()){
            dt = system.today().adddays(-1);
        }else{
           dt = system.today().adddays(integer.valueOf(Label.Days_to_Consider_For_Offboarding_Creation)); 
        }
        return Database.getQueryLocator([SELECT Id,Last_Working_Date__c,ContactId,LastModifiedDate,
                                         CreatedDate,Contact.Resource_Manager__c
                                         FROM CASE 
                                         WHERE Last_Working_Date__c=:dt
                                         AND Type = 'Resignation'
                                         AND Status = '	Resignation Approved'
                                          ]);
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
       
         List<Off_boarding_Request__c> offbList = new List<Off_boarding_Request__c>();
        for(Case offCase : caseList){
         Off_boarding_Request__c offReq = new Off_boarding_Request__c();
         offReq.Last_Day_Of_Work__c = offCase.Last_Working_Date__c; 
         offReq.Offboarding_Approved_Date__c = Date.valueOf(offCase.LastModifiedDate); 
         offReq.Offboarding_Request_Date__c = Date.valueOf(offCase.CreatedDate); 
         offReq.Reason_For_Offboarding__c = 'Resignation'; 
         offReq.Request_Approver__c = offCase.Contact.Resource_Manager__c;
         offReq.Resource__c = offCase.contactId; 
         offReq.Service_Request__c = offCase.Id;
         offReq.Status__c = 'Approved'; 
         offbList.add(offReq);
        }
         
       try{
            if(offbList.size()>0){
                insert offbList;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToCreateOffboardingRequest', 'execute');        
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