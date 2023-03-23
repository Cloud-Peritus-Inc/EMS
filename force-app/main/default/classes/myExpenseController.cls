public class myExpenseController {
    
@AuraEnabled(cacheable=true)
public static datawrapper getMyExpenseReport(){
        List<Expense__c> expList = new List<Expense__c>();
       List<expense> expNewList = new List<expense>();
        Map<string,string> nameMap = new Map<String,string>();
        User uRec = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
        Decimal pendingAmount = 0;
        expList = [SELECT id,Name,Amount__c,Expense_Amount__c,Project__c,Project__r.Name,Billing_Currency__c,CreatedDate,Status__c,Reimbursed_Date__c,is_Reimbursed__c FROM Expense__c WHERE Resource__c=:uRec.ContactId];
        for(Expense__c exp : expList){
            nameMap.put(exp.Name,exp.id);
            if(exp.Status__c != 'Rejected' && exp.Status__c != 'Draft' && !exp.is_Reimbursed__c && exp.Expense_Amount__c != null){
               pendingAmount = pendingAmount+exp.Expense_Amount__c; 
            } 
           expense ex = new expense();
           ex.expid = exp.id;
           ex.reimbdate = exp.Reimbursed_Date__c;
            ex.amount = exp.Expense_Amount__c;
            ex.projectName = exp.Project__r.Name;
            ex.status = exp.Status__c;
            ex.expName = exp.Name;
            ex.amountcurrency = exp.Billing_Currency__c;
            expNewList.add(ex);
        }
        datawrapper dw = new datawrapper();
        dw.pendingreim = pendingAmount;
        dw.resourceId = uRec.ContactId;
        dw.expList = expNewList;
        return dw;
    }
    @AuraEnabled
    public static datawrapper updateAndGetData(Id expId, String status){
        expense__c exp = new expense__c();
        exp = [SELECT Id,Project__c,Project__r.Project_Manager__c FROM expense__c WHERE Id=:expId];
        exp.Status__c = status;
        if(status == 'Submitted'){
            if(String.isEmpty(exp.Project__r.Project_Manager__c)){
                User Urec = [SELECT Id,ContactId,Contact.ReportsTo.Id,Contact.ReportsTo.EMS_TM_User__c FROM User WHERE Id=:userinfo.getUserId()]; 
             exp.Approval_Manager__c = Urec.Contact.ReportsToId;
            }else{
                 exp.Approval_Manager__c = exp.Project__r.Project_Manager__c;
            }
         exp.Reimbursed_Date__c =  system.today().adddays(14);            
        }
       
        update exp;
        return getMyExpenseReport();
       
    }
    
    public class expense{
        @AuraEnabled
        public string expName;
         @AuraEnabled
        public Date reimbdate;
         @AuraEnabled
        public decimal amount;
        @AuraEnabled
        public string amountcurrency;
         @AuraEnabled
        public string status;
         @AuraEnabled
        public string projectName;
         @AuraEnabled
        public string expid;
        
    }
    
    public class datawrapper{
        @AuraEnabled
        public decimal pendingreim;
        @AuraEnabled
        public string resourceId;
        @AuraEnabled
        public string expCurrency;
        @AuraEnabled
        public List<expense> expList;
        
    }

}