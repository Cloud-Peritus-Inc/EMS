global class EMS_TM_Lock_Previous_Week implements Schedulable {
    global void execute(SchedulableContext cnt) {
        Date today = Date.today();
        List<EMS_Timesheet__c> timesheetList = [SELECT Id, EMS_TM_Status__c, EMS_TM_Week__c
                                                FROM EMS_Timesheet__c
                                                WHERE EMS_TM_Week__c < :today
                                                AND EMS_TM_Status__c <> :EMS_TM_GlobalConstants.STATUS_SUBMITTED];
        for (EMS_Timesheet__c timesheet : timesheetList) {
            timesheet.EMS_TM_Status__c = EMS_TM_GlobalConstants.STATUS_LOCKED;
        }

        Database.update(timesheetList, false);
    }
}