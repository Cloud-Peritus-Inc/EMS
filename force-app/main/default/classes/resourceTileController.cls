public without sharing class resourceTileController {
@AuraEnabled(cacheable=true)
    public static datawrapper getUserInfo(Id userId) {
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name FROM User WHERE Id = :Userinfo.getUserId()];
        Contact conRec = [SELECT Id,Work_Location__c,Work_Location__r.Country__c,(SELECT Id FROM PayRolls__r),(Select Id,Amount__c FROM Benefits__r WHERE Type__c = 'Medical Insurence') FROM Contact WHERE Id=:urecord.contactId];
        datawrapper dwrap = new datawrapper();
        dwrap.resourceName = urecord.Name;
        dwrap.resourcePhotoURL = urecord.FullPhotoUrl;
        dwrap.resourceCpId = urecord.Contact.EMS_RM_Employee_Id__c;
        dwrap.resourceRole = urecord.Contact.Resource_Role__r.Name;
        dwrap.nextpaydate = lastdayoftheMonth(conRec);
        dwrap.resourceReportTo = urecord.Contact.ReportsTo.Name;
        dwrap.resourceUserId = urecord.Id;
        dwrap.resourceContactId = urecord.ContactId;
        dwrap.resourceInsurence = getMyInsurenceBenf(conRec);
        dwrap.rescodecurrency = conRec.Work_Location__r.Country__c == 'United States of America' ? 'USD' : 'INR';
        return dwrap;
    }
    
    public static decimal getMyInsurenceBenf(Contact conRec){
        if(!conRec.Benefits__r.isEmpty()){
           return  conRec.Benefits__r[0].Amount__c;
        }
        return 300000;
    }
    @AuraEnabled(cacheable=true)
    public static date lastdayoftheMonth(Contact conRec){
        
        List<Pay_Period__c> paylist = new List<Pay_Period__c>();
        Date dt = system.today();
        String payperoid = 'Monthly';
        if(conRec.Work_Location__r.Country__c == 'United States of America'){
           payperoid = 'Bi-Weekly'; 
        }
        paylist = [SELECT Id,Pay_Date__c FROM Pay_Period__c Where Pay_Date__c >=:dt and Pay_Period_Type__c=:payperoid and Office_Location__c =:conRec.Work_Location__c ORDER BY Pay_Date__c ASC ];
        
        // Return the last working day of the current month
        return paylist.size() > 0 ? paylist[0].Pay_Date__c : system.today();
    }
    @AuraEnabled(cacheable=true)
    public static List<datawrapper> getTheCurrentAlerts(){
        Date dt = system.today();
        List<datawrapper> dwrap = new List<datawrapper>();
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name,Contact.Resource_Role__c FROM User WHERE Id = :Userinfo.getUserId()];
        for(Grid_Configuration__c gridc : [SELECT Id,Description__c,Notification_Type__c,Name,Goal_End_Date__c,Goal_Start_Date__c,Grid_Configuration_Type__c,
                                         Navigation_address__c,is_Navigation_Required__c,Resource_Role__c 
                                         FROM Grid_Configuration__c 
                                         WHERE Goal_Start_Date__c=:dt AND (Grid_Configuration_Type__c = 'Org Level Alert' OR Grid_Configuration_Type__c = 'Resource Role Alert')]){
          if(gridc.Grid_Configuration_Type__c == 'Org Level Alert'){
          datawrapper dw = new datawrapper();
          dw.isAlert = gridc.Notification_Type__c == 'Alert' ? true:false;
          dw.alertTitle = gridc.Name;
          dw.alertDesc = gridc.Description__c;
          dwrap.add(dw);
          }else if(gridc.Grid_Configuration_Type__c == 'Resource Role Alert' && urecord.Contact.Resource_Role__c == gridc.Resource_Role__c){
             datawrapper dw = new datawrapper();
          dw.isAlert = gridc.Notification_Type__c == 'Alert' ? true:false;
          dw.alertTitle = gridc.Name;
          dw.alertDesc = gridc.Description__c;
          dwrap.add(dw);  
          }  
       
       }
        
        return dwrap; 
     }
    
    
    public class datawrapper{
        @AuraEnabled
        public string resourceUserId;
        @AuraEnabled
        public string resourceName;
        @AuraEnabled
        public string resourcePhotoURL;
        @AuraEnabled
        public string resourceCpId;
        @AuraEnabled
        public string resourceRole;
        @AuraEnabled
        public Date nextpaydate;
        @AuraEnabled
        public string resourceReportTo;
        @AuraEnabled
        public decimal resourceInsurence;
         @AuraEnabled
        public string rescodecurrency;
        @AuraEnabled
        public string resourceContactId;
         @AuraEnabled
        public Boolean isAlert;
         @AuraEnabled
        public string alertTitle;
         @AuraEnabled
        public string alertDesc;
        
        
    }   
}