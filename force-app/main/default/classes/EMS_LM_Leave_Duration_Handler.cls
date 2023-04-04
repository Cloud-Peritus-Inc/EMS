/**
* @author Sangharsh Kamble
* @date 24/01/2023
* @description When Leave or work from home created calculate duration of start date and end date.
*
*               Test code coverage provided by the following test class: 
*               - EMS_LM_ContactLeaveUpdate_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public  without sharing class EMS_LM_Leave_Duration_Handler {
    
    // this method is used to calculate the leave duraton whenever employee applying for Leave from community portal ---- it will consider the loggedin employee Location Holidays and Weekends(Saturday/Sunday)
    @AuraEnabled(Cacheable=true)
    public static Decimal getLeaveDuration(String stDate, String edDate, String location, Boolean dayCheck, String value){
        if (stDate == null || edDate == null || location == null || dayCheck == null ||
            stDate == '' || edDate == '' ) {
            return null;
        }
        // string s = stDate+' 00:00:00';
        // string e = edDate+' 00:00:00';
        Date startDate = Date.valueOf(stDate);
        Date endDate = Date.valueOf(edDate);
        Set<Date> holidaysSet = new Set<Date>();
        Id CountryOfficeLocationId = [SELECT Country__c, Id FROM Office_Location__c  Where Country__c =: location].Id;
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c,Office_Location__c from EMS_TM_Calendar__c where Office_Location__c = :CountryOfficeLocationId])  
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
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)) && value!=LeaveRequestConstant.LOSS_OF_PAY){  
                Duration += 1;  
            }else if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)) && value == LeaveRequestConstant.LOSS_OF_PAY && i>=14){
                Duration += 1; 
            }else if(value == LeaveRequestConstant.LOSS_OF_PAY && i<=14){
               Duration += 1;  
            }                   
        }
        System.debug('--Working days'+Duration);  
        if(dayCheck){
            Duration = Duration - 0.5;
        }
        return Duration;          
    }
    
    // this method is used to calculate the wfh duraton whenever employee applying for Leave from community portal ---- it will consider the loggedin employee Location Holidays and Weekends(Saturday/Sunday)
    @AuraEnabled(Cacheable=true)
    public static Integer getwfhDuration(String stDate, String edDate, String Location){
        if (stDate == null || edDate == null || Location == null
        || stDate == '' || edDate == '' ) {
            return null;
        }
        // string s = stDate+' 00:00:00';
        // string e = edDate+' 00:00:00';
        Date startDate = Date.valueOf(stDate);
        System.debug('##startDate '+ startDate);
        Date endDate = Date.valueOf(edDate);
        Set<Date> holidaysSet = new Set<Date>();
        Id CountryOfficeLocationId = [SELECT Country__c, Id FROM Office_Location__c  Where Country__c =: Location].Id;
        for(EMS_TM_Calendar__c currHoliday : [Select Id,EMS_TM_Calendar_Date__c,Office_Location__c from EMS_TM_Calendar__c where Office_Location__c = :CountryOfficeLocationId])  
        {  
            holidaysSet.add(currHoliday.EMS_TM_Calendar_Date__c);  
            system.debug(currHoliday.EMS_TM_Calendar_Date__c);
        }
        Integer Duration = 0; 
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)))  
            {  
                Duration += 1;  
            }                    
        }
        System.debug('--Working days'+Duration);  
        return Duration;          
    }
    
    @AuraEnabled(Cacheable=true)
    public static Integer getwfhWFHweekends(String stDate, String edDate){
        
        Date startDate = Date.valueOf(stDate);
        Date endDate = Date.valueOf(edDate);
        Integer weekEndDay = 1;
        boolean weekday = false;
        
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay == 'Saturday' || todayDay =='Sunday' )  
            {  
                weekEndDay = weekEndDay + 1;
                
            }                    
        }
        if(weekEndDay > 0){
            weekday = true;
        }else{
            weekday = false;
        }
        return weekEndDay;
        
    }
    
        // this method is used to calculate the leave duraton whenever employee applying for Leave from community portal ---- it will consider the loggedin employee Location Holidays and Weekends(Saturday/Sunday)
        @AuraEnabled(Cacheable=true)
    public static Decimal getMaternityLeaveDuration(String stDate, String edDate, String location, Boolean dayCheck){
        if (stDate == null || edDate == null || location == null || dayCheck == null ||
            stDate == '' || edDate == '' ) {
            return null;
        }
        // string s = stDate+' 00:00:00';
        // string e = edDate+' 00:00:00';
        Date startDate = Date.valueOf(stDate);
        Date endDate = Date.valueOf(edDate);
        Set<Date> holidaysSet = new Set<Date>();
        Id CountryOfficeLocationId = [SELECT Country__c, Id FROM Office_Location__c  Where Country__c =: location].Id;
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c,Office_Location__c from EMS_TM_Calendar__c where Office_Location__c = :CountryOfficeLocationId])  
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
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt))){  
                Duration += 1;  
            }                    
        }
        System.debug('--Working days'+Duration);  
        if(dayCheck){
            Duration = Duration - 0.5;
        }
        return Duration;          
    }
}