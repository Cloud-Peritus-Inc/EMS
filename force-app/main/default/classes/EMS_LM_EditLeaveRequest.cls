/**
* @author Sangharsh Kamble
* @date 24/01/2023
* @description Class for get leave request record to edit record.
*
*               Test code coverage provided by the following test class: 
*               - EMS_LM_ContactLeaveUpdate_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class EMS_LM_EditLeaveRequest {
    
    
    @AuraEnabled(Cacheable=true)
    public static EMS_LM_Leave_History__c getLeaveRequestMethod( String getrecordId ) {
        if(getrecordId != Null){
            EMS_LM_Leave_History__c leaverecord = [Select id , EMS_LM_Leave_Start_Date__c , EMS_LM_Leave_End_Date__c , EMS_LM_Leave_Duration__c,
                                                   EMS_LM_Leave_Type_Name__c ,Leave_Type_Name__c, EMS_LM_Reason__c , EMS_LM_Status__c , Name ,EMS_LM_Day__c
                                                   from EMS_LM_Leave_History__c 
                                                   where Id =: getrecordId];
            return leaverecord;
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static EMS_LM_Leave_History__c updateleaveRequest(EMS_LM_Leave_History__c newRecord,string recordId) {
        System.debug('*****New record Values checking******* '+newRecord);
        System.debug('New record record id  '+recordId);
        newRecord.id=recordId;
        update newRecord;
        system.debug('after update 38 $$$$$$'+newRecord);
        return newRecord;
    }
}