public without sharing class myExpenseController {
    
@AuraEnabled(cacheable=true)
public static datawrapper getMyExpenseReport(){
        List<Expense__c> expList = new List<Expense__c>();
       List<expense__c> expNewList = new List<expense__c>();
        Map<string,string> nameMap = new Map<String,string>();
        User uRec = [SELECT Id,ContactId,Contact.Work_Location__r.Country__c FROM User WHERE Id=:Userinfo.getUserId()];
        Decimal pendingAmount = 0;
        expList = [SELECT id,Name,Amount1__c,Resource__r.Work_Location__c,Resource__r.Work_Location__r.Country__c,
                   Expense_Amount__c,Project__c,Project__r.Name,Billing_Currency__c,
                   CreatedDate,Status__c,Reimbursed_Date__c,is_Reimbursed__c FROM Expense__c 
                   WHERE Resource__c=:uRec.ContactId];
        Integer defalutCon = Integer.valueOf(Label.Default_Conversion);
        String defalutCurrent = uRec.Contact.Work_Location__r.Country__c == 'India' ? 'INR' : 'USD';
        for(Expense__c exp : expList){
            
            Boolean isConversionRequired = defalutCurrent != exp.Billing_Currency__c;
            
            nameMap.put(exp.Name,exp.id);
            if(exp.Status__c != 'Rejected' && exp.Status__c != 'Draft' && !exp.is_Reimbursed__c && exp.Expense_Amount__c != null){
                decimal expenseAmount = exp.Expense_Amount__c;
                
                if(isConversionRequired){
                   expenseAmount = defalutCurrent == 'INR' ? expenseAmount * defalutCon : expenseAmount/defalutCon;  
                }
               pendingAmount = pendingAmount+expenseAmount; 
            }
            if(exp.Expense_Amount__c != null){
            expense ex = new expense();
            ex.expid = exp.id;
            ex.reimbdate = exp.Reimbursed_Date__c;
            integer expA = integer.valueOf(exp.Expense_Amount__c.setScale(0));
            if(isConversionRequired){
              ex.amount = defalutCurrent == 'INR' ?   '$ '+String.valueOf(expA) + ' ( ₹ ' + String.valueOf(expA * defalutCon) +')' : '₹ '+String.valueOf(expA) + ' ( $ ' + String.valueOf(expA/defalutCon) +')';  
            }else{ 
                ex.amount = defalutCurrent == 'INR' ? '₹ '+ String.valueOf(expA) : '$ ' + String.valueOf(expA);
             }
            
            ex.projectName = exp.Project__r.Name;
            ex.status = exp.Status__c;
            ex.expName = exp.Name;
            
            ex.amountcurrency = exp.Billing_Currency__c;
            expNewList.add(ex);
            }
        }
        datawrapper dw = new datawrapper();
        dw.pendingreim = pendingAmount;
        dw.resourceId = uRec.ContactId;
        dw.expCurrency = defalutCurrent;
        
        dw.expList = expNewList;
        return dw;
    }
    @AuraEnabled
    public static datawrapper updateAndGetData(Id expId, String status){
        expense__c exp = new expense__c();
        exp = [SELECT Id,Project__c,Project__r.Project_Manager__c,Approval_Manager__c FROM expense__c WHERE Id=:expId];
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
    
@AuraEnabled(cacheable=true)
public static expense checkTheExpense(Id expId){
  Expense__c exp = [SELECT Status__c FROM Expense__c Where Id=:expId];
    expense exp2 = new expense();
    exp2.disableApproval = exp.Status__c != 'Draft' ? true : false;
    exp2.disablerecall = exp.Status__c != 'Submitted' ? true : false;
  return exp2;
}
 
    @AuraEnabled
    public static expense updateforApproval(Id expId, String status){
        expense__c exp = new expense__c();
        exp.id = expId;
        exp.Status__c = status;
        try{
            update exp;
            return checkTheExpense(expId);
        }catch(exception ex){
             throw new AuraHandledException(ex.getMessage());
        }
        
    }

    
    public class expense{
        @AuraEnabled
        public string expName;
         @AuraEnabled
        public Date reimbdate;
         @AuraEnabled
        public String amount;
        @AuraEnabled
        public string amountcurrency;
         @AuraEnabled
        public string status;
         @AuraEnabled
        public string projectName;
         @AuraEnabled
        public string expid;
        @AuraEnabled
        public string approvalManager; 
         @AuraEnabled
        public boolean disableApproval; 
         @AuraEnabled
        public boolean disablerecall; 
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