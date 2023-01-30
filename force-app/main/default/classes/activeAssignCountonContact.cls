/**
    * @author RamaKrishna P
    * @date 20/01/2023
    * @description  enableAndDisableBillableOnContact to check the Active on assignments for Employees at the time of craete or update or 
    *               delete any record then update Count on the Contact.
    *
    *               Test code coverage provided by the following test class:
    *               - activeAssignCountonContactTestclass
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public class activeAssignCountonContact implements TriggerAction.AfterDelete{
 /**
    * @author Ramakrishna Papana
    * @date 20/01/2023
    * @description After Delete 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterDelete(List<EMS_TM_Assignment__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'enableAndDisableBillableOnContact.afterUpdate() : BEGIN');
        activeAssignmentCountOnContact(newList);
        System.debug(LoggingLevel.DEBUG, 'enableAndDisableBillableOnContact.afterUpdate() : END');       
    }    
    /**
    *   {Purpose} - Method to check the to check the Active on assignments for Employees at the time of craete or update or 
    *               delete any record then update Count on the Contact.
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    private void activeAssignmentCountOnContact(List<EMS_TM_Assignment__c> newAssignmentList){        
        set<Id> contactIdSet = new set<Id>();
        for(EMS_TM_Assignment__c assignmentRec : newAssignmentList){
            System.debug('assignmentRec.EMS_TM_EmployeeName__c'+assignmentRec.EMS_TM_EmployeeName__c);
            contactIdSet.add(assignmentRec.EMS_TM_EmployeeName__c);
        }
        Map<Id,List<EMS_TM_Assignment__c>> contactMap = new Map<Id,List<EMS_TM_Assignment__c>>();
        for(EMS_TM_Assignment__c assignLists :[SELECT Id, 
                                                       EMS_TM_Status_Asgn__c,
                                                       EMS_TM_EmployeeName__c
                                                       FROM EMS_TM_Assignment__c 
                                                       WHERE EMS_TM_EmployeeName__c IN : contactIdSet 
                                                       AND EMS_TM_Status_Asgn__c = 'Active']){
                                                           if (contactMap.containsKey(assignLists.EMS_TM_EmployeeName__c)) {
                                                               contactMap.get(assignLists.EMS_TM_EmployeeName__c).add(assignLists);
                                                           }else {
                                                               contactMap.put(assignLists.EMS_TM_EmployeeName__c,new List<EMS_TM_Assignment__c>{assignLists});
                                                           }               
                                                       }  
        List<Contact> updatedContactList = new List<Contact>();
        for(Contact contactRec :[SELECT Id,
                                        Current_Active_Assignments__c 
                                        FROM Contact 
                                        WHERE Id IN : contactIdSet]){
                                            List<EMS_TM_Assignment__c> assignmentList = contactMap.get(contactRec.Id); 
                                            contactRec.Current_Active_Assignments__c =assignmentList.size();
                                            updatedContactList.add(contactRec);
                                        }
                                        try{
                                            if(!updatedContactList.isEmpty()){
                                                update updatedContactList;
                                            }
                                        }catch(Exception e){
                                            LogException.logHandledException(e, 'enableAndDisableBillableOnContact', 'enableAndDisableBillable');
                                        }     
    }   
}