public  without sharing class EMS_LM_Leave_Duration_Handler {

    // this method is used to calculate the leave duraton whenever employee applying for Leave from community portal ---- it will consider the loggedin employee Location Holidays and Weekends(Saturday/Sunday)
    @AuraEnabled(Cacheable=true)
    public static Decimal getLeaveDuration(String stDate, String edDate, String location, Boolean dayCheck){
        // string s = stDate+' 00:00:00';
        // string e = edDate+' 00:00:00';
        Date startDate = Date.valueOf(stDate);
        Date endDate = Date.valueOf(edDate);
        Set<Date> holidaysSet = new Set<Date>();
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c from EMS_TM_Calendar__c where Location__c = :Location])  
        {  
            holidaysSet.add(currHoliday.EMS_TM_Calendar_Date__c);  
            system.debug(currHoliday.EMS_TM_Calendar_Date__c);
        }
        Decimal Duration = 0; 
            for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)))  
                {  
                    Duration = Duration + 1;  
                }                    
        }
        System.debug('--Working days'+Duration);  
        if(dayCheck){
            Duration = Duration - 0.5;
        }
        return Duration;          
    }   
}