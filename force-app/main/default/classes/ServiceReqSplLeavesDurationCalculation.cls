/**
* @author Pavan Tavva
* @date 11/04/2023
* @description  ServiceReqSplLeavesDurationCalculation Class to calculate the duration for Maternity and Comp-off.
*
*               Test code coverage provided by the following test class:
*               - ServiceReqSplLeavesDurationCalTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class ServiceReqSplLeavesDurationCalculation {
    
    /**
*   {Purpose} - Method to calculate the duration for Comp-off.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
   @AuraEnabled(Cacheable=true)
    public static Decimal getCompLeaveDuration(String stdate, String eddate, String Location, Boolean dayCheck){
        if (stdate == null || eddate == null || Location == null || dayCheck == null ||
            stdate == '' || eddate == '' ) {
            return null;
        }
        System.debug('### location' + Location);
        Date startDate = Date.valueOf(stdate);
        Date endDate = Date.valueOf(eddate);
        Set<Date> holidaysSet = new Set<Date>();
        Id CountryOfficeLocationId = [SELECT Country__c, Id FROM Office_Location__c  Where Country__c =: Location].Id;
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

    /**
*   {Purpose} - Method to calculate the duration for Maternity.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    @AuraEnabled(Cacheable=true)
    public static Decimal getMaternityLeaveDuration(String stDate, String edDate, String location){
        System.debug('### stDate' + stDate);
        System.debug('### edDate' + edDate);
        System.debug('### location' + location);
        if (stDate == null || edDate == null || Location == null
        || stDate == '' || edDate == '' ) {
            return null;
        }
        Date startDate = Date.valueOf(stDate);
        System.debug('##startDate '+ startDate);
        Date endDate = Date.valueOf(edDate);
        Set<Date> holidaysSet = new Set<Date>();
        Integer Duration = 0; 
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE'); 
            Duration += 1;
        }
        System.debug('--Working days'+Duration);  
        return Duration;
    }
}