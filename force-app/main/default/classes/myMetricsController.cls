public without sharing class myMetricsController {
    
    public static final String PULSE_RECORD_TYPE = 'pulse';
    public static final String STATUS_REQUESTED = 'Pulse Requested';
    public static final String STATUS_SUBMITTED = 'Pulse Submitted';
    public static final String HR_PROFILE = 'Employee - HR(Community)';
    
    @AuraEnabled(cacheable=true)
    public static datawrapper getTheCurrentFY(){
        
        Map<String,String> fyMap = new Map<String,String>();
        Id currentFY;
        String currentFYName;
        Date currentdate = system.today();
        
        
        for(Fiscal_Year__c fy : [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c Where End_Date__c<=THIS_FISCAL_YEAR Order BY Start_Date__c ASC]){
            if(fy.Start_Date__c <= currentdate && fy.End_Date__c >= currentdate){
                currentFY = fy.Id;
                currentFYName = fy.Id;
            }
            fyMap.put(fy.Name,fy.Id);
        }
        
        datawrapper dwrap = new datawrapper();
        dwrap.currentFYId = currentFY;
        dwrap.currentName = currentFYName;
        dwrap.fyListMap = fyMap;
        System.debug('Custom label ' + Boolean.valueOf(Label.Enable_Mentor_Feedback));
        dwrap.dontshowThePulse = !(Boolean.valueOf(Label.Enable_Mentor_Feedback));
        System.debug('Wrapper btn :' + dwrap.dontshowThePulse);
        dwrap.currentResId = [Select ContactId From User WHERE Id=:Userinfo.getUserId()].ContactId;
        User u = [Select ContactId,Profile.Name From User WHERE Id=:Userinfo.getUserId()];
        //smaske: FOR : PM_014 : checking if logged in user have Reportess under him
        List<Resource_Resource_Relationship__c> reportesList = [select id,Resource_Reports_To__c,Relationship_Type__c   from Resource_Resource_Relationship__c WHERE Resource_Reports_To__c =: u.ContactId AND Relationship_Type__c includes ('Mentor')];
        Boolean labelVal = Boolean.valueOf(Label.Enable_Mentor_Feedback);
        if (!reportesList.isEmpty() && labelVal) {
            dwrap.dontshowThePulse = false;
        }else if (reportesList.isEmpty() && labelVal) {
            dwrap.dontshowThePulse = true;
        }
        //smaske: FOR : PM_014 : END
        
        dwrap.showGenPerKra = false;
        if (u.Profile.Name == HR_PROFILE) {
            dwrap.showGenPerKra = true;
        }
        system.debug('==dwrap==='+dwrap);
        return dwrap;
    }
    
    @AuraEnabled
    public static List<perfWrapper> getAllKRAs(String fyId){
        Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        List<Fulfillment__c> returnList = new List<Fulfillment__c>();
        List<perfWrapper> returnval = new List<perfWrapper>();
        if(String.isEmpty(fyId)){
            Date currentdate = system.today();
            for(Fiscal_Year__c fy : [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c Order BY Start_Date__c ASC]){
                if(fy.Start_Date__c <= currentdate && fy.End_Date__c >= currentdate){
                    fyId = fy.Id;
                    break;
                }
                
            }
        }

        //Smaske : Current Fiscal quarter // April - June Q1 KRA data
        Period currentFiscalQuarter = [ SELECT StartDate, EndDate, FullyQualifiedLabel FROM Period WHERE Type = 'Quarter' AND StartDate = THIS_FISCAL_QUARTER LIMIT 1];
        //Smaske [PM_Def_072]: fetching records which are older than current quarter for logged in contact user  
        Contact currentContact = [Select Id,EMS_TM_User__c from Contact where EMS_TM_User__c=:Userinfo.getUserId()];

        List<Goal__c> prevQuarterGoals = [SELECT Id,Name,Check_in_Date__c,Quarter_Start_Date__c,Goal_Name__c,Quarter_End_Date__c,Status__c,Type__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c  
        FROM Goal__c 
        WHERE RecordTypeId =:kraRecordTypeId 
        AND Resource__c =:currentContact.Id
        AND Quarter_End_Date__c < :currentFiscalQuarter.StartDate
        ORDER BY Quarter_End_Date__c DESC, CreatedDate DESC LIMIT 1 ];

        System.debug(' prevQuarterGoals ' + prevQuarterGoals);

        //smaske : [UAT_PR_008] : Updated SOQL to fetch Next_Appraisal_Date__c field
        returnList = [SELECT Id,Name,Resource__c,Resource__r.Appraisal_Date__c,Resource__r.Next_Appraisal_Date__c,Fiscal_Year__c,Fiscal_Year__r.Name,Avg_Rating__c,Recognization_Type__c,LastModifiedDate,LastModifiedBy.Name,Status__c,
                      (SELECT Id,Name,Check_in_Date__c,Quarter_Start_Date__c,Goal_Name__c,Quarter_End_Date__c,Status__c,Type__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,Overall_Rating__c  FROM Goals__r WHERE RecordTypeId =:kraRecordTypeId) FROM Fulfillment__c WHERE Fiscal_Year__c =:fyId and Resource__r.EMS_TM_User__c=:Userinfo.getUserId()];
        for(Fulfillment__c ful : returnList){
            List<quatWrapper> qlist = new List<quatWrapper>();
            for(Goal__c gl : ful.Goals__r){
                quatWrapper qw = new quatWrapper();
                qw.name = gl.Goal_Name__c;
                qw.nameid = gl.Id;
                qw.qstartdate = gl.Quarter_Start_Date__c;
                qw.qendate = gl.Quarter_End_Date__c;
                qw.status = gl.Status__c;
                qw.typeval = gl.Type__c;
                //qw.rating = String.valueOf(gl.Rating__c);
                qw.overallRating = gl.Overall_Rating__c; //Ravitheja
                qw.allowedit = false;
                qw.allowCopy = false;
                //smaske : PM_061 : updating conditon to only allow edit when status is "Active" in MY METRIC TAB
                //Previously it was : gl.Status__c != 'KRA Complete'
                if(gl.Status__c == 'In Progress'){
                    qw.allowedit = true; 
                    qw.allowCopy = true; 
                }

                if (prevQuarterGoals.size() > 0) {
                    qw.allowCopy = true;
                }else {
                    qw.allowCopy = false;
                }
                
                //smaske :[UAT_066]: [12-July-2024] : Disabling copy prev btn , when kra is completed or In Review and also for old kra
                if(gl.Status__c == 'KRA Inreview' || gl.Status__c == 'KRA Completed' || gl.Status__c == 'HR KRA Completed' || gl.Status__c == 'Missed'    ){ //|| gl.Quarter_Start_Date__c < currentFiscalQuarter.StartDate
                    qw.allowCopy = false;
                }


                //smaske : [UAT_066] : [15-July-2024] : passing Mentee/Mentor Submitted var values to disable button based on tabs
                qw.menteeSubmitted = gl.Mentee_KRA_submitted__c;
                qw.mentorSubmitted = gl.Mentor_KRA_submitted__c;

                qlist.add(qw);
            }
            perfWrapper pw = new perfWrapper();
            pw.name = ful.Name;
            pw.nameid = ful.Id;
            pw.fyname = ful.Fiscal_Year__r.Name;
            pw.fyid = ful.Fiscal_Year__c;
            pw.lastmodifyby =ful.LastModifiedBy.Name;
            pw.rating = String.valueOf(ful.Avg_Rating__c);
            pw.lastmodified = ful.LastModifiedDate;
            //smaske : [UAT_PR_008] : replacing Appraisal_Date__c to Next_Appraisal_Date__c
            pw.nextappdate = ful.Resource__r.Next_Appraisal_Date__c;
            pw.qualList = qlist;
            pw.status = ful.Status__c;
            pw.dontallowCreateGoals = true;
            if(ful.Status__c == 'Active'){
                pw.dontallowCreateGoals = false; 
            }
            returnval.add(pw);
        }
        return returnval;
    }
    
    @AuraEnabled(cacheable=true)
    public static datawrapper getTheCompanyKRA(){
        
        Map<String,String> fyMap = new Map<String,String>();
        Id currentFY;
        String currentFYName;
        Date currentdate = system.today();
        
        User loggedinUser = [SELECT Id,Contact.Resource_Role__c FROM User WHERE Id=:Userinfo.getUserId()];
        
        for(Resource_Role__c fy : [SELECT Id,Name FROM Resource_Role__c WHERE Active__c = true Order BY Name ASC]){
            if(loggedinUser.Contact.Resource_Role__c == fy.Id){
                currentFYName = fy.Id;
            }
            fyMap.put(fy.Name,fy.Id);
        }
        /*  List<perfWrapper> kraAreaList = new List<perfWrapper>();
if(String.isNotEmpty(loggedinUser.Contact.Resource_Role__c)){
kraAreaList = getAllRoleKRAs(currentFYName);
}
system.debug(kraAreaList.size()+'====='+kraAreaList);*/
        datawrapper dwrap = new datawrapper();
        dwrap.currentName = currentFYName;
        dwrap.fyListMap = fyMap;
        system.debug('==dwrap==='+dwrap);
        return dwrap;
    }
    
    @AuraEnabled
    public static List<perfWrapper> getAllRoleKRAs(String resourceRoleId){
        List<perfWrapper> kraAreaList = new List<perfWrapper>();
        Map<String,List<quatWrapper>> areawithcompeneny = new Map<String,List<quatWrapper>>();
        for(PM_Configure__c gc : [SELECT Id,Name,Area__c,Question__c,Description__c FROM PM_Configure__c  WHERE Resource_Role__c=:resourceRoleId And Configuration_Type__c='KRA']){
            if(areawithcompeneny.containsKey(gc.Area__c)){
                quatWrapper qw = new quatWrapper();
                qw.name=gc.Question__c;
                qw.typeval=gc.Description__c;
                areawithcompeneny.get(gc.Area__c).add(qw);
            }else{
                List<quatWrapper> qlist = new List<quatWrapper>();
                quatWrapper qw = new quatWrapper();
                qw.name=gc.Question__c;
                qw.typeval=gc.Description__c;
                qlist.add(qw);
                areawithcompeneny.put(gc.Area__c,qlist);
            }
        }
        for(String ara : areawithcompeneny.keyset()){
            perfWrapper pw = new perfWrapper();
            pw.name = ara;
            pw.qualList = areawithcompeneny.get(ara);
            kraAreaList.add(pw);
        }
        return kraAreaList;
    }
    
    @AuraEnabled
    public static List<perfWrapper> getResourceKRAs(String resourceId,String fyId){
        Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();

        Period currentFiscalQuarter = [ SELECT StartDate, EndDate, FullyQualifiedLabel FROM Period WHERE Type = 'Quarter' AND StartDate = THIS_FISCAL_QUARTER LIMIT 1];
        Period lastFiscalQuarter = [ SELECT StartDate, EndDate, FullyQualifiedLabel 
                FROM Period  WHERE Type = 'Quarter'  AND EndDate < :currentFiscalQuarter.StartDate ORDER BY EndDate DESC  LIMIT 1];


        List<Fulfillment__c> returnList = new List<Fulfillment__c>();
        List<perfWrapper> returnval = new List<perfWrapper>();
        //smaske : [UAT_PR_008] : Updated SOQL to fetch Next_Appraisal_Date__c field
        returnList = [SELECT Id,Name,Resource__c,Resource__r.Appraisal_Date__c,Resource__r.Next_Appraisal_Date__c,Fiscal_Year__c,Fiscal_Year__r.Name,Avg_Rating__c,Recognization_Type__c,LastModifiedDate,LastModifiedBy.Name,Status__c,
                      (SELECT Id,Name,Check_in_Date__c,Quarter_Start_Date__c,Goal_Name__c,Quarter_End_Date__c,Status__c,Type__c,Mentee_KRA_submitted__c,Mentor_KRA_submitted__c,Overall_Rating__c FROM Goals__r WHERE RecordTypeId =:kraRecordTypeId) FROM Fulfillment__c WHERE Fiscal_Year__c =:fyId and Resource__c =:resourceId]; 
        
        
        for(Fulfillment__c ful : returnList){
            List<quatWrapper> qlist = new List<quatWrapper>();
            for(Goal__c gl : ful.Goals__r){
                quatWrapper qw = new quatWrapper();
                qw.name = gl.Goal_Name__c;
                qw.nameid = gl.Id;
                qw.qstartdate = gl.Quarter_Start_Date__c;
                qw.qendate = gl.Quarter_End_Date__c;
                qw.status = gl.Status__c;
                qw.typeval = gl.Type__c;
                //qw.rating = String.valueOf(gl.Rating__c);
                qw.overallRating = gl.Overall_Rating__c; //Ravitheja
                qw.allowedit = false;
                //smaske : PM_061 : updating conditon to only allow edit when status is "KRA Inreview" in MY TEAM TAB for selected Reportee's KRA
                //Previously it was : gl.Status__c != 'KRA Completed'
                if(gl.Status__c == 'In Progress'){
                    qw.allowedit = true;  
                }

                //smaske :[UAT_066]: [12-July-2024] : Disabling copy prev btn , when kra is completed or In Review and also for old kra
                qw.allowCopy = true;
                if(gl.Status__c == 'KRA Inreview' || gl.Status__c == 'KRA Completed' || gl.Quarter_Start_Date__c < currentFiscalQuarter.StartDate  ){
                    qw.allowCopy = false;
                }

                //smaske : [UAT_066] : [15-July-2024] : passing Mentee/Mentor Submitted var values to disable button based on tabs
                qw.menteeSubmitted = gl.Mentee_KRA_submitted__c;
                qw.mentorSubmitted = gl.Mentor_KRA_submitted__c;


                qlist.add(qw);
            }
            perfWrapper pw = new perfWrapper();
            pw.name = ful.Name;
            pw.nameid = ful.Id;
            pw.fyname = ful.Fiscal_Year__r.Name;
            pw.fyid = ful.Fiscal_Year__c;
            pw.lastmodifyby =ful.LastModifiedBy.Name;
            pw.rating = String.valueOf(ful.Avg_Rating__c);
            pw.lastmodified = ful.LastModifiedDate;
            //smaske : [UAT_PR_008] : replacing Appraisal_Date__c to Next_Appraisal_Date__c
            pw.nextappdate = ful.Resource__r.Next_Appraisal_Date__c;
            pw.qualList = qlist;
            pw.status = ful.Status__c;
            pw.dontallowCreateGoals = true;
            if(ful.Status__c == 'Active'){
                pw.dontallowCreateGoals = false; 
            }
            returnval.add(pw);
        }
        
        return returnval;
    }
    
    
    @AuraEnabled
    public static List<Goal__c> getKraPulseRecords(String loggedInUserConId,String FyId) {
        System.debug(' INSIDE getKraPulseRecords');
        
        //smaske : [UAT_037] : Updating the logic for record creation as we need to create records 4 quarter wise.
        
        List<Goal__c> pulseRecordList = new List<Goal__c>();
        try {
            Fulfillment__c full = [Select Id,Fiscal_Year__c,Resource__c,Status__c FROM Fulfillment__c WHERE Fiscal_Year__c =: FyId AND Resource__c =:loggedInUserConId];
            System.debug(' INSIDE full ' + full);
            
            Map<Id, Id> relationshipMap = new Map<Id, Id>();
            Map<Id,Id> goalsMap = new Map<Id,Id>();
            
            Id pulseRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get(PULSE_RECORD_TYPE).getRecordTypeId();
            
            List<Goal__c> records = [SELECT Id,CreatedDate,KRA_Pulse__c, Check_in_Date__c, Check_In_By__c, Check_In_By__r.Name, Status__c, Resource__c,Fulfillment__c FROM Goal__c WHERE RecordTypeId = :pulseRecTypeId AND (Status__c = :STATUS_REQUESTED OR Status__c = :STATUS_SUBMITTED) AND Check_In_By__c = :loggedInUserConId AND Fulfillment__c=:full.Id AND CreatedDate = THIS_QUARTER]; //AND CreatedDate = THIS_QUARTER
            
            System.debug(' getKraPulseRecords records ' + records);
            for (Resource_Resource_Relationship__c rrr : [SELECT Id, Resource__c, Resource_Reports_To__c FROM Resource_Resource_Relationship__c
                                                          WHERE Resource_Reports_To__c != NULL AND Resource__c != NULL AND Resource_Reports_To__c = :loggedInUserConId 
                                                          AND Resource__r.EMS_TM_User__r.isActive = true
                                                          AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation')
                                                          AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true]){
                                                              relationshipMap.put(rrr.Resource__c, loggedInUserConId);
                                                              //Lokesh   , Testing Employee
                                                          }
            System.debug(' relationshipMap records ' + relationshipMap);
            if (!records.isEmpty()) {
                for(Goal__c go : records){
                    goalsMap.put(go.Resource__c, loggedInUserConId);
                }
                
                if (!relationshipMap.isEmpty() && !goalsMap.isEmpty()) {
                    for (Id rrrKey : relationshipMap.keySet()) {
                        System.debug(' INSIDE MAP CHECK rrrKey' + rrrKey);
                        if (!goalsMap.containsKey(rrrKey)) {
                            // If the goalKey doesn't exist in the relationshipMap, it means the goal should be created
                            pulseRecordList = createKraPulseRecords(loggedInUserConId, full.Id);
                        }
                    }
                }
                //smaske [QA_PR_037]: copying all records to pulseRecordList,
                // coz if for all mentee pulse is created and no new pulse is getting created data was returning null,
                // as we are not returning the "records"
                if (pulseRecordList.isEmpty()) {
                    pulseRecordList.addAll(records);
                }
                
            }else{
                System.debug(' records empty 289 ');
                pulseRecordList = createKraPulseRecords(loggedInUserConId,full.Id);
                System.debug(' records empty 291 ' + pulseRecordList);
            }
            
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        System.debug(' B4 RETURN ' + pulseRecordList);
        return pulseRecordList;     
    }
    
    @AuraEnabled
    public static List<Goal__c> createKraPulseRecords(String loggedInUserConId,String fullId) {
        System.debug(' INSIDE  createKraPulseRecords ');
        List<Goal__c> pulseRecordList = new List<Goal__c>();
        Id pulseRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get(PULSE_RECORD_TYPE).getRecordTypeId();
        Map<Id, Id> relationshipMap = new Map<Id, Id>();
        //Added condition where Resource is not equal to inactive
        //PM_044 @Mukesh Rawat
        for (Resource_Resource_Relationship__c rrr : [SELECT Id, Resource__c, Resource_Reports_To__c FROM Resource_Resource_Relationship__c
                                                      WHERE Resource_Reports_To__c != NULL AND Resource__c != NULL AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation') 
                                                      AND Resource__r.EMS_TM_User__r.isActive = true AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true
                                                      AND Resource_Reports_To__c = :loggedInUserConId]){
                                                          relationshipMap.put(rrr.Resource__c, rrr.Resource_Reports_To__c);
                                                      }
        
        System.debug(' INSIDE  relationshipMap ' + relationshipMap);
        
        //smaske : [UAT_037]   : Fetching Existing Goal records to check if a new reporte is added and missed getting feedback email
        
        List<Goal__c> records = [SELECT Id,CreatedDate,KRA_Pulse__c, Check_in_Date__c, Check_In_By__c, Check_In_By__r.Name, Status__c, Resource__c,Fulfillment__c FROM Goal__c WHERE RecordTypeId = :pulseRecTypeId AND (Status__c = :STATUS_REQUESTED OR Status__c = :STATUS_SUBMITTED) AND Check_In_By__c = :loggedInUserConId AND Fulfillment__c=:fullId AND  CreatedDate = THIS_FISCAL_QUARTER]; //AND CreatedDate = THIS_QUARTER
        Set<Id> uniqueResourceSet = new Set<Id>();
        Set<Id> resources = new Set<Id>();
        for(Goal__c gg : records){
            resources.add(gg.Resource__c);
        }
        
        System.debug(' INSIDE  records ' + resources);
        if (!resources.isEmpty()) {
            for(Id key : relationshipMap.keySet()) {
                Boolean result = resources.contains(key);
                if (!result) {
                    uniqueResourceSet.add(key);
                }
            }
        }
        
        Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        List<Goal__c> KRA = [SELECT Id,CreatedDate,Fulfillment__c FROM Goal__c WHERE RecordTypeId = :kraRecordTypeId AND Fulfillment__c=: fullId AND Quarter_Start_Date__c = THIS_FISCAL_QUARTER LIMIT 1];
        System.debug(' INSIDE  KRA ' + KRA[0]);
        
        System.debug(' INSIDE  resourceSet ' + uniqueResourceSet);
        if (!uniqueResourceSet.isEmpty()) {
            for (Id resource : uniqueResourceSet ) {
                Goal__c pulseRecord = new Goal__c(
                    Resource__c = resource,
                    Check_In_By__c = relationshipMap.get(resource),
                    Check_in_Date__c = Date.today(),
                    Status__c = STATUS_REQUESTED,
                    Fulfillment__c = fullId,
                    RecordTypeId = pulseRecTypeId,
                    KRA_Pulse__c = KRA[0].Id
                );
                pulseRecordList.add(pulseRecord);
            }
        }else {
            for (Id resource : relationshipMap.keySet()) {
                Goal__c pulseRecord = new Goal__c(
                    Resource__c = resource,
                    Check_In_By__c = relationshipMap.get(resource),
                    Check_in_Date__c = Date.today(),
                    Status__c = STATUS_REQUESTED,
                    Fulfillment__c = fullId,
                    RecordTypeId = pulseRecTypeId,
                    KRA_Pulse__c = KRA[0].Id
                );
                pulseRecordList.add(pulseRecord);
            }
        }
        
        System.debug(' INSIDE  pulseRecordList ' + pulseRecordList);
        
        List<Database.SaveResult> results;
        try {
            results = Database.insert(pulseRecordList, false);
        } catch (DmlException e) {
            throw new AuraHandledException('Unable to perform the DML operation on Goal records: ' + e.getMessage());
        }
        
        for (Database.SaveResult result : results) {
            if (result.isSuccess()) {
                System.debug('Successfully inserted Goal record: ' + result.getId());
            } else {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error Status: ' + error.getStatusCode() + ', Error Fields: ' + error.getFields());
                }
            }
        }
        System.debug(' pulseRecordList CREATE RETURN : ' + pulseRecordList);
        return pulseRecordList;
    }
    
    
    public class perfWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String nameid;
        @AuraEnabled
        public String fyname;
        @AuraEnabled
        public String fyid;
        @AuraEnabled
        public String rating;
        @AuraEnabled
        public String lastmodifyby;
        @AuraEnabled
        public Datetime lastmodified;
        @AuraEnabled
        public Date nextappdate;
        @AuraEnabled
        public Boolean dontallowCreateGoals;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public List<quatWrapper> qualList;
        
    }
    
    public class quatWrapper {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String nameid;
        @AuraEnabled
        public Date qstartdate;
        @AuraEnabled
        public Date qendate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String typeval;
        @AuraEnabled
        public String rating;
        @AuraEnabled
        public Decimal overallRating; //Ravitheja
        @AuraEnabled
        public boolean allowedit;
        @AuraEnabled
        public boolean menteeSubmitted;
        @AuraEnabled
        public boolean mentorSubmitted;
        @AuraEnabled
        public boolean allowCopy;
        
    }
    
    
    
    
    public class datawrapper {
        @AuraEnabled
        public String currentFYId;
        @AuraEnabled
        public String currentResId;
        @AuraEnabled
        public String currentName;
        @AuraEnabled
        public Boolean dontshowThePulse;
        @AuraEnabled
        public Map<String,String> fyListMap;
        @AuraEnabled
        public Boolean showGenPerKra;
    }
    
    
    /* @AuraEnabled
public static List<Resource_Resource_Relationship__c> getProjectAssigneebyContactId(Id userId) {
//Id loggedInUser = Userinfo.getUserId();
// Ensure accountId is not null or empty
if (String.isEmpty(userId)) {
throw new AuraHandledException('loggedInUser ID cannot be null or empty.');
}
system.debug('Entered controller');
User u = [SELECT Id,name,ContactId from User where Id =:userId];
List<Resource_Resource_Relationship__c> menteeRecords = new List<Resource_Resource_Relationship__c>();
if(u.ContactId != null){
menteeRecords= [select id,name,Resource_Reports_To__r.name,Resource_Reports_To__r.Id,Resource__r.name from Resource_Resource_Relationship__c where  Resource_Reports_To__r.Id =:u.ContactId];
system.debug('Inside controller');
}
system.debug('menteeRecords'+menteeRecords);
return menteeRecords;

}*/
    
    public class projectAssgnWrapper {
        
        @AuraEnabled
        public String empName{get;set;}
        @AuraEnabled
        public String projectAssigmentId{get;set;}
        @AuraEnabled
        public String offshoremanagerid{get;set;}
        @AuraEnabled
        public String offshoremanagerName{get;set;}
        @AuraEnabled
        public String onshoremanagerid{get;set;}
        @AuraEnabled
        public String onshoremanagerName{get;set;}
        @AuraEnabled
        public Date startDate{get;set;}
        @AuraEnabled
        public Date endDate{get;set;}
        @AuraEnabled
        public String projectName{get;set;}
        @AuraEnabled
        public String projectid{get;set;}
        @AuraEnabled
        public List<ManagerOption> managerOptions { get; set; }      
    }
    
    public class ManagerOption {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        
        public ManagerOption(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<projectAssgnWrapper> getMenteeProjectAssigne(Id contactId) {
        
        if (String.isEmpty(contactId)) {
            throw new AuraHandledException('loggedInUser ID cannot be null or empty.');
        }
        
        List<AggregateResult> timesheetAggregate = [
            SELECT Assignment__c, SUM(Number_of_Hours__c) totalHours
            FROM EMS_TM_Timesheet_Record__c 
            WHERE EMS_Timesheet__r.Resource__c = :contactId AND 
            (EMS_Timesheet__r.Week_Start_Date__c = THIS_QUARTER OR EMS_Timesheet__r.Week_End_Date__c = THIS_QUARTER) and Status__c != 'Rejected'  
            GROUP BY Assignment__c];
        system.debug('timesheetAggregate'+timesheetAggregate);
        
        Set<Id> assignmentIds = new Set<Id>();
        for (AggregateResult ar : timesheetAggregate) {
            Decimal totalHours = (Decimal)ar.get('totalHours');
            if (totalHours >= 80) {
                assignmentIds.add((Id)ar.get('Assignment__c'));
            }
        }
        
        List<EMS_TM_Assignment__c> projectAssigneeidList = [SELECT Id,name,EMS_TM_EmployeeName__r.name,EMS_TM_EmployeeName__r.Work_Location_Country__c,EMS_TM_Status_Asgn__c,
                                                            Offshore_PM_Configure__c,Onshore_PM_Configure__c,Other_PM_Configure__c,
                                                            EMS_TM_ProjectName_Asgn__r.name,EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.Name,
                                                            EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,EMS_TM_ProjectName_Asgn__r.Project_Manager__c,
                                                            EMS_TM_ProjectName_Asgn__r.Project_Manager__r.Name,EMS_TM_StartDate_Asgn__c,EMS_TM_EndDate_Asgn__c 
                                                            from EMS_TM_Assignment__c where EMS_TM_EmployeeName__r.Id =:contactId   and Id =:assignmentIds ];
        system.debug('projectAssigneeidList-->'+projectAssigneeidList);
        List<projectAssgnWrapper> wrapperlist = new List<projectAssgnWrapper>();
        for(EMS_TM_Assignment__c assgn : projectAssigneeidList){
            projectAssgnWrapper wrp = new projectAssgnWrapper();
            wrp.empName =  assgn.EMS_TM_EmployeeName__r.name;
            wrp.projectAssigmentId = assgn.Id;
            wrp.offshoremanagerName = assgn.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.Name;
            wrp.offshoremanagerid=assgn.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c;
            wrp.onshoremanagerName = assgn.EMS_TM_ProjectName_Asgn__r.Project_Manager__r.Name;
            wrp.onshoremanagerid=assgn.EMS_TM_ProjectName_Asgn__r.Project_Manager__c; 
            wrp.startDate = assgn.EMS_TM_StartDate_Asgn__c;
            wrp.endDate = assgn.EMS_TM_EndDate_Asgn__c;
            wrp.projectName = assgn.EMS_TM_ProjectName_Asgn__r.name;
            wrp.projectid = assgn.EMS_TM_ProjectName_Asgn__c;
            
            wrp.managerOptions = new List<ManagerOption>();
            //wrp.managerOptions.add(new ManagerOption(' ' + 'None', 'None'));
            if(wrp.offshoremanagerid == wrp.onshoremanagerid && !assgn.Offshore_PM_Configure__c && !assgn.Onshore_PM_Configure__c){
                wrp.managerOptions.add(new ManagerOption('Onshore & Offshore Manager: ' + wrp.offshoremanagerName, wrp.offshoremanagerid));
            }else{
                if (wrp.offshoremanagerid != null && !assgn.Offshore_PM_Configure__c) {
                    wrp.managerOptions.add(new ManagerOption('Offshore Manager: ' + wrp.offshoremanagerName, wrp.offshoremanagerid));
                }
                if (wrp.onshoremanagerid != null && !assgn.Onshore_PM_Configure__c) {
                    wrp.managerOptions.add(new ManagerOption('Onshore Manager: ' + wrp.onshoremanagerName, wrp.onshoremanagerid));
                }
                if (wrp.onshoremanagerid != null && wrp.offshoremanagerid != null && !assgn.Offshore_PM_Configure__c && !assgn.Onshore_PM_Configure__c) {
                    wrp.managerOptions.add(new ManagerOption('Both Managers ' + '', wrp.onshoremanagerid +','+ wrp.offshoremanagerid));
                }
            }  
            if(!assgn.Other_PM_Configure__c){
                wrp.managerOptions.add(new ManagerOption('Other ' + '', 'Other'));
            }   
            wrapperlist.add(wrp);
        }
        
        return wrapperlist;
    }
    
    //Sangharsh :   :Creating Reporting Manager Answer Record, Refering in projectAssignmentTable LWC
    @AuraEnabled
    public static String createPMAnswerConfigureForManager(String contactId, String managerContact, String projectId, String projectassigmentid) {
        List<Id> managerContactList = managerContact.split(',');
        Set<Id> managerContactSet = new Set<Id>(managerContactList);
        System.debug('managerContactList: ' + managerContactList);
        
       /* List<Contact> conRecList =[Select Id,name,EMS_TM_User__c from Contact where Id IN :managerContactSet ];*/
        // Get Record Type IDs
        Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        Id questionRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        // Query for goals
        List<Goal__c> goalList = [SELECT Id, Type__c, RecordTypeId, Status__c, Fulfillment__r.Fiscal_Year__c,Resource__r.ContactName__c  
                                  FROM Goal__c 
                                  WHERE Type__c = 'KRA' 
                                  AND Status__c = 'In Progress' 
                                  AND Resource__c = :contactId 
                                  AND RecordTypeId = :kraRecordTypeId 
                                  AND CreatedDate = THIS_QUARTER];
        
        if (goalList.isEmpty()) {
            throw new AuraHandledException('No KRA goals found for the specified contact in the current quarter.');
        }
        
        // Query for contact
        List<Contact> contactList = [SELECT Id, Resource_Role__c 
                                     FROM Contact 
                                     WHERE Id = :contactId];
        
        list<Resource_Resource_Relationship__c> mentorlst =[Select id,Relationship_Type__c,Resource__c,Resource_Reports_To__c from Resource_Resource_Relationship__c 
                                                         where Relationship_Type__c='Mentor' AND Resource__c=:contactId];
        
        if (contactList.isEmpty()) {
            throw new AuraHandledException('Contact not found.');
        }
        
        // Query for project assignments
        List<EMS_TM_Assignment__c> projectAssignmentList = [SELECT Id, EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,
                                                            EMS_TM_ProjectName_Asgn__r.Project_Manager__c, Other_Resource_PM_Configure__c 
                                                            FROM EMS_TM_Assignment__c 
                                                            WHERE Id = :projectassigmentid];
        
        
        List<PM_Configure__c> pmAnswerList = new List<PM_Configure__c>();    
        
        for (Id reportingManager : managerContactSet) {
            System.debug('reportingManager: ' + reportingManager);
            Id gettingownerID =[Select Id, EMS_TM_User__c from Contact where Id =:reportingManager limit 1].EMS_TM_User__c;
            for (PM_Configure__c pm : [SELECT Id, Configuration_Type__c, Resource_Role__c,Name__c, Area__c,Question__c
                                       FROM PM_Configure__c 
                                       WHERE Configuration_Type__c = 'KRA' 
                                       AND Resource_Role__c = :contactList[0].Resource_Role__c 
                                       AND RecordTypeId = :questionRecordTypeId]) {
                                           PM_Configure__c pmAnswer = new PM_Configure__c();
                                           pmAnswer.Related_Question__c = pm.Id;
                                           pmAnswer.Name__c = goalList[0].Resource__r.ContactName__c + ' '+pm.Area__c +' '+pm.Question__c;
                                           pmAnswer.Status__c = 'Awaiting Response';
                                           pmAnswer.Reporting_Contact__c = reportingManager;
                                           pmAnswer.Project_Name__c = projectId;
                                           pmAnswer.Fiscal_Year__c = goalList[0].Fulfillment__r.Fiscal_Year__c;
                                           pmAnswer.KRA__c = goalList[0].Id;
                                           pmAnswer.Mentor__c=mentorlst[0].Resource_Reports_To__c!=null?mentorlst[0].Resource_Reports_To__c:null;
                                           pmAnswer.RecordTypeId = answerRecordTypeId;
                                           pmAnswer.Mentee__c=goalList[0].Resource__c;	
                                          if(gettingownerID!=null){
                                               pmAnswer.OwnerId = gettingownerID;
                                           }
                                          // pmAnswer.OwnerId = 
                                        //add reportingManager as the owner of the record
                                           pmAnswerList.add(pmAnswer);
                                       }
            
            EMS_TM_Assignment__c projectAssignment = new EMS_TM_Assignment__c();
            projectAssignment.Id = projectAssignmentList[0].Id;
            
            Boolean isOffshorePM = reportingManager == projectAssignmentList[0].EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c;
            Boolean isOnshorePM = reportingManager == projectAssignmentList[0].EMS_TM_ProjectName_Asgn__r.Project_Manager__c;
            
            if (isOffshorePM) {
                projectAssignment.Offshore_PM_Configure__c = true;  
            }
            
            if (isOnshorePM) {
                projectAssignment.Onshore_PM_Configure__c = true;  
            }
            
            if (isOffshorePM && isOnshorePM) {
                projectAssignment.Offshore_PM_Configure__c = true;
                projectAssignment.Onshore_PM_Configure__c = true;
            }
            
            if (!isOffshorePM && !isOnshorePM) {
                projectAssignment.Other_PM_Configure__c = true; 
                projectAssignment.Other_Resource_PM_Configure__c = reportingManager;
            }
            update projectAssignment;
        }
        
        try {
            if (!pmAnswerList.isEmpty()) {
                insert pmAnswerList;
            }
            return 'success'; 
        } catch (Exception ex) {
            throw new AuraHandledException('An error occurred while processing the request: ' + ex.getMessage());
        }
    }
    
}