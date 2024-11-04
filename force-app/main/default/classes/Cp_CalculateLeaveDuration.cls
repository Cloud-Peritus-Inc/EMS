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
    
    
    /*smaske: [20-Sep-2024] : Commented the leavedurationmethod as this method was not bulkified hence the leave balance calculation issue was occouring in system.
    Bulkified version of leavedurationmethod has been created below.
	Note : this changes has been made after Pooja Pimpdae <pooja.pimpdae@cloudperitus.com> reported this issue on 20-Sep-2024
    */
    
   /*@TestVisible
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
           for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && daycheck =='Full Day' && (!holidaysSet.contains(dt)) && leaveTypeName!=LeaveRequestConstant.LOSS_OF_PAY)  
                {  
                  //  Duration = Duration + 1;  
                    Duration += 1;
                    system.debug(Duration);
               }
            if(leaveTypeName == LeaveRequestConstant.LOSS_OF_PAY && daycheck =='Full Day'){
                Duration += 1;
            }
            if(daycheck !='Full Day'){
                Duration = 0.5 - Duration;
            }
        }
        for(EMS_LM_Leave_History__c leaveHistory:leaveHistoryList){
            leaveHistory.EMS_LM_Leave_Duration__c = Duration;
            }
    }*/
    
    
    /* Smaske : 20-Sep-2024 : Bulkified the code */
    @TestVisible
    private void leavedurationmethod(List<EMS_LM_Leave_History__c> leaveHistoryList) {
        // Collect all contact Ids from leave history records
        Set<Id> contactIds = new Set<Id>();
        for (EMS_LM_Leave_History__c leaveHistory : leaveHistoryList) {
            contactIds.add(leaveHistory.EMS_LM_Contact__c);
        }
    
        // Query for the Work Locations related to the Contact Ids in bulk
        Map<Id, Id> contactToLocationMap = new Map<Id, Id>();
        for (Contact contact : [SELECT Id, Work_Location__c FROM Contact WHERE Id IN :contactIds]) {
            contactToLocationMap.put(contact.Id, contact.Work_Location__c);
        }
    
        // Collect all location Ids
        Set<Id> locationIds = new Set<Id>(contactToLocationMap.values());
    
        // Query holidays related to the Work Locations in bulk
        Map<Id, Set<Date>> locationToHolidaysMap = new Map<Id, Set<Date>>();
        for (EMS_TM_Calendar__c holiday : [
            SELECT EMS_TM_Calendar_Date__c, Office_Location__c
            FROM EMS_TM_Calendar__c
            WHERE Office_Location__c IN :locationIds
        ]) {
            if (!locationToHolidaysMap.containsKey(holiday.Office_Location__c)) {
                locationToHolidaysMap.put(holiday.Office_Location__c, new Set<Date>());
            }
            locationToHolidaysMap.get(holiday.Office_Location__c).add(holiday.EMS_TM_Calendar_Date__c);
        }
    
        // Process each leave history record
        for (EMS_LM_Leave_History__c leaveHistory : leaveHistoryList) {
            Date startDate = leaveHistory.EMS_LM_Leave_Start_Date__c;
            Date endDate = leaveHistory.EMS_LM_Leave_End_Date__c;
            String daycheck = leaveHistory.EMS_LM_Day__c;
            String leaveTypeName = leaveHistory.Leave_Type_Name__c;
            Id contactId = leaveHistory.EMS_LM_Contact__c;
    
            Id locationId = contactToLocationMap.get(contactId);
            Set<Date> holidaysSet = locationToHolidaysMap.containsKey(locationId) ? locationToHolidaysMap.get(locationId) : new Set<Date>();
    
            Decimal duration = 0;
    
            // Calculate duration by iterating over days between start and end dates
            for (Integer i = 0; i <= startDate.daysBetween(endDate); i++) {
                Date dt = startDate.addDays(i);
                DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                String todayDay = currDate.format('EEEE');
    
                //@sangharsh 21/10/2024: Added condition for maternity leaves for excluding weekends and holiday for calculating duration
                if (todayDay != 'Saturday' && todayDay != 'Sunday' && daycheck == 'Full Day' && !holidaysSet.contains(dt) && (leaveTypeName != LeaveRequestConstant.LOSS_OF_PAY || leaveTypeName != LeaveRequestConstant.MATERNITY_LEAVE)) {
                    duration += 1;
                } else if ((leaveTypeName == LeaveRequestConstant.LOSS_OF_PAY || leaveTypeName == LeaveRequestConstant.MATERNITY_LEAVE) && daycheck == 'Full Day') {
                    duration += 1;
                } else if (daycheck != 'Full Day') {
                    duration += 0.5;
                }
            }
    
            // Set the calculated duration on the leave history record
            leaveHistory.EMS_LM_Leave_Duration__c = duration;
        }
    }
    
}