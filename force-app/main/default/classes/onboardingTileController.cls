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
    
    public class dataWrapper{
        @AuraEnabled
        public integer numberofTasks;
        @AuraEnabled
        public integer numberofcompletedTasks;
        @AuraEnabled
        public List<taskInfoWrap> taskList;
    }
    
    public class taskInfoWrap {
        @AuraEnabled
        public string taskurl;
         @AuraEnabled
        public String taskid;
         @AuraEnabled
        public String subject;
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