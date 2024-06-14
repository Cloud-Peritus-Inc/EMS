/**
* @author Subba Kalavala
* @date 2/10/2023
* @description  BatchToAssignTasksForOffboarding Batch to create the task for onbording on DOJ 
*              
*               Schedule class 
*               - BatchToAssignTasksForOffboarding_sch
*               Test code coverage provided by the following test class:
*               - BatchToAssignTasksForOffboarding_test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToAssignTasksForOffboarding implements Database.Batchable<sObject> {
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
        return Database.getQueryLocator([SELECT Id,Exit_Interview_Date__c,Feedback_From_Resource__c,Last_Day_Of_Work__c,
                                         Resource__c,Status__c,Resource__r.EMS_TM_User__c,Resource__r.ReportsTo.EMS_TM_User__c
                                         ,Resource__r.Resource_Manager__r.EMS_TM_User__c FROM Off_boarding_Request__c 
                                         WHERE Status__c = 'Approved' ]);
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
    global void execute(Database.BatchableContext BC, List<Off_boarding_Request__c> offboardingList) {
         List<Task> finalTaskList = new List<Task>();
         List<offboarding_Tasks__mdt> metaList = new List<offboarding_Tasks__mdt>();
        metaList = [SELECT Id,Assigned_To__c,Due_Date_Days__c,Notification_Required_HR__c,
                    Task_Subject__c,Owner_Type__c,Unique_Identifier__c, Navigation_Required__c, Navigation_address__c 
                    FROM offboarding_Tasks__mdt];
        System.debug('**metaList'+metaList);
         Map<String,Id> QueueWithId = new Map<String,Id>();
         Set<String> queueNames = new Set<String>();
         Map<String,Id> queueMap = new Map<String,Id>();
        for(offboarding_Tasks__mdt ptm : metaList){
            if(ptm.Owner_Type__c == 'Queue'){
            queueNames.add(ptm.Assigned_To__c);
            }
        }
        System.debug('*queueNames'+queueNames);
        for(Group grp : [SELECT Id,NAME FROM Group WHERE Type='Queue' And NAME IN:queueNames]){
          QueueWithId.put(grp.Name,grp.Id);  
        }
        System.debug('*QueueWithId'+QueueWithId);
        system.debug('===offboardingList=='+offboardingList);
         Set<String> defalutOwners = new Set<String>();
         defalutOwners.add(Label.Default_HR_Support_Request_Owner);
         for(User grp : [SELECT Id,Name,contactId,Email FROM User WHERE Email IN : defalutOwners and contactId != null]){
            queueMap.put(grp.Email,grp.id);
        }
        System.debug('**queueMap'+queueMap);
        for(Off_boarding_Request__c con : offboardingList){
            for(offboarding_Tasks__mdt ptm : metaList){
              Task t = new Task();
                if(ptm.Owner_Type__c == 'Queue' && queueMap.containsKey(Label.Default_HR_Support_Request_Owner)){
                 t.OwnerId =  queueMap.get(Label.Default_HR_Support_Request_Owner); 
                }else if(ptm.Owner_Type__c == 'Contact' && con.Resource__r.EMS_TM_User__c != null ){
                t.OwnerId = con.Resource__r.EMS_TM_User__c;    
                }else if(ptm.Owner_Type__c == 'Reporting Manager' && con.Resource__r.ReportsTo.EMS_TM_User__c != null ){
                t.OwnerId = con.Resource__r.ReportsTo.EMS_TM_User__c;    
                }else if(ptm.Owner_Type__c == 'Resource Manager' && con.Resource__r.Resource_Manager__r.EMS_TM_User__c != null ){
                t.OwnerId = con.Resource__r.Resource_Manager__r.EMS_TM_User__c;    
                }else{
                t.OwnerId = userinfo.getUserId();
                }
                if(ptm.Navigation_Required__c){
                 t.Navigation_address__c = ptm.Navigation_address__c;
                 t.Requires_Navigation__c =  ptm.Navigation_Required__c;
                }
                t.Subject = ptm.Task_Subject__c;
                t.Status = 'Open';
                t.Priority = 'High';
                t.IsReminderSet = true;
                t.IsVisibleInSelfService = True;
                t.Offboarding_UniqueKey__c  = ptm.Unique_Identifier__c;
                t.WhoId = con.Resource__c;
                t.whatId = con.Id;
                Date duedate = ptm.Due_Date_Days__c != null ? system.today().adddays(integer.valueOf(ptm.Due_Date_Days__c)) : system.today();
                t.ActivityDate = duedate;
                t.Notification_Required_HR__c = ptm.Notification_Required_HR__c;
                t.ReminderDateTime = DateTime.newInstance(duedate.year(), duedate.month(), duedate.day(), 20, 00, 00);
                finalTaskList.add(t); 
                con.Status__c ='Offboarding In Progress';
            }  
        }
         
       try{
            if(finalTaskList.size()>0){
                system.debug('===finalContactList==='+finalTaskList);
                insert finalTaskList; 
                update offboardingList;
            }
        }
        Catch(Exception excp){
            System.debug('MESSAGE'+excp.getMessage());
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