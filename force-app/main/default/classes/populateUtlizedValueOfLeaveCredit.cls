/**
* @author Subba Kalavala
* @date 10/01/2023
* @description  populateApproverDetails Class to populat the approver details
*
*               Test code coverage provided by the following test class:
*               - populateApproverDetailsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class populateUtlizedValueOfLeaveCredit implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate {
    
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
    public void afterInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'populateUtlizedValueOfLeaveCredit.afterInsert() : BEGIN');
     //   populateValuesOnLeaveCredit(newList,null);
        System.debug(LoggingLevel.DEBUG, 'populateUtlizedValueOfLeaveCredit.afterInsert() : END');       
    }
    
 /**
* @author Subba Kalavala
* @date 10/01/2023
* @description After Update 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<EMS_LM_Leave_History__c> newList,List<EMS_LM_Leave_History__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'populateUtlizedValueOfLeaveCredit.afterUpdate() : BEGIN');
       // populateValuesOnLeaveCredit(newList,new Map<Id,EMS_LM_Leave_History__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'populateUtlizedValueOfLeaveCredit.afterUpdate() : END');       
    }
    
    
    /**
*   {Purpose} - Method to populate the approver details on leave request after insert 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void populateValuesOnLeaveCredit(List<EMS_LM_Leave_History__c> newlist,Map<Id,EMS_LM_Leave_History__c> oldMap) {
        set<Id> resourceIdSet = new set<Id>();
        Map<Id,List<EMS_LM_Leave_History__c>> conWithLeaves = new Map<Id,List<EMS_LM_Leave_History__c>>();
        set<id> leaveTypes = new set<id>();
        Map<Id,Map<String,EMS_LM_Leave_Credit__c>> resourceCred = new Map<Id,Map<String,EMS_LM_Leave_Credit__c>>();
        List<EMS_LM_Leave_Credit__c> updateCredit = new List<EMS_LM_Leave_Credit__c>();
        for(EMS_LM_Leave_History__c newRec : newlist){
            if(newRec.EMS_LM_Leave_Type__r.Name != LeaveRequestConstant.ANNUAL_LEAVE 
               && newRec.EMS_LM_Leave_Type__r.Name != LeaveRequestConstant.LOSS_OF_PAY && newRec.EMS_LM_Leave_Type__r.Name != LeaveRequestConstant.WORK_FROM_HOME){
            resourceIdSet.add(newRec.EMS_LM_Contact__c);
            leaveTypes.add(newRec.EMS_LM_Leave_Type__c);
            if(conWithLeaves.containsKey(newRec.EMS_LM_Contact__c)){
                conWithLeaves.get(newRec.EMS_LM_Contact__c).add(newRec);
            }else{
                conWithLeaves.put(newRec.EMS_LM_Contact__c,new List<EMS_LM_Leave_History__c>{newRec}); 
            }
            }
        }
        
        if(!resourceIdSet.isEmpty()){
            for(EMS_LM_Leave_Credit__c credit : [SELECT Id,EMS_LM_Employee__c,EMS_LM_Leave_Type__c,Leave_Utilized__c,EMS_LM_Leaves_Credited__c 
                                                 FROM EMS_LM_Leave_Credit__c 
                                                 WHERE EMS_LM_Employee__c IN:resourceIdSet 
                                                 AND EMS_LM_Leave_Type__c IN:leaveTypes 
                                                 AND EMS_LM_Leave_Credited_Date__c = THIS_YEAR
                                                 AND EMS_LM_Leave_Type__r.Name != :LeaveRequestConstant.ANNUAL_LEAVE
                                                 AND EMS_LM_Leave_Type__r.Name != :LeaveRequestConstant.LOSS_OF_PAY ORDER BY EMS_LM_Leave_Credited_Date__c ASC ]){
                if(resourceCred.containsKey(credit.EMS_LM_Employee__c)){
                    Map<String,EMS_LM_Leave_Credit__c> credwithtype = resourceCred.get(credit.EMS_LM_Employee__c);
                    if(credwithtype.containsKey(credit.EMS_LM_Leave_Type__c)){
                        credwithtype.put(credit.EMS_LM_Leave_Type__c,credit);
                    }else{
                      credwithtype = new Map<String,EMS_LM_Leave_Credit__c>();
                      credwithtype.put(credit.EMS_LM_Leave_Type__c,credit);  
                    }
                   resourceCred.put(credit.EMS_LM_Employee__c,credwithtype); 
                }else{
                    Map<String,EMS_LM_Leave_Credit__c> credwithtype = new Map<String,EMS_LM_Leave_Credit__c>();
                    credwithtype.put(credit.EMS_LM_Leave_Type__c,credit);
                     resourceCred.put(credit.EMS_LM_Employee__c,credwithtype); 
                }  
            }
            
            for(String conid : conWithLeaves.keySet()){
                 Map<String,EMS_LM_Leave_Credit__c> credwithtype = resourceCred.get(conid);
                for(EMS_LM_Leave_History__c currentleave :  conWithLeaves.get(conid)){
                    if(credwithtype.containsKey(currentleave.EMS_LM_Leave_Type__c)){
                        EMS_LM_Leave_Credit__c lcredit = credwithtype.get(currentleave.EMS_LM_Leave_Type__c);
                        if(currentleave.EMS_LM_Status__c == 'Cancelled' || currentleave.EMS_LM_Status__c == 'Rejected'){
                            lcredit.Leave_Utilized__c =  lcredit.Leave_Utilized__c!= null ? lcredit.Leave_Utilized__c - currentleave.EMS_LM_Leave_Duration__c : -currentleave.EMS_LM_Leave_Duration__c;
                        }else{
                            lcredit.Leave_Utilized__c =  lcredit.Leave_Utilized__c!= null ? lcredit.Leave_Utilized__c + currentleave.EMS_LM_Leave_Duration__c : currentleave.EMS_LM_Leave_Duration__c;
                        }
                        updateCredit.add(lcredit);
                    }
                } 
            }   
            
        }
       
        try{
            if(updateCredit.size()>0){
                Update updateCredit;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'populateUtlizedValueOfLeaveCredit', 'populateValuesOnLeaveCredit');        
        } 
        
        
    }

}