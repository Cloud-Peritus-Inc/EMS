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

                    /*New Fields Created 26/12/23*/
                    Overall_Professional_Rating_2__c,Overall_Tech_Rating_2__c,Overall_Strategic_Rating_2__c,Overall_Goals_Results_Rating_2__c

                    FROM Goal__c WHERE Id = :recordId LIMIT 1];

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
                Resource_Resource_Relationship__c rrrRecord = [Select Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource_Role__c,Resource__c,Relationship_Type__c,
                Reports_To_Role__c
                FROM Resource_Resource_Relationship__c
                WHERE (Resource__c =:selectedresource AND Relationship_Type__c includes ('Mentor') AND Resource_Reports_To__c != NULL) ];
                if(rrrRecord != null){
                    goal.Review_Type__c = 'Mentor Review';
                    goal.Reviewer_Name__c = rrrRecord.Resource_Reports_To__r.Name;
                    goal.Reviewer_Title__c = rrrRecord.Reports_To_Role__c;
                    goal.Date_of_Review__c = System.today();
                }
                return goal;
            }else{

                User loggedinUser = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];

                Resource_Resource_Relationship__c rrrRecord = [Select Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource_Role__c,Resource__c,Relationship_Type__c,
                Reports_To_Role__c
                FROM Resource_Resource_Relationship__c
                WHERE (Resource__c =:loggedinUser.ContactId AND Relationship_Type__c includes ('Mentor') AND Resource_Reports_To__c != NULL) ];
                if(rrrRecord != null){
                    goal.Review_Type__c = 'Mentor Review';
                    goal.Reviewer_Name__c = rrrRecord.Resource_Reports_To__r.Name;
                    goal.Reviewer_Title__c = rrrRecord.Reports_To_Role__c;
                    goal.Date_of_Review__c = System.today();
                }
                return goal;
            }

        } catch (Exception e) {
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
            kraRecord.Status__c = STATUS_KRA_INREVIEW;
            Update kraRecord;
            return kraRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Goal__c submitKraRecord( Goal__c kraRecord){
        try {
            System.debug('kraRecord Record Detail : :' + kraRecord);
            kraRecord.Status__c = STATUS_KRA_COMPLETE;
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
       

        
        for(Grid_Configuration__c gc : [SELECT Id,KRA_Competency__c FROM Grid_Configuration__c WHERE Grid_Configuration_Type__c = 'KRA' and Resource_Role__c=:resourceRoleId and KRA_Competency__c!=null]){
            System.debug('#FOR GC ' + gc);
            if(gc.KRA_Competency__c == 'Development'){
               returnWrap.showDevelopment = true;
               //break;
            }else if(gc.KRA_Competency__c == 'Testing'){
               returnWrap.showTesting = true;
               //break; 
            }else if(gc.KRA_Competency__c == 'Understanding Code'){
               returnWrap.showUnderstandingCode = true;
               //break;  
            }else if(gc.KRA_Competency__c == 'Platform Knowledge'){
               returnWrap.showPlatformKnowledge = true;
               //break;
            }else if(gc.KRA_Competency__c == 'Design and Architecture'){
                returnWrap.showDesignArchitecture = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Documentation'){
                returnWrap.showDocumentation = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Continuous Improvement'){
                returnWrap.showContinuousImprovement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Delivery Accountability'){
                returnWrap.showDeliveryAccountability = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Effective Communication'){
                returnWrap.showEffectiveCommunication = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Knowledge Sharing'){
                returnWrap.showKnowledgeSharing = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Teamwork'){
                returnWrap.showTeamwork = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Attitude and Behavior'){
                returnWrap.showAttitudeBehavior = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Business Development'){
                returnWrap.showBusinessDevelopment = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Strategic Work'){
                returnWrap.showStrategicWork = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Company Growth'){
                returnWrap.showCompanyGrowth = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Requirement Gathering'){
                returnWrap.showRequirementGathering = true;
                //break;
            }else if(gc.KRA_Competency__c == 'POV Creation & Demos'){
                returnWrap.showPOVCreationDemos = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Project Planning and Scheduling Management'){
                returnWrap.showProjectPlanningSchedulingManagement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Task Management'){
                returnWrap.showTaskManagement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Risk Management'){
                returnWrap.showRiskManagement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Resource Management'){
                returnWrap.showResourceManagement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Stakeholder Management'){
                returnWrap.showStakeholderManagement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Communication Management'){
                returnWrap.showCommunicationManagement = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Documentation & Reporting Management'){
                returnWrap.showDocumentationReportingManagement = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Estimations'){
                returnWrap.showEstimations = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Test Case Design and Execution'){
                returnWrap.showTestCaseDesignExecution = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Defect Management'){
                returnWrap.showDefectManagement = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Technical Troubleshooting & Test Environment Prep'){
                returnWrap.showTroubleshootingAndEnvironmentPrep = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Project Success'){
                returnWrap.showCommunicationManagement = true;
                ////break;
            }else if(gc.KRA_Competency__c == 'Stakeholder Satisfaction'){
                returnWrap.showStakeholderSatisfaction = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Project Success'){
                returnWrap.showProjectSuccess = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Goal Achievement'){
                returnWrap.showGoalAchievement = true;
                //break;
            }else if(gc.KRA_Competency__c == 'Continuous Learning and Skill Development'){
                returnWrap.showLearningAndSkillDevelopment = true;
                //break;
            }

        }

        return returnWrap;
    }

    //KraWrapper
    public class KraVisiableWrapper {
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

        
    }

}