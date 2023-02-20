public without sharing class holidayTitleController {
    
  @AuraEnabled(cacheable=true)
    public static List<datawrapper> getMyUpcomingHoliday(){
        List<datawrapper> dataList = new List<datawrapper>(); 
        User uREc = [SELECT Id,contactId,contact.Work_Location__c FROM User WHERE Id=:Userinfo.getUserId()];
        List<EMS_TM_Calendar__c> holidayCalender = new List<EMS_TM_Calendar__c>();
        Date dt = system.today();
        holidayCalender = [SELECT Id,EMS_TM_Calendar_Date__c,Office_Location__c,Name,EMS_TM_Type_Of_Holiday__c 
                           FROM EMS_TM_Calendar__c 
                           WHERE EMS_TM_Calendar_Date__c=THIS_YEAR 
                           AND EMS_TM_Calendar_Date__c >:dt  
                           AND Office_Location__c=:uREc.contact.Work_Location__c];
        for(EMS_TM_Calendar__c holi : holidayCalender){
            datawrapper dtwrap = new datawrapper();
            dtwrap.holidayDate = holi.EMS_TM_Calendar_Date__c;
            dtwrap.duration = '1';
            dtwrap.status = 'NA';
            dtwrap.holidayType =  holi.Name;
            dataList.add(dtwrap);
        }
        
        List<EMS_LM_Leave_History__c> leaveRequestList = new List<EMS_LM_Leave_History__c>();
        leaveRequestList = [SELECT Id,EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_Duration__c,EMS_LM_Leave_Type__c,EMS_LM_Leave_Type__r.Name,EMS_LM_Status__c 
                            FROM EMS_LM_Leave_History__c 
                            WHERE EMS_LM_Leave_Start_Date__c>:dt 
                            AND EMS_LM_Leave_Start_Date__c= THIS_YEAR
                            AND EMS_LM_Status__c != 'Rejected' 
                            AND EMS_LM_Status__c != 'Cancelled'];
            for(EMS_LM_Leave_History__c history : leaveRequestList){
              datawrapper dtwrap = new datawrapper();
            dtwrap.holidayDate = history.EMS_LM_Leave_Start_Date__c;
            dtwrap.duration = string.valueOf(integer.valueOf(history.EMS_LM_Leave_Duration__c));
                if(history.EMS_LM_Status__c == 'Auto Approved' || history.EMS_LM_Status__c == 'Approved'){
                 dtwrap.status = 'Approved';
                }else  if(history.EMS_LM_Status__c == 'Pending'){ 
                 dtwrap.status = 'Pending';
                }else {
                   dtwrap.status = 'In Review';
                }
            dtwrap.holidayType =  history.EMS_LM_Leave_Type__r.Name;
            dataList.add(dtwrap);  
            }
        dataList.sort();
        return dataList;
    }
    
    public class datawrapper implements Comparable {
        @AuraEnabled
        public Date holidayDate;
        @AuraEnabled 
        public string duration;
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string holidayType;
        
        public Integer compareTo(Object objToCompare) {
        datawrapper that = (datawrapper)objToCompare;
        if (this.holidayDate > that.holidayDate) return 1;
        if (this.holidayDate < that.holidayDate) return -1;
        return 0;
        }
    }

}