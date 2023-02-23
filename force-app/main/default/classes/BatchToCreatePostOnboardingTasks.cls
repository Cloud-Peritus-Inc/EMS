/**
* @author Subba Kalavala
* @date 2/10/2023
* @description  BatchToCreatePostOnboardingTasks Batch to create the task for post onboarding of the employee
*              
*               Schedule class 
*               - BatchToCreatePostOnboardingTasks_SCH
*               Test code coverage provided by the following test class:
*               - BatchToCreatePostOnboardingTasks_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreatePostOnboardingTasks implements Database.Batchable<sObject> {
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
        Date dt = system.today();
        return Database.getQueryLocator([SELECT Id,EMS_EM_JD__c,EMS_TM_User__c,EMS_TM_User__r.Id
                                         FROM CONTACT 
                                         WHERE EMS_EM_JD__c=:dt
                                         AND RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID ]);
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
        metaList = [SELECT Id,Assigned_To__c,Contact_API__c,Due_Date_Days__c,Notification_Required_HR__c,Notification_Required_IT__c,Task_Subject__c,Type__c,Unique_Identifier__c, Navigation_Required__c, Navigation_address__c  FROM Preonboarding_Task_Mapping__mdt WHERE Onboarding_Task__c = 'Post'];
         Map<String,Id> QueueWithId = new Map<String,Id>();
         Set<String> queueNames = new Set<String>();
         Map<String,Id> UserWithId = new Map<String,Id>();
         Set<String> UserNames = new Set<String>();
         Set<String> uniqueIds = new Set<String>();
         Map<String, Set<String>> conWithTasks = new Map<String, Set<String>>();
        for(Preonboarding_Task_Mapping__mdt ptm : metaList){
            uniqueIds.add(ptm.Unique_Identifier__c);
            if(ptm.Type__c == 'Queue'){
            queueNames.add(ptm.Assigned_To__c);
            }else if(ptm.Type__c == 'User'){
             UserNames.add(ptm.Assigned_To__c);   
            }
        }
        for(Group grp : [SELECT Id,NAME FROM Group WHERE Type='Queue' And NAME IN:queueNames]){
          QueueWithId.put(grp.Name,grp.Id);  
        }
        
        for(User uRec : [SELECT Id,Name FROM User WHERE isActive = true AND Name IN:UserNames]){
          UserWithId.put(uRec.Name,uRec.Id);  
        }
        
        for(Task tRec : [SELECT Id,Onboarding_UniqueKey__c,whoId FROM Task Where Onboarding_UniqueKey__c IN:uniqueIds and WhoId IN:conList ]){
            if(conWithTasks.containsKey(tRec.WhoId)){
               conWithTasks.get(tRec.WhoId).add(tRec.Onboarding_UniqueKey__c); 
            }else{
                conWithTasks.put(tRec.WhoId, new Set<String>{tRec.Onboarding_UniqueKey__c});
            }
        }
        
        for(contact con : conList){
            for(Preonboarding_Task_Mapping__mdt ptm : metaList){
                Boolean goheadtoCreate = true;
                if(conWithTasks.containsKey(con.Id)){
                    if(conWithTasks.get(con.Id).contains(ptm.Unique_Identifier__c)){
                        goheadtoCreate = false;
                    }
                }
                if(goheadtoCreate){
              Task t = new Task();
                if(ptm.Type__c == 'Queue' && QueueWithId.containsKey(ptm.Assigned_To__c)){
                t.OwnerId = QueueWithId.get(ptm.Assigned_To__c);
                } if(ptm.Type__c == 'User' && UserWithId.containsKey(ptm.Assigned_To__c)){
                t.OwnerId = UserWithId.get(ptm.Assigned_To__c);
                } if(ptm.Type__c == 'Contact' && con.EMS_TM_User__r.Id != null){
                t.OwnerId = con.EMS_TM_User__r.Id;
                }else{
                t.OwnerId = Userinfo.getUserId();    
                }
                if(ptm.Navigation_Required__c){
                 t.Navigation_address__c = ptm.Navigation_address__c;
                 t.Requires_Navigation__c =  ptm.Navigation_Required__c;
                }
                t.Notification_Required_HR__c = ptm.Notification_Required_HR__c;
                t.Notification_Required_IT__c = ptm.Notification_Required_IT__c;
                t.Subject = ptm.Task_Subject__c;
                t.Status = 'Open';
                t.Priority = 'High';
                t.IsReminderSet = true;
                t.Onboarding_UniqueKey__c  = ptm.Unique_Identifier__c;
                t.WhoId = con.Id;
                if(ptm.Due_Date_Days__c != null){
                  t.ActivityDate = system.today().adddays(integer.valueOf(ptm.Due_Date_Days__c));
                }else{
                  t.ActivityDate = system.today();   
                }
               
                finalTaskList.add(t); 
                }
            }  
        }
         
       try{
            if(finalTaskList.size()>0){
                system.debug('===finalContactList==='+finalTaskList);
                insert finalTaskList;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToCreatePostOnboardingTasks', 'execute');        
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