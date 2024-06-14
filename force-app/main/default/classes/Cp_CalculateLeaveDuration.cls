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
    String leaveTypeName = leaveHistoryList[0].Leave_Type_Name__c;  
    String ContactId =leaveHistoryList[0].EMS_LM_Contact__c;
       
    Id locationId = [SELECT Id, Work_Location__c FROM Contact Where Id =: ContactId].Work_Location__c;
        Set<Date> holidaysSet = new Set<Date>();
        
        for(EMS_TM_Calendar__c currHoliday : [Select ID,EMS_TM_Calendar_Date__c ,Office_Location__r.Country__c 
                                              from EMS_TM_Calendar__c 
                                              where Office_Location__c = :locationId])  
        {  
            holidaysSet.add(currHoliday.EMS_TM_Calendar_Date__c);  
            system.debug('duration cal'+currHoliday.EMS_TM_Calendar_Date__c);
        }
	
        Decimal Duration = 0;
        if (startDate != null && endDate != null) {
        
           for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && daycheck =='Full Day' && (!holidaysSet.contains(dt)) && leaveTypeName!=LeaveRequestConstant.LOSS_OF_PAY && leaveTypeName!=LeaveRequestConstant.UNPAID_TIMEOFF )  
                {  
                  //  Duration = Duration + 1;  
                    Duration += 1;
                    system.debug(Duration);
               }
            if((leaveTypeName == LeaveRequestConstant.LOSS_OF_PAY || leaveTypeName == LeaveRequestConstant.UNPAID_TIMEOFF ) && daycheck =='Full Day'){
                Duration += 1;
            }
            if(daycheck !='Full Day'){
                Duration = 0.5 - Duration;
            }
        }
        for(EMS_LM_Leave_History__c leaveHistory:leaveHistoryList){
            leaveHistory.EMS_LM_Leave_Duration__c = Duration;
        }
    }
    for(EMS_LM_Leave_History__c leaveHistory:leaveHistoryList){
        leaveHistory.EMS_LM_Leave_Duration__c = Duration;
    }      
        
    }
    
}