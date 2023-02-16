public without sharing class onboardingTileController {
    
    
   @AuraEnabled(cacheable=true)
    public static dataWrapper getMyOnboardingTasks(){
        List<Task> taskList = new List<Task>();
        taskList = [SELECT Id,Subject,ActivityDate,Onboarding_UniqueKey__c,Status
                         FROM Task WHERE Onboarding_UniqueKey__c != null AND OwnerId=:Userinfo.getUserId() ];
        List<taskInfoWrap> taskInfoWrapper = new List<taskInfoWrap>();
        List<dataWrapper> dataWrapper = new List<dataWrapper>();
        Integer numberTasks = taskList.size();
        Integer NumberofCompletedTasks = 0;
        
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
          return null;  
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
    }

}