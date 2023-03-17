public without sharing class newServiceRequestController {
    
    @AuraEnabled(cacheable=true)
    public static datawrapper getTheCurrentData(){
        User uRec = [SELECT Id,ContactId FROM User Where Id=:Userinfo.getUserId()];
            integer openCases = 0;
            integer inprogressCases = 0;
            integer closedCases = 0;
            List<Case> caseList = new List<Case>();
          List<casewrapper> caswDt = new List<casewrapper>();
        caseList = [SELECT Id,AccountId,ContactId,CreatedDate,Description,Status,Subject,CaseNumber FROM Case WHERE ContactId=:uRec.ContactId];
        for(Case cnew : caseList){
            casewrapper cw = new casewrapper();
            cw.caseNumber = cnew.caseNumber;
            cw.caseid = cnew.Id;
            cw.Status = cnew.Status;
            cw.CreatedDate = Date.valueOf(cnew.CreatedDate);
              caswDt.add(cw);           
            if(cnew.Status == 'New'){
                openCases = openCases+1;
            }else if(cnew.Status == 'Closed'){
                closedCases = closedCases+1;
            }else {
                inprogressCases = inprogressCases+1;
            }
        }
        datawrapper dw = new datawrapper();
        dw.openCases = openCases;
        dw.inprogressCases = inprogressCases;
        dw.closedCases = closedCases;
        dw.caseList = caswDt;
        
        return dw;
        
    }
    
     @AuraEnabled(cacheable=true)
    public static casewrapper getTheCurrentAccAndContactId(){
        User urec = [SELECT Id,ContactId,Contact.AccountId FROM User Where Id=:Userinfo.getUserId()];
        casewrapper  cw = new casewrapper();
        cw.contactid = urec.ContactId;
        cw.accountid = urec.Contact.AccountId;
        cw.conRec = [SELECT Id,Name, LastName, FirstName, AccountId,EMS_RM_Employee_Id__c, Department__c, Department__r.Name, Resource_Role__r.Name,
                     Resource_Role__r.Id, Resource_Role__c,Work_Experience__c, EMS_RM_Notice_Period__c FROM Contact WHERE Id=:urec.ContactId];
        return cw;
    }    
    
    public class casewrapper{
        @AuraEnabled
        public string caseid;
        @AuraEnabled
        public string contactid;
        @AuraEnabled
        public string accountid;
         @AuraEnabled
        public Contact conRec;
         @AuraEnabled
        public string caseNumber;
         @AuraEnabled
        public string Status;
         @AuraEnabled
        public Date CreatedDate;
        
    }
    
    public class datawrapper {
        @AuraEnabled
        public integer openCases;
         @AuraEnabled
        public integer inprogressCases;
         @AuraEnabled
        public integer closedCases;
        @AuraEnabled
        public list<casewrapper> caseList;
        
    }

}