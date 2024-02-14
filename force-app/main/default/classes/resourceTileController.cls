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
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name,Contact.EMS_TM_User__c FROM User WHERE Id = :Userinfo.getUserId() and ContactId != null];
        
        Contact conRec = [SELECT Id,Work_Location__c,Work_Location__r.Country__c,(SELECT Id FROM PayRolls__r),(Select Id,Amount__c FROM Benefits__r WHERE Type__c = 'Medical Insurence') FROM Contact WHERE Id=:urecord.contactId];
        datawrapper dwrap = new datawrapper();
        dwrap.resourceName = urecord.Name;
        dwrap.resourcePhotoURL = urecord.FullPhotoUrl;
        dwrap.resourceCpId = urecord.Contact.EMS_RM_Employee_Id__c;
        dwrap.resourceRole = urecord.Contact.Resource_Role__r.Name;
        dwrap.nextpaydate = lastdayoftheMonth(conRec);
        dwrap.resourceReportTo = urecord.Contact.ReportsTo.Name;
        dwrap.resourceUserId = urecord.Id;
        dwrap.loggedinresource = urecord.Contact.EMS_TM_User__c == Userinfo.getUserId();
        dwrap.resourceContactId = urecord.ContactId;
        dwrap.resourceInsurence = getMyInsurenceBenf(conRec);
        dwrap.rescodecurrency = conRec.Work_Location__r.Country__c == 'United States of America' ? 'USD' : 'INR';
        return dwrap;
    }
    
    @AuraEnabled(cacheable=true)
    public static datawrapper getContactInfo(Id conid) {
        Contact con = [SELECT Id,EMS_TM_User__c FROM Contact WHERE Id=:conId];
        datawrapper dwrap = new datawrapper();
        dwrap.loggedinresource = con.EMS_TM_User__c == Userinfo.getUserId();
        
        return dwrap;
    }
    
    public static decimal getMyInsurenceBenf(Contact conRec){
        if(!conRec.Benefits__r.isEmpty()){
            return  conRec.Benefits__r[0].Amount__c;
        }
        return 500000;
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
        string BASE_URL='/sfc/servlet.shepherd/document/download/';
        Map<String,String> fileExtensionToTypeMap = new Map<String,String>{
            'MP4' => 'Video',
                'MP3' => 'Audio',
                'WAV' => 'Audio'
                }; 
                    Date dt = Test.isRunningTest() ? system.today().adddays(1) : system.today();
        Set<Id> recordIdSet = new Set<Id>();
        List<datawrapper> dwrap = new List<datawrapper>();
        List<Grid_Configuration__c> fileredFiles = new List<Grid_Configuration__c>();
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name,Contact.Resource_Role__c FROM User WHERE Id = :Userinfo.getUserId()];
        for(Grid_Configuration__c gridc : [SELECT Id,Description__c,Notification_Type__c,Name,Goal_End_Date__c,Goal_Start_Date__c,Grid_Configuration_Type__c,
                                           Navigation_address__c,is_Navigation_Required__c,Resource_Role__c 
                                           FROM Grid_Configuration__c 
                                           WHERE (Goal_Start_Date__c <=:dt AND Goal_End_Date__c>=:dt) 
                                           AND (Grid_Configuration_Type__c = 'Org Level Alert' OR Grid_Configuration_Type__c = 'Resource Role Alert'
                                                OR Grid_Configuration_Type__c = 'Audio Podcast' OR Grid_Configuration_Type__c = 'Videocast')]){
                                                    if(gridc.Grid_Configuration_Type__c == 'Org Level Alert'){
                                                        datawrapper dw = new datawrapper();
                                                        dw.isAlert = gridc.Notification_Type__c == 'Alert' ? true:false;
                                                        dw.alertTitle = gridc.Name;
                                                        dw.alertDesc = gridc.Description__c;
                                                        dw.isAudioVideo = false;
                                                        dwrap.add(dw);
                                                    }else if(gridc.Grid_Configuration_Type__c == 'Resource Role Alert' && urecord.Contact.Resource_Role__c == gridc.Resource_Role__c){
                                                        datawrapper dw = new datawrapper();
                                                        dw.isAlert = gridc.Notification_Type__c == 'Alert' ? true:false;
                                                        dw.alertTitle = gridc.Name;
                                                        dw.alertDesc = gridc.Description__c;
                                                        dw.isAudioVideo = false;
                                                        dwrap.add(dw);  
                                                    }else if(gridc.Grid_Configuration_Type__c == 'Audio Podcast' || gridc.Grid_Configuration_Type__c == 'Videocast'){
                                                        recordIdSet.add(gridc.Id); 
                                                        fileredFiles.add(gridc);
                                                    }  
                                                    
                                                }
        
        if(!fileredFiles.isEmpty()){
            Set<id> ContentDocumentIds = new Set<id>();
            for(ContentDocumentLink cdl :  [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN:recordIdSet]){
                ContentDocumentIds.add(cdl.contentdocumentId);
            }    
            ContentDocument[] contentDocList = [
                SELECT Id,Title,FileType,FileExtension 
                FROM ContentDocument 
                WHERE Id IN :ContentDocumentIds
                AND FileType IN :fileExtensionToTypeMap.keySet()
            ];
            
            for(ContentDocument cd : contentDocList){
                datawrapper dw = new datawrapper();
                dw.name=cd.Title;
                dw.url=BASE_URL+cd.Id;
                dw.filetype = fileExtensionToTypeMap.get(cd.FileType);
                dw.isAudioVideo = true;
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
        system.debug('files-=-=-=-=-=-=-=-=-=-='+files);
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
        
        Id conReportToId;
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,contact.ReportsToId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name FROM User WHERE Id = :Userinfo.getUserId() and ContactId != null];
        
        Contact conRec = [SELECT Id,Work_Location__c,Work_Location__r.Country__c,ReportsTo.Resource_Role__r.Name,(SELECT Id,Resource_Reports_Name__c,Resource_Reports_To__c FROM Resource_Resource_Relationships__r where Relationship_Type__c INCLUDES('Mentor'))
                          ReportsTo.EMS_RM_Employee_Id__c,ReportsTo.EMS_TM_User__c,
                          ReportsTo.EMS_TM_User__r.FullPhotoUrl,ReportsTo.Name,ReportsToId FROM Contact WHERE Id=:urecord.contactId AND EMS_RM_ApplicantStatus_Update__c != 'Inactive'];
        
        if (!conRec.Resource_Resource_Relationships__r.isEmpty()) {
            Id mentorId = conRec.Resource_Resource_Relationships__r[0].Id;
            conReportToId = conRec.Resource_Resource_Relationships__r[0].Resource_Reports_To__c;
        }
        
        List<Contact> mydirectReports = new List<Contact>();
        Set<Id> myrepotiescontids = new Set<Id>();
        Set<Id> mereportsTo = new Set<Id>();
        for(Resource_Resource_Relationship__c rrr : [SELECT Id,Resource__c,Resource_Reports_To__c,Relationship_Type__c FROM Resource_Resource_Relationship__c WHERE ( Resource_Reports_To__c=:urecord.contactId OR Resource__c=:urecord.contactId) AND Relationship_Type__c INCLUDES('Mentor')]){
            if(rrr.Resource__c == urecord.contactId){
                if(rrr.Relationship_Type__c.contains('Mentor')){
                    myrepotiescontids.add(rrr.Resource__c);
                }
            }
            if(rrr.Resource_Reports_To__c == urecord.contactId){
                // if(rrr.Relationship_Type__c.contains('Mentor')){
                mereportsTo.add(rrr.Resource__c);
                // }
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
                                   ,EMS_TM_User__c FROM Contact WHERE Id IN: mereportsTo and EMS_TM_User__r.isActive = true]){
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
        if (conReportToId != null) {
        for(Contact myreporties : [SELECT Id,Name,EMS_TM_User__r.FullPhotoUrl,EMS_RM_Employee_Id__c,Resource_Role__r.Name,ReportsTo.Name
                                   ,(SELECT Id,Resource_Reports_Name__c FROM Resource_Resource_Relationships__r where Relationship_Type__c INCLUDES('Mentor')),EMS_TM_User__c FROM Contact WHERE Id=:conReportToId AND EMS_TM_User__r.isActive = true AND EMS_RM_ApplicantStatus_Update__c != 'Inactive']){
                                       datawrapper dwrap2 = new datawrapper();
                                       dwrap2.resourceName = myreporties.Name;
                                       dwrap2.resourcePhotoURL = myreporties.EMS_TM_User__r.FullPhotoUrl;
                                       dwrap2.resourceCpId = myreporties.EMS_RM_Employee_Id__c;
                                       dwrap2.resourceRole = myreporties.Resource_Role__r.Name;
                                       if (!myreporties.Resource_Resource_Relationships__r.isEmpty()) {
                                           dwrap2.resourceReportTo = myreporties.Resource_Resource_Relationships__r[0].Resource_Reports_Name__c;//myreporties.ReportsTo.Name;
                                       }
                                       
                                       dwrap2.resourceUserId = myreporties.EMS_TM_User__c;
                                       dwrap2.resourceContactId = myreporties.id;
                                       meReportsToList.add(dwrap2);
                                   }
            dwrap.meReportsToList = meReportsToList;
        }
        
        dwrap.directReportesUnderme = directReportsList;
        
        
        return dwrap;  
    }
    @AuraEnabled(cacheable=true)
    public static List<datawrapper> getUserReportees(Id userId) {
        User urecord = [SELECT FullPhotoUrl,Id,Name,Employee_Id__c,Contact.EMS_RM_Employee_Id__c,ContactId,contact.ReportsToId,
                        Contact.ReportsTo.Name,Contact.Resource_Role__r.Name FROM User WHERE Id = :userId and ContactId != null];
        
        List<Resource_Resource_Relationship__c> resourceList =[select id,Resource__r.id,Resource_Reports_To__c,Relationship_Type__c from Resource_Resource_Relationship__c where Resource_Reports_To__c=:urecord.contactId and Resource__r.EMS_TM_User__r.IsPortalEnabled = true and Resource__r.EMS_RM_ApplicantStatus_Update__c != 'Inactive'];
        Set<Id> resourceIds = new Set<Id>();
        for(Resource_Resource_Relationship__c rr:resourceList){
            if(rr.Relationship_Type__c.contains('Mentor')){
                resourceIds.add(rr.Resource__r.id);
            }
        }
        
        List<Contact> directReports = [SELECT Id,Name,EMS_TM_User__r.FullPhotoUrl,EMS_RM_Employee_Id__c,Resource_Role__r.Name,ReportsTo.Name,
                                       EMS_TM_User__c FROM Contact WHERE ID IN : resourceIds AND ReportsToId=:urecord.contactId AND EMS_RM_ApplicantStatus_Update__c != 'Inactive' AND EMS_TM_User__r.IsPortalEnabled = true ];
        
        /*List<Contact> directReports = [SELECT Id,Name,EMS_TM_User__r.FullPhotoUrl,EMS_RM_Employee_Id__c,Resource_Role__r.Name,ReportsTo.Name,
			EMS_TM_User__c FROM Contact WHERE ReportsToId=:urecord.contactId AND EMS_RM_ApplicantStatus_Update__c != 'Inactive'];*/
        
        List<datawrapper> reporteesList = new List<datawrapper>();
        for(Contact reportee : directReports){
            datawrapper dwrap = new datawrapper();
            dwrap.resourceName = reportee.Name;
            dwrap.resourcePhotoURL = reportee.EMS_TM_User__r.FullPhotoUrl;
            dwrap.resourceCpId = reportee.EMS_RM_Employee_Id__c;
            dwrap.resourceRole = reportee.Resource_Role__r.Name;
            dwrap.resourceReportTo = reportee.ReportsTo.Name;
            dwrap.resourceUserId = reportee.EMS_TM_User__c;
            dwrap.resourceContactId = reportee.Id;
            reporteesList.add(dwrap);
            system.debug('dwrap ' +dwrap);
        }
        system.debug('reporteesList ' +reporteesList);
        return reporteesList;  
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
        public boolean loggedinresource;
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
        public Boolean isAudioVideo;
        @AuraEnabled
        public string alertTitle;
        @AuraEnabled
        public string alertDesc; 
        @AuraEnabled
        public List<datawrapper> directReportesUnderme;
        @AuraEnabled
        public List<datawrapper> reporteesList; 
        @AuraEnabled
        public List<datawrapper> meReportsToList;
        @AuraEnabled public string name;
        @AuraEnabled public string url;
        @AuraEnabled public string filetype;
    }  
    
}