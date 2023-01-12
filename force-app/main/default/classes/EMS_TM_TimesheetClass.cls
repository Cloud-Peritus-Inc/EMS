public class EMS_TM_TimesheetClass {

    
    @AuraEnabled(cacheable=true)
    public static wrapperAP getAssignmentProjectWire( date week, Boolean wireMethod, Id userId ) {
        wrapperAP returnObj = getAssignmentProject(week, wireMethod, userId);
        return returnObj;
    }

    @AuraEnabled
    public static wrapperAP getAssignmentProject( date week, Boolean wireMethod, Id userId ) {
        wrapperAP returnObj = new wrapperAP();
        List<Id> projects = new List<Id>();
        List<EMS_TM_Assignment__c> assignmentList = new List<EMS_TM_Assignment__c>();
        List<EMS_TM_Project__c> projectList = new List<EMS_TM_Project__c>();
        List<EMS_TM_Picklist_value__c> picklistValues = new List<EMS_TM_Picklist_value__c>();
        User user = new user();
        Id systemAdminId;

        List<Id> idList = new List<Id>();
        List<Profile> profileDetails = [SELECT Id, Name FROM Profile WHERE Name IN :EMS_TM_GlobalConstants.USERPROFILES];
        
        for (Profile profile : profileDetails) {
            if (profile.Name == EMS_TM_GlobalConstants.SYSTEMADMINISTRATOR) {
                systemAdminId = profile.Id;
            }
            idList.add(profile.Id);
        }

        user = [SELECT Id, ProfileId, FirstName, LastName, Name, ContactId,
                (Select id, lastname, Location__c from Contacts__r)
                FROM User WHERE Id = :userId];
        
        String location= user.Contacts__r[0].Location__c;

        System.debug('location'+location);

        Date weekStart = date.today();
        Date weekEnd = date.today();

        String timeZone = UserInfo.getTimeZone().getID();
        Datetime dateGMT=System.now();// here you can user your dates e.g. createddate
        Date d1=Date.valueOf(dateGMT);
        date s1=d1.toStartofWeek().addDays(1);

        System.debug('date.today() e'+date.today());
        System.debug('timeZon e'+timeZone);
        System.debug('dateGMT '+dateGMT);
        System.debug('d1 '+d1);
        System.debug('s1 '+s1);

        if (wireMethod) {
            Date today = Date.today();
            weekStart = today.toStartofWeek().addDays(1);
            weekEnd = today.toStartofWeek().addDays(7);
        } else {
            weekStart = week;
            weekEnd = week.addDays(6);
        }

        List<EMS_TM_Assignment__c> assignments = [SELECT Id, EMS_TM_EmployeeName__c, 
                                                EMS_TM_Numberofallocatedhours__c, 
                                                EMS_TM_ProjectName_Asgn__c,
                                                EMS_TM_StartDate_Asgn__c, EMS_TM_EndDate_Asgn__c, 
                                                EMS_TM_AssignedAs__c
                                                FROM EMS_TM_Assignment__c 
                                                WHERE EMS_TM_EmployeeName__r.EMS_TM_User__c= :userId
                                                AND EMS_TM_StartDate_Asgn__c <= :weekEnd];

        if (!assignments.isEmpty()) {
            for (EMS_TM_Assignment__c assignment : assignments) {
                if (assignment.EMS_TM_EndDate_Asgn__c == null) {
                    assignmentList.add(assignment);
                    projects.add(assignment.EMS_TM_ProjectName_Asgn__c);
                } else if (assignment.EMS_TM_EndDate_Asgn__c >= weekStart) {
                    assignmentList.add(assignment);
                    projects.add(assignment.EMS_TM_ProjectName_Asgn__c);
                }
            }
        }

        List<EMS_TM_Calendar__c> holidays = [SELECT Id, Name, EMS_TM_Calendar_Date__c,
                                                EMS_TM_Type_Of_Holiday__c, Location__c
                                                FROM EMS_TM_Calendar__c
                                                WHERE EMS_TM_Calendar_Date__c >= :weekStart
                                                AND EMS_TM_Calendar_Date__c <= :weekEnd
                                                AND Location__c = :location];
        
      // added for leave integration 89 to 115  
        set <Date> dates = new set<Date>(); 
        List<EMS_LM_Leave_History__c> leaves1 = [SELECT Id, EMS_LM_Leave_Start_Date__c,
                                                EMS_LM_Leave_End_Date__c
                                                FROM EMS_LM_Leave_History__c
                                                WHERE EMS_LM_Contact__r.EMS_TM_User__c= :userId AND EMS_LM_Status__c = 'Approved'];
        for(EMS_LM_Leave_History__c l1:leaves1){
        Date startDate = l1.EMS_LM_Leave_Start_Date__c;
        Date endDate = l1.EMS_LM_Leave_End_Date__c;
        Set<Date> holidaysSet = new Set<Date>();
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c from EMS_TM_Calendar__c where Location__c = :location])  // need to change Location
        {  
            holidaysSet.add(currHoliday.EMS_TM_Calendar_Date__c);  
        }
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i; 
            if(dt >= weekStart && dt<= weekEnd){
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)))  {
                    dates.add(dt);                 
            }
            }
        }
        }
        List<Date> leaves = new List<Date>(dates);                                                

        Id recordTypeId = [SELECT Id FROM RecordType
                            WHERE Name = :EMS_TM_GlobalConstants.GLOBALPROJECTS].Id;
        projectList = [SELECT Id, EMS_TM_Project_Type__c, Name
                        FROM EMS_TM_Project__c WHERE Id in :projects
                        OR RecordTypeId = :recordTypeId];

        picklistValues = [SELECT Id, EMS_TM_Value__c, EMS_TM_Label__c, 
                                                        EMS_TM_Type__c FROM EMS_TM_Picklist_value__c];

        wrapperTimesheetRecords timesheetWrapper = new wrapperTimesheetRecords();
        timesheetWrapper = getTimeSheetData( weekStart, userId );

        returnObj.project           = projectList;
        returnObj.holidays          = holidays;
        returnObj.assignment        = assignmentList;
        returnObj.picklist          = picklistValues;
        returnObj.enableManagerView = user.ProfileId == systemAdminId ? true : false;
        returnObj.User              = user;
        returnObj.projectIdList     = idList;
        returnObj.leaves            = leaves;
        if (!(timesheetWrapper.timeSheet == null)) {
            returnObj.timeSheet         = timesheetWrapper.timeSheet;
            returnObj.timeSheetRecords  = timesheetWrapper.timeSheetRecords == null ? null : timesheetWrapper.timeSheetRecords;
        }

        return returnObj;
    }

    @AuraEnabled
    public static wrapperTimesheetRecords getTimeSheetData( date week, Id userId ) {
        wrapperTimesheetRecords wrapper = new wrapperTimesheetRecords();
        List<EMS_TM_Timesheet_Record__c> timeSheetRecordValues = new List<EMS_TM_Timesheet_Record__c>();

        List<EMS_Timesheet__c> timeSheetValues = [SELECT Id, User__c, User__r.Name,
                                                EMS_TM_Week__c, EMS_TM_Status__c
                                                FROM EMS_Timesheet__c where User__c = :userId
                                                AND EMS_TM_Week__c = :week LIMIT 1];

        if (!timeSheetValues.isEmpty()) {
            timeSheetRecordValues = [SELECT Id, EMS_TM_Sun__c, EMS_TM_Mon__c, EMS_TM_Tue__c,
                                    EMS_TM_Wed__c, EMS_TM_Thu__c, EMS_TM_Fri__c, EMS_TM_Sat__c,
                                    EMS_TM_ProjectTask__c, EMS_TM_Project__c,
                                    EMS_TM_Week__c, User__c, EMS_Timesheet__c, EMS_TM_Remarks__c,
                                    EMS_TM_OtherTask__c
                                    FROM EMS_TM_Timesheet_Record__c
                                    WHERE EMS_Timesheet__c = :timeSheetValues[0].Id];
            wrapper.timeSheet = timeSheetValues[0];
            wrapper.timeSheetRecords = !timeSheetRecordValues.isEmpty() ? timeSheetRecordValues : null;
        }
        return wrapper;
    }

    @AuraEnabled
    public static wrapperTimesheetRecords getPreWeekData( EMS_Timesheet__c timesheet ) {
        wrapperTimesheetRecords wrapper = new wrapperTimesheetRecords();

        Date weekStart = timesheet.EMS_TM_Week__c.addDays(-7);

        list<EMS_Timesheet__c> timeSheetValues = [SELECT id
                                                        FROM EMS_Timesheet__c  
                                                        WHERE EMS_TM_Week__c = :weekStart  
                                                        AND User__c = :timesheet.User__c];

        if (!timeSheetValues.isEmpty()) {
            List<EMS_TM_Timesheet_Record__c> timeSheetRecordValues = [SELECT Id, EMS_TM_Sun__c, EMS_TM_Mon__c, EMS_TM_Tue__c,
                                    EMS_TM_Wed__c, EMS_TM_Thu__c, EMS_TM_Fri__c, EMS_TM_Sat__c,
                                    EMS_TM_ProjectTask__c, EMS_TM_Project__c,
                                    EMS_TM_Week__c, User__c, EMS_Timesheet__c, EMS_TM_Remarks__c,
                                    EMS_TM_OtherTask__c
                                    FROM EMS_TM_Timesheet_Record__c
                                    WHERE EMS_Timesheet__c = :timeSheetValues[0].Id
                                    AND User__c = :timesheet.User__c];
            wrapper.timeSheet = timeSheetValues[0];
            wrapper.timeSheetRecords = !timeSheetRecordValues.isEmpty() ? timeSheetRecordValues : null;
        }
        return wrapper;
    }

    @AuraEnabled
    public static Boolean duplicatetimesheetLWC( EMS_Timesheet__c timesheet ) {
        Boolean returnStatement = false;
        list<EMS_Timesheet__c> listOfDuplicateSheets = [SELECT id
                                                        FROM EMS_Timesheet__c  
                                                        WHERE EMS_TM_Week__c = :timesheet.EMS_TM_Week__c  
                                                        AND User__c = :timesheet.User__c];
        if(listOfDuplicateSheets.size()>0) {
            returnStatement = true;
        } else {
            returnStatement = false;
        }
        return returnStatement;
    }

    public static EMS_Timesheet__c underWorkingHourDays(EMS_Timesheet__c timesheet){
        String  underWorkedDays = '';
        String  OverWorkedDays = '';
        String  comoff= '';
        if(timesheet.EMS_TM_Mon__c <8) {
            underWorkedDays = 'Mon, ';
        } else if(timesheet.EMS_TM_Mon__c >8) {
            OverWorkedDays = 'Mon, ';
        }

        if(timesheet.EMS_TM_Tue__c <8){
            underWorkedDays +='Tue, ';
        } else if(timesheet.EMS_TM_Tue__c >8) {
            OverWorkedDays = 'Tue, ';
        }

        if(timesheet.EMS_TM_Wed__c <8){
            underWorkedDays +='Wed, ';
        } else if(timesheet.EMS_TM_Wed__c >8) {
            OverWorkedDays = 'Wed, ';
        }

        if(timesheet.EMS_TM_Thu__c <8){
            underWorkedDays +='Thu, ';
        } else if(timesheet.EMS_TM_Thu__c >8) {
            OverWorkedDays = 'Thu, ';
        }

        if(timesheet.EMS_TM_Fri__c <8){
            underWorkedDays +='Fri';
        } else if(timesheet.EMS_TM_Sat__c >8) {
            OverWorkedDays = 'Fri';
        }

        if(timesheet.EMS_TM_Sun__c >0){
            comoff ='Sat, ';
        }
        if(timesheet.EMS_TM_Sat__c >0){
            comoff +='Sun';
        }
        timesheet.Comp_off__c = comoff;
        timesheet.Under_hours_Days__c = underWorkedDays;
        timesheet.Over_Worked_Days__c = OverWorkedDays;

        return timesheet;
    }

    @AuraEnabled
    public static String saveTimeSheetRecords( List<EMS_TM_Timesheet_Record__c> timeRecords, EMS_Timesheet__c timesheet ) {

        String returnStatement = '';
        Boolean isError = false;
        Id createdId = null;

        EMS_Timesheet__c timeSheetRecord = renderTimeSheet(timesheet);

        Database.SaveResult timesheetSaveResult = Database.insert(timeSheetRecord, false);

        if (timesheetSaveResult.isSuccess()) {
            createdId = timesheetSaveResult.getId();
            returnStatement = 'Success';
        } else {
            for(Database.Error objErr : timesheetSaveResult.getErrors()) {
                isError = true;
            }
        }

        List<EMS_TM_Timesheet_Record__c> objRecordsList = new List<EMS_TM_Timesheet_Record__c>();
        if (isError) {
            returnStatement = JSON.serialize(timesheetSaveResult);
        } else if (!isError) {
            for(EMS_TM_Timesheet_Record__c record : timeRecords) {
                EMS_TM_Timesheet_Record__c row = renderTimeRecord( record, timesheet, createdId );
                objRecordsList.add(row);
            }

            Database.SaveResult[] saveResultList = Database.insert(objRecordsList, false);
            for (Database.SaveResult sr : saveResultList) {
                if (sr.isSuccess()) {
                    returnStatement = 'Success';
                } else {
                    returnStatement = JSON.serialize(saveResultList);
                }
            }
        }

        if (returnStatement == 'Success') {
            returnStatement = returnStatement + createdId;
        }
        
        return returnStatement;
    }

    public static EMS_Timesheet__c renderTimeSheet( EMS_Timesheet__c timesheet ) {

        EMS_Timesheet__c timeSheetRecord = new EMS_Timesheet__c();
        timeSheetRecord.EMS_TM_Sun__c                       = timesheet.EMS_TM_Sun__c;
        timeSheetRecord.EMS_TM_Mon__c                       = timesheet.EMS_TM_Mon__c;
        timeSheetRecord.EMS_TM_Tue__c                       = timesheet.EMS_TM_Tue__c;
        timeSheetRecord.EMS_TM_Wed__c                       = timesheet.EMS_TM_Wed__c;
        timeSheetRecord.EMS_TM_Thu__c                       = timesheet.EMS_TM_Thu__c;
        timeSheetRecord.EMS_TM_Fri__c                       = timesheet.EMS_TM_Fri__c;
        timeSheetRecord.EMS_TM_Sat__c                       = timesheet.EMS_TM_Sat__c;
        timeSheetRecord.EMS_TM_Week__c                      = timesheet.EMS_TM_Week__c;
       // timeSheetRecord.Complete_Week__c                    = timesheet.Complete_Week__c;
        timeSheetRecord.EMS_TM_Remarks__c                   = timesheet.EMS_TM_Remarks__c;
        timeSheetRecord.EMS_TM_Status__c                    = timesheet.EMS_TM_Status__c;
        timeSheetRecord.User__c                             = timesheet.User__c;
        timeSheetRecord = underWorkingHourDays(timeSheetRecord);

        return timeSheetRecord;
    }

    public static EMS_TM_Timesheet_Record__c renderTimeRecord( EMS_TM_Timesheet_Record__c timerecord, EMS_Timesheet__c timesheet, Id timesheetId ) {

        EMS_TM_Timesheet_Record__c timeRecordRow = new EMS_TM_Timesheet_Record__c();
        timeRecordRow.EMS_TM_Sun__c                       = timerecord.EMS_TM_Sun__c;
        timeRecordRow.EMS_TM_Mon__c                       = timerecord.EMS_TM_Mon__c;
        timeRecordRow.EMS_TM_Tue__c                       = timerecord.EMS_TM_Tue__c;
        timeRecordRow.EMS_TM_Wed__c                       = timerecord.EMS_TM_Wed__c;
        timeRecordRow.EMS_TM_Thu__c                       = timerecord.EMS_TM_Thu__c;
        timeRecordRow.EMS_TM_Fri__c                       = timerecord.EMS_TM_Fri__c;
        timeRecordRow.EMS_TM_Sat__c                       = timerecord.EMS_TM_Sat__c;
        timeRecordRow.EMS_TM_Project__c                   = timerecord.EMS_TM_Project__c;
        timeRecordRow.EMS_TM_ProjectTask__c               = timerecord.EMS_TM_ProjectTask__c;
        timeRecordRow.EMS_TM_OtherTask__c                 = timerecord.EMS_TM_OtherTask__c;
        timeRecordRow.EMS_TM_Week__c                      = timesheet.EMS_TM_Week__c;
        timeRecordRow.User__c                             = timesheet.User__c;
        timeRecordRow.EMS_TM_Remarks__c                   = timerecord.EMS_TM_Remarks__c;
        timeRecordRow.EMS_Timesheet__c                    = timesheetId;

        return timeRecordRow;
    }

    @AuraEnabled
    public static String reviseTimesheet( EMS_Timesheet__c timesheet ) {
        String returnStatement;
        try {
            List<EMS_Timesheet__c> timeSheetValues = [SELECT Id, User__c, User__r.Name,
                                                    EMS_TM_Week__c, EMS_TM_Status__c
                                                    FROM EMS_Timesheet__c where User__c = :timesheet.User__c
                                                    AND EMS_TM_Week__c = :timesheet.EMS_TM_Week__c LIMIT 1];
            timeSheetValues[0].EMS_TM_Status__c = EMS_TM_GlobalConstants.STATUS_SAVED;
            Database.SaveResult[] timesheetupdateResult = Database.update(timeSheetValues, false);
            for (Database.SaveResult sr : timesheetupdateResult) {
                if (sr.isSuccess()) {
                    returnStatement = 'Success';
                } else {
                    returnStatement = JSON.serialize(timesheetupdateResult);
                }
            }
        } catch (Exception e) {
            returnStatement =  'The following exception has occurred: ' + e.getMessage();
        }
        return returnStatement;
    }

    @AuraEnabled
    public static String updateTimeSheetRecords( List<EMS_TM_Timesheet_Record__c> updateRecords, List<EMS_TM_Timesheet_Record__c> newRecords, List<EMS_TM_Timesheet_Record__c> deleteRecords, EMS_Timesheet__c timesheet ) {

        String returnStatement;
        Id timeSheetId = null;
        Boolean isError = false;

        EMS_Timesheet__c timeSheetRecord = renderTimeSheet(timesheet);
        timeSheetRecord.Id = timesheet.Id;

        Database.SaveResult timesheetupdateResult = Database.update(timeSheetRecord, false);
        if (timesheetupdateResult.isSuccess()) {
            timeSheetId = timesheetupdateResult.getId();
            returnStatement = 'Success';
        } else {
            returnStatement = JSON.serialize(timesheetupdateResult);
            isError = true;
        }

        if (!isError) {
            if (!deleteRecords.isEmpty()) { Database.delete(deleteRecords); }
            if (!updateRecords.isEmpty()) { Database.update(updateRecords); }
            if (!newRecords.isEmpty()) {
                List<EMS_TM_Timesheet_Record__c> recordstoInsert = new List<EMS_TM_Timesheet_Record__c>();
                for(EMS_TM_Timesheet_Record__c record : newRecords) {
                    EMS_TM_Timesheet_Record__c row = renderTimeRecord(record, timeSheetRecord, timesheetId);
                    recordstoInsert.add(row);
                }
                Database.insert(recordstoInsert);
            }
        }

        return returnStatement;
    }

    @AuraEnabled
    public static Integer getEmployeesCount() {
        Integer count = 0;
        Id recordTypeId = [SELECT Id FROM RecordType
                            WHERE Name = 'Resource'].Id;
        List<Contact> resourseList = [SELECT RecordTypeId, Id, MasterRecordId
                                        FROM Contact WHERE recordtypeid = :recordTypeId];
        for (Contact resourse : resourseList) {
            count++;
        }
        return count;
    }

    public class wrapperAP {
        @AuraEnabled
        public List<EMS_TM_Project__c> project {get; set;}
        @AuraEnabled
        public List<EMS_TM_Calendar__c> holidays {get; set;}
        @AuraEnabled
        public List<EMS_TM_Assignment__c> assignment {get; set;}
        @AuraEnabled
        public List<EMS_TM_Picklist_value__c> picklist {get; set;}
        @AuraEnabled
        public User User {get; set;}
        @AuraEnabled
        public Boolean enableManagerView {get; set;}
        @AuraEnabled
        public EMS_Timesheet__c timeSheet {get; set;}
        @AuraEnabled
        public List<EMS_TM_Timesheet_Record__c> timeSheetRecords {get; set;}
        @AuraEnabled
        public List<Id> projectIdList {get; set;}
        @AuraEnabled
        public List<Date> leaves {get; set;}
    }

    public class wrapperTimesheetRecords {
        @AuraEnabled
        public EMS_Timesheet__c timeSheet {get; set;}
        @AuraEnabled
        public List<EMS_TM_Timesheet_Record__c> timeSheetRecords {get; set;}
    }
}