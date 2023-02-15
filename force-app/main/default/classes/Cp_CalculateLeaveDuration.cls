/**
* @author Sangharsh Kamble
* @date 31/01/2023
* @description Calculate duration of start date and end date.
*
*               Test code coverage provided by the following test class: 
*               - LeaveCalculateHandler_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class Cp_CalculateLeaveDuration implements TriggerAction.BeforeInsert,TriggerAction.BeforeUpdate{
    
    
    public void beforeInsert(List<EMS_LM_Leave_History__c> leaveHistoryList) {      
        leavedurationmethod(leaveHistoryList);     
    }
    
    public void beforeupdate(List<EMS_LM_Leave_History__c> leaveHistoryList,List<EMS_LM_Leave_History__c> oldList) {      
        leavedurationmethod(leaveHistoryList);     
    }
    
    
    @TestVisible
   	private void leavedurationmethod(list<EMS_LM_Leave_History__c> leaveHistoryList){
        
    Date startDate = leaveHistoryList[0].EMS_LM_Leave_Start_Date__c;
	Date endDate = leaveHistoryList[0].EMS_LM_Leave_End_Date__c;
    String daycheck = leaveHistoryList[0].EMS_LM_Day__c;
    String location =leaveHistoryList[0].EMS_LM_Contact__r.Location__c;
        Set<Date> holidaysSet = new Set<Date>();
        
        for(EMS_TM_Calendar__c currHoliday : [Select EMS_TM_Calendar_Date__c from EMS_TM_Calendar__c where Location__c = :location])  
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
            if(todayDay != 'Saturday' && todayDay !='Sunday' && daycheck =='Full Day' && (!holidaysSet.contains(dt)))  
                {  
                    Duration = Duration + 1;  
                    system.debug(Duration);
               }
            if(daycheck !='Full Day'){
                Duration = 0.5 - Duration;
            }
        }
        for(EMS_LM_Leave_History__c leaveHistory:leaveHistoryList){
            leaveHistory.EMS_LM_Leave_Duration__c = Duration;
            }
    
        /*  list<date> sdate =New list<date>();
        list<date> edate =New list<date>();
        
        for(EMS_LM_Leave_History__c leavelist :leaveHistoryList){
         sdate.add(leavelist.EMS_LM_Leave_Start_Date__c);
         edate.add(leavelist.EMS_LM_Leave_End_Date__c);
         }
        
        for(EMS_LM_Leave_History__c leaveh :leaveHistoryList){
            
            if(leaveh.EMS_LM_Leave_Start_Date__c !=null && leaveh.EMS_LM_Leave_End_Date__c !=null){
                integer dur =leaveh.EMS_LM_Leave_Start_Date__c.daysBetween(leaveh.EMS_LM_Leave_End_Date__c);
            	leaveh.EMS_LM_Leave_Duration__c=dur+1;
            }
        }  */    
    }
    
}