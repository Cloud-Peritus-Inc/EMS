public without sharing class resourceTileController {
@AuraEnabled(cacheable=true)
    public static datawrapper getUserInfo(Id userId) {
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name FROM User WHERE Id = :Userinfo.getUserId()];
        datawrapper dwrap = new datawrapper();
        dwrap.resourceName = urecord.Name;
        dwrap.resourcePhotoURL = urecord.FullPhotoUrl;
        dwrap.resourceCpId = urecord.Contact.EMS_RM_Employee_Id__c;
        dwrap.resourceRole = urecord.Contact.Resource_Role__r.Name;
        dwrap.nextpaydate = lastdayoftheMonth(urecord.contactId);
        dwrap.resourceReportTo = urecord.Contact.ReportsTo.Name;
        dwrap.resourceUserId = urecord.Id;
        return dwrap;
    }
    
    public static date lastdayoftheMonth(Id contactId){
        Contact conRec = [SELECT Id,Work_Location__c,Work_Location__r.Country__c,(SELECT Id FROM PayRolls__r) FROM Contact WHERE Id=:contactId];
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
        
    }   
}