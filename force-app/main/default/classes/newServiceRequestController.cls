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
                     Resource_Role__r.Id, Resource_Role__c,Work_Experience__c, Notice_Period__c FROM Contact WHERE Id=:urec.ContactId];
        return cw;
    }    
    
     @AuraEnabled(cacheable=true)
    public static casewrapper getTheCaseDetails(Id caseid){
        Case newCase = [SELECT Id,CreatedDate,Status,OwnerId,IsEscalated FROM Case WHERE Id=:caseid];
         casewrapper  cw = new casewrapper();
         cw.caseid = newCase.Id;
         cw.enableEscalate = daysBetweenExcludingWeekends(newCase.CreatedDate,system.now()) > 5 ? false : true;
         cw.enableClose = (newCase.Status == 'Closed' || newCase.Status == 'Resignation Approved' || newCase.Status == '	Resignation Rejected');  
         cw.enableEscalate = cw.enableClose ? true :  cw.enableEscalate; 
         
         return cw;
    }
    
    @AuraEnabled
    public static casewrapper processTheCaseUpdate(String caseid,String comments, Boolean isEsacalted){
        Case newcase = new Case();
        newcase.id = caseid;
        if(isEsacalted){
          newcase.Escalation_Reason__c = comments;
          newcase.IsEscalated = true;
          newcase.Status = 'Escalated';
        }else{
            newcase.Comments = comments;
            newcase.Status = 'Closed';
        }
        
        try{
            update newcase;
            return getTheCaseDetails(newcase.id);
        }catch(exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    public static Integer daysBetweenExcludingWeekends(Datetime startDate, Datetime endDate) {
        Integer days = startDate.date().daysBetween(endDate.date());
        days -= ((integer)Math.floor((days / 7)) * 2);
    
        if (startDate.format('E') != 'Sat') {
            days -= 1;
        } else if (startDate.format('E') != 'Sun') {
            days -= 2;
        }
    
        return days;
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
        @AuraEnabled
        public boolean enableEscalate;
         @AuraEnabled
        public boolean enableClose;
        
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