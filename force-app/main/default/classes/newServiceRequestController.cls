public without sharing class newServiceRequestController {
    
    @AuraEnabled(cacheable=true)
    public static datawrapper getTheCurrentData(){
        User uRec = [SELECT Id,ContactId FROM User Where Id=:Userinfo.getUserId()];
            integer openCases = 0;
            integer inprogressCases = 0;
            integer closedCases = 0;
            List<Case> caseList = new List<Case>();
          List<casewrapper> caswDt = new List<casewrapper>();
        caseList = [SELECT Id,AccountId,ContactId,CreatedDate,Description,Status,Subject,CaseNumber,Type FROM Case WHERE ContactId=:uRec.ContactId Order By CreatedDate DESC];
        for(Case cnew : caseList){
            casewrapper cw = new casewrapper();
            cw.caseNumber = cnew.caseNumber;
            cw.caseid = cnew.Id;
            cw.Status = cnew.Status;
            cw.caseType = cnew.Type;
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
        Case newCase = [SELECT Id,CreatedDate,Status,OwnerId,IsEscalated,Case_Assignee__c,Case_Assignee__r.EMS_TM_User__c,Contact.EMS_TM_User__c FROM Case WHERE Id=:caseid];
         casewrapper  cw = new casewrapper();
         cw.caseid = newCase.Id;
         cw.enableTransfer = true; //Disable the Transfer button
         cw.enableClose = (newCase.Status == 'Closed' || newCase.Status == 'Resignation Approved' || newCase.Status == 'Resignation Rejected');  
         if(newCase.Contact.EMS_TM_User__c == Userinfo.getUserId()){
            cw.enableEscalate = daysBetweenExcludingWeekends(newCase.CreatedDate,system.now()) > 3 ? false : true;
            cw.enableEscalate = cw.enableClose ? true :  cw.enableEscalate; 
         }else{
               cw.enableEscalate = true; 
         }
         
         if(newCase.Case_Assignee__c != null && newCase.Case_Assignee__r.EMS_TM_User__c == Userinfo.getUserId()){
              cw.enableTransfer = false;  
         }
        
         
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
    
     @AuraEnabled
    public static string processTheCaseTransfer(String caseid,String conId){
        Case newcase = new Case();
        newcase.id = caseid;
        newcase.Case_Assignee__c = conId;
        
        try{
            update newcase;
            return 'Successfully transferred the service request.';
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
    
      @AuraEnabled(cacheable=true)
    public static caseviewWrapper getTheCaseViewDetails(Id caseid){
        Case newCase = [SELECT Id,Type,CreatedDate,Status,OwnerId,IsEscalated,Case_Assignee__c,Case_Assignee__r.EMS_TM_User__c,Contact.EMS_TM_User__c
                        FROM Case WHERE Id=:caseid];
        
        caseviewWrapper cw = new caseviewWrapper();
        cw.isLoggedUserisAssignee = newCase.Case_Assignee__r.EMS_TM_User__c == Userinfo.getUserId();
         cw.isOtherType = false;
         cw.isChangeOfDetails = false;
         cw.isSpecialLeaves = false;
         cw.isResign = false;
         cw.isTechProblemType = false;

        if(newCase.Type == 'Others'){
         cw.isOtherType = true;   
        }else if(newCase.Type == 'Change of Details'){
         cw.isChangeOfDetails = true;   
        }else if(newCase.Type == 'Special Leaves'){
         cw.isSpecialLeaves = true;   
        }else if(newCase.Type == 'Resignation'){
         cw.isResign = true;   
        }else if(newCase.Type == 'Technical Issues'){
         cw.isTechProblemType = true;   
        }
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
        public string caseType;
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
        @AuraEnabled
        public boolean enableTransfer;
        
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
    
    public class caseviewWrapper {
        @AuraEnabled
        public boolean isOtherType;
        @AuraEnabled
        public boolean isTechProblemType;
        @AuraEnabled
        public boolean isResign;
        @AuraEnabled
        public boolean isChangeOfDetails;
        @AuraEnabled
        public boolean isSpecialLeaves;
        @AuraEnabled
        public boolean isLoggedUserisAssignee;
    }

}