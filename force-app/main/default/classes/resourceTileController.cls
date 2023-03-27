/**
* @author Subba Kalavala
* @date 01/03/2023
* @description  resourceTileController Class to show the data on Home page Resource details
*
*               Test code coverage provided by the following test class:
*               - resourceTileControllerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class resourceTileController {
@AuraEnabled(cacheable=true)
    public static datawrapper getUserInfo(Id userId) {
      
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name FROM User WHERE Id = :Userinfo.getUserId() and ContactId != null];
       
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
        
        Date dt = Test.isRunningTest() ? system.today().adddays(1) : system.today();
       
        List<datawrapper> dwrap = new List<datawrapper>();
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name,Contact.Resource_Role__c FROM User WHERE Id = :Userinfo.getUserId()];
        for(Grid_Configuration__c gridc : [SELECT Id,Description__c,Notification_Type__c,Name,Goal_End_Date__c,Goal_Start_Date__c,Grid_Configuration_Type__c,
                                         Navigation_address__c,is_Navigation_Required__c,Resource_Role__c 
                                         FROM Grid_Configuration__c 
                                         WHERE (Goal_Start_Date__c <=:dt AND Goal_End_Date__c>=:dt) AND (Grid_Configuration_Type__c = 'Org Level Alert' OR Grid_Configuration_Type__c = 'Resource Role Alert')]){
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
    
    @AuraEnabled(cacheable=true)
    public static List<fileWrapper> getRelatedFilesByRecordId() {
        Map<Id,fileWrapper> fileWrapMap = new Map<Id,fileWrapper>();
        User urec = [SELECT Id,Contact.AccountId FROM User WHERE Id=:Userinfo.getUserId()];
        String accountId = urec.Contact.AccountId != null ? urec.Contact.AccountId : null;
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = '00152000010lJfYAAU'];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }

        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN: fileIDs ];
       
        for (ContentVersion docLink : docs) {
           fileWrapper fw = new fileWrapper();
           fw.fileName = docLink.Title;
           fw.fileExtension = docLink.FileExtension + accountId;
           fw.fileId = docLink.ContentDocumentId;
           fileWrapMap.put(docLink.ContentDocumentId,fw);
        }
        
        for(ContentDistribution cdoc : [Select Id,ContentDocumentId,ContentDownloadUrl,DistributionPublicUrl from ContentDistribution where ContentDocumentId IN:fileWrapMap.keySet()]){
            if(fileWrapMap.containsKey(cdoc.ContentDocumentId)){
                fileWrapMap.get(cdoc.ContentDocumentId).filePublicURL = cdoc.DistributionPublicUrl;
            }
        }

        return fileWrapMap.values();
    }
    
    
    @AuraEnabled(cacheable=true)
    public static datawrapper getUserHiearchyInfo(Id userId) {
        
           
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,contact.ReportsToId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name FROM User WHERE Id = :Userinfo.getUserId() and ContactId != null];
       
        Contact conRec = [SELECT Id,Work_Location__c,Work_Location__r.Country__c,ReportsTo.Resource_Role__r.Name,
                          ReportsTo.EMS_RM_Employee_Id__c,ReportsTo.EMS_TM_User__c,
                          ReportsTo.EMS_TM_User__r.FullPhotoUrl,ReportsTo.Name,ReportsToId FROM Contact WHERE Id=:urecord.contactId];
        List<Contact> mydirectReports = new List<Contact>();
        Set<Id> myrepotiescontids = new Set<Id>();
         Set<Id> mereportsTo = new Set<Id>();
        for(Resource_Resource_Relationship__c rrr : [SELECT Id,Resource__c,Resource_Reports_To__c FROM Resource_Resource_Relationship__c WHERE ( Resource_Reports_To__c=:urecord.contactId OR Resource__c=:urecord.contactId)]){
            if(rrr.Resource__c == urecord.contactId){
                myrepotiescontids.add(rrr.Resource__c); 
            }
             if(rrr.Resource_Reports_To__c == urecord.contactId){
                mereportsTo.add(rrr.Resource__c); 
            }
            
        }
        List<datawrapper> dwrapList = new List<datawrapper>();
        List<datawrapper> directReportsList = new List<datawrapper>();
        List<datawrapper> meReportsToList = new List<datawrapper>();
         datawrapper dwrap = new datawrapper();
        dwrap.resourceName = urecord.Name;
        dwrap.resourcePhotoURL = urecord.FullPhotoUrl;
        dwrap.resourceCpId = urecord.Contact.EMS_RM_Employee_Id__c;
        dwrap.resourceRole = urecord.Contact.Resource_Role__r.Name;
        dwrap.resourceReportTo = urecord.Contact.ReportsTo.Name;
        dwrap.resourceUserId = urecord.Id;
        dwrap.resourceContactId = urecord.ContactId;
       
        
        for(Contact myreporties : [SELECT Id,Name,EMS_TM_User__r.FullPhotoUrl,EMS_RM_Employee_Id__c,Resource_Role__r.Name,ReportsTo.Name
                                  ,EMS_TM_User__c FROM Contact WHERE Id IN: mereportsTo]){
        datawrapper dwrap2 = new datawrapper();
        dwrap2.resourceName = myreporties.Name;
        dwrap2.resourcePhotoURL = myreporties.EMS_TM_User__r.FullPhotoUrl;
        dwrap2.resourceCpId = myreporties.EMS_RM_Employee_Id__c;
        dwrap2.resourceRole = myreporties.Resource_Role__r.Name;
        dwrap2.resourceReportTo = myreporties.ReportsTo.Name;
        dwrap2.resourceUserId = myreporties.EMS_TM_User__c;
        dwrap2.resourceContactId = myreporties.id;
        directReportsList.add(dwrap2);
        }
        
        for(Contact myreporties : [SELECT Id,Name,EMS_TM_User__r.FullPhotoUrl,EMS_RM_Employee_Id__c,Resource_Role__r.Name,ReportsTo.Name
                                  ,EMS_TM_User__c FROM Contact WHERE Id=:urecord.contact.ReportsToId]){
        datawrapper dwrap2 = new datawrapper();
        dwrap2.resourceName = myreporties.Name;
        dwrap2.resourcePhotoURL = myreporties.EMS_TM_User__r.FullPhotoUrl;
        dwrap2.resourceCpId = myreporties.EMS_RM_Employee_Id__c;
        dwrap2.resourceRole = myreporties.Resource_Role__r.Name;
        dwrap2.resourceReportTo = myreporties.ReportsTo.Name;
        dwrap2.resourceUserId = myreporties.EMS_TM_User__c;
        dwrap2.resourceContactId = myreporties.id;
        meReportsToList.add(dwrap2);
        }
        
        
        
        
        dwrap.directReportesUnderme = directReportsList;
        dwrap.meReportsToList = meReportsToList;
      
        return dwrap;  
    }
    
    public class fileWrapper{
        @AuraEnabled
        public string fileName;
         @AuraEnabled
        public string fileExtension;
         @AuraEnabled
        public string filePublicURL;
         @AuraEnabled
        public string fileId;
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
        @AuraEnabled
        public List<datawrapper> directReportesUnderme;
        @AuraEnabled
        public List<datawrapper> meReportsToList;
    }   
}