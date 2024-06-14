public class timeTestClass {
    /**
    * @author Ramakrishna 
    * @date 07/02/2023
    * @description  timesheetRecordApprovalProcess to Send  TimesheetRecord  to related Project Manager for Approval.
    *
    *               Test code coverage provided by the following test class:
    *               - timesheetRecordApprovalProcessTest
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public static void updateTimeRec(List<EMS_timesheet__c> newList,map<Id,EMS_timesheet__c> oldmap){
        //EMS_TM_Timesheet_Record__c
        Set<Id> timesheetIdSet = new Set<Id>();
        
        for(EMS_timesheet__c t : newList){
            if((oldMap != null && oldMap.get(t.Id).EMS_TM_Status__c != t.EMS_TM_Status__c && t.EMS_TM_Status__c == 'Submitted' ) || 
               (oldmap ==null && t.EMS_TM_Status__c == 'Submitted')){
                     timesheetIdSet.add(t.Id);
                }
        }
        List<EMS_TM_Timesheet_Record__c> updatedTimesheetRecList = new List<EMS_TM_Timesheet_Record__c>();
        for(EMS_TM_Timesheet_Record__c et :[SELECT Id,
                                            		Status__c,
                                            		EMS_TM_Project__r.Approval_Needed__c 
                                            		FROM EMS_TM_Timesheet_Record__c 
                                            		WHERE EMS_Timesheet__c IN:timesheetIdSet]){
            if(et.Status__c !='Approved'){
                et.Status__c ='Submitted';
                updatedTimesheetRecList.add(et);
            }
        }
        
        try{
            update updatedTimesheetRecList;
        }catch(Exception e){
            System.debug('status'+e.getMessage());
        }
        
    }

}