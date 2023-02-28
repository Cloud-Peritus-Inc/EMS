public without sharing class calenderController {
@AuraEnabled(cacheable=true)
    public static List<datawrapper> getEvents() {
        List<datawrapper> dataWrap = new List<datawrapper>();
        
        List<EMS_LM_Leave_History__c> evtList = [SELECT Id,EMS_LM_Contact__c,EMS_LM_Contact__r.Name, EMS_LM_Leave_Start_Date__c,
                                                 EMS_LM_Leave_End_Date__c,EMS_LM_Status__c ,EMS_LM_Approved_On__c, EMS_LM_Final_Approver__c  ,EMS_LM_Leave_Duration__c , EMS_LM_Reason__c  
                                                 FROM EMS_LM_Leave_History__c WHERE EMS_LM_Status__c  != 'Cancelled' AND EMS_LM_Status__c  != 'Rejected '  ORDER BY CreatedDate DESC
              ];
        
        For(EMS_LM_Leave_History__c evt :  evtList){
            datawrapper dw = new datawrapper();
            dw.Id = evt.Id;
            dw.title = evt.EMS_LM_Contact__r.Name;
           // dw.start = convertTimeToOtherTimeZone(DateTime.newInstance(evt.EMS_LM_Leave_Start_Date__c, Time.newInstance(0, 0, 0, 0)));
           // dw.endTime = convertTimeToOtherTimeZone(DateTime.newInstance(evt.EMS_LM_Leave_End_Date__c, Time.newInstance(0, 0, 0, 0)));
           dw.start = evt.EMS_LM_Leave_Start_Date__c;
            dw.endTime = evt.EMS_LM_Leave_End_Date__c.adddays(1);
            dw.allDay = true;
            dataWrap.add(dw);
              }
       return dataWrap;
    }
    
    @AuraEnabled 
    public static EMS_LM_Leave_History__c getRecordInfo(id recid){
        system.debug('===recid===='+recid);
       return [SELECT Id,EMS_LM_Contact__c,EMS_LM_Contact__r.Name, EMS_LM_Leave_Start_Date__c,
                                                 EMS_LM_Leave_End_Date__c FROM EMS_LM_Leave_History__c WHERE Id=:recid]; 
    }
    
 
    
     public static DateTime convertTimeToOtherTimeZone(DateTime dttime)
    {
        TimeZone tz = Timezone.getTimeZone('GMT');
        System.debug('Display name: ' + tz.getDisplayName());
        System.debug('ID: ' + tz.getID());
        
        Integer offset=tz.getOffset(dttime);
        System.debug('Offset: ' + offset);
        
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone(UserInfo.getTimeZone().getID());
        System.debug('Display name: ' + targetTZ.getDisplayName());
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
       	integer correction = offsetTotargetTZ- offset;
		    
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        
        return targetDT;
    }
    
    
    public class datawrapper {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public string title;
        @AuraEnabled
        public date start;
        @AuraEnabled
        public date endTime;
        @AuraEnabled
        public boolean allDay;   
    }
}