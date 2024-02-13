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
        System.debug('reportesList :' + reportesList);
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
          returnList = [SELECT Id,Name,Resource__c,Resource__r.Appraisal_Date__c,Fiscal_Year__c,Fiscal_Year__r.Name,Avg_Rating__c,Recognization_Type__c,LastModifiedDate,LastModifiedBy.Name,Status__c,
                         (SELECT Id,Name,Check_in_Date__c,Quarter_Start_Date__c,Goal_Name__c,Quarter_End_Date__c,Rating__c,Status__c,Type__c, Overall_Rating__c FROM Goals__r WHERE RecordTypeId =:kraRecordTypeId) FROM Fulfillment__c WHERE Fiscal_Year__c =:fyId and Resource__r.EMS_TM_User__c=:Userinfo.getUserId()];
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
               qw.rating = String.valueOf(gl.Rating__c);
               qw.overallRating = gl.Overall_Rating__c;
               qw.allowedit = false;
               //smaske : PM_061 : updating conditon to only allow edit when status is "Active" in MY METRIC TAB
               //Previously it was : gl.Status__c != 'KRA Complete'
                if(gl.Status__c == 'Active'){
                  qw.allowedit = true;  
                }
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
               pw.nextappdate = ful.Resource__r.Appraisal_Date__c;
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
        for(Grid_Configuration__c gc : [SELECT Id,KRA_Area__c,KRA_Competency__c,Description__c FROM Grid_Configuration__c WHERE Resource_Role__c=:resourceRoleId]){
            if(areawithcompeneny.containsKey(gc.KRA_Area__c)){
                quatWrapper qw = new quatWrapper();
                qw.name=gc.KRA_Competency__c;
                qw.typeval=gc.Description__c;
                areawithcompeneny.get(gc.KRA_Area__c).add(qw);
            }else{
                 List<quatWrapper> qlist = new List<quatWrapper>();
                quatWrapper qw = new quatWrapper();
                qw.name=gc.KRA_Competency__c;
                qw.typeval=gc.Description__c;
                qlist.add(qw);
                areawithcompeneny.put(gc.KRA_Area__c,qlist);
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
        List<Fulfillment__c> returnList = new List<Fulfillment__c>();
        List<perfWrapper> returnval = new List<perfWrapper>();
        returnList = [SELECT Id,Name,Resource__c,Resource__r.Appraisal_Date__c,Fiscal_Year__c,Fiscal_Year__r.Name,Avg_Rating__c,Recognization_Type__c,LastModifiedDate,LastModifiedBy.Name,Status__c,
                         (SELECT Id,Name,Check_in_Date__c,Quarter_Start_Date__c,Goal_Name__c,Quarter_End_Date__c,Rating__c,Status__c,Type__c, Overall_Rating__c FROM Goals__r WHERE RecordTypeId =:kraRecordTypeId) FROM Fulfillment__c WHERE Fiscal_Year__c =:fyId and Resource__c =:resourceId]; 
        
        
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
               qw.rating = String.valueOf(gl.Rating__c);
               qw.overallRating = gl.Overall_Rating__c;
               qw.allowedit = false;
                //smaske : PM_061 : updating conditon to only allow edit when status is "KRA Inreview" in MY TEAM TAB for selected Reportee's KRA
               //Previously it was : gl.Status__c != 'KRA Completed'
                if(gl.Status__c == 'KRA Inreview'){
                  qw.allowedit = true;  
                }
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
               pw.nextappdate = ful.Resource__r.Appraisal_Date__c;
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

        

        List<Goal__c> pulseRecordList = new List<Goal__c>();
        try {
            Fulfillment__c full = [Select Id,Fiscal_Year__c,Resource__c,Status__c FROM Fulfillment__c WHERE Fiscal_Year__c =: FyId AND Resource__c =:loggedInUserConId AND Status__c = 'Active'];
            System.debug(' INSIDE full ' + full);

            Map<Id, Id> relationshipMap = new Map<Id, Id>();
            Map<Id,Id> goalsMap = new Map<Id,Id>();

            Id pulseRecTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get(PULSE_RECORD_TYPE).getRecordTypeId();
            
            List<Goal__c> records = [SELECT Id, Check_in_Date__c, Check_In_By__c, Check_In_By__r.Name, Status__c, Resource__c,Fulfillment__c FROM Goal__c WHERE RecordTypeId = :pulseRecTypeId AND (Status__c = :STATUS_REQUESTED OR Status__c = :STATUS_SUBMITTED) AND Resource__c = :loggedInUserConId AND Fulfillment__c=:full.Id];

            System.debug(' getKraPulseRecords records ' + records);
            for (Resource_Resource_Relationship__c rrr : [SELECT Id, Resource__c, Resource_Reports_To__c FROM Resource_Resource_Relationship__c
                                                          WHERE Resource_Reports_To__c != NULL AND Resource__c != NULL AND Resource_Reports_To__c = :loggedInUserConId 
                                                          AND Resource__r.EMS_TM_User__r.isActive = true
                                                          AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation')
                                                          AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true]){//[SELECT Id, Resource__c, Resource_Reports_To__c FROM Resource_Resource_Relationship__c  WHERE Resource_Reports_To__c != NULL AND Resource__c != NULL AND Resource_Reports_To__c = :loggedInUserConId]) {                                                                                                               
                                                              relationshipMap.put(loggedInUserConId, rrr.Resource__c);
                                                              //Testing   , Lokesh
                                                          }
                                                          System.debug(' relationshipMap records ' + relationshipMap);
            if (!records.isEmpty()) {

                for(Goal__c go : records){
                    goalsMap.put(loggedInUserConId, go.Check_In_By__c);
                }

                if(!relationshipMap.isEmpty() && !goalsMap.isEmpty()){
                    for(Id key : relationshipMap.keySet()) {
                        Id subContactRRR = relationshipMap.get(loggedInUserConId);
                        Id subContactGoal = goalsMap.get(loggedInUserConId);

                        System.debug(' INSIDE MAP CHECK ' + subContactRRR  + ' --- ' + subContactGoal);
                        if( subContactRRR != subContactGoal){
                            pulseRecordList = createKraPulseRecords(loggedInUserConId,full.Id);
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
                System.debug(' records not empty 271 ');
                pulseRecordList = createKraPulseRecords(loggedInUserConId,full.Id);
                System.debug(' records not empty 271 ' + pulseRecordList);
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
                                                      AND Resource_Reports_To__c = :loggedInUserConId]){/*[SELECT Id, Resource__c, Resource_Reports_To__c FROM Resource_Resource_Relationship__c  WHERE Resource_Reports_To__c != NULL AND Resource__c != NULL AND Resource__r.EMS_RM_ApplicantStatus_Update__c != 'Inactive' AND Resource_Reports_To__c = :loggedInUserConId]) {*/
                                                                                                                                                 
                                                          relationshipMap.put(rrr.Resource__c, rrr.Resource_Reports_To__c);
                                                      }

        System.debug(' INSIDE  relationshipMap ' + relationshipMap);
        for (Id resource : relationshipMap.keySet()) {
            Goal__c pulseRecord = new Goal__c(
                Resource__c = relationshipMap.get(resource),
                Check_In_By__c = resource,
                Check_in_Date__c = Date.today(),
                Status__c = STATUS_REQUESTED,
                Fulfillment__c = fullId,
                RecordTypeId = pulseRecTypeId
            );
            pulseRecordList.add(pulseRecord);
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
        public String overallRating;
        @AuraEnabled
        public boolean allowedit;
        
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
}