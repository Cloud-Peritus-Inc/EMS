public without sharing class myGoalsController {
    
    @AuraEnabled(cacheable=true)
    public static List<goalWrapper>  getAlltheGoals(String kraId){
        Goal__c currentKRA = [SELECT Id,Fulfillment__c,Resource__c From Goal__c WHERE Fulfillment__c != null and Id=:kraId];
        List<goalWrapper> gwList = new List<goalWrapper>();
         Id goalRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Goal').getRecordTypeId();
        for(Goal__c gl : [SELECT Id,Name,Goal_Name__c,Parent_Goal__c,Start_Date__c,CreatedDate,End_Date__c,Status__c,Description__c,Feedback_and_Comments__c 
                          FROM Goal__c WHERE RecordTypeId=:goalRecTypeId 
                          AND Parent_Goal__r.Fulfillment__c =:currentKRA.Fulfillment__c
                          //smaske
                          AND Resource__c =: currentKRA.Resource__c 
                          ORDER BY CreatedDate DESC]){
               goalWrapper qw = new goalWrapper();
               qw.name = gl.Goal_Name__c;
               qw.nameid = gl.Id;
               qw.qstartdate = gl.Start_Date__c;
               qw.qendate = gl.End_Date__c;
               qw.status = gl.Status__c;
               qw.creaedDate = Date.valueOf(gl.CreatedDate);
               qw.Description = gl.Description__c;
               qw.comments = gl.Feedback_and_Comments__c;
               qw.showedit = false;
               if(gl.Status__c == 'Active' || gl.Status__c == 'Draft'){
                   qw.showedit = true; 
               }
               gwList.add(qw);
        }
        return gwList;
        
    }
    
    @AuraEnabled 
    public static void createTheGoals(String fulfilmentId,String resourceRTId,String name,Date startdate, Date enddate, String descri){
        if(!String.isEmpty(fulfilmentId)){
             Id goalRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Goal').getRecordTypeId();
             Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
               if(String.isEmpty(resourceRTId)){
                 resourceRTId = [SELECT ContactId FROM User WHERE Id=:Userinfo.getUserId()].contactId;  
               }

             Goal__c gl = new Goal__c();
             gl.Resource__c = resourceRTId;
             gl.RecordTypeId = goalRecordTypeId;
             gl.Goal_Name__c = name;
             gl.Start_Date__c = startdate;
             gl.End_Date__c = enddate;
             gl.Description__c = descri;
             
             List<Goal__c> findTheActiveGoal;
             findTheActiveGoal = [SELECT Id FROM Goal__c WHERE Fulfillment__c=:fulfilmentId And RecordTypeId=:kraRecordTypeId And Status__c= 'Active' LIMIT 1];
             System.debug('$findTheActiveGoal' + findTheActiveGoal);
            
             //smaske : made findTheActiveGoal as List
             //checking is Active record is available , if yes then assigning id else searching for Inreview/Completed records
             if (findTheActiveGoal != null && findTheActiveGoal.size() > 0) {
              System.debug('$findTheActiveGoal' + findTheActiveGoal);
              gl.Parent_Goal__c = findTheActiveGoal[0].Id;
              } else {
                findTheActiveGoal = [SELECT Id FROM Goal__c WHERE Fulfillment__c=:fulfilmentId And RecordTypeId=:kraRecordTypeId And (Status__c= 'KRA Inreview' OR Status__c= 'KRA Completed' ) LIMIT 1];
                System.debug('$findTheActiveGoal' + findTheActiveGoal);
                gl.Parent_Goal__c = findTheActiveGoal[0].Id;
              }
            //gl.Parent_Goal__c = findTheActiveGoal.Id;
            try{
              insert gl;  
            }catch(exception ex){
             String errorMsg = ex.getMessage();
             System.debug(errorMsg);
            throw new AuraHandledException(ErrorMsg); 
            } 
            
        }else{
            String errorMsg = 'No fulfilment record found.';
            throw new AuraHandledException(ErrorMsg);  
        }
    }
    
    @AuraEnabled 
    public static Goal__c getTheGoals(String goalId){
        return [SELECT Id,Goal_Name__c,Start_Date__c,End_Date__c,Description__c,Feedback_and_Comments__c FROM Goal__c WHERE Id=:goalId];
    }
    
     @AuraEnabled 
    public static void saveTheGoal(String goalId, String finalComments){
       Goal__c gl = [SELECT Id,Goal_Name__c,Start_Date__c,End_Date__c,Description__c,Feedback_and_Comments__c,Status__c FROM Goal__c WHERE Id=:goalId];
       gl.Feedback_and_Comments__c = finalComments;
        if(gl.End_Date__c >= system.today()){
          gl.Status__c = 'Completed - OnTime';  
        }else{
          gl.Status__c = '	Completed - PostTime';    
        }
        try{
              update gl;  
            }catch(exception ex){
             String errorMsg = ex.getMessage();
            throw new AuraHandledException(ErrorMsg); 
            } 
    }
    
    public class goalWrapper {
        @AuraEnabled
        public String name;
         @AuraEnabled
        public String nameid;
         @AuraEnabled
        public Date qstartdate;
         @AuraEnabled
        public Date qendate;
        @AuraEnabled
        public Date creaedDate;
         @AuraEnabled
        public String status;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String comments;
        @AuraEnabled
        public boolean showedit;
        
    }

}