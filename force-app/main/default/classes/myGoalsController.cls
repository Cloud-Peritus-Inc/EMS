public without sharing class myGoalsController {
    
    @AuraEnabled(cacheable=true)
    public static List<goalWrapper>  getAlltheGoals(String kraId){
        Goal__c currentKRA = [SELECT Id,Fulfillment__c,Resource__c From Goal__c WHERE Fulfillment__c != null and Id=:kraId];
        List<goalWrapper> gwList = new List<goalWrapper>();
         Id goalRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Goal').getRecordTypeId();
        //smaske : [PM_133] : Fetching Loggedin User Proifle details to HIDE the Edit button for Goal if HR-PROFILE 
        User userData = [SELECT Id,Profile.Name FROM User WHERE Id=:Userinfo.getUserId() LIMIT 1];
 
         for(Goal__c gl : [SELECT Id,Name,Goal_Name__c,Parent_Goal__c,Start_Date__c, Goal_Completed_Date__c, CreatedDate,End_Date__c,Status__c,Description__c,Feedback_and_Comments__c 
                          FROM Goal__c WHERE RecordTypeId=:goalRecTypeId 
                          //@Mukesh - For Defect- PM_126, Added a condition where Goals created in the current Quarter will show in only the Linked KRAs 
                          AND Parent_Goal__r.Fulfillment__c =:currentKRA.Fulfillment__c
                          AND Parent_Goal__r.Id = :currentKRA.Id
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
               qw.goalCompletedDate = gl.Goal_Completed_Date__c;
               qw.showedit = false;
               if(gl.Status__c == 'Active' || gl.Status__c == 'Draft' || gl.Status__c =='In Progress'){
                   qw.showedit = true; 
               }
               //smaske : [PM_133] : Passing back profile Name to LWC
               qw.profileName = userData.Profile.Name;

             /*  if(gl.Status__c == 'Active'){
                 qw.showInprogress = true;
               } */
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
             
             //smaske : [PM_Def_014] : Query for In Progress, KRA InReview KRA records as per PHASE 2.
            List<Goal__c> findTheActiveGoal = [
                SELECT Id 
                FROM Goal__c 
                WHERE Fulfillment__c = :fulfilmentId 
                AND RecordTypeId = :kraRecordTypeId 
                AND (Status__c = 'In Progress' OR Status__c = 'KRA Inreview') 
                LIMIT 1
            ];

            if (!findTheActiveGoal.isEmpty()) {
                gl.Parent_Goal__c = findTheActiveGoal[0].Id;
                insert gl;
            } else {
                throw new AuraHandledException('Goals cannot be created for missed and completed KRAs');
            } 
            
        }else{
            String errorMsg = 'No fulfilment record found.';
            throw new AuraHandledException(errorMsg);  
        }
    }
    
    @AuraEnabled 
    public static Goal__c getTheGoals(String goalId){
        return [SELECT Id,Goal_Name__c,Start_Date__c,End_Date__c, Goal_Completed_Date__c, Description__c,Feedback_and_Comments__c FROM Goal__c WHERE Id=:goalId];
    }
    
    @AuraEnabled 
    public static void saveTheGoal(String goalId, String finalComments){
        try{
            Goal__c gl = [SELECT Id,Goal_Name__c,Start_Date__c,End_Date__c, Goal_Completed_Date__c, Description__c,Feedback_and_Comments__c,Status__c FROM Goal__c WHERE Id=:goalId];
            gl.Feedback_and_Comments__c = finalComments;
            gl.Goal_Completed_Date__c = system.today();
            if(gl.End_Date__c >= system.today()){
                gl.Status__c = 'Completed - OnTime';  
            }else{
                gl.Status__c = '	Completed - PostTime';    
            }
            
            update gl;  
        }catch(exception ex){
            String errorMsg = ex.getMessage();
            throw new AuraHandledException(ErrorMsg); 
        } 
    }
    @AuraEnabled 
    public static void updateRecord(String goalId){
        try{
            Goal__c gl = [SELECT Id,Goal_Name__c,Start_Date__c,End_Date__c, Goal_Completed_Date__c, Description__c,Feedback_and_Comments__c,Status__c FROM Goal__c WHERE Id=:goalId];
                gl.Status__c = 'In Progress';  
            
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
        public Date goalCompletedDate;
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
    /*    @AuraEnabled
        public boolean showInprogress; */
        @AuraEnabled
        public String profileName;
        
    }

}