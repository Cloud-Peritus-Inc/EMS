public without sharing class holidayTitleController {
    
  @AuraEnabled(cacheable=true)
    public static returnedDate getMyUpcomingHoliday(){
        List<datawrapper> dataList = new List<datawrapper>();
         List<String> locaList = new List<String>(); 
        Map<String,String> locationWithId = new Map<String,String>();
        User uREc = [SELECT Id,contactId,contact.Work_Location__c,contact.Work_Location__r.Name FROM User WHERE Id=:Userinfo.getUserId()];
        List<EMS_TM_Calendar__c> holidayCalender = new List<EMS_TM_Calendar__c>();
        String resourceLocation = uREc.contact.Work_Location__c;
        Date dt = system.today();
        holidayCalender = [SELECT Id,EMS_TM_Calendar_Date__c,Office_Location__c,Name,Office_Location__r.Name,EMS_TM_Type_Of_Holiday__c 
                           FROM EMS_TM_Calendar__c 
                           WHERE EMS_TM_Calendar_Date__c=THIS_YEAR 
                           AND EMS_TM_Calendar_Date__c >:dt  
                           ];
        
        for(EMS_TM_Calendar__c holi : holidayCalender){
            system.debug('====holi.Office_Location__c=='+holi.Office_Location__c);
             system.debug('==== uREc.contact.Work_Location__c=='+ uREc.contact.Work_Location__c);
            if(holi.Office_Location__c == uREc.contact.Work_Location__c){
                System.debug('=Inside====');
                DateTime dt2 = DateTime.newInstance(holi.EMS_TM_Calendar_Date__c, Time.newInstance(0,0,0,0));
            datawrapper dtwrap = new datawrapper();
            dtwrap.holidayDate = holi.EMS_TM_Calendar_Date__c;
            dtwrap.status = dt2.format('EEEE');
            dtwrap.holidayType =  holi.Name;
            dataList.add(dtwrap);
            }
            
            locationWithId.put(holi.Office_Location__r.Name,holi.Office_Location__c);
        }
        
      locaList.addAll(locationWithId.keySet());
         dataList.sort();
        returnedDate rdData = new returnedDate();
        rdData.datalist = dataList;
        rdData.locList = locaList;
        rdData.locationList = locationWithId;
        rdData.resourceLocation = resourceLocation;
       
        return rdData;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<datawrapper> getSelectLocList(Id locationId){
         List<datawrapper> dataList = new List<datawrapper>();
         Date dt = system.today();
         for(EMS_TM_Calendar__c holi : [SELECT Id,EMS_TM_Calendar_Date__c,Office_Location__c,Name,Office_Location__r.Name,EMS_TM_Type_Of_Holiday__c 
                           FROM EMS_TM_Calendar__c 
                           WHERE EMS_TM_Calendar_Date__c=THIS_YEAR 
                           AND EMS_TM_Calendar_Date__c >:dt  
                           AND Office_Location__c=:locationId ]){
            DateTime dt2 = DateTime.newInstance(holi.EMS_TM_Calendar_Date__c, Time.newInstance(0,0,0,0));
            datawrapper dtwrap = new datawrapper();
            dtwrap.holidayDate = holi.EMS_TM_Calendar_Date__c;
            dtwrap.status = dt2.format('EEEE');
            dtwrap.holidayType =  holi.Name;
            dataList.add(dtwrap);
        }
        return dataList;
    }
    
    
    
    public class returnedDate {
        @AuraEnabled 
        public List<datawrapper> datalist;
        @AuraEnabled
        public Map<String,String> locationList;
        @AuraEnabled
        public List<String> locList;
        @AuraEnabled
        public string resourceLocation;
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