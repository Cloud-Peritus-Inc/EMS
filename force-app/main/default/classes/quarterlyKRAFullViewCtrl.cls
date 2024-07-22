public without sharing class quarterlyKRAFullViewCtrl {
    
    @AuraEnabled
    public static String completekraMethod(String kraid) {
        Goal__c goalRecord = [SELECT Id, Type__c, RecordTypeId, Status__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c 
                              FROM Goal__c 
                              WHERE Id=:kraid AND Status__c!='KRA Completed' Limit 1]; 
        goalRecord.Status__c='KRA Completed';
        update goalRecord;
        
        list<PM_Configure__c> pmAnswer =[Select Id,Status__c,KRA__c 
                                         from PM_Configure__c 
                                         WHERE KRA__c=:kraid AND Status__c='Awaiting Response'];
        for(PM_Configure__c pm:pmAnswer){
            pm.Status__c='Cancelled';   
        }    
        try {
            if(!pmAnswer.isEmpty()){
                update pmAnswer;
            }
            return 'updated'; 
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred while processing the request: ' + ex.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static viewAnswerWrapper getLoginAnswerdata(String kraid,String tab) {
        
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        viewAnswerWrapper aw =new viewAnswerWrapper();
        Goal__c goalRecord = [SELECT Id, Type__c, RecordTypeId, Status__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,
                              Resource__r.ContactName__c ,Resource__r.Resource_Role__c 
                              FROM Goal__c 
                              WHERE Id=:kraid Limit 1];
        if(goalRecord.Status__c == 'KRA Completed' && tab =='My Team'){
            aw.submittedKRAbutton=false;
        }
        if(tab =='My Metric'){
            aw.submittedKRAbutton=false;
        }
        
        
        User loggedInUser = [SELECT Id,ContactId,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];
        
        List<PM_Configure__c> answersrecord = new List<PM_Configure__c>();
        
        
        answersrecord= [SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,
                        Related_Question__c,Status__c,KRA__c
                        FROM PM_Configure__c 
                        Where RecordTypeId = :AnswerRecordTypeId AND KRA__c =:kraid AND Mentor_Mentee__c =:loggedInUser.ContactId];  
        
        for(PM_Configure__c answer: answersrecord){
            if(tab =='My Team'){
                if(answer.Status__c == 'Submitted'){
                    aw.submittedRecords=false;
                }else if(goalRecord.Status__c == 'KRA Completed'){
                    aw.submittedRecords=false;
                }else{
                    aw.submittedRecords=true;
                }
            }
            if(tab =='My Metric'){
                aw.submittedRecords=false;
            }
        }
        return aw;
    }
    
    public class viewAnswerWrapper{
        @AuraEnabled 
        public Boolean submittedRecords=true;
        @AuraEnabled 
        public Boolean submittedKRAbutton=true;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<QuestionWrapper> getPMConfigKRAFullDetails(String kraid, String selectedarea, String tab) {
        List<QuestionWrapper> questionWrappers = new List<QuestionWrapper>();
        
        //get recordtypeId
        Id QuestionRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        User loggedInUser = [SELECT Id,ContactId,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];
        
        Goal__c goalRecord = [SELECT Id, Type__c, RecordTypeId, Status__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,
                              Resource__r.ContactName__c ,Resource__r.Resource_Role__c 
                              FROM Goal__c 
                              WHERE Id=:kraid Limit 1];
        
        List<PM_Configure__c> questions = new List<PM_Configure__c>();
        if(tab=='My Team'){
            questions= [SELECT Id,Area__c, KRA__c,Resource_Role__c,Question__c,
                        (SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                         Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,Reporting_Contact__r.Name
                         FROM PM_Configure__r Where KRA__c =:kraid AND ((Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))
                                                     OR Mentor_Mentee__c =: loggedInUser.ContactId))
                        FROM PM_Configure__c 
                        Where RecordTypeId  = :QuestionRecordTypeId AND Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c]; 
            //OR Reporting_Contact__c=: loggedInUser.ContactId
        }
        if(tab=='My Metric'){
            questions= [SELECT Id,Area__c, KRA__c,Resource_Role__c,Question__c,
                        (SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                         Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,Reporting_Contact__r.Name
                         FROM PM_Configure__r Where KRA__c =:kraid AND ( Mentor_Mentee__c =: loggedInUser.ContactId OR (Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))))
                        FROM PM_Configure__c 
                        Where RecordTypeId  = :QuestionRecordTypeId AND Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c];
        }
        
        /*questions= [SELECT Id,Area__c, KRA__c,Resource_Role__c,Question__c,
(SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,
Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name
FROM PM_Configure__r Where KRA__c =:kraid)
FROM PM_Configure__c 
Where RecordTypeId  = :QuestionRecordTypeId AND Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c ];*/
        
        
        // Loop through questions to construct the wrapper
        for (PM_Configure__c question : questions) {                                  
            Map<String, List<AnswerWrapper>> roleToAnswersMap = new Map<String, List<AnswerWrapper>>();
            List<String> answerIdlst =New List<String>();
            
            for (PM_Configure__c answer : question.PM_Configure__r) {
                String contactKey = answer.Mentor_Mentee__c!=null?answer.Mentor_Mentee__c:answer.Reporting_Contact__c;
                
                if (!roleToAnswersMap.containsKey(contactKey)) {
                    roleToAnswersMap.put(contactKey, new List<AnswerWrapper>());
                }
                
                // Create an AnswerWrapper instance and set properties individually
                AnswerWrapper awn = new AnswerWrapper();
                awn.answerId = answer.Id;
                awn.answerValue = (answer.Description__c!=null ||answer.Description__c!='')?answer.Description__c:' ';
                awn.Ratingoverview = answer.Related_Question__r.Rating_overview__c;
                awn.Descriptionoverview = answer.Related_Question__r.Question_overview__c;
                awn.rating = answer.Rating__c!=null?answer.Rating__c:0;
                awn.contactId = contactKey;
                awn.contactName = answer.Mentor_Mentee__c!=null?answer.Mentor_Mentee__r.Name:answer.Reporting_Contact__r.Name;
                
                roleToAnswersMap.get(contactKey).add(awn);
                answerIdlst.add(answer.Id);
            } 
            questionWrappers.add(new QuestionWrapper(question.Id, question.Question__c,question.Area__c, roleToAnswersMap,answerIdlst,goalRecord));
        } 
        System.debug('questionWrappers-->' + questionWrappers);
        return questionWrappers;
    }
    
    // Wrapper class for Question
    public class QuestionWrapper {
        @AuraEnabled
        public Id questionId;
        @AuraEnabled
        public String questionName;
        @AuraEnabled
        public String area;
        @AuraEnabled
        public Map<String, List<AnswerWrapper>> answers; // Map of Contact Id to List of Answers
        @AuraEnabled
        public List<String> answersId;
        @AuraEnabled
        public Goal__c goalRecord;
        
        public QuestionWrapper(Id questionId, String questionName,String area, Map<String, List<AnswerWrapper>> answers,List<String> answersId, Goal__c goalRecord) {
            this.questionId = questionId;
            this.questionName = questionName;
            this.area = area;
            this.answers = answers;
            this.answersId =answersId;
            this.goalRecord = goalRecord;
        }
    }
    
    // Wrapper class for Answer
    public class AnswerWrapper {
        @AuraEnabled
        public Id answerId;
        @AuraEnabled
        public String answerValue;
        @AuraEnabled
        public String Ratingoverview;
        @AuraEnabled
        public String Descriptionoverview;
        @AuraEnabled
        public Decimal rating;
        @AuraEnabled
        public Id contactId;
        @AuraEnabled
        public String contactName;
        
        public AnswerWrapper() {}
        
        public AnswerWrapper(Id answerId, String answerValue,String Ratingoverview,String Descriptionoverview, Decimal rating, Id contactId, String contactName) {
            this.answerId = answerId;
            this.answerValue = answerValue;
            this.rating = rating;
            this.contactId = contactId;
            this.contactName = contactName;
        }
    }
}