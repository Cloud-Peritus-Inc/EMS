/**
* @author Shubham Maske
* @date 11/08/2023
* @description  Update Contacts Assigned User based on contact status field change
*
*               Test code coverage provided by the following test class: ContactUserUpdaterTest
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          		NAME                    DESCRIPTION
* 11/08/2023           Sahubham Maske           Initial Version
* ====================================================================================================
**/
public without sharing class ContactUserUpdater implements TriggerAction.AfterUpdate {
	
    /**
     * @author Shubham Maske
     * @date 11/08/2023
     * @description After Update 
     *
     * CHANGE HISTORY
     * ====================================================================================================
     * DATE          NAME                    DESCRIPTION
     * N/A           N/A                     N/A
     * ====================================================================================================
     **/
     public void afterUpdate(List<Contact> newList,List<Contact> oldList) {      
         System.debug(LoggingLevel.DEBUG, 'updateUsersAsync: BEGIN');
         
         Set<Id> contactIdsToUpdate = new Set<Id>();
         Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
         
         for(Contact oldContact : oldList){
             oldContactMap.put(oldContact.Id, oldContact);
         }

        for (Contact newContact : newList) {
            Contact oldContact = oldContactMap.get(newContact.Id);

            if (newContact.EMS_RM_ApplicantStatus_Update__c == 'Inactive' && newContact.EMS_RM_ApplicantStatus_Update__c != oldContact.EMS_RM_ApplicantStatus_Update__c) {
                contactIdsToUpdate.add(newContact.Id);
            }
        }
         System.debug(' ** contactIdsToUpdate ** ' + contactIdsToUpdate);

        if (!contactIdsToUpdate.isEmpty()) {
            updateUsersAsync(contactIdsToUpdate);
            UpdateRelatedProjectAssignment(contactIdsToUpdate);
        }
         
     }
    
    @future
    public static void updateUsersAsync(Set<Id> contactIds) {
        updateUsers(contactIds);
    }
    
    public static void updateUsers(Set<Id> contactIds) {
        System.debug(' ** IN updateUsers method ** ');
        List<User> usersToUpdate = new List<User>();

        for (Id contactId : contactIds) {
            Contact contact = [SELECT Id, EMS_TM_User__c FROM Contact WHERE Id = :contactId LIMIT 1];
            if (contact.EMS_TM_User__c != null) {
                usersToUpdate.add(new User(Id = contact.EMS_TM_User__c, IsActive = false));
            }
        }
        if (!usersToUpdate.isEmpty()) {
            try {
                update usersToUpdate;
            } catch (DmlException excp) {
                LogException.logHandledException(excp, 'ContactUserUpdater', 'updateUsers');
            }
        }
    }
    
    //Method to Update the Related Project Assignee records Status Value
    public static void UpdateRelatedProjectAssignment(Set<Id> contactIds){
        System.debug(' ** IN updateUsers method ** ');
        List<EMS_TM_Assignment__c> projectAssignesToUpdate = new List<EMS_TM_Assignment__c>();

        List<EMS_TM_Assignment__c> projectAssignee = [SELECT Id, Name,EMS_TM_ProjectName_Asgn__c,EMS_TM_ProjectName_Asgn__r.EMS_TM_EndDate__c,EMS_TM_ProjectName_Asgn__r.EMS_TM_StartDate__c ,EMS_TM_EndDate_Asgn__c, EMS_TM_Status_Asgn__c, EMS_TM_EmployeeName__c,
                                                	EMS_TM_EmployeeName__r.LastModifiedDate 
                                                    FROM EMS_TM_Assignment__c 
                                                    WHERE ( EMS_TM_EmployeeName__c IN:contactIds AND EMS_TM_Status_Asgn__c != 'Closed' AND Project_Allocation__c != NULL) ];
        
        for(EMS_TM_Assignment__c pa : projectAssignee){
            pa.EMS_TM_Status_Asgn__c = 'Closed';
            Date projEndDate = pa.EMS_TM_ProjectName_Asgn__r.EMS_TM_EndDate__c;
            Date projStartDate = pa.EMS_TM_ProjectName_Asgn__r.EMS_TM_StartDate__c;
            Date conModDate = Date.today();
            if( conModDate < projEndDate && conModDate > projStartDate ){
                pa.EMS_TM_EndDate_Asgn__c = pa.EMS_TM_EmployeeName__r.LastModifiedDate.date();
            }else{
                pa.EMS_TM_EndDate_Asgn__c = projEndDate;
            }
            projectAssignesToUpdate.add(pa);
        }
        
        if(projectAssignesToUpdate.size() > 0 && projectAssignesToUpdate != null){
            update projectAssignesToUpdate;
        }
        
    }
}