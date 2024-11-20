/**
* @author Eswar and Shireesha
* @date 10/01/2023
* @description  UpdateContactEmail Class to update the email field with official mail id 
*              
*
*               Test code coverage provided by the following test class:
*               - UpdateContactEmailTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class updateContactEmail implements TriggerAction.BeforeInsert,TriggerAction.BeforeUpdate{
	/**
    * @author Eswar and Shireesha
    * @date 10/01/2023
    * @description Before Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void beforeInsert(List<Contact> newList) {      
        System.debug(LoggingLevel.DEBUG, 'updateContactEmail.beforeInsert() : BEGIN');
        updateOfficialMail(newList);
        System.debug(LoggingLevel.DEBUG, 'updateContactEmail.beforeInsert() : END');       
    }
    
    /**
    * @author Eswar and Shireesha
    * @date 10/01/2023
    * @description Before Update 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void beforeUpdate(List<Contact> newList,List<Contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'updateContactEmail.beforeUpdate() : BEGIN');
        updateOfficialMail(newList);
        System.debug(LoggingLevel.DEBUG, 'updateContactEmail.beforeUpdate() : END');       
    }
    
    /**
    *   {Purpose} - Method for update official mail 
    *
    *   CHANGE HISTORY
    *   ====================================================================================================
    *   Date        Name                    Description
    *   N/A         N/A                     N/A
    *   ====================================================================================================
    **/
    
    private void updateOfficialMail(List<Contact> contactList){       
        for(contact contactRec: contactList){
            if(!String.isEmpty(contactRec.Official_Mail__c)){
            contactRec.EMS_RM_Resource_Email_id__c = contactRec.Official_Mail__c;  
            contactRec.Email = contactRec.Official_Mail__c;
            }
        }
    }
    
}