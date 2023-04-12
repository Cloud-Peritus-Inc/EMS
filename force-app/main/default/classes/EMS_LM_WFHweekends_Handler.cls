public without sharing class EMS_LM_WFHweekends_Handler {

    @AuraEnabled(Cacheable=true)
    public static boolean getwfhWFHweekends(String stDate, String edDate){
        // string s = stDate+' 00:00:00';
        // string e = edDate+' 00:00:00';
        Date startDate = Date.valueOf(stDate);
        Date endDate = Date.valueOf(edDate);
        
        Decimal Duration = 0; 
            for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' )  
                {  
                    Duration = Duration + 1;  
                }                    
        }
        System.debug('--Working days'+Duration);  
        return null;          
    } 
}