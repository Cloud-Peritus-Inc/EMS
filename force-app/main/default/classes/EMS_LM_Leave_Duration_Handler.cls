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
    public static Decimal getLeaveDuration(String stDate, String edDate, String location, Boolean dayCheck, String value,String fullday){
        System.debug('Start Date: ' + stDate);
    System.debug('End Date: ' + edDate);
    System.debug('Location: ' + location);
    System.debug('Day Check: ' + dayCheck);
    System.debug('Value: ' + value);
    system.debug('fullday: '+fullday);
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
        System.debug('$$$$$CountryOfficeLocationId ****'+CountryOfficeLocationId);
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c,Office_Location__c from EMS_TM_Calendar__c where Office_Location__c = :CountryOfficeLocationId])  
        {  
            holidaysSet.add(currHoliday.EMS_TM_Calendar_Date__c);  
            system.debug(' ## currHoliday :: ' + currHoliday.EMS_TM_Calendar_Date__c);
        }
        Decimal Duration = 0;
        Integer numberDaysDue = startDate.daysBetween(endDate);
        system.debug(' ## numberDaysDue :: ' + numberDaysDue);

        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            system.debug(' ## INSIDE FOR LOOP ');
            Date dt = startDate + i;
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');
            system.debug('hOLIDAY SET :: ' + holidaysSet);
            system.debug('todayDay ' + todayDay);

            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt)) && value!=LeaveRequestConstant.LOSS_OF_PAY && value!=LeaveRequestConstant.UNPAID_TIMEOFF){  
                Duration += 1;
            }
           /*else if(todayDay != 'Saturday' && todayDay !='Sunday' && (holidaysSet.contains(dt)) && value!=LeaveRequestConstant.LOSS_OF_PAY && value!=LeaveRequestConstant.UNPAID_TIMEOFF){  
                Duration += 1;
                system.debug(' ## INSIDE FOR Custom 1 ');
            } */
            else if ((todayDay != 'Saturday' && todayDay != 'Sunday' && !holidaysSet.contains(dt)) && ((value == LeaveRequestConstant.UNPAID_TIMEOFF || value == LeaveRequestConstant.LOSS_OF_PAY ) && startDate.daysBetween(endDate) <= 14)) {
                Duration += 1; 
            }
            /*else if ((todayDay != 'Saturday' && todayDay != 'Sunday' && holidaysSet.contains(dt)) && ((value == LeaveRequestConstant.UNPAID_TIMEOFF || value == LeaveRequestConstant.LOSS_OF_PAY ) && startDate.daysBetween(endDate) <= 14)) {
                Duration += 1;
                system.debug(' ## INSIDE FOR Custom 2 '); 
            } */
            else if((value == LeaveRequestConstant.UNPAID_TIMEOFF || value == LeaveRequestConstant.LOSS_OF_PAY) && startDate.daysBetween(endDate) > 14){
                Duration += 1;
            }
           
        }
       // if()
        system.debug(' **** Duration B4 dayCheck **** '+ Duration);
       // if(dayCheck&&startdate==enddate&&fullday!='FULL DAY'&&fullday==null){
           if(startdate==enddate&&fullday!='FULL DAY'){
            Duration = Duration - 0.5;
        }
        system.debug(' **** Duration after dayCheck **** '+ Duration);
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
}