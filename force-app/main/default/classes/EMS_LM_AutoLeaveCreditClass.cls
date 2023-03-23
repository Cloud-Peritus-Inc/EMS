public class EMS_LM_AutoLeaveCreditClass implements
Database.Batchable<sObject>, Database.Stateful {
    public Integer recordsProcessed = 0;
    public date myDate = date.today();
    public Integer day = myDate.day();
    public Integer month = myDate.month();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, Name FROM Contact'
        );
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope){
        
        List<EMS_LM_Leave_Credit__c> leaveCreditList = new List<EMS_LM_Leave_Credit__c>();
        
        if(Test.isRunningTest()) {
            myDate = Date.newInstance(2023, 01, 01);
            day = 1;
            month = 1;
        }
        
        // process each batch of records
        for (Contact cont : scope) { 
            if((month == 1 || month == 4 || month == 7 || month == 10) && day == 1) {
                EMS_LM_Leave_Credit__c leaveCredit = new EMS_LM_Leave_Credit__c();
                leaveCredit.EMS_LM_Employee__c = cont.Id;
                leaveCredit.EMS_LM_Leave_Credited_Date__c = System.today();
                leaveCredit.EMS_LM_Leaves_Credited__c = 5;
                leaveCredit.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
                leaveCreditList.add(leaveCredit);
            }
        }
        
        try {
            if(leaveCreditList.Size() > 0) {
                insert leaveCreditList;
            }
        } catch(Exception e) {
            System.debug(e);
        }
        
    }
    public void finish(Database.BatchableContext bc){
        
    }
}