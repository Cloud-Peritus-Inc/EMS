/**
* @author CloudPeritus Inc
* @date 31/07/2024
* @description  
* @test class CalculateFullQuarterlyKRATEST
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           SANGHARSH KAMBLE        controller of KRA View and calculating and returning overall rating
* ====================================================================================================
**/
public without sharing class CalculateFullQuarterlyKRA {
    
   /* @AuraEnabled(cacheable=true)
    public static boolean updateconsideringCheckbox(String kraid, String contactId, boolean isChecked ){
        try { 
            String reportingContactId;
            String projectId;
            
            if (contactId != null && contactId.contains('&')) {
                List<String> parts = contactId.split('&');
                if (parts.size() == 2) {
                    reportingContactId = parts[0];
                    projectId = parts[1];
                }
            }
            Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
            List<PM_Configure__c> answers = [SELECT Id,Consider_Feedback_Rating__c,Reporting_Contact__r.Resource_Role__r.Name,Project_Name__c
                                             FROM PM_Configure__c 
                                             Where KRA__c =:kraid AND RecordTypeId  = :AnswerRecordTypeId AND Reporting_Contact__c =:reportingContactId
                                             and Project_Name__c=:projectId];           
            List<PM_Configure__c> newanswers= new List<PM_Configure__c>(); 
            if(!answers.isEmpty()){
                for(PM_Configure__c answer: answers){
                    answer.Consider_Feedback_Rating__c = isChecked;
                    newanswers.add(answer);
                }
                update newanswers;
            }
            // updatePmConfigure( kraid,  reportingContactId,projectId,  isChecked);
            return true;        
        }catch (Exception e) {
            // Handle errors
            System.debug('Error in updateFeedbackRating: ' + e.getMessage());
            throw new AuraHandledException('Failed to update feedback ratings. ' + e.getMessage());
        }
    }*/
    
    /*@future    
public static void updatePmConfigure(String kraid,String reportingContactId,String projectId, Boolean isChecked){
Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
List<PM_Configure__c> answers = [SELECT Id,Consider_Feedback_Rating__c,Reporting_Contact__r.Resource_Role__r.Name,Project_Name__c
FROM PM_Configure__c 
Where KRA__c =:kraid AND RecordTypeId  = :AnswerRecordTypeId AND Reporting_Contact__c =:reportingContactId
and Project_Name__c=:projectId];           

if(!answers.isEmpty()){
for(PM_Configure__c answer: answers){
answer.Consider_Feedback_Rating__c = isChecked;
}
update answers;
}
}*/
    
    @AuraEnabled(cacheable=true)
    public static void updateFeedbackRating(String kraid, String contactData) {
        updatePmConfigure( kraid,  contactData);
    }
    
    @future    
    public static void updatePmConfigure(String kraid, String contactData){
        // Deserialize the input data
        Object deserializedData = JSON.deserializeUntyped(contactData);
        
        // Validate that the data is a list
        if (!(deserializedData instanceof List<Object>)) {
            throw new AuraHandledException('Invalid data format. Expected a list of contacts.');
        }
        
        // Convert to a list of maps
        List<Object> contactListGeneric = (List<Object>) deserializedData;
        List<Map<String, Object>> contactList = new List<Map<String, Object>>();
        
        for (Object contactObj : contactListGeneric) {
            if (!(contactObj instanceof Map<String, Object>)) {
                throw new AuraHandledException('Invalid data format. Each contact should be a map.');
            }
            contactList.add((Map<String, Object>) contactObj);
        }
        
        System.debug('Contact List: ' + contactList);
        
        // Get RecordTypeId for 'Answer'
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        // Prepare to collect data for querying and updating
        Set<String> contactIds = new Set<String>();
        Map<String, Boolean> feedbackMap = new Map<String, Boolean>();
        
        // Extract contact IDs and feedback ratings
        for (Map<String, Object> contact : contactList) {
            if (contact.containsKey('contactId') && contact.containsKey('ConsiderFeedbackRating')) {
                String fullContactId = (String) contact.get('contactId');
                String contactId = fullContactId.split('&')[0];
                contactIds.add(contactId);
                feedbackMap.put(contactId, (Boolean) contact.get('ConsiderFeedbackRating'));
            }
        }
        
        System.debug('Extracted Contact IDs: ' + contactIds);
        System.debug('Feedback Map: ' + feedbackMap);
        
        // Query all relevant PM_Configure__c records
        List<PM_Configure__c> answersToUpdate = [
            SELECT Id, Consider_Feedback_Rating__c, Reporting_Contact__c
            FROM PM_Configure__c
            WHERE KRA__c = :kraid
            AND RecordTypeId = :answerRecordTypeId
            AND Reporting_Contact__c IN :contactIds
        ];
        
        // Update feedback ratings based on input map
        for (PM_Configure__c answer : answersToUpdate) {
            if (feedbackMap.containsKey(answer.Reporting_Contact__c)) {
                answer.Consider_Feedback_Rating__c = feedbackMap.get(answer.Reporting_Contact__c);
            }
        }
        
        // Perform bulk DML update
        if (!answersToUpdate.isEmpty()) {
            update answersToUpdate; // Single DML for all records
            System.debug('Updated PM_Configure__c records: ' + answersToUpdate);
        }
        //--------------------------------------------------------------------------
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
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<AreaWrapper> calculateAverageRatingForKRA(String kraid, String tab ){
        List<AreaWrapper> AreaWrapperlst = new List<AreaWrapper>();
        //get recordtypeId
        Id QuestionRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        User loggedInUser = [SELECT Id,ContactId,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];
        
        Goal__c goalRecord = [SELECT Id, Type__c, RecordTypeId, Status__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,
                              Resource__r.ContactName__c ,Resource__r.Resource_Role__c 
                              FROM Goal__c 
                              WHERE Id=:kraid Limit 1];
        
        Resource_Role__c kraResourceRole = [ Select id,name,technical_acumen__c, professional_skills__c, goals_and_results__c, strategic_impact__c 
                                            from Resource_Role__c 
                                            where Id =: goalRecord.Resource__r.Resource_Role__c LIMIT 1];
        
        List<PM_Configure__c> answers = new List<PM_Configure__c>();
        if(tab=='My Team'){
            answers= [SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                      Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                      Reporting_Contact__r.Name,Related_Question__r.Area__c,Project_Name__c,Project_Name__r.Name,
                      Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name,Consider_Feedback_Rating__c
                      FROM PM_Configure__c 
                      Where KRA__c =:kraid AND RecordTypeId  = :AnswerRecordTypeId 
                      AND Related_Question__r.Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c 
                      AND (Mentor_Mentee__c =: loggedInUser.ContactId OR 
                           (Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))) ]; 
            //OR Reporting_Contact__c=: loggedInUser.ContactId
        }
        if(tab=='My Metric'){
            if(goalRecord.Mentor_KRA_submitted__c==true){
                answers= [SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                          Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                          Reporting_Contact__r.Name,Related_Question__r.Area__c,Project_Name__c,Project_Name__r.Name,
                          Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name,Consider_Feedback_Rating__c
                          FROM PM_Configure__c Where KRA__c =:kraid AND RecordTypeId  = :AnswerRecordTypeId 
                          AND Related_Question__r.Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c 
                          AND ( Mentor_Mentee__c =: loggedInUser.ContactId
                               OR (Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))) ];
            }else{
                answers= [SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                          Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                          Reporting_Contact__r.Name,Related_Question__r.Area__c,Project_Name__c,Project_Name__r.Name,
                          Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name,Consider_Feedback_Rating__c
                          FROM PM_Configure__c Where KRA__c =:kraid AND RecordTypeId  = :AnswerRecordTypeId
                          AND Related_Question__r.Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c 
                          AND Mentor_Mentee__c =: loggedInUser.ContactId];
            }
        }
        
        // Map to hold aggregated results
        Map<String, Map<String, AnswerWrapper>> areaToContactMap = new Map<String, Map<String, AnswerWrapper>>();
        
        for (PM_Configure__c pmAns : answers) {
            String contactKey;
            if(pmAns.Mentor_Mentee__c!=null){
                contactKey = pmAns.Mentor_Mentee__c;
            }else{
                contactKey =pmAns.Reporting_Contact__c+'&'+pmAns.Project_Name__c;
            }
            String area = pmAns.Related_Question__r.Area__c;
            System.debug('area-->'+area);
            if (!areaToContactMap.containsKey(area)) {
                areaToContactMap.put(area, new Map<String, AnswerWrapper>());
            }
            if (!areaToContactMap.get(area).containsKey(contactKey)) {
                areaToContactMap.get(area).put(contactKey, new AnswerWrapper(0, 0));
            }
            
            AnswerWrapper answerWrapper = areaToContactMap.get(area).get(contactKey);
            answerWrapper.contactId = contactKey;
            answerWrapper.contactname = pmAns.Mentor_Mentee__c != null ? pmAns.Mentor_Mentee__r.Name : pmAns.Reporting_Contact__r.Name;
            answerWrapper.ProjectName =pmAns.Project_Name__c!=null? '('+pmAns.Project_Name__r.Name+')':null;
            answerWrapper.resourceRole=pmAns.Mentor_Mentee__c!=null?pmAns.Mentor_Mentee__r.Resource_Role__r.Name:pmAns.Reporting_Contact__r.Resource_Role__r.Name;
            answerWrapper.ConsiderFeedbackRating= pmAns.Consider_Feedback_Rating__c;
            answerWrapper.averageRating += pmAns.Rating__c != null?pmAns.Rating__c:0;
            answerWrapper.ratingCount += 1;
        }
        
        // Calculate average ratings
        for (String area : areaToContactMap.keySet()) {
            Map<String, List<AnswerWrapper>> answerscalculation = new Map<String, List<AnswerWrapper>>();
            Decimal areapercentage = 0;
            
            for (String contactKey : areaToContactMap.get(area).keySet()) {
                AnswerWrapper answerWrapper = areaToContactMap.get(area).get(contactKey);
                if (answerWrapper.ratingCount > 0) {
                    answerWrapper.averageRating= (answerWrapper.averageRating / answerWrapper.ratingCount).setScale(2, RoundingMode.FLOOR);
                }else{
                    answerWrapper.averageRating= answerWrapper.averageRating.setScale(2, RoundingMode.FLOOR);
                }
                if(area=='TECHNICAL SKILLS'){
                    areapercentage = kraResourceRole.technical_acumen__c;
                    system.debug('kraResourceRole.technical_acumen__c'+kraResourceRole.technical_acumen__c);
                    answerWrapper.AvgRatingSkillForResource=  ((answerWrapper.averageRating * kraResourceRole.technical_acumen__c)/100).setScale(2, RoundingMode.FLOOR);
                } else if (area == 'PROFESSIONAL SKILLS') {
                    areapercentage = kraResourceRole.professional_skills__c;
                    system.debug('kraResourceRole.professional_skills__c'+kraResourceRole.professional_skills__c);
                    answerWrapper.AvgRatingSkillForResource=  ((answerWrapper.averageRating * kraResourceRole.professional_skills__c)/100).setScale(2, RoundingMode.FLOOR);           
                } else if (area == 'STRATEGIC IMPACT') {
                    areapercentage = kraResourceRole.strategic_impact__c;
                    answerWrapper.AvgRatingSkillForResource=  ((answerWrapper.averageRating * kraResourceRole.strategic_impact__c)/100).setScale(2, RoundingMode.FLOOR);
                } else if (area == 'GOALS AND RESULTS') {
                    areapercentage = kraResourceRole.goals_and_results__c;
                    answerWrapper.AvgRatingSkillForResource=  ((answerWrapper.averageRating *  kraResourceRole.goals_and_results__c)/100).setScale(2, RoundingMode.FLOOR);   
                }
                
                if (!answerscalculation.containsKey(contactKey)) {
                    answerscalculation.put(contactKey, new List<AnswerWrapper>());
                }
                answerscalculation.get(contactKey).add(answerWrapper);
            }
            AreaWrapperlst.add(new AreaWrapper(area,areapercentage, answerscalculation));
        }
        System.debug('AreaWrapperlst-->'+AreaWrapperlst);
        return AreaWrapperlst;
    }
    
    // Wrapper class for Question
    public class AreaWrapper {
        @AuraEnabled
        public String area;
        @AuraEnabled
        public Decimal areapercentage;
        @AuraEnabled
        public Map<String, List<AnswerWrapper>> answerscalculation; // Map of Contact Id to List of Answers
        
        public AreaWrapper(String area, Decimal areapercentage, Map<String, List<AnswerWrapper>> answerscalculation) {
            this.area = area;
            this.areapercentage =areapercentage;
            this.answerscalculation = answerscalculation;
        }
    }
    
    // Wrapper class for Answer
    public class AnswerWrapper {
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String contactname;
        @AuraEnabled
        public String ProjectName;
        @AuraEnabled
        public String resourceRole;
        @AuraEnabled
        public Boolean ConsiderFeedbackRating;
        @AuraEnabled
        public Decimal averageRating;
        @AuraEnabled
        public Integer ratingCount=0;
        @AuraEnabled
        public Decimal AvgRatingSkillForResource;
        
        public AnswerWrapper() {}
        
        public AnswerWrapper(Decimal averageRating, Integer ratingCount) {
            this.averageRating = averageRating;
            this.ratingCount = ratingCount;
        }
        
        public AnswerWrapper(Decimal averageRating, Integer ratingCount, String contactId, String contactname) {
            this.averageRating = averageRating;
            this.ratingCount = ratingCount;
            this.contactId = contactId;
            this.contactname = contactname;
        }
    }
}