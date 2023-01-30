/**
    * @author Ramakrishna 
    * @date 24/01/2023
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
public class timesheetRecordApprovalProcess implements TriggerAction.AfterUpdate,TriggerAction.AfterInsert {
      /**
    * @author Ramakrishna
    * @date 24/01/2023
    * @description After Update 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterUpdate(List<EMS_TM_Timesheet_Record__c> newList,List<EMS_TM_Timesheet_Record__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterUpdate() : BEGIN');
        Map<id,EMS_TM_Timesheet_Record__c> timesheetOldMap = new Map<id,EMS_TM_Timesheet_Record__c>(oldList);
        submitAndProcessApprovalRequest(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterUpdate() : END');       
    }
    
   /**
    * @author Ramakrishna
    * @date 24/01/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterInsert(List<EMS_TM_Timesheet_Record__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterInsert() : BEGIN');
        submitAndProcessApprovalRequest(newList,Null);
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterInsert() : END');       
    }
    /**
    * @author Ramakrishna
    * @date 24/01/2023
    * @description In this method we send timsheet record for approval for respective Manager 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void submitAndProcessApprovalRequest(List<EMS_TM_Timesheet_Record__c> newList,Map<Id,EMS_TM_Timesheet_Record__c> oldMap) {
        Set<Id> projectIdsSet = new Set<Id>();
        Map<Id,EMS_TM_Timesheet_Record__c> projectRecMap = new Map<Id,EMS_TM_Timesheet_Record__c>();
        for(EMS_TM_Timesheet_Record__c timesheetRec: newList){
            if((oldMap != null && oldMap.get(timesheetRec.Id).Status__c != timesheetRec.Status__c && timesheetRec.Status__c != 'Saved' && timesheetRec.Status__c != 'Approved'  && timesheetRec.Status__c !='Rejected' && timesheetRec.Status__c != null ) || (oldmap ==null && timesheetRec.Status__c != 'Saved' && timesheetRec.Status__c != 'Approved'  && timesheetRec.Status__c !='Rejected' && timesheetRec.Status__c != null )){
                System.debug('If Passed');
                projectIdsSet.add(timesheetRec.EMS_TM_Project__c); 
                projectRecMap.put(timesheetRec.EMS_TM_Project__c,timesheetRec);                
            }           
        }
        Map<Id,EMS_TM_Timesheet_Record__c> timeSheetRecMap = new Map<Id,EMS_TM_Timesheet_Record__c>();
        System.debug('projectRecMap'+projectRecMap);
        
        for(EMS_TM_Project__c projectRec:[SELECT Id, 
                                                   Project_Manager__c 
                                                   FROM EMS_TM_Project__c 
                                                   WHERE Id IN:projectRecMap.keyset()]){
                                                       if(projectRec.Project_Manager__c !=null){
            timeSheetRecMap.put(projectRec.Project_Manager__c,projectRecMap.get(projectRec.Id));
                                                       }
        }
         System.debug('timeSheetRecMap'+timeSheetRecMap);
        for(contact contactRec:[SELECT Id,
                                         Ems_tm_user__c 
                                         FROM contact 
                                         WHERE Id IN:timeSheetRecMap.keySet()]){
            if(contactRec.Ems_tm_user__c != null){
                System.debug('contactRec.Ems_tm_user__c'+contactRec.Ems_tm_user__c);
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(timeSheetRecMap.get(contactRec.Id).Id);
                System.debug('contactId'+timeSheetRecMap.get(contactRec.Id).Id+'>>>>>OwnerId'+timeSheetRecMap.get(contactRec.Id).OwnerId);
                req1.setSubmitterId(timeSheetRecMap.get(contactRec.Id).OwnerId);
                req1.setNextApproverIds(new Id[] {contactRec.EMS_TM_User__c});

                req1.setProcessDefinitionNameOrId('Timesheet_Records_Approval');
                req1.setSkipEntryCriteria(false);
                try{
               Approval.ProcessResult result = Approval.process(req1);
                }catch(Exception e){
                    System.debug('timesheetRecordApprovalProcess'+e.getMessage()+e.getLineNumber());
                     LogException.logHandledException(e, 'timesheetRecordApprovalProcess', 'submitAndProcessApprovalRequest');
                }               
            }
            
        }
        
    }    
}