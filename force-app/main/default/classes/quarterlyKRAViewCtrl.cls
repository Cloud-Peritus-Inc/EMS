/**
 * Apex class for fetching and updating GOAL__C (kraRecords) for Perfomance Management
 *
 * @author Shubham Maske
 * @date 23/10/2023
 */
public without sharing class quarterlyKRAViewCtrl {

    public static final String STATUS_KRA_INREVIEW = 'KRA Inreview';
    public static final String STATUS_KRA_COMPLETE = 'KRA Completed';

    @AuraEnabled(cacheable = true)
    public static Contact getCurrentUserConDetails() {
        String resourceRole = null;
        Contact con = new Contact();
        try {
                con = [SELECT Id, EMS_TM_User__c, EMS_TM_User__r.Profile.Name , Resource_Role__c, Resource_Role__r.Name,
                Resource_Role__r.technical_acumen__c,Resource_Role__r.goals_and_results__c,Resource_Role__r.professional_skills__c,Resource_Role__r.strategic_impact__c	 
                FROM Contact 
                WHERE EMS_TM_User__c = :UserInfo.getUserId() LIMIT 1];

            if (con != null && con.Resource_Role__r != null) {
                resourceRole = con.Resource_Role__r.Name;
            }
        } catch (QueryException qe) {
            // Log the exception or handle it appropriately
            throw new AuraHandledException('Error querying Contact: ' + qe.getMessage());
        } catch (Exception e) {
            // Log the exception or handle it appropriately
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }

        return con;
    }

    @AuraEnabled(cacheable = true)
    public static Contact getSelectedResourceConDetails(String selectedResourceId) {
        Contact con = new Contact();
        try {
            if (!String.isBlank(selectedResourceId)) {
                User loggedinUser = [SELECT Id,ContactId FROM User WHERE ContactId=:selectedResourceId];
            
                con = [SELECT Id, EMS_TM_User__c, EMS_TM_User__r.Profile.Name , Resource_Role__c, Resource_Role__r.Name,
                Resource_Role__r.technical_acumen__c,Resource_Role__r.goals_and_results__c,Resource_Role__r.professional_skills__c,Resource_Role__r.strategic_impact__c	 
                FROM Contact 
                WHERE EMS_TM_User__c = :loggedinUser.Id LIMIT 1];
            }
        } catch (QueryException qe) {
            // Log the exception or handle it appropriately
            throw new AuraHandledException('Error querying Contact: ' + qe.getMessage());
        } catch (Exception e) {
            // Log the exception or handle it appropriately
            throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
        }

        return con;
    }












    /**
     * This method returns the Goal__c record for displaying record values on the KRArecord edit/view action
     *
     * @param recordId : Goal__c record ID which needs to be fetched.
     * @return Goal__c record retrieved via SOQL
     * @throws AuraHandledException - If an exception occurs during the save operation, it is caught and rethrown as an AuraHandledException.
     */
    
    @AuraEnabled(cacheable = true)
    public static Goal__c fetchKRARecords(String recordId,String selectedresource) {
        System.debug(' # fetchKRARecords recordId' + recordId);
        System.debug(' # fetchKRARecords selectedresource' + selectedresource);
        try {

            Goal__c goal = [SELECT
                    Id, Name,Status__c,Review_Type__c, Reviewer_Name__c, Reviewer_Title__c, Date_of_Review__c,
                    Development_Rating__c,Development_Example__c,Testing_Rating__c,Testing_Example__c,Understanding_Code_Rating__c,
                    Understanding_Code_Example__c,Documentation_Rating__c,Documentation_Example__c,Continuous_Improvement_Rating__c,
                    Continuous_Improvement_Example__c,Platform_Knowledge_Rating__c,Platform_Knowledge_Example__c,Design_and_Architecture_Rating__c,
                    Design_and_Architecture_Example__c,Delivery_Accountability_Rating__c,Delivery_Accountability_Example__c,
                    Effective_Communication_Rating__c,Effective_Communication_Example__c,Knowledge_Sharing_Rating__c,Knowledge_Sharing_Example__c,
                    Teamwork_Rating__c,Teamwork_Example__c,Attitude_and_Behavior_Rating__c,Attitude_and_Behavior_Example__c,Business_Development_Rating__c,
                    Business_Development_Example__c,Strategic_Work_Rating__c,Strategic_Work_Example__c,Company_Growth_Rating__c,
                    Company_Growth_Example__c,
                    Overall_Tech_Rating__c,Overall_Professional_Rating__c,Overall_Strategic_Rating__c,Overall_Goals_Results_Rating__c,
                    Overall_Average_Section_Rating__c,
                    /* New Fields Created 16/11/23 */

                    Task_Management_Rating__c, Task_Management_Example__c,Risk_Management_Rating__c, Risk_Management_Example__c, 
                    Resource_Management_Rating__c, Resource_Management_Example__c,Stakeholder_Management_Rating__c, Stakeholder_Management_Example__c, 
                    Communication_Management_Rating__c, Communication_Management_Example__c, Estimations_Rating__c, Estimations_Example__c, 
                    Defect_Management_Rating__c, Defect_Management_Example__c, Requirement_Gathering_Rating__c, Requirement_Gathering_Example__c, 
                    Goal_Achievement_Rating__c, Goal_Achievement_Example__c, Stakeholder_Satisfaction_Rating__c, Stakeholder_Satisfaction_Example__c, 
                    Project_Success_Rating__c, Project_Success_Example__c, POV_Creation_Client_Demos_Rating__c, POV_Creation_Client_Demos_Example__c, 
                    Test_Case_Design_Execution_Rating__c, Test_Case_Design_Execution_Example__c,
                    Learning_and_Skill_Development_Rating__c, Learning_and_Skill_Development_Example__c,
                    Documentation_Reporting_Mgmt_Rating__c, Documentation_Reporting_Mgmt_Example__c, 
                    Project_Planning_Scheduling_Rating__c, Project_Planning_Scheduling_Example__c,
                    Troubleshooting_Environment_Prep_Rating__c, Troubleshooting_Environment_Prep_Example__c,

                    /*New Fields Created 05/02/24*/
                    Average_Tech_Rating__c, Average_Professional_Rating__c, Average_Strategic_Rating__c, Average_Goals_Results_Rating__c,
                    /*New Fields Created 26/12/23*/
                    Overall_Professional_Rating_2__c,Overall_Tech_Rating_2__c,Overall_Strategic_Rating_2__c,Overall_Goals_Results_Rating_2__c,
                    /*New Fields Added to Query for  [Defect : PM_040] */
                    Resource__c,Check_In_By__c
                    FROM Goal__c WHERE Id = :recordId LIMIT 1];
					System.debug('goal' +goal);
                return getReviewerDetails(goal, selectedresource);
        } catch (Exception e) {
            System.debug(' # fetchKRARecords error : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }

    /**
     * This method returns the Goal__c record for displaying record values on the KRArecord edit/view action by prepopulating field values from 
     * Resource_Resource_Relationship__c object field values 
     *
     * @param recordId : Goal__c record whose fields to be prepopulated.
     * @return Goal__c record retrieved via SOQL
     * @throws AuraHandledException - If an exception occurs during the save operation, it is caught and rethrown as an AuraHandledException.
     */
    @AuraEnabled(cacheable = true)
    public static Goal__c getReviewerDetails(Goal__c goal, String selectedresource) {
        try {

            if (String.isNotBlank(selectedresource) && selectedresource != null) {
                System.debug('Line 139');
                Resource_Resource_Relationship__c rrrRecord = [Select Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource_Role__c,Resource__c,Relationship_Type__c,
                Reports_To_Role__c
                FROM Resource_Resource_Relationship__c
                WHERE (Resource__c =:selectedresource AND Relationship_Type__c includes ('Mentor') AND Resource_Reports_To__c != NULL) ];
                System.debug('rrrRecord1' +rrrRecord);
                if(rrrRecord != null){
                    goal.Review_Type__c = 'Mentor Review';
                    goal.Reviewer_Name__c = rrrRecord.Resource_Reports_To__r.Name;
                    goal.Reviewer_Title__c = rrrRecord.Reports_To_Role__c;
                    goal.Date_of_Review__c = System.today();
                }
                return goal;
            }else{
				System.debug('Line 153');
                User loggedinUser = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
				System.debug('loggedinUser' +loggedinUser);
                Resource_Resource_Relationship__c rrrRecord = [Select Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource_Role__c,Resource__c,Relationship_Type__c,
                Reports_To_Role__c
                FROM Resource_Resource_Relationship__c
                WHERE (Resource__c =:loggedinUser.ContactId AND Relationship_Type__c includes ('Mentor') AND Resource_Reports_To__c != NULL) ];
                System.debug('rrrRecord2' +rrrRecord);
                if(rrrRecord != null){
                    goal.Review_Type__c = 'Mentor Review';
                    goal.Reviewer_Name__c = rrrRecord.Resource_Reports_To__r.Name;
                    goal.Reviewer_Title__c = rrrRecord.Reports_To_Role__c;
                    goal.Date_of_Review__c = System.today();
                }
                return goal;
            }

        } catch (Exception e) { 
            System.debug(' error : ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    /**
     * This method is used to save a Goal__c record, typically used for Key Result Areas (KRA) records.
     * @param kraRecord - The Goal__c record to be saved.
     * @return - The saved Goal__c record.
     * @throws AuraHandledException - If an exception occurs during the save operation, it is caught and rethrown as an AuraHandledException.
     */
    @AuraEnabled
    public static Goal__c saveKraRecord( Goal__c kraRecord){
        try {
            System.debug('kraRecord Record Detail : :' + kraRecord);
            //smaske : Not updating Status for [Defect : PM_040]
            /*
            As whenever the the KRA record is created default status is "Active"
            Hence on SAVE btn click not updating the status ,as Status will change on SUBMIT btn.
            This will work for both MENTOR AND MENTEE.
            */
            //kraRecord.Status__c = STATUS_KRA_INREVIEW;
            Update kraRecord;
            return kraRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Goal__c submitKraRecord( Goal__c kraRecord){
        try {
            System.debug('submitKraRecord Record Detail : :' + kraRecord.Resource__c);
            //smaske: Updating Status conditionally for [Defect : PM_040]
            /*
            1) When mentee SUBMIT the KRA, Status will change to "KRA Inreview" as he will submit his KRA to his mentor for review.
            2) When Mentor SUBMIT the KRA, Status will change to "KRA Complete: as he will Complete KRA review from his end and submit the KRA as a Final Action.
            */

            Contact con = [SELECT Id, EMS_TM_User__c, EMS_TM_User__r.Profile.Name FROM Contact WHERE EMS_TM_User__c = :UserInfo.getUserId() LIMIT 1];
            System.debug('con Record Detail : :' + con.Id);
            if (kraRecord.Resource__c == con.Id) {
                System.debug('IN 208');
                kraRecord.Status__c = STATUS_KRA_INREVIEW;
            }else {
                System.debug('IN 211');
                kraRecord.Status__c = STATUS_KRA_COMPLETE;
            }

            Update kraRecord;
            return kraRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static KraVisiableWrapper getGridConfigurationKRAData(String krarecordId) {
        String resourceRoleId = '';
        System.debug('#getGridConfigurationKRAData');
        if(String.isEmpty(krarecordId)){
             User loggedInUser = [SELECT Id,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];
             resourceRoleId = loggedInUser.Contact.Resource_Role__c;
             System.debug('#IF ' + resourceRoleId);
        }else{
            resourceRoleId = [SELECT Resource__r.Resource_Role__c FROM Goal__c WHERE Id=:krarecordId].Resource__r.Resource_Role__c;
            System.debug('#ELSE ' + resourceRoleId);
        }
        
        KraVisiableWrapper returnWrap = new KraVisiableWrapper();
        returnWrap.showDevelopment = false;
        returnWrap.showTesting = false;
        returnWrap.showUnderstandingCode = false;
        returnWrap.showPlatformKnowledge = false;

        returnWrap.showDesignArchitecture = false;
        returnWrap.showDocumentation = false;
        returnWrap.showContinuousImprovement = false;

        returnWrap.showRequirementGathering = false;

        returnWrap.showPOVCreationDemos = false;
        returnWrap.showProjectPlanningSchedulingManagement = false;
        returnWrap.showTaskManagement = false;
        returnWrap.showRiskManagement = false;

        returnWrap.showResourceManagement = false;
        returnWrap.showStakeholderManagement = false;
        returnWrap.showCommunicationManagement = false;
        returnWrap.showDocumentationReportingManagement = false;

        returnWrap.showEstimations = false;
        returnWrap.showTestCaseDesignExecution = false;
        returnWrap.showDefectManagement = false;
        returnWrap.showTroubleshootingAndEnvironmentPrep = false;
        returnWrap.showLearningAndSkillDevelopment = false;

        /* PROFESSIONAL SKILLS */
        returnWrap.showDeliveryAccountability = false;
        returnWrap.showEffectiveCommunication = false;
        returnWrap.showKnowledgeSharing = false;
        returnWrap.showTeamwork = false;
        returnWrap.showAttitudeBehavior = false;
        /* PROFESSIONAL SKILLS */

        /* STRATEGIC IMPACT */
        returnWrap.showBusinessDevelopment = false;
        returnWrap.showStrategicWork = false;
        returnWrap.showCompanyGrowth = false;
        /* STRATEGIC IMPACT */

        /* GOALS AND RESULTS */
        returnWrap.showGoalAchievement = false;
        returnWrap.showStakeholderSatisfaction = false;
        returnWrap.showProjectSuccess = false;
        /* GOALS AND RESULTS */
       

        
        for(Grid_Configuration__c gc : [SELECT Id,KRA_Competency__c,KRA_Competency_Overview__c,KRA_Competency_Example__c FROM Grid_Configuration__c WHERE Grid_Configuration_Type__c = 'KRA' and Resource_Role__c=:resourceRoleId and KRA_Competency__c!=null]){
            System.debug('#FOR GC ' + gc);
            if(gc.KRA_Competency__c == 'Development'){
               returnWrap.showDevelopment = true;
               returnWrap.developmentRtngTxt = gc.KRA_Competency_Overview__c; 
			   returnWrap.developmentExTxt = gc.KRA_Competency_Example__c;
               //break;
            }else if(gc.KRA_Competency__c == 'Testing'){
               returnWrap.showTesting = true;
               returnWrap.testingRtngTxt = gc.KRA_Competency_Overview__c;
			   returnWrap.testingExTxt = gc.KRA_Competency_Example__c;
               //break; 
            }else if(gc.KRA_Competency__c == 'Understanding Code'){
               returnWrap.showUnderstandingCode = true;
               returnWrap.understandingCodeRtngTxt = gc.KRA_Competency_Overview__c;
			   returnWrap.understandingCodeExTxt = gc.KRA_Competency_Example__c;
               //break;  
            }else if(gc.KRA_Competency__c == 'Platform Knowledge'){
               returnWrap.showPlatformKnowledge = true;
               returnWrap.platformKnowledgeRtngTxt = gc.KRA_Competency_Overview__c;
			   returnWrap.platformKnowledgeExTxt = gc.KRA_Competency_Example__c;
               //break;
            }else if(gc.KRA_Competency__c == 'Design and Architecture'){
                returnWrap.showDesignArchitecture = true;
                returnWrap.designArchitectureRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.designArchitectureExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Documentation'){
                returnWrap.showDocumentation = true;
                returnWrap.documentationRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.documentationExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Continuous Improvement'){
                returnWrap.showContinuousImprovement = true;
                returnWrap.continuousImprovementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.continuousImprovementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Delivery Accountability'){
                returnWrap.showDeliveryAccountability = true;
                returnWrap.deliveryAccountabilityRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.deliveryAccountabilityExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Effective Communication'){
                returnWrap.showEffectiveCommunication = true;
                returnWrap.effectiveCommunicationRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.effectiveCommunicationExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Knowledge Sharing'){
                returnWrap.showKnowledgeSharing = true;
                returnWrap.knowledgeSharingRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.knowledgeSharingExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Teamwork'){
                returnWrap.showTeamwork = true;
                returnWrap.teamworkRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.teamworkExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Attitude and Behavior'){
                returnWrap.showAttitudeBehavior = true;
                returnWrap.attitudeBehaviorRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.attitudeBehaviorExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Business Development'){
                returnWrap.showBusinessDevelopment = true;
                returnWrap.businessDevelopmentRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.businessDevelopmentExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Strategic Work'){
                returnWrap.showStrategicWork = true;
                returnWrap.strategicWorkRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.strategicWorkExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Company Growth'){
                returnWrap.showCompanyGrowth = true;
                returnWrap.companyGrowthRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.companyGrowthExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Requirement Gathering'){
                returnWrap.showRequirementGathering = true;
                returnWrap.requirementGatheringRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.requirementGatheringExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'POV Creation & Demos'){
                returnWrap.showPOVCreationDemos = true;
                returnWrap.povCreationDemosRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.povCreationDemosExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Project Planning and Scheduling Management'){
                returnWrap.showProjectPlanningSchedulingManagement = true;
                returnWrap.projectPlanningSchedulingManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.projectPlanningSchedulingManagementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Task Management'){
                returnWrap.showTaskManagement = true;
                returnWrap.taskManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.taskManagementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Risk Management'){
                returnWrap.showRiskManagement = true;
                returnWrap.riskManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.riskManagementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Resource Management'){
                returnWrap.showResourceManagement = true;
                returnWrap.resourceManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.resourceManagementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Stakeholder Management'){
                returnWrap.showStakeholderManagement = true;
                returnWrap.stakeholderManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.stakeholderManagementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Communication Management'){
                returnWrap.showCommunicationManagement = true;
                returnWrap.communicationManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.communicationManagementExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Documentation & Reporting Management'){
                returnWrap.showDocumentationReportingManagement = true;
                returnWrap.documentationReportingManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.documentationReportingManagementExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Estimations'){
                returnWrap.showEstimations = true;
                returnWrap.estimationsRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.estimationsExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Test Case Design and Execution'){
                returnWrap.showTestCaseDesignExecution = true;
                returnWrap.testCaseDesignExecutionRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.testCaseDesignExecutionExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Defect Management'){
                returnWrap.showDefectManagement = true;
                returnWrap.defectManagementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.defectManagementExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Technical Troubleshooting & Test Environment Prep'){
                returnWrap.showTroubleshootingAndEnvironmentPrep = true;
                returnWrap.troubleshootingAndEnvironmentPrepRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.troubleshootingAndEnvironmentPrepExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Project Success'){
                returnWrap.showProjectSuccess = true;
                returnWrap.projectSuccessRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.projectSuccessExTxt = gc.KRA_Competency_Example__c;
                ////break;
            }else if(gc.KRA_Competency__c == 'Stakeholder Satisfaction'){
                returnWrap.showStakeholderSatisfaction = true;
                returnWrap.stakeholderSatisfactionRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.stakeholderSatisfactionExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Goal Achievement'){
                returnWrap.showGoalAchievement = true;
                returnWrap.goalAchievementRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.goalAchievementExTxt = gc.KRA_Competency_Example__c;
                //break;
            }else if(gc.KRA_Competency__c == 'Continuous Learning and Skill Development'){
                returnWrap.showLearningAndSkillDevelopment = true;
                returnWrap.learningAndSkillDevelopmentRtngTxt = gc.KRA_Competency_Overview__c;
				returnWrap.learningAndSkillDevelopmentExTxt = gc.KRA_Competency_Example__c;
                //break;
            }

        }

        return returnWrap;
    }

    @AuraEnabled
    public static KraVisiableWrapper calculateAverageRatingForKRA(List<String> PMAnswerRecordsId, Goal__c kraRecord, String tab ){
        try {

            System.debug(' RECEIVED PMAnswerRecordsId' + PMAnswerRecordsId);
            System.debug(' RECEIVED kraRecord' + kraRecord);
            System.debug(' RECEIVED tab' + tab);

            KraVisiableWrapper wrap = new KraVisiableWrapper();

            Decimal TechSkillSum = 0;
            Integer TechSkillNo = 0;

            Decimal ProfSkillSum = 0;
            Integer ProfSkillNo = 0;

            Decimal StrategicSum = 0;
            Integer StrategicNo = 0;

            Decimal GoalResultSum = 0;
            Integer GoalResultNo = 0;


            Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();

            User loggedInUser = [SELECT Id,ContactId,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];


            Resource_Role__c kraContactResourceRole = [ Select id,name,technical_acumen__c, professional_skills__c, goals_and_results__c, strategic_impact__c from Resource_Role__c where Id =: kraRecord.Resource__r.Resource_Role__c LIMIT 1];      
            
            List<PM_Configure__c> pmAnswerRecords = New List<PM_Configure__c>(); 
            
            if (tab == 'My Metric' || tab == 'My Team') {
                pmAnswerRecords = [Select Id,Name,Area__c,KRA__c,Mentor_Mentee__c,Rating__c,Reporting_Contact__c,Resource_Role__c,Related_Question__r.Area__c FROM PM_Configure__c 
                WHERE
                Mentor_Mentee__c = :loggedInUser.ContactId
                AND RecordTypeId =: AnswerRecordTypeId
                AND KRA__c =: kraRecord.Id 
                AND Id IN :PMAnswerRecordsId
                ];
            }else {
                pmAnswerRecords = [Select Id,Name,Area__c,KRA__c,Mentor_Mentee__c,Rating__c,Reporting_Contact__c,Resource_Role__c,Related_Question__r.Area__c FROM PM_Configure__c 
                WHERE
                Reporting_Contact__c = :loggedInUser.ContactId
                AND RecordTypeId =: AnswerRecordTypeId
                AND KRA__c =: kraRecord.Id
                AND Id IN :PMAnswerRecordsId
                ];
            }

            System.debug(' SIZE OF pmAnswerRecords  ' +  pmAnswerRecords);

            for (PM_Configure__c pmAns : pmAnswerRecords) {
                if (pmAns.Related_Question__r.Area__c == 'TECHNICAL SKILLS') {
                    if (pmAns.Rating__c != null) {
                        TechSkillSum = TechSkillSum + pmAns.Rating__c;
                        TechSkillNo ++;
                    }
                    
                } else if (pmAns.Related_Question__r.Area__c == 'PROFESSIONAL SKILLS') {

                    if (pmAns.Rating__c != null) {
                        ProfSkillSum = ProfSkillSum + pmAns.Rating__c;
                        ProfSkillNo ++;
                    }
                    
                } else if (pmAns.Related_Question__r.Area__c == 'STRATEGIC IMPACT') {
                    if (pmAns.Rating__c != null) {
                        StrategicSum = StrategicSum + pmAns.Rating__c;
                        StrategicNo ++;
                    }
                    
                } else if (pmAns.Related_Question__r.Area__c == 'GOALS AND RESULTS') {
                    if (pmAns.Rating__c != null) {
                        GoalResultSum = GoalResultSum + pmAns.Rating__c;
                        GoalResultNo ++;
                    }
                }                 
            }

        System.debug( 'TechSkillSum : ' + TechSkillSum );

        System.debug( 'ProfSkillSum : ' + ProfSkillSum );
        
        System.debug( 'StrategicSum : ' + StrategicSum );
        
        System.debug( 'GoalResultSum : ' + GoalResultSum );

        Decimal avgTechSkillRating = TechSkillNo > 0 ? TechSkillSum / TechSkillNo : 0;
        Decimal avgProfSkillRating = ProfSkillNo > 0 ? ProfSkillSum / ProfSkillNo : 0;
        Decimal avgStrategicRating = StrategicNo > 0 ? StrategicSum / StrategicNo : 0;
        Decimal avgGoalResultRating = GoalResultNo > 0 ? GoalResultSum / GoalResultNo : 0;

        System.debug( 'avgTechSkillRating : ' + avgTechSkillRating );

        System.debug( 'avgProfSkillRating : ' + avgProfSkillRating );
        
        System.debug( 'avgStrategicRating : ' + avgStrategicRating );
        
        System.debug( 'avgGoalResultRating : ' + avgGoalResultRating );
        
        //smaske : Adding validation to check if value is NULL if yes then setting default value to 25
        kraContactResourceRole.technical_acumen__c = kraContactResourceRole.technical_acumen__c != null ? kraContactResourceRole.technical_acumen__c : 25;
        kraContactResourceRole.professional_skills__c = kraContactResourceRole.professional_skills__c != null ? kraContactResourceRole.professional_skills__c : 25;
        kraContactResourceRole.strategic_impact__c = kraContactResourceRole.strategic_impact__c != null ? kraContactResourceRole.strategic_impact__c : 25;
        kraContactResourceRole.goals_and_results__c = kraContactResourceRole.goals_and_results__c != null ? kraContactResourceRole.goals_and_results__c : 25;

        Decimal AvgTechSkillForResource = avgTechSkillRating * (kraContactResourceRole.technical_acumen__c/100);
        Decimal AvgProfSkillForResource = avgProfSkillRating * (kraContactResourceRole.professional_skills__c/100);
        Decimal AvgStrategicForResource = avgStrategicRating * (kraContactResourceRole.strategic_impact__c/100);
        Decimal AvgGoalResultForResource = avgGoalResultRating * (kraContactResourceRole.goals_and_results__c/100);

        System.debug( 'AvgTechSkillForResource : ' + AvgTechSkillForResource );

        System.debug( 'AvgProfSkillForResource : ' + AvgProfSkillForResource );
        
        System.debug( 'AvgStrategicForResource : ' + AvgStrategicForResource );
        
        System.debug( 'AvgGoalResultForResource : ' + AvgGoalResultForResource );


        Decimal totalAreaWiseAvgRating = (AvgTechSkillForResource + AvgProfSkillForResource + AvgStrategicForResource + AvgGoalResultForResource);

        //Avg Rating values without Resource role % allocation
        // Set the scale to 1 decimal place
        wrap.TechSkillData = avgTechSkillRating.setScale(1, RoundingMode.HALF_UP);
        wrap.ProfSkillData = avgProfSkillRating.setScale(1, RoundingMode.HALF_UP);
        wrap.StrategicData = avgStrategicRating.setScale(1, RoundingMode.HALF_UP);
        wrap.GoalResultData = avgGoalResultRating.setScale(1, RoundingMode.HALF_UP);


        //Avg Rating values based on Resource Role % allocated to AREA
        wrap.AvgTechSkillData = AvgTechSkillForResource.setScale(1, RoundingMode.HALF_UP);
        wrap.AvgProfSkillData = AvgProfSkillForResource.setScale(1, RoundingMode.HALF_UP);
        wrap.AvgStrategicData = AvgStrategicForResource.setScale(1, RoundingMode.HALF_UP);
        wrap.AvgGoalResultData = AvgGoalResultForResource.setScale(1, RoundingMode.HALF_UP);


        //Avg rating of ALL AREA'S  based on Resource Role % allocated
        wrap.AreaWiseAvgRating = totalAreaWiseAvgRating.setScale(1, RoundingMode.HALF_UP);

        wrap.kraRecordData = kraRecord;

        return wrap;

        }catch (Exception e) {
            System.debug('Error Line No :::: ' + e.getLineNumber());
            System.debug('Error Message:::: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PM_Configure__c> updatePMAnswerRecordsStatus(List<String> PMAnswerRecordsId, String newStatus){
        try {
            System.debug('APEX updatePMAnswerRecordsStatus List' + PMAnswerRecordsId);
            System.debug('APEX updatePMAnswerRecordsStatus size' + PMAnswerRecordsId.size());
            System.debug('APEX updatePMAnswerRecordsStatus newStatus' + newStatus);
            List<PM_Configure__c> PMAnswerListToUpdate = New List<PM_Configure__c>();
            List<PM_Configure__c> PMAnswerList = [SELECT Id, Status__c FROM PM_Configure__c WHERE Id IN :PMAnswerRecordsId];
            if (PMAnswerList.size() > 0) {
                for(PM_Configure__c PMRA :PMAnswerList){
                    if (newStatus == 'Save') {
                        PMRA.Status__c = 'Saved';
                    } else if (newStatus == 'Submit') {
                        PMRA.Status__c = 'Submitted';
                    }
                    PMAnswerListToUpdate.add(PMRA);
                }
            }

            if (PMAnswerListToUpdate.size() > 0) {
                Update PMAnswerListToUpdate;
            }
            System.debug('APEX PMAnswerListToUpdate' + PMAnswerListToUpdate);
            return PMAnswerListToUpdate;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    //KraWrapper
    public class KraVisiableWrapper {

        //Boolean variables for Visibility

        @AuraEnabled
        public Boolean showDevelopment;
        @AuraEnabled
        public Boolean showTesting;
        @AuraEnabled
        public Boolean showUnderstandingCode;
        @AuraEnabled
        public Boolean showPlatformKnowledge;

        @AuraEnabled
        public Boolean showDesignArchitecture;
        @AuraEnabled
        public Boolean showDocumentation;
        @AuraEnabled
        public Boolean showContinuousImprovement;
        @AuraEnabled
        public Boolean showDeliveryAccountability;

        @AuraEnabled
        public Boolean showEffectiveCommunication;
        @AuraEnabled
        public Boolean showKnowledgeSharing;
        @AuraEnabled
        public Boolean showTeamwork;
        @AuraEnabled
        public Boolean showAttitudeBehavior;

        @AuraEnabled
        public Boolean showBusinessDevelopment;
        @AuraEnabled
        public Boolean showStrategicWork;
        @AuraEnabled
        public Boolean showCompanyGrowth;
        @AuraEnabled
        public Boolean showRequirementGathering;

        @AuraEnabled
        public Boolean showPOVCreationDemos;
        @AuraEnabled
        public Boolean showProjectPlanningSchedulingManagement;
        @AuraEnabled
        public Boolean showTaskManagement;
        @AuraEnabled
        public Boolean showRiskManagement;

        @AuraEnabled
        public Boolean showResourceManagement;
        @AuraEnabled
        public Boolean showStakeholderManagement;
        @AuraEnabled
        public Boolean showCommunicationManagement;
        @AuraEnabled
        public Boolean showDocumentationReportingManagement;

        @AuraEnabled
        public Boolean showEstimations;
        @AuraEnabled
        public Boolean showTestCaseDesignExecution;
        @AuraEnabled
        public Boolean showDefectManagement;
        @AuraEnabled
        public Boolean showTroubleshootingAndEnvironmentPrep;
        @AuraEnabled
        public Boolean showLearningAndSkillDevelopment;

        @AuraEnabled
        public Boolean showGoalAchievement;
        @AuraEnabled
        public Boolean showStakeholderSatisfaction;
        @AuraEnabled
        public Boolean showProjectSuccess;

        //String Variables for RatingFields ToolTip
        
        @AuraEnabled 
        public String developmentRtngTxt;
        @AuraEnabled 
        public String testingRtngTxt;
        @AuraEnabled 
        public String understandingCodeRtngTxt;
        @AuraEnabled 
        public String platformKnowledgeRtngTxt;

        @AuraEnabled 
        public String designArchitectureRtngTxt;
        @AuraEnabled 
        public String documentationRtngTxt;
        @AuraEnabled 
        public String continuousImprovementRtngTxt;
        @AuraEnabled 
        public String deliveryAccountabilityRtngTxt;

        @AuraEnabled 
        public String effectiveCommunicationRtngTxt;
        @AuraEnabled 
        public String knowledgeSharingRtngTxt;
        @AuraEnabled 
        public String teamworkRtngTxt;
        @AuraEnabled 
        public String attitudeBehaviorRtngTxt;

        @AuraEnabled 
        public String businessDevelopmentRtngTxt;
        @AuraEnabled 
        public String strategicWorkRtngTxt;
        @AuraEnabled 
        public String companyGrowthRtngTxt;
        @AuraEnabled 
        public String requirementGatheringRtngTxt;

        @AuraEnabled 
        public String povCreationDemosRtngTxt;
        @AuraEnabled 
        public String projectPlanningSchedulingManagementRtngTxt;
        @AuraEnabled 
        public String taskManagementRtngTxt;
        @AuraEnabled 
        public String riskManagementRtngTxt;

        @AuraEnabled 
        public String resourceManagementRtngTxt;
        @AuraEnabled 
        public String stakeholderManagementRtngTxt;
        @AuraEnabled 
        public String communicationManagementRtngTxt;
        @AuraEnabled 
        public String documentationReportingManagementRtngTxt;

        @AuraEnabled 
        public String estimationsRtngTxt;
        @AuraEnabled 
        public String testCaseDesignExecutionRtngTxt;
        @AuraEnabled 
        public String defectManagementRtngTxt;
        @AuraEnabled 
        public String troubleshootingAndEnvironmentPrepRtngTxt;
        @AuraEnabled 
        public String learningAndSkillDevelopmentRtngTxt;

        @AuraEnabled 
        public String goalAchievementRtngTxt;
        @AuraEnabled 
        public String stakeholderSatisfactionRtngTxt;
        @AuraEnabled 
        public String projectSuccessRtngTxt;

        /*String Variables for ExampleFields ToolTip*/
        @AuraEnabled 
        public String developmentExTxt;
        @AuraEnabled 
        public String testingExTxt;
        @AuraEnabled 
        public String understandingCodeExTxt;
        @AuraEnabled 
        public String platformKnowledgeExTxt;

        @AuraEnabled 
        public String designArchitectureExTxt;
        @AuraEnabled 
        public String documentationExTxt;
        @AuraEnabled 
        public String continuousImprovementExTxt;
        @AuraEnabled 
        public String deliveryAccountabilityExTxt;

        @AuraEnabled 
        public String effectiveCommunicationExTxt;
        @AuraEnabled 
        public String knowledgeSharingExTxt;
        @AuraEnabled 
        public String teamworkExTxt;
        @AuraEnabled 
        public String attitudeBehaviorExTxt;

        @AuraEnabled 
        public String businessDevelopmentExTxt;
        @AuraEnabled 
        public String strategicWorkExTxt;
        @AuraEnabled 
        public String companyGrowthExTxt;
        @AuraEnabled 
        public String requirementGatheringExTxt;

        @AuraEnabled 
        public String povCreationDemosExTxt;
        @AuraEnabled 
        public String projectPlanningSchedulingManagementExTxt;
        @AuraEnabled 
        public String taskManagementExTxt;
        @AuraEnabled 
        public String riskManagementExTxt;

        @AuraEnabled 
        public String resourceManagementExTxt;
        @AuraEnabled 
        public String stakeholderManagementExTxt;
        @AuraEnabled 
        public String communicationManagementExTxt;
        @AuraEnabled 
        public String documentationReportingManagementExTxt;

        @AuraEnabled 
        public String estimationsExTxt;
        @AuraEnabled 
        public String testCaseDesignExecutionExTxt;
        @AuraEnabled 
        public String defectManagementExTxt;
        @AuraEnabled 
        public String troubleshootingAndEnvironmentPrepExTxt;
        @AuraEnabled 
        public String learningAndSkillDevelopmentExTxt;

        @AuraEnabled 
        public String goalAchievementExTxt;
        @AuraEnabled 
        public String stakeholderSatisfactionExTxt;
        @AuraEnabled 
        public String projectSuccessExTxt;
        
    }

}