public with sharing class timesheetRecordPageController {

    @AuraEnabled(cacheable=true)
    public  static List<WrapperClass>fetchTimesheetRecordsData(String timesheetId)
    {
       
        List<WrapperClass> wrapperOppList=new List<WrapperClass>();
        for(EMS_TM_Timesheet_Record__c timesheetsRecordsRec:[select id, Name, EMS_Timesheet__r.Name, EMS_TM_Project__r.Name, EMS_TM_Project__r.Id, Assignment__r.EMS_TM_AssignedAs__c, 
                                                            EMS_Timesheet__c, Timesheet_Weekdate__c, EMS_TM_Mon__c, EMS_TM_Tue__c, EMS_TM_Wed__c, 
                                                            EMS_TM_Thu__c, EMS_TM_Fri__c, EMS_TM_Sat__c, EMS_TM_Sun__c, EMS_Timesheet__r.EMS_TM_Total__c,EMS_TM_Remarks__c
                                                            from EMS_TM_Timesheet_Record__c 
                                                            where EMS_Timesheet__c != NULL 
                                                            and EMS_Timesheet__c =: timesheetId]) //'a0552000006L05cAAC'
        {
        System.debug('the timesheetrecordsrecs Are checking ###########'+timesheetsRecordsRec);
            WrapperClass wrapItemFld = new WrapperClass();
            wrapItemFld.Id = timesheetsRecordsRec.id;
            wrapItemFld.TimesheetRecordName = timesheetsRecordsRec.Name;
            wrapItemFld.ProjectName = timesheetsRecordsRec.EMS_TM_Project__r.Name;
            wrapItemFld.ProjectId = timesheetsRecordsRec.EMS_TM_Project__r.Id;
            wrapItemFld.Assignment = timesheetsRecordsRec.Assignment__r.EMS_TM_AssignedAs__c;
            wrapItemFld.Remarks=timesheetsRecordsRec.EMS_TM_Remarks__c;
            wrapItemFld.Timesheet = timesheetsRecordsRec.EMS_Timesheet__c;
            wrapItemFld.Week = timesheetsRecordsRec.Timesheet_Weekdate__c;
            wrapItemFld.Monday = timesheetsRecordsRec.EMS_TM_Mon__c != null ? timesheetsRecordsRec.EMS_TM_Mon__c : 0;
            wrapItemFld.Tuesday = timesheetsRecordsRec.EMS_TM_Tue__c != null ? timesheetsRecordsRec.EMS_TM_Tue__c : 0;
            wrapItemFld.Wednesday = timesheetsRecordsRec.EMS_TM_Wed__c != null ? timesheetsRecordsRec.EMS_TM_Wed__c : 0;
            wrapItemFld.Thursday = timesheetsRecordsRec.EMS_TM_Thu__c != null ? timesheetsRecordsRec.EMS_TM_Thu__c : 0;
            wrapItemFld.Friday = timesheetsRecordsRec.EMS_TM_Fri__c != null ? timesheetsRecordsRec.EMS_TM_Fri__c : 0;
            wrapItemFld.Saturday = timesheetsRecordsRec.EMS_TM_Sat__c != null ? timesheetsRecordsRec.EMS_TM_Sat__c : 0;
            wrapItemFld.Sunday = timesheetsRecordsRec.EMS_TM_Sun__c != null ? timesheetsRecordsRec.EMS_TM_Sun__c : 0;
            wrapItemFld.TotalHours = timesheetsRecordsRec.EMS_Timesheet__r.EMS_TM_Total__c ;
            System.debug('the wrapItemFld.TotalHours &&&&&'+wrapItemFld.TotalHours);
            wrapperOppList.add(wrapItemFld);
        }
        return wrapperOppList;
    }
    
    public class WrapperClass
    {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String TimesheetRecordName;
        @AuraEnabled
        public String ProjectId;
        @AuraEnabled
        public String ProjectName;
        @AuraEnabled
        public String Assignment;
        @AuraEnabled
        public String Remarks;
        @AuraEnabled
        public Id Timesheet;
        @AuraEnabled
        public Date Week;
        @AuraEnabled
        public Decimal Monday;
        @AuraEnabled
        public Decimal Tuesday;
        @AuraEnabled
        public Decimal Wednesday;
        @AuraEnabled
        public Decimal Thursday;
        @AuraEnabled
        public Decimal Friday;
        @AuraEnabled
        public Decimal Saturday;
        @AuraEnabled
        public Decimal Sunday;
        @AuraEnabled
        public Decimal TotalHours;
    }
}