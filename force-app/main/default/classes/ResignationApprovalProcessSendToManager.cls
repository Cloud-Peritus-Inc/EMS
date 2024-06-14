/**
* @author Ramakrishna Papana 
* @date 17/03/2023
* @description  ResignationApprovalProcessSendToManager to Send  TimesheetRecord  to related Project Manager for Approval.
*
*               Test code coverage provided by the following test class:
*               - ResignationApprovalProcessSendToManagerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class ResignationApprovalProcessSendToManager implements TriggerAction.AfterInsert{
    
    
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
    
    public void afterInsert(List<Case> newList) {      
        System.debug(LoggingLevel.DEBUG, 'ResignationApprovalProcessSendToManager.afterInsert() : BEGIN');
        //reginationApprovalProcess(newList);
        System.debug(LoggingLevel.DEBUG, 'ResignationApprovalProcessSendToManager.afterInsert() : END');       
    }
    
        /**
    * @author Ramakrishna
    * @date 17/03/2023
    * @description In this method we send ApplyRegination Type Service record for approval for respective Manager 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void reginationApprovalProcess(List<Case> caseNewList){
        System.debug('METHJOD IS CALLED');
        Map<Id,Case> contactCaseMap = new Map<Id,Case>();
        for(Case caseRec:caseNewList){        
            if(caseRec.Type =='Apply Resignation' && caseRec.Status =='New'){
                contactCaseMap.put(caseRec.ContactId,caseRec);
            }
        }
        
        for(Contact contactRec:[SELECT Id,
                                EMS_TM_User__c, 
                                Resource_Manager__c,
                                Resource_Manager__r.EMS_TM_user__c 
                                FROM Contact
                                WHERE Id IN:contactCaseMap.keySet()
                                AND EMS_TM_User__c != Null
                                AND Resource_Manager__r.EMS_TM_User__c != Null
                               ]){
                                   System.debug('contactRec.Ems_tm_user__c'+contactRec.Ems_tm_user__c);
                                   Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                                   req1.setComments('Submitting request for approval.');
                                   req1.setObjectId(contactCaseMap.get(contactRec.Id).Id);
                                   System.debug('contactId'+contactCaseMap.get(contactRec.Id).Id+'>>>>>OwnerId'+contactCaseMap.get(contactRec.Id).OwnerId);
                                   req1.setSubmitterId(contactRec.Ems_tm_user__c);
                                   req1.setNextApproverIds(new Id[] {contactRec.Resource_Manager__r.EMS_TM_User__c});
                                   
                                   req1.setProcessDefinitionNameOrId('Resignation_Approval_Process');
                                   req1.setSkipEntryCriteria(false);
                                   try{
                                       Approval.ProcessResult result = Approval.process(req1);
                                   }catch(Exception e){
                                       System.debug('ResignationApprovalProcessSendToManager'+e.getMessage()+e.getLineNumber());
                                       LogException.logHandledException(e, 'ResignationApprovalProcessSendToManager', 'reginationApprovalProcess');
                                   }               
                                   
                               }
        
    }
    
}