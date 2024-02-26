public without sharing class checkInController {
    
    @AuraEnabled
    public static List<checkinWrapper> getThePulseInfo(String resourceId,String fyId){
        List<checkinWrapper> cList = new List<checkinWrapper>();
         Id checkinRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('pulse').getRecordTypeId();
        List<Goal__c> glist = new List<Goal__c>();
            Date startdate = null;
            Date enddate = null;
            if(String.isEmpty(fyId)){
                 Date currentdate = system.today();
                for(Fiscal_Year__c fy : [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c Order BY Start_Date__c ASC]){
                    if(fy.Start_Date__c <= currentdate && fy.End_Date__c >= currentdate){
                        startdate =  fy.Start_Date__c;
                         enddate = fy.End_Date__c;
                         break;
                    }
                  
                }
            }else{
                Fiscal_Year__c fy = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c WHERE Id=:fyId];
                startdate =  fy.Start_Date__c;
                enddate = fy.End_Date__c;
            }
            if(String.isNotBlank(resourceId)){
                glist = [SELECT Id,Check_In_By__c,Check_In_By__r.Name,Pulse_Id__c,Check_in_Date__c,Feedback_and_Comments__c,
                         Career_Development_Rating__c,Communication_Rating__c,Feedback_and_Recognition_Rating__c,Job_Satisfaction_Rating__c,
                         Leadership_and_Management_Rating__c,Work_Environment_Rating__c,Work_Life_Balance_Rating__c,Rating__c,Overall_Rating__c,Goal_Name__c,Status__c,
                         //Smaske : Added Overall_Pulse_Rating__c for PM_027
                         Overall_Pulse_Rating__c FROM Goal__c 
                         WHERE RecordTypeId=:checkinRecordTypeId AND Resource__c=:resourceId AND CreatedDate >=:startdate and CreatedDate <=:enddate ORDER BY CreatedDate DESC];
            }else{
                 glist = [SELECT Id,Check_In_By__c,Check_In_By__r.Name,Pulse_Id__c,Check_in_Date__c,Feedback_and_Comments__c,
                         Career_Development_Rating__c,Communication_Rating__c,Feedback_and_Recognition_Rating__c,Job_Satisfaction_Rating__c,
                         Leadership_and_Management_Rating__c,Work_Environment_Rating__c,Work_Life_Balance_Rating__c,Rating__c,Overall_Rating__c,Goal_Name__c,Status__c,
                         //Smaske : Added Overall_Pulse_Rating__c for PM_027
                         Overall_Pulse_Rating__c FROM Goal__c 
                         WHERE RecordTypeId=:checkinRecordTypeId AND Resource__r.EMS_TM_User__c=:Userinfo.getUserId()  AND CreatedDate >=:startdate and CreatedDate <=:enddate ORDER BY CreatedDate DESC ];
            }
        for(Goal__c gc : glist){
            checkinWrapper cw = new checkinWrapper();
             cw.goalname = gc.Pulse_Id__c;
             cw.goalid = gc.Pulse_Id__c;
             cw.checkbyName = gc.Check_In_By__r.Name;
             cw.CheckinDate = gc.Check_in_Date__c;
             cw.Comments = gc.Feedback_and_Comments__c;
             cw.Status = gc.Status__c;
             cw.carrerRating = gc.Career_Development_Rating__c;
            cw.JobStatRating = gc.Job_Satisfaction_Rating__c;
            cw.WorkEnvRating = gc.Work_Environment_Rating__c;
            cw.commRating = gc.Communication_Rating__c;
            cw.workLifeRating = gc.Work_Life_Balance_Rating__c;
            cw.FeedbackRating = gc.Feedback_and_Recognition_Rating__c;
            cw.LeadershipRating = gc.Leadership_and_Management_Rating__c;
            cw.overallRating = gc.Overall_Rating__c;
            //Smaske : Added for PM_027
            cw.overallPulseRating = gc.Overall_Pulse_Rating__c;
             cList.add(cw);
        }  
            
        return cList;
        
    }
    
    @AuraEnabled
    public static List<checkinWrapper> getTheCheckInInfo(String resourceId,String fyId){
        List<checkinWrapper> cList = new List<checkinWrapper>();
         Id checkinRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('checkin').getRecordTypeId();
        List<Goal__c> glist = new List<Goal__c>();
            Date startdate = null;
            Date enddate = null;
            if(String.isEmpty(fyId)){
                 Date currentdate = system.today();
                for(Fiscal_Year__c fy : [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c Order BY Start_Date__c ASC]){
                    if(fy.Start_Date__c <= currentdate && fy.End_Date__c >= currentdate){
                        startdate =  fy.Start_Date__c;
                         enddate = fy.End_Date__c;
                         break;
                    }
                  
                }
            }else{
                Fiscal_Year__c fy = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c WHERE Id=:fyId];
                startdate =  fy.Start_Date__c;
                enddate = fy.End_Date__c;
            }
        
            if(String.isNotBlank(resourceId)){
                //smaske : updated query to return data in DESC order based on createdDate
                glist = [SELECT Id,Check_In_By__c,Check_In_By__r.Name,Check_in_Date__c,Feedback_and_Comments__c,Goal_Name__c,Status__c,CreatedDate FROM Goal__c 
                         WHERE RecordTypeId=:checkinRecordTypeId AND Resource__c=:resourceId  AND Check_in_Date__c >=:startdate and Check_in_Date__c <=:enddate ORDER BY CreatedDate DESC ];
            }else{
                //smaske : updated query to return data in DESC order based on createdDate
                 glist = [SELECT Id,Check_In_By__c,Check_In_By__r.Name,Check_in_Date__c,Feedback_and_Comments__c,Goal_Name__c,Status__c,CreatedDate FROM Goal__c 
                         WHERE RecordTypeId=:checkinRecordTypeId AND Resource__r.EMS_TM_User__c=:Userinfo.getUserId()  AND Check_in_Date__c >=:startdate and Check_in_Date__c <=:enddate ORDER BY CreatedDate DESC ];
            }
        for(Goal__c gc : glist){
            checkinWrapper cw = new checkinWrapper();
             cw.goalname = gc.Goal_Name__c;
             cw.goalid = gc.Id;
             cw.checkbyName = gc.Check_In_By__r.Name;
             cw.CheckinDate = gc.Check_in_Date__c;
             cw.Comments = gc.Feedback_and_Comments__c;
             cw.Status = gc.Status__c;
             cList.add(cw);
        }  
            
        return cList;
        
    }
    
    
     @AuraEnabled
    public static String createCheckIn(String resourceId,String mentorId, String checkInComments){
        Id checkinRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('checkin').getRecordTypeId();
        Contact resourceCon = [SELECT Id,Name FROM Contact WHERE Id=:resourceId];
        Contact mentorCon = [SELECT Id,Name FROM Contact WHERE Id=:mentorId];
        Goal__c checkInGoal = new Goal__c();
        checkInGoal.Goal_Name__c = 'Check-In On '+String.valueOf(System.today());
        checkInGoal.Check_In_By__c = mentorCon.Id;
        checkInGoal.Resource__c = resourceCon.Id;
        checkInGoal.Check_in_Date__c = System.today();
        checkInGoal.Feedback_and_Comments__c = checkInComments;
        checkInGoal.RecordTypeId = checkinRecordTypeId;
        checkInGoal.Status__c = 'Completed';
        insert checkInGoal;
        return 'success';
    }
    
    @AuraEnabled
    public static checkinWrapper getTheCheckInRecord(String checkiin){
        Goal__c gc = [SELECT Id,Check_In_By__c,Check_In_By__r.Name,Check_in_Date__c,Feedback_and_Comments__c,Goal_Name__c,Status__c FROM Goal__c WHERE Id=:checkiin];
           checkinWrapper cw = new checkinWrapper();
             cw.goalname = gc.Goal_Name__c;
             cw.goalid = gc.Id;
             cw.checkbyName = gc.Check_In_By__r.Name;
             cw.CheckinDate = gc.Check_in_Date__c;
             cw.Comments = gc.Feedback_and_Comments__c;
             cw.Status = gc.Status__c;
        return cw;
    }
    
    
    
    
        public class checkinWrapper {
        @AuraEnabled
        public String goalname;
         @AuraEnabled
        public String goalid;
         @AuraEnabled
        public String checkbyName;
         @AuraEnabled
        public Date CheckinDate;
         @AuraEnabled
        public String Comments;
         @AuraEnabled
        public String Status;
        @AuraEnabled
        public String carrerRating;
       @AuraEnabled
        public String JobStatRating;
        @AuraEnabled
        public String WorkEnvRating;
         @AuraEnabled
        public String commRating;
         @AuraEnabled
        public String workLifeRating;
          @AuraEnabled
        public String FeedbackRating;
          @AuraEnabled
        public String LeadershipRating;
         @AuraEnabled
        public String overallRating;
        //smaske :Added for PM_027 
        @AuraEnabled
        public String overallPulseRating;
         
        
    }

}