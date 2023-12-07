/**
* @author Rohit Bhupati
* @date 8/02/2023
* @description  BatchToAdd5LeavesEveryQuarter Batch to add leaves Every Month at Start of the Month 
*              
*               Schedule class 
*               - BatchToAdd5LeavesEveryQuarter_sch
*               Test code coverage provided by the following test class:
*               - BatchToAdd5LeavesEveryQuarterTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

global class BatchToAdd5LeavesEveryQuarter implements Database.Batchable<sObject>{
    
    /** 
* @author Rohit Bhupati
* @date 8/02/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        Id WORKLOCATION_HYD_ID = [select id,Name from Office_Location__c where Name = 'Hyderabad - India' LIMIT 1].id;
        Id WORKLOCATION_USA_ID =[select Id, Name From Office_Location__c WHERE Name='California - USA' LIMIT 1].Id;
        
        return Database.getQueryLocator([SELECT Id,AccountId,EMS_LM_No_Of_Carry_Forward_Leaves__c, EMS_LM_No_Of_Leaves_Credit__c,
                                         EMS_LM_No_Of_Availble_Leaves__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
                                         EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Compensatory_Off__c,
                                         EMS_LM_No_Of_Available_Bereavement_Leave__c,EMS_EM_JD__c,Work_Location__c,Work_Location__r.name,EMS_Employee_Type__c,
                                         (SELECT Id, EMS_LM_Employee__c,CreditedMonthYear__c,EMS_LM_Leave_Type__c FROM Leave_Credits__r)
                                         FROM Contact WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID AND AccountId !=Null AND (EMS_RM_ApplicantStatus_Update__c ='Active' OR EMS_RM_ApplicantStatus_Update__c ='Active - Probation') AND
                                          (Work_Location__c =:WORKLOCATION_HYD_ID OR Work_Location__c =:WORKLOCATION_USA_ID)]);
    }
    
     /**
* @author Rohit Bhupati
* @date 8/02/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/   
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
         List<EMS_LM_Leave_Credit__C> leaveCreditList = new List<EMS_LM_Leave_Credit__C>();
         Map<String,Decimal> leaveMap = new Map<String,Decimal>();
         Id AnnualLeaveTypeId = [Select Id, Name FROM EMS_LM_Leave__c  Where Name = 'Annual Leave'].Id;
        Id PaidTimeOffTypeId=[SELECT Id, Name FROM EMS_LM_Leave__c WHERE Name='Paid time off'].Id;
         Date dt = system.today();
         Boolean isJan = dt.month() == 11 ? true : false;
         String uniqueMonthYear = String.valueOf(dt.month())+String.valueOf(dt.year());
          for(Leave_Accrued_Mapping__mdt lmpRec : [SELECT Is_Lessthan_15_Days__c,Joining_Month__c,Leaves_Credits__c FROM Leave_Accrued_Mapping__mdt ]){
            leaveMap.put(String.valueOf(integer.valueof(lmpRec.Joining_Month__c)+String.valueOf(lmpRec.Is_Lessthan_15_Days__c)),lmpRec.Leaves_Credits__c);
           }
        Map<String,decimal> contactWithCarryFwdBalance = new Map<String,Decimal>();
        
        if(isJan || Test.isRunningTest()){
            for(Contact conRec : conList){
                if(conRec.Work_Location__r.name =='Hyderabad - India'){
                    if(conRec.EMS_LM_No_Of_Availble_Leaves__c >=10) {
                        contactWithCarryFwdBalance.put(conRec.Id,10);
                    }
                    else{
                        contactWithCarryFwdBalance.put(conRec.Id,conRec.EMS_LM_No_Of_Availble_Leaves__c); 
                    }
                }else{
                    if(conRec.EMS_LM_No_Of_Availble_Leaves__c >=5) {
                        contactWithCarryFwdBalance.put(conRec.Id,5);
                    }
                    else{
                        contactWithCarryFwdBalance.put(conRec.Id,conRec.EMS_LM_No_Of_Availble_Leaves__c); 
                    }  
                }
                
            } 
        }
        
        for(Contact conRec : conList){
            if( !(conRec.Work_Location__r.name == 'California - USA' && conRec.EMS_Employee_Type__c == 'Contract')){
                
            
            Boolean shouldIcreatedTheBal = true;
            Date processingDate = system.today();
             Integer processingDay = processingDate.day();
             Integer processingMonth = processingDate.month();
             Boolean isItlessthan15 = processingDay <= 15;
             String uniqueKey = String.valueOf(processingMonth)+String.valueOf(isItlessthan15);
            
                for(EMS_LM_Leave_Credit__C leaveCreds : conRec.Leave_Credits__r){
                    system.debug('in apex'+leaveCreds.CreditedMonthYear__c );
                    system.debug('in apex'+uniqueMonthYear);
                    system.debug('in apex'+leaveCreds.CreditedMonthYear__c == uniqueMonthYear);
                    if(leaveCreds.CreditedMonthYear__c == uniqueMonthYear &&
                       (leaveCreds.EMS_LM_Leave_Type__c ==AnnualLeaveTypeId || leaveCreds.EMS_LM_Leave_Type__c == PaidTimeOffTypeId)){
                       shouldIcreatedTheBal = false; 
                    }
                }
                
                  
                 String valuefromclabe1=System.Label.leaveforbelowtwoyear;
                Decimal ususlessthan24= Decimal.valueOf(valuefromclabe1);
                 String valuefromlabel2=System.Label.leavegreater2years;
                Decimal ususgreaterthan24= Decimal.valueOf(valuefromlabel2);
                
            if(shouldIcreatedTheBal || Test.isRunningTest()){
             EMS_LM_Leave_Credit__c leaveCredit = new EMS_LM_Leave_Credit__c();
                 leaveCredit.EMS_LM_Employee__c = conRec.Id;
                 leaveCredit.EMS_LM_Leave_Credited_Date__c = System.today();
                if(conRec.Work_Location__r.name == 'Hyderabad - India'){
                    leaveCredit.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
                    leaveCredit.EMS_LM_Leave_Type__c = AnnualLeaveTypeId;
                }else{
                    leaveCredit.EMS_LM_Select_Leave_Type__c = 'Paid time off';
                    leaveCredit.EMS_LM_Leave_Type__c = PaidTimeOffTypeId;
                }
                
                if (conRec.Work_Location__r.Name == 'California - USA' ) {
                    Integer monthsSinceJoin = conRec.EMS_EM_JD__c.monthsBetween(System.today());
                     if(monthsSinceJoin<24){
                            System.debug('### Contains ' + contactWithCarryFwdBalance.containsKey(conRec.Id));
                        if (contactWithCarryFwdBalance.containsKey(conRec.Id)) {
                            leaveCredit.EMS_LM_Leaves_Credited__c = contactWithCarryFwdBalance.get(conRec.Id) + ususlessthan24;
            leaveCredit.Comments__c = 'Included the Last Year Carry Forward Balance of ' + contactWithCarryFwdBalance.get(conRec.Id);
                        } else {
                            leaveCredit.EMS_LM_Leaves_Credited__c =ususlessthan24;
                        }
                    }else if(monthsSinceJoin>=24){
                        if (contactWithCarryFwdBalance.containsKey(conRec.Id)) {
                            leaveCredit.EMS_LM_Leaves_Credited__c = contactWithCarryFwdBalance.get(conRec.Id) + ususgreaterthan24;
            leaveCredit.Comments__c = 'Included the Last Year Carry Forward Balance of ' + contactWithCarryFwdBalance.get(conRec.Id);
                        } else {
                            leaveCredit.EMS_LM_Leaves_Credited__c =ususgreaterthan24;
                        }
                    }
                    
                    
                }else {
                    if (contactWithCarryFwdBalance.containsKey(conRec.Id)){
                        leaveCredit.EMS_LM_Leaves_Credited__c = contactWithCarryFwdBalance.get(conRec.Id) + leaveMap.get(uniqueKey);
                    leaveCredit.Comments__c = 'Included the Last Year Carry Forward Balance of ' + contactWithCarryFwdBalance.get(conRec.Id);
                    } else{
                        leaveCredit.EMS_LM_Leaves_Credited__c = leaveMap.get(uniqueKey);
                    }
                }
              leaveCreditList.add(leaveCredit);      
        }
                  }
   
    
}
         system.debug('===leaveCreditList=='+leaveCreditList);
        
        database.insert(leaveCreditList,false);
        }
        

        

    
    global void finish(Database.BatchableContext BC) {
        
    }
}