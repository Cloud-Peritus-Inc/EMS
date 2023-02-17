/**
* @author SAI
* @date 10/01/2023
* @description  updateTheAppOwnerToAccOwner Portal Users cant create a contact, in
*               order to achieve this we are blanking out the account after applicate created.
*
*               Test code coverage provided by the following test class:
*               - ContactTriggerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class updateTheAppOwnerToAccOwner implements TriggerAction.BeforeInsert {

    public void beforeInsert(List<Contact> newList) {      
        System.debug(LoggingLevel.DEBUG, 'updateTheAppOwnerToAccOwner.afterInsert() : BEGIN');
        clearTheAccountValueForCustomers(newList);
        System.debug(LoggingLevel.DEBUG, 'updateTheAppOwnerToAccOwner.afterInsert() : END');       
    }
    
    /**
*   {Purpose} - Method to blank out the contact Account
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/    
 public static void clearTheAccountValueForCustomers(List<Contact> newList) {
     
        if (UserInfo.getUserType() == 'CSPLitePortal') {
            Id theOwnerId;
            for (Contact con : newList) {
                if(con.RecordTypeId == ContactConstant.APPLICANT_RECORDTYPEID){
                con.AccountId = null;
                }
            }
        }
    }
}