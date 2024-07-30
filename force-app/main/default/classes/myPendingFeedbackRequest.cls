/**
* @author Ravitheja
* @date 05/07/2024
* @description the apex class has been implemented for the goalDatable LWC.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/


public without sharing class myPendingFeedbackRequest {

    public static final String PM_ANSWER_REJECTED = 'Rejected';
    public static final String PM_ANSWER_AWAITING = 'Awaiting Response';
    public static final String PM_ANSWER_SUBMITTED = 'Submitted'; 
    public static final String PM_ANSWER_ACCEPTED = 'Accepted';
    public static final Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

    @AuraEnabled
    public static List<goalWrapper> getKRARecordsOfContact() {
        
        try {
            User us = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Id contactId = us.ContactId;

            List<goalWrapper> goalWrapperList = new List<goalWrapper>();
            Set<Id> kraIdSet = new Set<Id>();
            Map<Id, String> kraToProjectNameMap = new Map<Id, String>();
            Map<String, EMS_TM_Assignment__c> projectVsResourceMap = new Map<String, EMS_TM_Assignment__c>();
            Map<Id, Id> kraVsProjectNameMap = new Map<Id, Id>();
            
            List<PM_Configure__c> pmConfigAnswerList = [SELECT Id
                                                                , KRA__c
                                                                , Reporting_Contact__c
                                                                ,Project_Name__r.Name
                                                                ,Mentee__c
                                                                ,Project_Name__c
                                                        FROM PM_Configure__c
                                                        WHERE RecordTypeId = :AnswerRecordTypeId 
                                                        AND KRA__c != NULL 
                                                        AND Reporting_Contact__c != NULL
                                                        AND Reporting_Contact__c = :contactId
                                                        AND (status__c = :PM_ANSWER_AWAITING OR status__c = :PM_ANSWER_ACCEPTED)                
            ];
           
            if (!pmConfigAnswerList.isEmpty()) {
                
                for (PM_Configure__c pmConfig : pmConfigAnswerList) {
                    kraIdSet.add(pmConfig.KRA__c);
                    kraToProjectNameMap.put(pmConfig.KRA__c,pmConfig.Project_Name__r.Name);
                    kraVsProjectNameMap.put(pmConfig.KRA__c,pmConfig.Project_Name__c);
                }
            }
             
            List<Goal__c> glList = [SELECT Id, Name, Goal_Name__c,Start_Date__c,End_Date__c, Resource__c, Resource__r.EMS_TM_User__r.CommunityNickname,
                (Select Id, Name, status__c, CreatedById, CreatedBy.CommunityNickname from PM_Answer_Configure__r where RecordTypeId = :AnswerRecordTypeId AND OwnerId =: us.Id)
                FROM Goal__c 
                WHERE Id IN :kraIdSet
            ];
            
            List<EMS_TM_Assignment__c> projectassignmentList = [SELECT Id
                                                            		   ,EMS_TM_ProjectName_Asgn__c
                                                                       ,EMS_TM_EmployeeName__c
                                                                       ,EMS_TM_StartDate_Asgn__c
                                                                       ,EMS_TM_EndDate_Asgn__c
                                                                FROM EMS_TM_Assignment__c                                                       
            ];
            
            if(!projectassignmentList.isEmpty()){
                for (EMS_TM_Assignment__c assignment : projectassignmentList) {
                    projectVsResourceMap.put(assignment.EMS_TM_ProjectName_Asgn__c + '|' + assignment.EMS_TM_EmployeeName__c, assignment);
                }
            }
            

            for (Goal__c glwarp : glList) {  
                goalWrapper glwp = new goalWrapper();
                glwp.hideEditBtn = true; 
                glwp.hideAcceptBtn = true;
                glwp.hideRejectBtn = true;
                
                for (PM_Configure__c goalAnswer : glwarp.PM_Answer_Configure__r) {  
                    if (goalAnswer.Status__c == PM_ANSWER_AWAITING) {
                        glwp.hideAcceptBtn = false;
                        glwp.hideRejectBtn = false;
                        glwp.requestedBy = goalAnswer.CreatedById;
                        glwp.requestedByName = goalAnswer.CreatedBy.CommunityNickname;
                    } else if (goalAnswer.Status__c == PM_ANSWER_ACCEPTED) {
                        glwp.hideEditBtn = false;
                        glwp.hideAcceptBtn = true;
                        glwp.hideRejectBtn = true;
                        glwp.requestedBy = goalAnswer.CreatedById;
                        glwp.requestedByName = goalAnswer.CreatedBy.CommunityNickname;
                    }
                }
                
                glwp.ProjectName = kraToProjectNameMap.get(glwarp.Id);
                glwp.goalName = glwarp.Goal_Name__c;
                glwp.resource = glwarp.Resource__c;
                
                String assignmentKey = kraVsProjectNameMap.get(glwarp.Id) + '|' + glwp.resource;
                if (projectVsResourceMap.containsKey(assignmentKey)) {
                    EMS_TM_Assignment__c assignment = projectVsResourceMap.get(assignmentKey);
                    glwp.startDate = assignment.EMS_TM_StartDate_Asgn__c;
                    glwp.endDate = assignment.EMS_TM_EndDate_Asgn__c;
                }
                
                glwp.resourceName = glwarp.Resource__r.EMS_TM_User__r.CommunityNickname;
                glwp.Id = glwarp.Id;
                goalWrapperList.add(glwp);
                
            }
            return goalWrapperList;
             
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while fetching KRA records: ' + e.getMessage());
        }
    }  
    
    @AuraEnabled
    public static List<goalWrapper> updatePMConfigureRecord(Id goalId, String actionType, String rejectionReason) {
        try {
            User us = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Id contactId = us.ContactId;
            
            List<PM_Configure__c> pmConfigureRecords = [
                SELECT Id, Status__c
                FROM PM_Configure__c
                WHERE KRA__c = :goalId
                AND RecordTypeId = :AnswerRecordTypeId
                AND Reporting_Contact__c != NULL
                AND Reporting_Contact__c = :contactId
            ];
            
            for (PM_Configure__c pmconfig : pmConfigureRecords) {
                if (actionType == 'accept') {
                    pmconfig.Status__c = PM_ANSWER_ACCEPTED;
                } else if (actionType == 'reject') {
                    pmconfig.Status__c = PM_ANSWER_REJECTED;
                    pmconfig.Rejection_Cancellation_Reason__c = rejectionReason;
                }
            }
            
            update pmConfigureRecords;
            return myPendingFeedbackRequest.getKRARecordsOfContact();
        } catch (Exception e) {
            throw new AuraHandledException('Failed to Update PM Configure records ' + e.getMessage());
        }
    }

    public class goalWrapper {
        @AuraEnabled
        public String goalName;

        @AuraEnabled
        public Date startDate;

        @AuraEnabled
        public Date endDate;

        @AuraEnabled
        public String resource;

        @AuraEnabled
        public String resourceName;

        @AuraEnabled
        public String requestedBy;

        @AuraEnabled
        public String requestedByName;

        @AuraEnabled
        public String Id;

        @AuraEnabled
        public String ProjectName;

        @AuraEnabled
        public Boolean hideEditBtn;

        @AuraEnabled
        public Boolean hideRejectBtn ;

        @AuraEnabled
        public Boolean hideAcceptBtn ;
    }
}