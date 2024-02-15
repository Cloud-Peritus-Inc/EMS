public without sharing class onboardingTileController {
    
    
   @AuraEnabled(cacheable=true)
    public static dataWrapper getMyOnboardingTasks(){
        List<Task> taskList = new List<Task>();
        taskList = [SELECT Id,Subject,ActivityDate,Onboarding_UniqueKey__c,Status,Requires_Navigation__c,Navigation_address__c
                         FROM Task WHERE Onboarding_UniqueKey__c != null AND OwnerId=:Userinfo.getUserId() ];
        List<taskInfoWrap> taskInfoWrapper = new List<taskInfoWrap>();
        List<dataWrapper> dataWrapper = new List<dataWrapper>();
        Integer numberTasks = taskList.size();
        Integer NumberofCompletedTasks = 0;
        List<Network> network = [select name, UrlPathPrefix FROM Network where name like '%grid' limit 1];
           String base = URL.getSalesforceBaseUrl().toExternalForm(); 
        for(Task tnew : taskList){
            taskInfoWrap tw = new taskInfoWrap();
            tw.taskid = tnew.Id;
            tw.subject = tnew.Subject;
            tw.taskurl = '/task/:'+tnew.Id;
            Date duedate = tnew.ActivityDate;
            tw.substring = 'Due by '+duedate.day() + '/' + duedate.month() + '/' + duedate.year();
            tw.isCompleted = false;
            if(tnew.Status == 'Completed'){
               NumberofCompletedTasks = NumberofCompletedTasks+1;
               tw.isCompleted = true;
            }
            if(tnew.Requires_Navigation__c){
                tw.reqNav = tnew.Requires_Navigation__c;
                if(!Test.isRunningTest()){
                 tw.navLink = base + '/' + network[0].UrlPathPrefix + '/s/'+tnew.Navigation_address__c;
                }else{
                  tw.navLink = tnew.Navigation_address__c;  
                }
            }
            taskInfoWrapper.add(tw);
        }
        dataWrapper dwrap = new dataWrapper();
        dwrap.numberofTasks=numberTasks;
        dwrap.numberofcompletedTasks=NumberofCompletedTasks;
        dwrap.taskList = taskInfoWrapper;
        
        return dwrap;
    }
    
    @AuraEnabled(cacheable=true)
    public static dataWrapper getoffboardingTasks(){
        List<Task> taskList = new List<Task>();
      
        taskList = [SELECT Id,Subject,ActivityDate,Who.Name,Offboarding_UniqueKey__c,Status,Requires_Navigation__c,Navigation_address__c
                         FROM Task WHERE Offboarding_UniqueKey__c != null AND OwnerId=:Userinfo.getUserId() ];
        
        List<taskInfoWrap> taskInfoWrapper = new List<taskInfoWrap>();
        List<dataWrapper> dataWrapper = new List<dataWrapper>();
        Integer numberTasks = taskList.size();
        Integer NumberofCompletedTasks = 0;
        
        List<Network> network = [select name, UrlPathPrefix FROM Network where name like '%grid' limit 1];
           String base = URL.getSalesforceBaseUrl().toExternalForm(); 
        for(Task tnew : taskList){
            taskInfoWrap tw = new taskInfoWrap();
            tw.taskid = tnew.Id;
            tw.subject = tnew.Who.Name+'-'+tnew.Subject;
            tw.taskurl = '/task/:'+tnew.Id;
            Date duedate = tnew.ActivityDate;
            tw.substring = 'Due by '+duedate.day() + '/' + duedate.month() + '/' + duedate.year();
            tw.isCompleted = false;
            if(tnew.Status == 'Completed'){
               NumberofCompletedTasks = NumberofCompletedTasks+1;
               tw.isCompleted = true;
            }
            if(tnew.Requires_Navigation__c){
                tw.reqNav = tnew.Requires_Navigation__c;
                if(!Test.isRunningTest()){
                 //tw.navLink = base + '/' + network[0].UrlPathPrefix + '/s/'+tnew.Navigation_address__c;
                 tw.navLink = base + '/' + network[0].UrlPathPrefix + '/'+tnew.Navigation_address__c;
                }else{
                  tw.navLink = tnew.Navigation_address__c;  
                }
            }
            taskInfoWrapper.add(tw);
        }
        dataWrapper dwrap = new dataWrapper();
        dwrap.numberofTasks=numberTasks;
        dwrap.numberofcompletedTasks=NumberofCompletedTasks;
        dwrap.taskList = taskInfoWrapper;
        
        return dwrap;
    }
    
    @AuraEnabled
    public static string updateTheTaskasComplete(Id taskid){
        try{
            task trec = new task();
            trec.Id = taskid;
            trec.Status = 'Completed';
            update trec;
            return 'Successfully marked the task as completed.';
        }catch(exception ex){
          throw new AuraHandledException(ex.getMessage());
        }
    }
    
     @AuraEnabled(cacheable=true)
    public static dataWrapper getMyActiveGoals(){
        user urec = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
           Id goalRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Goal').getRecordTypeId();
        List<Goal__c> goalList = new List<Goal__c>();
        goalList = [SELECT Id,Description__c,End_Date__c,Name,Goal_Name__c,is_Navigation_Required__c,Navigation_address__c,Notes__c,Resource__c,
                        Start_Date__c,Status__c FROM Goal__c WHERE Status__c = 'Active' AND Resource__c=:urec.ContactId and RecordTypeId=:goalRecordTypeId ORDER BY End_Date__c DESC  ];
        List<taskInfoWrap> taskInfoWrapper = new List<taskInfoWrap>();
          List<taskInfoWrap> taskInfoWrapper1 = new List<taskInfoWrap>();
          List<taskInfoWrap> taskInfoWrapper2 = new List<taskInfoWrap>();
        List<dataWrapper> dataWrapper = new List<dataWrapper>();
        Integer numberTasks = 0;
        Integer NumberofCompletedTasks = 0;
        List<Network> network = [select name, UrlPathPrefix FROM Network where name like '%grid' limit 1];
           String base = URL.getSalesforceBaseUrl().toExternalForm(); 
        for(Goal__c gnew : goalList){
            taskInfoWrap tw = new taskInfoWrap();
            tw.taskid = gnew.Id;
            tw.subject = gnew.Goal_Name__c;
            tw.taskurl = '/Goal__c/:'+gnew.Id;
            tw.description = gnew.Description__c;
            tw.mygoal = gnew;
            Date duedate = gnew.End_Date__c;
           
            tw.isCompleted = false;
            if(gnew.is_Navigation_Required__c){
                tw.reqNav = gnew.is_Navigation_Required__c;
                tw.navLink = gnew.Navigation_address__c;  
               
            }
            taskInfoWrapper.add(tw);
        }
        
        if(taskInfoWrapper.size()>0){
            for(integer i=0;i<taskInfoWrapper.size();i++){
                if(math.mod(i, 2) == 0){
                  taskInfoWrapper1.add(taskInfoWrapper[i]);  
                }else{
                  taskInfoWrapper2.add(taskInfoWrapper[i]);  
                }
            } 
        }
        dataWrapper dwrap = new dataWrapper();
        dwrap.numberofTasks=numberTasks;
        dwrap.numberofcompletedTasks=NumberofCompletedTasks;
        dwrap.showUI = !taskInfoWrapper.isEmpty();
        dwrap.taskList = taskInfoWrapper1;
        dwrap.taskList2 = taskInfoWrapper2;
        return dwrap;
    }
    
     @AuraEnabled
    public static dataWrapper updateTheGoal(Id goalid){
        try{
            Goal__c goalrec = [SELECT Id,Status__c,End_Date__c FROM Goal__c WHERE Id=:goalid];
            goalrec.Status__c = goalrec.End_Date__c >=System.today() ? 'Completed - OnTime' : 'Completed - PostTime';
            update goalrec;
            return getMyActiveGoals();
        }catch(exception ex){
          throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static performanceWrapper getTheCurrentGoals(){
         Id goalRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Goal').getRecordTypeId();
      List<taskInfoWrap> taskInfoWrapper = new List<taskInfoWrap>();
        List<Goal__c> goalList = new List<Goal__c>();
        goalList = [SELECT Id,Name,Status__c,Goal_Name__c,Start_Date__c,End_Date__c FROM Goal__c 
                    WHERE Resource__r.EMS_TM_User__c=:Userinfo.getUserId() 
                    AND End_Date__c=THIS_FISCAL_YEAR And Type__c != 'Survey' and RecordTypeId=:goalRecordTypeId ORDER BY End_Date__c DESC	];
        Integer numberofCompleted = 0;
        Integer numberofInprogress = 0;
         Integer numberofMissed = 0;
        Integer numberofDraft = 0;
        Integer numberofActive = 0;
         Integer numberofstricks = 0;
         integer utlizationPercentage = 0;
         Integer lastPto = 0;
        for(Goal__c gl : goalList){
            if(gl.Status__c == 'In Progress'){//'Active'){
                numberofInprogress = numberofInprogress +1;
            }else if(gl.Status__c == 'Completed - OnTime' || gl.Status__c == 'Completed - PostTime'){
                numberofCompleted = numberofCompleted +1;
            }else if(gl.Status__c == 'Missed'){
                numberofMissed = numberofMissed +1;
            }else if(gl.Status__c == 'Active'){
                numberofActive = numberofActive+1;
            }else if(gl.Status__c == 'Draft'){
                numberofDraft = numberofDraft +1;
            }
        }
       Date dt = system.today();
       List<EMS_LM_Leave_History__c> leaveRequest = [SELECT Id,EMS_LM_Status__c,EMS_LM_Leave_End_Date__c 
                                                     FROM EMS_LM_Leave_History__c 
                                                     WHERE (EMS_LM_Status__c = 'Approved' OR EMS_LM_Status__c = 'Auto Approved')
                                                     AND EMS_LM_Leave_End_Date__c <:dt
                                                     AND EMS_LM_Contact__r.EMS_TM_User__c =:Userinfo.getUserId() ORDER BY EMS_LM_Leave_End_Date__c DESC LIMIT 1 ];
        
      lastPto = leaveRequest.isEmpty() ? 0 : (leaveRequest[0].EMS_LM_Leave_End_Date__c).daysBetween(dt);
        performanceWrapper dwrap = new performanceWrapper();
        dwrap.numberofCompleted=numberofCompleted;
        dwrap.numberofInprogress=numberofInprogress;
         dwrap.numberofMissed=numberofMissed;
         dwrap.numberofActive = numberofActive;
         dwrap.numberofDraft = numberofDraft;
         dwrap.numberofstricks=numberofstricks;
         dwrap.utlizationPercentage=utlizationPercentage;
         dwrap.lastPto=lastPto;
        dwrap.goalList = goalList;  
        return dwrap;
    }
    
     public class performanceWrapper{
        @AuraEnabled
        public integer numberofCompleted;
        @AuraEnabled
        public integer numberofInprogress;
         @AuraEnabled
        public integer numberofActive;
        @AuraEnabled
        public integer numberofMissed;
        @AuraEnabled
        public integer numberofDraft;
        @AuraEnabled
        public integer numberofstricks;
        @AuraEnabled 
        public decimal utlizationPercentage;
        @AuraEnabled 
        public integer lastPto;
        @AuraEnabled 
        public List<Goal__c> goalList;
         
     }
    
    public class dataWrapper{
        @AuraEnabled
        public integer numberofTasks;
        @AuraEnabled
        public integer numberofcompletedTasks;
        @AuraEnabled
        public boolean showUI;
        @AuraEnabled
        public List<taskInfoWrap> taskList;
        @AuraEnabled
        public List<taskInfoWrap> taskList2;
    }
    
    public class taskInfoWrap {
        @AuraEnabled
        public string taskurl;
         @AuraEnabled
        public String taskid;
         @AuraEnabled
        public String subject;
        @AuraEnabled
        public string description;
        @AuraEnabled
        public Goal__c mygoal;
         @AuraEnabled
        public String substring;
         @AuraEnabled
        public boolean isCompleted;
         @AuraEnabled
        public boolean reqNav;
         @AuraEnabled
        public string navLink;
    }

}
