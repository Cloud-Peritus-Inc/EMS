/**
 * Apex class for fetching and updating GOAL__C (kraRecords) for Perfomance Management
 * Test Class: quarterlyKRAViewCtrl_Test
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
                con = [SELECT Id,Name, EMS_TM_User__c, EMS_TM_User__r.Profile.Name , Resource_Role__c, Resource_Role__r.Name,
                Resource_Role__r.technical_acumen__c,Resource_Role__r.goals_and_results__c,Resource_Role__r.professional_skills__c,Resource_Role__r.strategic_impact__c  
                FROM Contact 
                WHERE EMS_TM_User__c = :UserInfo.getUserId() LIMIT 1];
				System.debug('con '+con);
            if (con != null && con.Resource_Role__r != null) {
                System.debug('con.Resource_Role__r  '+con.Resource_Role__r );
                resourceRole = con.Resource_Role__r.Name;
                System.debug('resourceRole  '+resourceRole );
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
        System.debug('getSelectedResourceConDetails ');
        Contact con = new Contact();
        try {
            if (!String.isBlank(selectedResourceId)) {
                User loggedinUser = [SELECT Id,ContactId FROM User WHERE ContactId=:selectedResourceId];
            	System.debug('loggedinUser '+loggedinUser);
                con = [SELECT Id, EMS_TM_User__c, EMS_TM_User__r.Profile.Name , Resource_Role__c, Resource_Role__r.Name,
                Resource_Role__r.technical_acumen__c,Resource_Role__r.goals_and_results__c,Resource_Role__r.professional_skills__c,Resource_Role__r.strategic_impact__c  
                FROM Contact 
                WHERE EMS_TM_User__c = :loggedinUser.Id LIMIT 1];
            }
            System.debug('con '+con);
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
                    Average_Technical_Skills_Rating__c,Average_Goals_And_Result_Rating__c,Average_Professional_Skills_Rating__c,Average_Strategic_Impact_Rating__c,
                    Mentor_KRA_submitted__c,Mentee_KRA_submitted__c,
                    Resource__c,Check_In_By__c,Resource__r.Resource_Role__c,Resource__r.Resource_Role__r.Name
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
            //smaske : fetching the RRR record where kra resource is Resource to check if logged in user is mentor or mentee
            Resource_Resource_Relationship__c RRR = [Select Id,Name,Relationship_Type__c,Resource__c,Resource__r.Name,Resource_Reports_To__c ,Resource_Reports_To__r.Name from Resource_Resource_Relationship__c where Relationship_Type__c INCLUDES('Mentor') AND Resource__c =: kraRecord.Resource__c LIMIT 1];
            System.debug('con Record Detail : :' + con.Id);
            if (kraRecord.Resource__c == con.Id) {
                System.debug('IN 208');
                //smaske :[10-July-2024] : Updatng Mentee_KRA_submitted__c checkbox to TRUE when mentee submits his all answer records
                kraRecord.Mentee_KRA_submitted__c	= true;
            }else if (RRR.Resource_Reports_To__c == con.Id) {
                //smaske :[10-July-2024] : Updatng Mentor_KRA_submitted__c checkbox to TRUE when mentor submits his all answer records
                kraRecord.Mentor_KRA_submitted__c	= true;
                kraRecord.Status__c = STATUS_KRA_INREVIEW; //smaske : Setting status to "KRA Inreview" when mentor submits his PM ANSWERS 
            }

            Update kraRecord;
            return kraRecord;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled
    public static KraVisiableWrapper getPMConfigKRAData(Goal__c krarecordId, String tab,Boolean copy, String selectedProjectId, String selectedresource) {

        System.debug('Received TAB :: ' + tab);

        Id QuestionRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        Id AnswerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        KraVisiableWrapper returnWrap = new KraVisiableWrapper();

        String resourceRoleId = '';
        System.debug('#getGridConfigurationKRAData');
        User loggedInUser = [SELECT Id,ContactId,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];
        if(String.isEmpty(krarecordId.Id)){
             //User loggedInUser = [SELECT Id,Contact.Resource_Role__c From User WHERE Id=:Userinfo.getUserId()];
             resourceRoleId = loggedInUser.Contact.Resource_Role__c;
             System.debug('#IF ' + resourceRoleId);
        }else{
            resourceRoleId = [SELECT Resource__r.Resource_Role__c FROM Goal__c WHERE Id=:krarecordId.Id].Resource__r.Resource_Role__c;
            System.debug('#ELSE ' + resourceRoleId);
        }

        Set<Id> pmAnswerRecordsIdSet = new Set<Id>();
        List<Id> pmAnswerRecordsIdList = new List<Id>();

        List<String> technicalArea = new List<String>();
        List<String> goalsAndResultArea = new List<String>();
        List<String> profiessionalSkillsArea = new List<String>();
        List<String> strategicImpactArea = new List<String>();

        List<PM_Configure__c> pmAnswerConfigRecords = new List<PM_Configure__c>();
        List<PM_Configure__c> pmAnswerConfigRecordsOld = new List<PM_Configure__c>();

        if (tab == 'My Metric' || tab == 'My Team') {
            System.debug('INSIDE IF FOR TAB :' + tab);
            pmAnswerConfigRecords = [SELECT Id,name,Question__c,Rating__c, Description__c,Status__c,Related_Question__r.Question__c,Related_Question__r.Resource_Role__c, Related_Question__r.Area__c, KRA__c, Related_Question__r.Question_overview__c,Related_Question__r.Rating_overview__c,Related_Question__r.Description__c,Mentor_Mentee__c,Reporting_Contact__c 
            FROM PM_Configure__c 
            WHERE RecordTypeId =: AnswerRecordTypeId
            AND Related_Question__r.Resource_Role__c =: resourceRoleId
            AND Mentor_Mentee__c =: loggedInUser.ContactId
            AND KRA__c =:krarecordId.Id ];
        } else {
            pmAnswerConfigRecords = [SELECT Id,name,Question__c,Rating__c, Description__c,Status__c,Related_Question__r.Question__c,Related_Question__r.Resource_Role__c, Related_Question__r.Area__c, KRA__c, Related_Question__r.Question_overview__c,Related_Question__r.Rating_overview__c,Related_Question__r.Description__c,Mentor_Mentee__c,Reporting_Contact__c,Project_Name__c,KRA__r.Resource__c
            FROM PM_Configure__c 
            WHERE RecordTypeId =: AnswerRecordTypeId
            AND Related_Question__r.Resource_Role__c =: resourceRoleId
            AND Reporting_Contact__c =: loggedInUser.ContactId
            AND KRA__c =:krarecordId.Id
            AND Project_Name__c =: selectedProjectId
            AND KRA__r.Resource__c =: selectedresource];
        }
        System.debug('pmAnswerConfigRecords records found  :' + pmAnswerConfigRecords);
		
        If(copy){
            pmAnswerConfigRecords.sort();
            
            // Query the current fiscal quarter
            Period currentFiscalQuarter = [ SELECT StartDate, EndDate, FullyQualifiedLabel FROM Period WHERE Type = 'Quarter' AND StartDate = THIS_FISCAL_QUARTER LIMIT 1];
            
            /* Query the previous fiscal quarter using the current fiscal quarter's start date
            Period lastFiscalQuarter = [ SELECT StartDate, EndDate, FullyQualifiedLabel 
                FROM Period  WHERE Type = 'Quarter'  AND EndDate < :currentFiscalQuarter.StartDate ORDER BY EndDate DESC  LIMIT 1]; */
            
            if (tab == 'My Metric' || tab == 'My Team') {
                System.debug('INSIDE IF FOR TAB :' + tab);
                pmAnswerConfigRecordsOld = [SELECT Id,name,Question__c,Rating__c, Description__c,Status__c,Related_Question__r.Question__c,Related_Question__r.Resource_Role__c, Related_Question__r.Area__c, KRA__c,KRA__r.Quarter_Start_Date__c,KRA__r.Quarter_End_Date__c, Related_Question__r.Question_overview__c,Related_Question__r.Rating_overview__c,Related_Question__r.Description__c,Mentor_Mentee__c,Reporting_Contact__c 
                                            FROM PM_Configure__c 
                                            WHERE RecordTypeId =: AnswerRecordTypeId
                                            AND Related_Question__r.Resource_Role__c =: resourceRoleId
                                            AND Mentor_Mentee__c =: loggedInUser.ContactId
                                            AND KRA__r.Quarter_End_Date__c < :currentFiscalQuarter.StartDate
                                            ORDER BY KRA__r.Quarter_End_Date__c DESC, CreatedDate DESC ];
            } else {
                pmAnswerConfigRecordsOld = [SELECT Id,name,Question__c,Rating__c, Description__c,Status__c,Related_Question__r.Question__c,Related_Question__r.Resource_Role__c, Related_Question__r.Area__c, KRA__c,KRA__r.Quarter_Start_Date__c,KRA__r.Quarter_End_Date__c,Related_Question__r.Question_overview__c,Related_Question__r.Rating_overview__c,Related_Question__r.Description__c,Mentor_Mentee__c,Reporting_Contact__c
                                            FROM PM_Configure__c 
                                            WHERE RecordTypeId =: AnswerRecordTypeId
                                            AND Related_Question__r.Resource_Role__c =: resourceRoleId
                                            AND Reporting_Contact__c =: loggedInUser.ContactId
                                            AND KRA__r.Quarter_End_Date__c < :currentFiscalQuarter.StartDate
                                            ORDER BY KRA__r.Quarter_End_Date__c DESC, CreatedDate DESC ];
            }
            
            if(pmAnswerConfigRecordsOld.size()>0){
                System.debug('OLD PM AVAILABLE ::: '+ pmAnswerConfigRecordsOld);
                pmAnswerConfigRecordsOld.sort();
                for (Integer i = 0; i < pmAnswerConfigRecords.size(); i++) {
                    if (i < pmAnswerConfigRecordsOld.size()) {
                        pmAnswerConfigRecords[i].Rating__c = pmAnswerConfigRecordsOld[i].Rating__c != null ? pmAnswerConfigRecordsOld[i].Rating__c : 0 ;
                        pmAnswerConfigRecords[i].Description__c = pmAnswerConfigRecordsOld[i].Description__c != null ? pmAnswerConfigRecordsOld[i].Description__c : '';
                    }
                }
                System.debug('VALUE POPULATED ' + pmAnswerConfigRecords);
            }
        }

        Map<String, Map<String,PM_Configure__c> > areaAndQueAnsMap = new Map<String, Map<String,PM_Configure__c> >();
        Map<String,PM_Configure__c> questionAndAnswerMap = new Map<String,PM_Configure__c>();

        for (PM_Configure__c ans : pmAnswerConfigRecords) {
            if (ans.Related_Question__r.Question__c != null && ans.Related_Question__r.Area__c != null) {
                questionAndAnswerMap.put(ans.Related_Question__r.Question__c, ans);
            }
            pmAnswerRecordsIdSet.add(ans.Id);
        }

        for (String question : questionAndAnswerMap.keySet()) {
            PM_Configure__c ansRec = questionAndAnswerMap.get(question);
            String area = ansRec.Related_Question__r.Area__c;
        
            if (area == 'TECHNICAL SKILLS') {
                if (!areaAndQueAnsMap.containsKey(area)) {
                    areaAndQueAnsMap.put(area, new Map<String, PM_Configure__c>());
                }
                areaAndQueAnsMap.get(area).put(ansRec.Related_Question__r.Question__c, ansRec);
            } else if (area == 'PROFESSIONAL SKILLS') {
                if (!areaAndQueAnsMap.containsKey(area)) {
                    areaAndQueAnsMap.put(area, new Map<String, PM_Configure__c>());
                }
                areaAndQueAnsMap.get(area).put(ansRec.Related_Question__r.Question__c, ansRec);
            } else if (area == 'STRATEGIC IMPACT') {
                if (!areaAndQueAnsMap.containsKey(area)) {
                    areaAndQueAnsMap.put(area, new Map<String, PM_Configure__c>());
                }
                areaAndQueAnsMap.get(area).put(ansRec.Related_Question__r.Question__c, ansRec);
            } else if (area == 'GOALS AND RESULTS') {
                if (!areaAndQueAnsMap.containsKey(area)) {
                    areaAndQueAnsMap.put(area, new Map<String, PM_Configure__c>());
                }
                areaAndQueAnsMap.get(area).put(ansRec.Related_Question__r.Question__c, ansRec);
            }
        }

        System.debug('areaAndQueAnsMap: ' + areaAndQueAnsMap);
        returnWrap.queAndAnsMapData = questionAndAnswerMap;
        returnWrap.areaAndQueAnsMapData = areaAndQueAnsMap;
        if (pmAnswerRecordsIdSet.size() > 0) {
            pmAnswerRecordsIdList.addAll(pmAnswerRecordsIdSet);
        }
        returnWrap.pmAnsRecordsIdData = pmAnswerRecordsIdList;
        
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
                    pmAns.Rating__c = pmAns.Rating__c == null ? 0 : pmAns.Rating__c;                    
                        TechSkillSum = TechSkillSum + pmAns.Rating__c;
                        TechSkillNo ++;
                    
                } else if (pmAns.Related_Question__r.Area__c == 'PROFESSIONAL SKILLS') {
                    pmAns.Rating__c = pmAns.Rating__c == null ? 0 : pmAns.Rating__c;    
                    ProfSkillSum = ProfSkillSum + pmAns.Rating__c;
                    ProfSkillNo ++;
                    
                    
                } else if (pmAns.Related_Question__r.Area__c == 'STRATEGIC IMPACT') {
                    pmAns.Rating__c = pmAns.Rating__c == null ? 0 : pmAns.Rating__c;    
                        StrategicSum = StrategicSum + pmAns.Rating__c;
                        StrategicNo ++;
                    
                } else if (pmAns.Related_Question__r.Area__c == 'GOALS AND RESULTS') {
                    pmAns.Rating__c = pmAns.Rating__c == null ? 0 : pmAns.Rating__c;    
                        GoalResultSum = GoalResultSum + pmAns.Rating__c;
                        GoalResultNo ++;
                    
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
        kraContactResourceRole.technical_acumen__c = kraContactResourceRole.technical_acumen__c != null ? kraContactResourceRole.technical_acumen__c : 0;
        kraContactResourceRole.professional_skills__c = kraContactResourceRole.professional_skills__c != null ? kraContactResourceRole.professional_skills__c : 0;
        kraContactResourceRole.strategic_impact__c = kraContactResourceRole.strategic_impact__c != null ? kraContactResourceRole.strategic_impact__c : 0;
        kraContactResourceRole.goals_and_results__c = kraContactResourceRole.goals_and_results__c != null ? kraContactResourceRole.goals_and_results__c : 0;

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
        wrap.TechSkillData = avgTechSkillRating.setScale(2, RoundingMode.FLOOR);
        wrap.ProfSkillData = avgProfSkillRating.setScale(2, RoundingMode.FLOOR);
        wrap.StrategicData = avgStrategicRating.setScale(2, RoundingMode.FLOOR);
        wrap.GoalResultData = avgGoalResultRating.setScale(2, RoundingMode.FLOOR);


        //Avg Rating values based on Resource Role % allocated to AREA
        wrap.AvgTechSkillData = AvgTechSkillForResource.setScale(2, RoundingMode.FLOOR);
        wrap.AvgProfSkillData = AvgProfSkillForResource.setScale(2, RoundingMode.FLOOR);
        wrap.AvgStrategicData = AvgStrategicForResource.setScale(2, RoundingMode.FLOOR);
        wrap.AvgGoalResultData = AvgGoalResultForResource.setScale(2, RoundingMode.FLOOR);


        //Avg rating of ALL AREA'S  based on Resource Role % allocated
        wrap.AreaWiseAvgRating = totalAreaWiseAvgRating.setScale(2, RoundingMode.FLOOR);

        wrap.kraRecordData = kraRecord;

        return wrap;

        }catch (Exception e) {
            System.debug('Error Line No :::: ' + e.getLineNumber());
            System.debug('Error Message:::: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<PM_Configure__c> updatePMAnswerRecordsStatus(List<String> PMAnswerRecordsId, String newStatus, String tab){
        try {
            System.debug('APEX updatePMAnswerRecordsStatus List' + PMAnswerRecordsId);
            System.debug('APEX updatePMAnswerRecordsStatus size' + PMAnswerRecordsId.size());
            System.debug('APEX updatePMAnswerRecordsStatus newStatus' + newStatus);
            List<PM_Configure__c> PMAnswerListToUpdate = New List<PM_Configure__c>();
            List<PM_Configure__c> PMAnswerList = [SELECT Id, Status__c, KRA__c, KRA__r.Mentor_KRA_submitted__c FROM PM_Configure__c WHERE Id IN :PMAnswerRecordsId];
            if (PMAnswerList.size() > 0) {
                for(PM_Configure__c PMRA :PMAnswerList){
                    //smaske : added tab wise status change as the mentor can reedit the records even after submitting kra. which was affecting the record status value change.
                    if (tab == 'My Team') {
                        if (PMRA.KRA__r.Mentor_KRA_submitted__c == false) {
                            if (newStatus == 'Save') {
                                PMRA.Status__c = 'Saved';
                            } else if (newStatus == 'Submit') {
                                PMRA.Status__c = 'Submitted';
                            }
                        }else{
                            PMRA.Status__c = 'Submitted';
                        }
                    }else{
                        if (newStatus == 'Save') {
                            PMRA.Status__c = 'Saved';
                        } else if (newStatus == 'Submit') {
                            PMRA.Status__c = 'Submitted';
                        }
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

        @AuraEnabled 
        public String questionData;

        @AuraEnabled 
        public String areaData;

        @AuraEnabled 
        public List<Id> pmAnsRecordsIdData;

        @AuraEnabled 
        public Map<String, Map<String,PM_Configure__c> > areaAndQueAnsMapData;

        @AuraEnabled 
        public Map<String, PM_Configure__c> queAndAnsMapData;

        @AuraEnabled 
        public Goal__c kraRecordData;

        //Sum of Avg ratings of Resource Role Based Area wise rating 
        @AuraEnabled
        public Decimal AreaWiseAvgRating;

        //Avg Rating values based on Resource Role % allocated to AREA 
        @AuraEnabled
        public Decimal AvgTechSkillData;

        @AuraEnabled
        public Decimal AvgProfSkillData;

        @AuraEnabled
        public Decimal AvgStrategicData;

        @AuraEnabled
        public Decimal AvgGoalResultData;

        //Avg Rating values without Resource role % allocation
        @AuraEnabled
        public Decimal TechSkillData;

        @AuraEnabled
        public Decimal ProfSkillData;

        @AuraEnabled
        public Decimal StrategicData;

        @AuraEnabled
        public Decimal GoalResultData;
        
    }

}