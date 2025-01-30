/**
* @author CloudPeritus Inc
* @date 24/07/2024
* @description  
* @test class quarterlyKRAFullViewCtrl_TEST
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           SANGHARSH KAMBLE        Create class for full view lwc controller
* ====================================================================================================
**/
public without sharing class quarterlyKRAFullViewCtrl {
    
    @AuraEnabled
    public static String SavePMFeedbackReason(String kraid,String contactData) {
        try {
            // Debug input data
            System.debug('Contact Data: ' + contactData);
            
            // Deserialize and validate input
            List<Object> contactListGeneric = (List<Object>) JSON.deserializeUntyped(contactData);
            if (contactListGeneric == null || contactListGeneric.isEmpty()) {
                throw new AuraHandledException('Contact data is empty or invalid.');
            }
            
            // Parse contact data into a structured format
            List<Map<String, Object>> contactList = new List<Map<String, Object>>();
            for (Object contactObj : contactListGeneric) {
                if (contactObj instanceof Map<String, Object>) {
                    contactList.add((Map<String, Object>) contactObj);
                } else {
                    throw new AuraHandledException('Invalid data format: Each contact should be a map.');
                }
            }
            
            System.debug('Parsed Contact List: ' + contactList);
            
            // Extract Contact IDs and feedback details
            Set<String> contactIds = new Set<String>();
            Map<String, Boolean> feedbackMap = new Map<String, Boolean>();
            Map<String, String> reasonMap = new Map<String, String>();
            
            for (Map<String, Object> contact : contactList) {
                if (contact.containsKey('contactId')) {
                    String fullContactId = (String) contact.get('contactId');
                    String contactId = fullContactId.split('&')[0]; // Extract the first 18 characters
                    contactIds.add(contactId);
                    
                    if (contact.containsKey('ConsiderFeedbackRating')) {
                        feedbackMap.put(contactId, (Boolean) contact.get('ConsiderFeedbackRating'));
                    }
                    
                    if (contact.containsKey('NotConsiderFeedbackReason')) {
                        reasonMap.put(contactId, (String) contact.get('NotConsiderFeedbackReason'));
                    }
                }
            }
            
            System.debug('Extracted Contact IDs: ' + contactIds);
            System.debug('Feedback Map: ' + feedbackMap);
            System.debug('Reason Map: ' + reasonMap);
            
            // Retrieve RecordTypeId for PM_Configure__c with 'Answer'
            Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
            
            // Query relevant PM_Configure__c records
            List<PM_Configure__c> answersToUpdate = [
                SELECT Id, Consider_Feedback_Rating__c, Not_Consider_Feedback_Reason__c, Reporting_Contact__c
                FROM PM_Configure__c
                WHERE KRA__c = :kraid
                AND RecordTypeId = :answerRecordTypeId
                AND Reporting_Contact__c IN :contactIds
            ];
            
            System.debug('Queried PM_Configure__c Records: ' + answersToUpdate);
            
            // Update records with new feedback data
            for (PM_Configure__c answer : answersToUpdate) {
                String reportingContactId = answer.Reporting_Contact__c;
                if (feedbackMap.containsKey(reportingContactId)) {
                    answer.Consider_Feedback_Rating__c = feedbackMap.get(reportingContactId);
                }
                
                if (reasonMap.containsKey(reportingContactId)) {
                    answer.Not_Consider_Feedback_Reason__c = reasonMap.get(reportingContactId);
                }
            }
            
            // Perform bulk DML update
            if (!answersToUpdate.isEmpty()) {
                update answersToUpdate;
                System.debug('Updated PM_Configure__c Records: ' + answersToUpdate);
            }
            
            return 'success';
        } catch (Exception e) {
            System.debug('Error in SavePMFeedbackReason: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while saving PM feedback: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String completekraMethod(String kraid,String contactData) {
        system.debug('contactData-->'+contactData);
        updatePmConfigure( kraid,  contactData, true);
        return 'success';
    }
    
    @future    
    public static void updatePmConfigure(String kraid, String contactData, boolean completekra){
        // Deserialize and validate input
        List<Object> contactListGeneric = (List<Object>) JSON.deserializeUntyped(contactData);
        if (contactListGeneric == null || contactListGeneric.isEmpty()) {
            throw new AuraHandledException('Contact data is empty or invalid.');
        }
        
        // Parse contact data into a structured format
        List<Map<String, Object>> contactList = new List<Map<String, Object>>();
        for (Object contactObj : contactListGeneric) {
            if (contactObj instanceof Map<String, Object>) {
                contactList.add((Map<String, Object>) contactObj);
            } else {
                throw new AuraHandledException('Invalid data format: Each contact should be a map.');
            }
        }
        
        System.debug('Parsed Contact List: ' + contactList);
        
        // Extract Contact IDs and feedback details
        Set<String> contactIds = new Set<String>();
        Map<String, Boolean> feedbackMap = new Map<String, Boolean>();
        Map<String, String> reasonMap = new Map<String, String>();
        
        for (Map<String, Object> contact : contactList) {
            if (contact.containsKey('contactId')) {
                String fullContactId = (String) contact.get('contactId');
                String contactId = fullContactId.split('&')[0]; // Extract the first 18 characters
                contactIds.add(contactId);
                
                if (contact.containsKey('ConsiderFeedbackRating')) {
                    feedbackMap.put(contactId, (Boolean) contact.get('ConsiderFeedbackRating'));
                }
                
                if (contact.containsKey('NotConsiderFeedbackReason')) {
                    reasonMap.put(contactId, (String) contact.get('NotConsiderFeedbackReason'));
                }
            }
        }
        
        System.debug('Extracted Contact IDs: ' + contactIds);
        System.debug('Feedback Map: ' + feedbackMap);
        System.debug('Reason Map: ' + reasonMap);
        
        // Retrieve RecordTypeId for PM_Configure__c with 'Answer'
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        // Query relevant PM_Configure__c records
        List<PM_Configure__c> answersToUpdate = [
            SELECT Id, Consider_Feedback_Rating__c, Not_Consider_Feedback_Reason__c, Reporting_Contact__c
            FROM PM_Configure__c
            WHERE KRA__c = :kraid
            AND RecordTypeId = :answerRecordTypeId
            AND Reporting_Contact__c IN :contactIds
        ];
        
        System.debug('Queried PM_Configure__c Records: ' + answersToUpdate);
        
        // Update records with new feedback data
        for (PM_Configure__c answer : answersToUpdate) {
            String reportingContactId = answer.Reporting_Contact__c;
            if (feedbackMap.containsKey(reportingContactId)) {
                answer.Consider_Feedback_Rating__c = feedbackMap.get(reportingContactId);
            }
            
            if (reasonMap.containsKey(reportingContactId)) {
                answer.Not_Consider_Feedback_Reason__c = reasonMap.get(reportingContactId);
            }
        }
        
        // Perform bulk DML update
        if (!answersToUpdate.isEmpty()) {
            update answersToUpdate;
            System.debug('Updated PM_Configure__c Records: ' + answersToUpdate);
        }
        //--------------------------------------------------------------------------
        if(completekra){
            
            Goal__c goalRecord = [SELECT Id, Type__c, RecordTypeId, Status__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,Resource__c
                                  FROM Goal__c 
                                  WHERE Id=:kraid AND Status__c!='KRA Completed' Limit 1]; 
            goalRecord.Status__c='KRA Completed';
            update goalRecord;
            
            //unchecking project assignement 
            List<EMS_TM_Assignment__c> projectAssignmentList = [SELECT Id, EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,
                                                                EMS_TM_EmployeeName__c,Offshore_PM_Configure__c, Other_Resource_PM_Configure__c,
                                                                Onshore_PM_Configure__c,Other_PM_Configure__c
                                                                FROM EMS_TM_Assignment__c 
                                                                WHERE EMS_TM_EmployeeName__c = :goalRecord.Resource__c];
            for(EMS_TM_Assignment__c projectass:projectAssignmentList){
                if (projectass.Offshore_PM_Configure__c ==true) {
                    projectass.Offshore_PM_Configure__c = false;  
                }
                
                if (projectass.Onshore_PM_Configure__c == true) {
                    projectass.Onshore_PM_Configure__c = false;  
                }
                
                if (projectass.Other_PM_Configure__c ==true ) {
                    projectass.Other_PM_Configure__c = false; 
                    projectass.Other_Resource_PM_Configure__c = null;
                }
            }
            
            if(!projectAssignmentList.isEmpty()){
                update projectAssignmentList;
            }
            
            // updating status as Cancelled all Pm comfigure answers who still status Awaiting Response, Accepeted and Saved
            list<PM_Configure__c> pmAnswer =[Select Id,Status__c,KRA__c 
                                             from PM_Configure__c 
                                             WHERE KRA__c=:kraid AND (Status__c='Awaiting Response' OR Status__c='Accepted' OR Status__c='Saved')];
            for(PM_Configure__c pm:pmAnswer){
                pm.Status__c='Cancelled';   
            }    
            if(!pmAnswer.isEmpty()){
                update pmAnswer;
            }
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static viewAnswerWrapper getLoginAnswerdata(String kraid,String tab, Boolean viewonlymode) {
        
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        viewAnswerWrapper aw =new viewAnswerWrapper();
        Goal__c goalRecord = [SELECT Id, Type__c, RecordTypeId, Status__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,
                              Resource__r.ContactName__c ,Resource__r.Resource_Role__c,Resource__c 
                              FROM Goal__c 
                              WHERE Id=:kraid Limit 1];
        if(goalRecord.Mentor_KRA_submitted__c == true && tab =='My Team' && goalRecord.Status__c == 'KRA In Review' && viewonlymode==false){
            aw.submittedKRAbutton=true; //@sangharsh by making it true will show Complete KRA button on UI
        }
        if(tab =='My Metric'){
            aw.submittedKRAbutton=false;
        }       
        
        if(tab =='My Team'){
            if(viewonlymode==true || goalRecord.Status__c == 'KRA Completed' || goalRecord.Status__c =='HR KRA Completed' || goalRecord.Status__c == 'Missed'){
                aw.submittedRecords=false;
            }else{
                aw.submittedRecords=true;   //@sangharsh by making it true will show KRA Edit button on UI
            }
        }
        if(tab =='My Metric'){
            aw.submittedRecords=false;
        }
        if(goalRecord.Status__c == 'KRA Completed'){ //@SANGHARSH by making it true will show Note on overall view screen
            aw.overallViewScreenNote=true;
        }
        if(goalRecord.Status__c == 'KRA Completed' || goalRecord.Status__c == 'KRA In Review'){
            if(tab =='My Team'){
                aw.visiablecheckbox=true; //@sangharsh mentor and HR can we checkbox
            }
            if(tab =='My Metric'){
                aw.visiablecheckbox=false; //@sangharsh mentee it will disable
            }
        }
        aw.kraResourceId=goalRecord.Resource__c;
        return aw;
    }
    
    public class viewAnswerWrapper{
        //KRA Edit button variable -submittedRecords
        @AuraEnabled 
        public Boolean submittedRecords=false; //default making it false
        //Complete KRA button variable -submittedKRAbutton
        @AuraEnabled 
        public Boolean submittedKRAbutton=false;
        @AuraEnabled
        public Boolean overallViewScreenNote =false; 
        @AuraEnabled
        public Boolean visiablecheckbox=false; 
        @AuraEnabled 
        public string kraResourceId;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<QuestionWrapper> getPMConfigKRAFullDetails(String kraid, String tab) {
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
                         Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                         Reporting_Contact__r.Name,Project_Name__r.Name,Project_Name__c,Consider_Feedback_Rating__c,
                         Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name
                         FROM PM_Configure__r 
                         Where KRA__c =:kraid AND ((Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))
                                                   OR Mentor_Mentee__c =: loggedInUser.ContactId) ORDER BY Mentor_Mentee__c ASC NULLS LAST)
                        FROM PM_Configure__c 
                        Where RecordTypeId  = :QuestionRecordTypeId AND Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c]; 
            //OR Reporting_Contact__c=: loggedInUser.ContactId
        }
        if(tab=='My Metric'){
            System.debug('goalRecord.Mentor_KRA_submitted__c'+goalRecord.Mentor_KRA_submitted__c);
            if(goalRecord.Mentor_KRA_submitted__c==true){
                questions= [SELECT Id,Area__c, KRA__c,Resource_Role__c,Question__c,
                            (SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                             Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                             Reporting_Contact__r.Name,Project_Name__r.Name,Project_Name__c,Consider_Feedback_Rating__c,
                             Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name
                             FROM PM_Configure__r Where KRA__c =:kraid AND ( Mentor_Mentee__c =: loggedInUser.ContactId OR (Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))) ORDER BY Mentor_Mentee__c ASC NULLS LAST)
                            FROM PM_Configure__c 
                            Where RecordTypeId  = :QuestionRecordTypeId AND Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c];   
            }else{
                questions= [SELECT Id,Area__c, KRA__c,Resource_Role__c,Question__c,
                            (SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                             Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                             Reporting_Contact__r.Name,Project_Name__r.Name,Project_Name__c,Consider_Feedback_Rating__c,
                             Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name
                             FROM PM_Configure__r Where KRA__c =:kraid AND Mentor_Mentee__c =: loggedInUser.ContactId ORDER BY Mentor_Mentee__c ASC NULLS LAST)
                            FROM PM_Configure__c 
                            Where RecordTypeId  = :QuestionRecordTypeId AND Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c];
            }
        } 
        
        // Loop through questions to construct the wrapper
        for (PM_Configure__c question : questions) {                                  
            Map<String, List<AnswerWrapper>> roleToAnswersMap = new Map<String, List<AnswerWrapper>>();
            List<String> answerIdlst =New List<String>();
            
            for (PM_Configure__c answer : question.PM_Configure__r) {  
                String contactKey;
                if(answer.Mentor_Mentee__c!=null){
                    contactKey = answer.Mentor_Mentee__c;
                }else{
                    contactKey =answer.Reporting_Contact__c+'&'+answer.Project_Name__c;
                }
                
                if (!roleToAnswersMap.containsKey(contactKey)) {
                    roleToAnswersMap.put(contactKey, new List<AnswerWrapper>());
                }
                
                // Create an AnswerWrapper instance and set properties individually
                AnswerWrapper awn = new AnswerWrapper();
                awn.answerId = answer.Id;
                awn.answerValue = (answer.Description__c!=null ||answer.Description__c!='')?answer.Description__c:' ';
                awn.Ratingoverview = answer.Related_Question__r.Rating_overview__c;
                awn.Descriptionoverview = answer.Related_Question__r.Question_overview__c;
                awn.rating = answer.Rating__c!=null?answer.Rating__c:null;
                awn.contactId = contactKey;
                awn.ConsiderFeedbackRating = answer.Consider_Feedback_Rating__c;
                awn.ProjectName =answer.Project_Name__c!=null? '('+answer.Project_Name__r.Name+')':' ';
                awn.contactName = answer.Mentor_Mentee__c!=null?answer.Mentor_Mentee__r.Name:answer.Reporting_Contact__r.Name;
                awn.resourceRole =answer.Mentor_Mentee__c!=null?answer.Mentor_Mentee__r.Resource_Role__r.Name:answer.Reporting_Contact__r.Resource_Role__r.Name;
                
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
        public String contactId;
        @AuraEnabled
        public String contactName;
        @AuraEnabled
        public String ProjectName;
        @AuraEnabled
        public String resourceRole;
        @AuraEnabled
        public Decimal averageRating;
        @AuraEnabled
        public Integer ratingCount;
        @AuraEnabled
        Public boolean ConsiderFeedbackRating;
        
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