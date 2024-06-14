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
public without sharing class LeaveRequestWFHStatus implements TriggerAction.BeforeInsert{
    /**
* @author Subba Kalavala
* @date 10/01/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'populateApproverDetails.beforeInsert() : BEGIN');
        wfhReqStatusUpdate(newList);
        System.debug(LoggingLevel.DEBUG, 'populateApproverDetails.beforeInsert() : END');       
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
    private void wfhReqStatusUpdate(List<EMS_LM_Leave_History__c> newlist) {
        for(EMS_LM_Leave_History__c newRec : newlist){
            if(newRec.EMS_LM_Status__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c <= 3){
                newRec.EMS_LM_Status__c = LeaveRequestConstant.PENDING;
            }else if (newRec.EMS_LM_Status__c == LeaveRequestConstant.WORK_FROM_HOME && newRec.EMS_LM_Leave_Duration__c >= 3){
                newRec.EMS_LM_Status__c = LeaveRequestConstant.APPROVER_2_WAITING;
                
            }     
        }
        
    }
    
}