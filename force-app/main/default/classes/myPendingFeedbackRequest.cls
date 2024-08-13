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
    public static final String PM_ANSWER_ACCEPTED = 'Accepted';
    public static final String PM_ANSWER_SAVED = 'Saved';
    public static final String PM_KRA_IN_PROGRESS = 'In Progress';
    
    public static final Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

    @AuraEnabled
    public static List<goalWrapper> getKRARecordsOfContact() {
        try {
            User us = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Id contactId = us.ContactId;
            
            List<goalWrapper> goalWrapperList = new List<goalWrapper>();
            Set<Id> kraIdSet = new Set<Id>();
            Map<Id, List<PM_Configure__c>> kraToPmConfigMap = new Map<Id, List<PM_Configure__c>>();
            Map<Id, Map<String, PM_Configure__c>> displayedRecordsMap = new Map<Id, Map<String, PM_Configure__c>>();
            //Map<Id, Id> goalIdToResourceIdMap = new Map<Id, Id>();
            //Map<Id, String> goalIdToResourceNameMap = new Map<Id, String>();
            Map<String, EMS_TM_Assignment__c> projectVsResourceMap = new Map<String, EMS_TM_Assignment__c>();
            Map<Id, Goal__c> goalStatusMap = new Map<Id, Goal__c>();
            
            List<PM_Configure__c> pmConfigAnswerList = [SELECT Id
                                                        ,KRA__c
                                                        ,KRA__r.Goal_Name__c
                                                        ,KRA__r.Resource__c
                                                        ,Reporting_Contact__c
                                                        ,Project_Name__c
                                                        ,Project_Name__r.Name
                                                        ,Mentee__c  
                                                        ,Status__c
                                                        ,CreatedById
                                                        ,CreatedBy.CommunityNickname
                                                        FROM PM_Configure__c
                                                        WHERE RecordTypeId = :AnswerRecordTypeId 
                                                        AND KRA__c != NULL 
                                                        AND Reporting_Contact__c != NULL
                                                        AND Reporting_Contact__c = :contactId
                                                        AND (status__c = :PM_ANSWER_AWAITING OR status__c = :PM_ANSWER_ACCEPTED OR status__c = :PM_ANSWER_SAVED)];
            
            if (!pmConfigAnswerList.isEmpty()) {
                for (PM_Configure__c pmConfig : pmConfigAnswerList) {
                    kraIdSet.add(pmConfig.KRA__c);
                    
                    if (!kraToPmConfigMap.containsKey(pmConfig.KRA__c)) {
                        kraToPmConfigMap.put(pmConfig.KRA__c, new List<PM_Configure__c>());
                    }
                    kraToPmConfigMap.get(pmConfig.KRA__c).add(pmConfig);
                    //goalIdToResourceIdMap.put(pmConfig.KRA__c, pmConfig.KRA__r.Resource__c);
            
                }
            }
            
            List<Goal__c> glList = [SELECT Id
                                   			,Resource__c
                                    		,Resource__r.Name
                                    		,Resource__r.EMS_TM_User__r.CommunityNickname
                                            ,Status__c
                                    FROM Goal__c
                                    WHERE Id IN : kraIdSet];
            
            for (Goal__c goal : glList) {
                goalStatusMap.put(goal.Id,goal);
                if (!displayedRecordsMap.containsKey(goal.Id)) {
                    displayedRecordsMap.put(goal.Id, new Map<String, PM_Configure__c>());
                    //goalIdToResourceNameMap.put(goal.Id,goal.Resource__r.Name);
                }
                
                List<PM_Configure__c> pmConfigs = kraToPmConfigMap.get(goal.Id);
                if (pmConfigs != null) {
                    for (PM_Configure__c pmConfig : pmConfigs) {
                        String projectKey = pmConfig.Project_Name__c;
                        if (!displayedRecordsMap.get(goal.Id).containsKey(projectKey)) {
                            displayedRecordsMap.get(goal.Id).put(projectKey, pmConfig);
                        }
                    }
                }
            }
            
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
            
            
            for (Id goalId : displayedRecordsMap.keySet()) {
                Goal__c gl = goalStatusMap.get(goalId);
                for (PM_Configure__c pmConfig : displayedRecordsMap.get(goalId).values()) {
                    goalWrapper gw = new goalWrapper();
                    gw.hideEditBtn = true; 
                	gw.hideAcceptBtn = true;
                	gw.hideRejectBtn = true;
                    if (pmConfig.Status__c == PM_ANSWER_AWAITING) {
                        gw.hideAcceptBtn = false;
                        gw.hideRejectBtn = false;
                        gw.requestedByName = pmConfig.CreatedBy.CommunityNickname;
                    } else if (pmConfig.Status__c == PM_ANSWER_ACCEPTED || pmConfig.Status__c == PM_ANSWER_SAVED) {
                        gw.hideEditBtn = false;
                        gw.hideAcceptBtn = true;
                        gw.hideRejectBtn = true;
                        gw.requestedByName = pmConfig.CreatedBy.CommunityNickname;
                    }
                    
                    gw.projectId = pmConfig.Project_Name__c;
                    gw.goalId = goalId;
                    gw.resource = gl.Resource__c; //goalIdToResourceIdMap.get(goalId);
                    gw.ProjectName = pmConfig.Project_Name__r.Name;
                    gw.goalName = pmConfig.KRA__r.Goal_Name__c;
                    gw.resourceName = gl.Resource__r.Name;//goalIdToResourceNameMap.get(goalId);
                    
                    String assignmentKey = pmConfig.Project_Name__c + '|' + gw.resource;
                    if (projectVsResourceMap.containsKey(assignmentKey)) {
                        EMS_TM_Assignment__c assignment = projectVsResourceMap.get(assignmentKey);
                        gw.startDate = assignment.EMS_TM_StartDate_Asgn__c;
                        gw.endDate = assignment.EMS_TM_EndDate_Asgn__c;
                    }
                    goalWrapperList.add(gw);
                }
            }
            
            return goalWrapperList;  
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while fetching KRA records: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<goalWrapper> updatePMConfigureRecord(Id projectId, Id goalId, Id resourceId, String actionType, String rejectionReason) {
        try {
            User us = [SELECT Id, Name, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            Id contactId = us.ContactId;
            
            List<PM_Configure__c> pmConfigureRecords = [
                SELECT Id, Status__c
                FROM PM_Configure__c
                WHERE Project_Name__c = :projectId
                AND RecordTypeId = :AnswerRecordTypeId
                AND Reporting_Contact__c != NULL
                AND Reporting_Contact__c = :contactId
                AND Status__c =: PM_ANSWER_AWAITING
                AND KRA__c =: goalId
                AND KRA__r.Resource__c =: resourceId
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
        public String projectId;
        
         @AuraEnabled
        public String goalId;

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