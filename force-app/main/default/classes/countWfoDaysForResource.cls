public class countWfoDaysForResource {
    
    public static Integer GetWfoDaysForCurrentMonth() {
        Date today = Date.today();
        Integer currentYear = today.year();
        Integer currentMonth = today.month();
        Date monthStartDate = Date.newInstance(currentYear, currentMonth, 1);
        Integer lastDayOfMonth = Date.daysInMonth(currentYear, currentMonth);
        Date monthEndDate = Date.newInstance(currentYear, currentMonth, lastDayOfMonth);
        
        System.debug('Current Month Start Date: ' + monthStartDate);
        System.debug('Current Month End Date: ' + monthEndDate);
        
        Integer wfoDaysCount = 0;
        User usrConId = [SELECT Id, ContactId FROM User WHERE Id =: LeaveRequestConstant.LOGGEDIN_USERID];
        // Query Timesheet records that have a date range overlapping with the current month
        List<EMS_Timesheet__c> timesheetRecords = [
            SELECT Id,WFH_Mon__c,WFH_Tue__c,WFH_Wed__c,WFH_Thu__c,WFH_Fri__c,WFH_Sat__c,WFH_Sun__c,Week_Start_Date__c,enddate__c  from EMS_Timesheet__c 
            WHERE Week_Start_Date__c <= :monthEndDate AND enddate__c  >= :monthStartDate and Resource__c  =:usrConId.ContactId];//usrConId.ContactId
        system.debug('timesheetRecords---'+timesheetRecords);
        for (EMS_Timesheet__c record : timesheetRecords) {
            // Determine the valid range for counting days
            Date validStartDate = record.Week_Start_Date__c < monthStartDate ? monthStartDate : record.Week_Start_Date__c;
            Date validEndDate = record.enddate__c  > monthEndDate ? monthEndDate : record.enddate__c ;
            system.debug('validStartDate---'+validStartDate);
            system.debug('validEndDate---'+validEndDate);
                DateTime dt = DateTime.newInstance(validStartDate.year(), validStartDate.month(), validStartDate.day(), 0, 0, 0);
            DateTime dt2 = DateTime.newInstance(validEndDate.year(), validEndDate.month(), validEndDate.day(), 0, 0, 0);
            Integer startOffset = Integer.valueOf(dt.format('u')) - 1;
            Integer endOffset =  Integer.valueOf(dt2.format('u')) - 1;
            system.debug('startOffset---'+startOffset);
            system.debug('endOffset---'+endOffset);
            //Integer startOffset = (Integer) validStartDate.format('u'); // 'u' gives 1 (Monday) to 7 (Sunday)
            // Integer startOffset = validStartDate.dayOfWeek() - 1; // Convert Monday=1 to index 0
            // Integer endOffset = validEndDate.dayOfWeek() - 1;
            
            List<Boolean> weeklyData = new List<Boolean>{
                record.WFH_Mon__c, record.WFH_Tue__c, record.WFH_Wed__c, record.WFH_Thu__c,
                    record.WFH_Fri__c, record.WFH_Sat__c, record.WFH_Sun__c
                    };
                        system.debug('weeklyData----'+weeklyData);
            
            // Count only the relevant WFO days in the current month
            for (Integer i = startOffset; i <= endOffset; i++) {
                if (weeklyData[i]) {
                    wfoDaysCount++;
                    system.debug('wfoDaysCount----'+wfoDaysCount);
                }
            }
        }
        
        return wfoDaysCount;
    }
    
    // Function to test WFO calculations
    @AuraEnabled(Cacheable = true)
    public static integer RunWfoCalculations() {
        Integer wfoDays = GetWfoDaysForCurrentMonth();
        System.debug('Total Work From Office days in Current Month: ' + wfoDays);
        return wfoDays;
    }
}