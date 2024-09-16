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
                      Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name
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
                          Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name
                          FROM PM_Configure__c Where KRA__c =:kraid AND RecordTypeId  = :AnswerRecordTypeId 
                          AND Related_Question__r.Resource_Role__c=: goalRecord.Resource__r.Resource_Role__c 
                          AND ( Mentor_Mentee__c =: loggedInUser.ContactId
                               OR (Status__c ='Submitted' AND (Reporting_Contact__c !=null OR Mentor_Mentee__c !=: loggedInUser.ContactId))) ];
            }else{
                answers= [SELECT Id, Description__c, Rating__c, Mentor_Mentee__c,Reporting_Contact__c,Related_Question__c,Status__c,
                          Related_Question__r.Rating_overview__c,Related_Question__r.Question_overview__c,Mentor_Mentee__r.Name,
                          Reporting_Contact__r.Name,Related_Question__r.Area__c,Project_Name__c,Project_Name__r.Name,
                          Mentor_Mentee__r.Resource_Role__r.Name,Reporting_Contact__r.Resource_Role__r.Name
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
            answerWrapper.ProjectName =pmAns.Project_Name__c!=null? '('+pmAns.Project_Name__r.Name+')':' ';
         	answerWrapper.resourceRole=pmAns.Mentor_Mentee__c!=null?pmAns.Mentor_Mentee__r.Resource_Role__r.Name:pmAns.Reporting_Contact__r.Resource_Role__r.Name;
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