/**
* @author Mukesh Rawat
* @date 06/26/2023
* @description  restrictLeaveForNoticPeriod Class to restrict the leaves for notice period
*
*               Test code coverage provided by the following test class:
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class restrictLeaveForNoticPeriod implements TriggerAction.BeforeInsert{
    /**
* @author Mukesh Rawat
* @date 06/26/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictLeaveForNoticPeriod.beforeInsert() : BEGIN');
        restrictNoticPeriodLeave(newList, null);
        System.debug(LoggingLevel.DEBUG, 'restrictLeaveForNoticPeriod.beforeInsert() : END');       
    }
 
    /**
*   {Purpose} - Method to restrict the same date leaves 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
   public void restrictNoticPeriodLeave(List<EMS_LM_Leave_History__c> newlist, Map<Id, EMS_LM_Leave_History__c> oldConMap) {
       system.debug('&&&the hte new valuea are && 43:--'+newlist);
       system.debug('&&&the hte  oldConMap are && 44:--'+oldConMap);
    Set<String> resourcId = new Set<String>();
       system.debug('####the map valuea are ***  46***;--'+resourcId);
    Map<Id, Contact> contactMap = new Map<Id, Contact>();
       system.debug('####the map valuea are ***  48***;--'+contactMap);
    
    for (EMS_LM_Leave_History__c his : newlist) {
        resourcId.add(his.EMS_LM_Contact__c);
    }
    
   for (Contact con : [SELECT Id, EMS_RM_ApplicantStatus_Update__c, EMS_RM_Last_Working_day__c,
                              (SELECT Id, Leave_Type_Name__c, EMS_LM_Leave_Duration__c, EMS_LM_Leave_End_Date__c, EMS_LM_Leave_Start_Date__c,
                               EMS_LM_Status__c,EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c
                               FROM Leaves_History__r
                               WHERE EMS_LM_Leave_End_Date__c = THIS_YEAR
                                   AND EMS_LM_Status__c != 'Cancelled'
                                   AND EMS_LM_Status__c != 'Rejected'
                                   AND EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c != :LeaveRequestConstant.WORK_FROM_HOME)
                       FROM Contact
                       WHERE Id IN :resourcId
                           AND EMS_RM_ApplicantStatus_Update__c = 'Notice Period']) {
        contactMap.put(con.Id, con);
    }
    
    List<EMS_LM_Leave__c> leaveTypeLOP = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Loss of Pay'];
    Id lossofpayTypeId = leaveTypeLOP.size() > 0 ? leaveTypeLOP[0].Id : null;
    system.debug('###thr lossofpayTypeId:69***'+lossofpayTypeId);
    for (EMS_LM_Leave_History__c his : newlist) {
        //system.debug('his.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c-->' + his.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c);
        system.debug('###the leave type is &&&'+his.EMS_LM_Leave_Type__c);
        if (contactMap.containsKey(his.EMS_LM_Contact__c) &&  his.EMS_LM_Leave_Type__c != lossofpayTypeId) {
           //if (contactMap.containsKey(his.EMS_LM_Contact__c) && his.EMS_LM_Leave_Type__c != lossofpayTypeId && his.EMS_LM_Leave_Type__r != null && his.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c != null && his.EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c != lossofpayTypeId) { 
        Contact contact = contactMap.get(his.EMS_LM_Contact__c);
            if (contact.EMS_RM_ApplicantStatus_Update__c == 'Notice Period') {
                his.addError('During the notice period, only Loss of Pay leave is allowed. Please check the leave type and try again.');
            }
        }else{
            //if (contactMap.get(his.EMS_LM_Contact__c).EMS_RM_Last_Working_day__c <= his.EMS_LM_Leave_End_Date__c) {
           if (contactMap.containsKey(his.EMS_LM_Contact__c) && contactMap.get(his.EMS_LM_Contact__c).EMS_RM_Last_Working_day__c <= his.EMS_LM_Leave_End_Date__c) {
             his.addError('You can not apply for a date beyond the last date of the Notice Period.');
            }
        }
    }
   }
}