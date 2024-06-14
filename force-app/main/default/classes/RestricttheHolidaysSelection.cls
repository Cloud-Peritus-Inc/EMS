public class RestricttheHolidaysSelection implements TriggerAction.BeforeInsert{
     public static final String COUNTRY_INDIA = 'India';
     public static final String COUNTRY_USA = 'United States of America';

    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'RestricttheHolidaysSelection.beforeInsert() : BEGIN');
        //restrictTheLeaveHoliday(newList);
        System.debug(LoggingLevel.DEBUG, 'RestricttheHolidaysSelection.beforeInsert() : END');       
    }
    /*public void restrictTheLeaveHoliday(List<EMS_LM_Leave_History__c> newList){
        
        //smaske
        Date startDate;
        Date endDate;
        List<Date> datesBetween = new List<Date>();
        Map<Id, String> leaveReqConWorkLocationCountryMap = new Map<Id, String>();
        Set<Id> leaveRequestConIdSet = new Set<Id>();
        for(EMS_LM_Leave_History__c lh : newList){
            leaveRequestConIdSet.add(lh.EMS_LM_Contact__c);
        }
        For(Contact con : [Select Id, Work_Location__r.Country__c From Contact Where Id IN : leaveRequestConIdSet]){
            leaveReqConWorkLocationCountryMap.put(con.Id, con.Work_Location__r.Country__c);
        }
        Id CountryOfficeLocationId = [SELECT Country__c, Id FROM Office_Location__c  Where Country__c IN: leaveReqConWorkLocationCountryMap.values()].Id;
        //smaske
        
        Set<Date> holidaydates = new Set<Date>();
        
        //smaske: commented below 3 lines for updating code logic
        //Id CountryOfficeLocationUSAId = [SELECT Country__c, Id FROM Office_Location__c  Where Country__c =:COUNTRY_USA].Id;
        //Id CountryOfficeLocationINDIAId=[SELECT Country__c, Id FROM Office_Location__c  Where Country__c =:COUNTRY_INDIA].Id;
        //Set<Id> locationId=new Set<Id>{CountryOfficeLocationUSAId,CountryOfficeLocationINDIAId};

        Set<Id> locationId = new Set<Id>{CountryOfficeLocationId};
        
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c,Office_Location__c from EMS_TM_Calendar__c where Office_Location__c IN :locationId ])  
        {  
            holidaydates.add(currHoliday.EMS_TM_Calendar_Date__c);
        }
         system.debug('the holidaydates'+holidaydates);
        for(EMS_LM_Leave_History__c lh:newList){
            smaske
            startDate = lh.EMS_LM_Leave_Start_Date__c;
            endDate = lh.EMS_LM_Leave_End_Date__c;

            if (startDate != null && endDate != null) {
                for (Date da = startDate; da <= endDate; da = da.addDays(1)) {
                    datesBetween.add(da);
                }
            }
            
            for (Date da : datesBetween) {
                if (holidaydates.contains(da)) {
                    lh.addError('You cannot submit leave on holiday');
                }
            }
            
            //smaske
            
            //smaske: commenting below 3 lines for updating code logic
            if((holidaydates.contains(lh.EMS_LM_Leave_Start_Date__c)) || (holidaydates.contains(lh.EMS_LM_Leave_End_Date__c))){
               lh.addError('You cannot submit leave on holiday');
            }
        }
    } */
    
}