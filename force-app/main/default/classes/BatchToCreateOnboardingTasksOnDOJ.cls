/**
* @author Subba Kalavala
* @date 2/10/2023
* @description  BatchToCreateOnboardingTasksOnDOJ Batch to create the task for onbording on DOJ 
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
global class BatchToCreateOnboardingTasksOnDOJ implements Database.Batchable<sObject> {
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
        Date dt = system.today().adddays(integer.valueOf(Label.Days_Consider_for_Onboarding_Taks));
        return Database.getQueryLocator([SELECT Id,EMS_EM_JD__c
                                         FROM CONTACT 
                                         WHERE EMS_EM_JD__c=:dt
                                         AND RecordTypeId =:ContactConstant.APPLICANT_RECORDTYPEID ]);
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
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
         List<Task> finalTaskList = new List<Task>();
         List<Preonboarding_Task_Mapping__mdt> metaList = new List<Preonboarding_Task_Mapping__mdt>();
        metaList = [SELECT Id,Assigned_To__c,Contact_API__c,Due_Date_Days__c,Notification_Required_HR__c,Notification_Required_IT__c,Task_Subject__c,Type__c,Unique_Identifier__c  FROM Preonboarding_Task_Mapping__mdt WHERE Onboarding_Task__c = 'Pre'];
         Map<String,Id> QueueWithId = new Map<String,Id>();
         Set<String> queueNames = new Set<String>();
        for(Preonboarding_Task_Mapping__mdt ptm : metaList){
            if(ptm.Type__c == 'Queue'){
            queueNames.add(ptm.Assigned_To__c);
            }
        }
        for(Group grp : [SELECT Id,NAME FROM Group WHERE Type='Queue' And NAME IN:queueNames]){
          QueueWithId.put(grp.Name,grp.Id);  
        }
        
        for(contact con : conList){
            for(Preonboarding_Task_Mapping__mdt ptm : metaList){
              Task t = new Task();
                if(ptm.Type__c == 'Queue' && QueueWithId.containsKey(ptm.Assigned_To__c)){
                t.OwnerId = QueueWithId.get(ptm.Assigned_To__c);
                
                }else{
                t.OwnerId = Userinfo.getUserId();    
                }
                t.Subject = ptm.Task_Subject__c;
                t.Status = 'Open';
                t.Priority = 'High';
                t.IsReminderSet = true;
                t.IsVisibleInSelfService = True;
                t.Onboarding_UniqueKey__c  = ptm.Unique_Identifier__c;
                t.WhoId = con.Id;
                t.ActivityDate = con.EMS_EM_JD__c;
                t.Notification_Required_HR__c = ptm.Notification_Required_HR__c;
                t.Notification_Required_IT__c = ptm.Notification_Required_IT__c;
                t.ReminderDateTime = DateTime.newInstance(con.EMS_EM_JD__c.year(), con.EMS_EM_JD__c.month(), con.EMS_EM_JD__c.day(), 20, 00, 00);
                finalTaskList.add(t); 
            }  
        }
         
       try{
            if(finalTaskList.size()>0){
                system.debug('===finalContactList==='+finalTaskList);
                insert finalTaskList;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToCreateOnboardingTasksOnDOJ', 'execute');        
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