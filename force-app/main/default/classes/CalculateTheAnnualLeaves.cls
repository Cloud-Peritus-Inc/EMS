/**
* @author Subba Kalavala
* @date 10/01/2023
* @description  CalculateTheAnnualLeaves Class to calculate the annual 
*               leaves for an contact with record type resource
*
*               Test code coverage provided by the following test class:
*               - CalculateTheAnnualLeavesTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class CalculateTheAnnualLeaves implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
     /**
     * @author Subba Kalavala
     * @date 10/01/2023
     * @description After Insert 
     *
     * CHANGE HISTORY
     * ====================================================================================================
     * DATE          NAME                    DESCRIPTION
     * N/A           N/A                     N/A
     * ====================================================================================================
     **/
     public void afterInsert(List<Contact> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CalculateTheAnnualLeaves.afterInsert() : BEGIN');
         updateResourceLeaves(newList,null);
         System.debug(LoggingLevel.DEBUG, 'CalculateTheAnnualLeaves.afterInsert() : END');       
     }
    
     /**
     * @author Subba Kalavala
     * @date 10/01/2023
     * @description After Insert 
     *
     * CHANGE HISTORY
     * ====================================================================================================
     * DATE          NAME                    DESCRIPTION
     * N/A           N/A                     N/A
     * ====================================================================================================
     **/
     public void afterUpdate(List<Contact> newList,List<Contact> oldList) {      
         System.debug(LoggingLevel.DEBUG, 'CalculateTheAnnualLeaves.afterInsert() : BEGIN');
         updateResourceLeaves(newList, new Map<Id,Contact>(oldList));
         System.debug(LoggingLevel.DEBUG, 'CalculateTheAnnualLeaves.afterInsert() : END');       
     }
     /**
     *   {Purpose} - Method for calcualte the leaves for resource 
     *
     *   CHANGE HISTORY
     *   ====================================================================================================
     *   Date        Name                    Description
     *   N/A         N/A                     N/A
     *   ====================================================================================================
     **/
     private void updateResourceLeaves(List<Contact> contactList,Map<Id,Contact> oldMap) {
      Map<String,Decimal> leaveMap = new Map<String,Decimal>();
      Id AnnualLeaveTypeId = [Select Id FROM EMS_LM_Leave__c  WHERE Name = 'Annual Leave' Limit 1].Id;
      Id PaidTimeOffTypeId=[SELECT Id FROM EMS_LM_Leave__c WHERE Name='Paid time off' Limit 1].Id;
         
      List<EMS_LM_Leave_Credit__c> leaveCreditList = new List<EMS_LM_Leave_Credit__c>();
        List<Contact> filteredList = new List<Contact>();
        for(Contact conRec : contactList) {
            contact oldCon = oldMap != null ? oldMap.get(conRec.Id) : null;
             if(conRec.RecordTypeId == ContactConstant.RESOURCE_RECORDTYPEID && conRec.EMS_EM_JD__c != null && (oldCon == null || conRec.RecordTypeId != oldCon.RecordTypeId ) ){
                 filteredList.add(conRec);
             }
         }
         
         if(!filteredList.isEmpty()){
             for(Leave_Accrued_Mapping__mdt lmpRec : [SELECT Is_Lessthan_15_Days__c,Joining_Month__c,Leaves_Credits__c FROM Leave_Accrued_Mapping__mdt ]){
                 leaveMap.put(String.valueOf(integer.valueof(lmpRec.Joining_Month__c)+String.valueOf(lmpRec.Is_Lessthan_15_Days__c)),lmpRec.Leaves_Credits__c);
             }
         }
       
         for(Contact contactRec: filteredList) {
             Date joiningDate = contactRec.EMS_EM_JD__c;
             Integer joiningDay = joiningDate.day();
             Integer joiningMonth = joiningDate.month();
             Boolean isItlessthan15 = joiningDay <= 15;
             String uniqueKey = String.valueOf(joiningMonth)+String.valueOf(isItlessthan15);
            // String locationvar=contactRec.Work_Location__r.name;            
          Id WORKLOCATION_HYD_ID = [select id,Name from Office_Location__c where Name = 'Hyderabad - India' LIMIT 1].id;
        Id WORKLOCATION_USA_ID =[select Id, Name From Office_Location__c WHERE Name='California - USA' LIMIT 1].Id;
              Integer joiningYear=joiningDate.year();
             //Integer daysinmonth=joiningDate.daysInMonth(joiningYear,joiningMonth);
             Integer daysInMonth = Date.daysInMonth(joiningYear, joiningMonth);
             Integer daystillcrediteven;
                    integer daystillcreditodd;
              String leaveCreditUSSecoff=System.Label.leaveCreditUS1;
             Decimal usleavecreditsecOff= Decimal.valueOf(leaveCreditUSSecoff);
             String valuefromclabe1=System.Label.leaveforbelowtwoyear;
                Decimal usleaveCreditFirstoff= Decimal.valueOf(valuefromclabe1);
   if(leaveMap.containsKey(uniqueKey)){
               EMS_LM_Leave_Credit__c leaveCredit = new EMS_LM_Leave_Credit__c();
                 leaveCredit.EMS_LM_Employee__c = contactRec.Id;
                 leaveCredit.EMS_LM_Leave_Credited_Date__c = System.today();
                  if(contactRec.Work_Location__c == WORKLOCATION_HYD_ID ){
                    leaveCredit.EMS_LM_Select_Leave_Type__c = 'Annual Leave';
                    leaveCredit.EMS_LM_Leave_Type__c = AnnualLeaveTypeId;
                      leaveCredit.EMS_LM_Leaves_Credited__c = leaveMap.get(uniqueKey);
                }else if(contactRec.Work_Location__c == WORKLOCATION_USA_ID){
                    leaveCredit.EMS_LM_Select_Leave_Type__c = 'Paid time off';
                    leaveCredit.EMS_LM_Leave_Type__c = PaidTimeOffTypeId;
                    
                    if(math.mod(daysInMonth, 2) == 0){
                        daystillcrediteven=daysInMonth/2;
                        if(joiningDate.day()<=daystillcrediteven){
                            leaveCredit.EMS_LM_Leaves_Credited__c =usleaveCreditFirstoff;
                        } else{
                            leaveCredit.EMS_LM_Leaves_Credited__c =usleavecreditsecOff;
                        }
                        
                    }else if(math.mod(daysInMonth, 2) != 0){
                        daystillcreditodd=(daysInMonth + 1) / 2;
                        if(joiningDate.day()<=daystillcreditodd){
                            leaveCredit.EMS_LM_Leaves_Credited__c =usleaveCreditFirstoff;
                        }else{
                            leaveCredit.EMS_LM_Leaves_Credited__c =usleavecreditsecOff;
                        }
                    }
                    
                    
              
             
                }
                 
                 //leaveCredit.EMS_LM_Leaves_Credited__c=1;
                 leaveCreditList.add(leaveCredit);
                  
             }
         }  
            
         try {
             if(leaveCreditList.Size() > 0) {
                 insert leaveCreditList;
             }
         } catch(Exception excp) {
             LogException.logHandledException(excp, 'CalculateTheAnnualLeaves', 'updateResourceLeaves');
         }    
         
     }
 }