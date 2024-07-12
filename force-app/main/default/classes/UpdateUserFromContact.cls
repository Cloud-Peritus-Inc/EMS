/**
* @author Eswar Tangudu
* @date 3/02/2023
* @description  UpdateUserFromContact updates the data in user object if anything is updated in contact
*
*               Test code coverage provided by the following test class:
*               - UpdateUserFromContactTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class UpdateUserFromContact implements TriggerAction.AfterUpdate{
	    
    	/**
        * @author Eswar Tangudu
        * @date 3/02/2023
        * @description After Update 
        *
        * CHANGE HISTORY
        * ====================================================================================================
        * DATE          NAME                    DESCRIPTION
        * N/A           N/A                     N/A
        * ====================================================================================================
        **/
    //smaske : declaring public variables for future method
    public Static List<Contact> newListCon = new List<Contact>();
    public Static List<Contact> oldListCon = new List<Contact>();
    
    public void afterUpdate(List<Contact> newList, List<contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'UpdateUserFromContact.afterUpdate() : BEGIN');
        //smaske : commented below method calling to fix MIX DML error 
        //updateUserDataFromContactData(newList,new Map<Id,Contact>(oldList));
        
        
        newListCon.addAll(newList);
        oldListCon.addAll(oldList);
        System.debug('newListCon ' +  newListCon);
        System.debug('oldListCon ' +  oldListCon);
        updateUserDataFromContactData2();
        System.debug(LoggingLevel.DEBUG, 'UpdateUserFromContact.afterUpdate() : END');       
    }
    
/**
*   {Purpose} - Method to update the data in user object if anything is updated in contact
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    /*
    public void updateUserDataFromContactData(List<Contact> newlist,Map<Id,Contact> oldMap){
        
        Set<Id> contactIds = new Set<Id>();
        for (Contact c : newlist) {
            contactIds.add(c.Id);
        }
        
        Map<Id, User> usersToUpdate = new Map<Id, User>();
        for (User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds]) {
            usersToUpdate.put(u.ContactId, u);
        }
        
        //
        List<User> usersToUpdateList = new List<User>();
        for (Contact c : newlist) {
            if ((c.EMS_Phone_Number__c != null && oldMap.containsKey(c.Id) && c.EMS_Phone_Number__c != oldMap.get(c.Id).EMS_Phone_Number__c) || 
                (c.LastName != null && oldMap.containsKey(c.Id) && c.LastName != oldMap.get(c.Id).LastName) ||
                (c.FirstName != null && oldMap.containsKey(c.Id) && c.FirstName != oldMap.get(c.Id).FirstName) ||
                (c.EMS_EM_CAddress_Line_1__c != null && oldMap.containsKey(c.Id) && c.EMS_EM_CAddress_Line_1__c != oldMap.get(c.Id).EMS_EM_CAddress_Line_1__c) ||
                (c.EMS_EM_CA_City__c != null && oldMap.containsKey(c.Id) && c.EMS_EM_CA_City__c != oldMap.get(c.Id).EMS_EM_CA_City__c) ||
                (c.EMS_EM_CA_State__c != null && oldMap.containsKey(c.Id) && c.EMS_EM_CA_State__c != oldMap.get(c.Id).EMS_EM_CA_State__c)) {
                    
                User u = usersToUpdate.get(c.Id);
        		if (u != null) {
                    u.FirstName = c.FirstName;
                    u.LastName = c.LastName;
                    u.Phone = c.EMS_Phone_Number__c;
                    u.Street = c.EMS_EM_CAddress_Line_1__c;
                    u.City = c.EMS_EM_CA_City__c;
                    u.State = c.EMS_EM_CA_State__c;
                    //
                    usersToUpdateList.add(u);
                }
            }
        }
        //update usersToUpdate.values();
        if (!usersToUpdateList.isEmpty()) {
            update usersToUpdateList;
        }
    }
    */
    
    @future
    public static void updateUserDataFromContactData2(){
        
        Set<Id> contactIds = new Set<Id>();
        for (Contact c : newListCon) {
            contactIds.add(c.Id);
        }
        
        Map<Id,Contact> oldConMap = new Map<Id,Contact>(oldListCon); 
        
        Map<Id, User> usersToUpdate = new Map<Id, User>();
        for (User u : [SELECT Id, ContactId FROM User WHERE ContactId IN :contactIds]) {
            usersToUpdate.put(u.ContactId, u);
        } 
        
        List<User> usersToUpdateList = new List<User>();
        for (Contact c : newListCon) {
            if ((c.EMS_Phone_Number__c != null && oldConMap.containsKey(c.Id) && c.EMS_Phone_Number__c != oldConMap.get(c.Id).EMS_Phone_Number__c) || 
                (c.LastName != null && oldConMap.containsKey(c.Id) && c.LastName != oldConMap.get(c.Id).LastName) ||
                (c.FirstName != null && oldConMap.containsKey(c.Id) && c.FirstName != oldConMap.get(c.Id).FirstName) ||
                (c.EMS_EM_CAddress_Line_1__c != null && oldConMap.containsKey(c.Id) && c.EMS_EM_CAddress_Line_1__c != oldConMap.get(c.Id).EMS_EM_CAddress_Line_1__c) ||
                (c.EMS_EM_CA_City__c != null && oldConMap.containsKey(c.Id) && c.EMS_EM_CA_City__c != oldConMap.get(c.Id).EMS_EM_CA_City__c) ||
                (c.EMS_EM_CA_State__c != null && oldConMap.containsKey(c.Id) && c.EMS_EM_CA_State__c != oldConMap.get(c.Id).EMS_EM_CA_State__c)) {
                    
                    User u = usersToUpdate.get(c.Id);
                    if (u != null) {
                        u.FirstName = c.FirstName;
                        u.LastName = c.LastName;
                        u.Phone = c.EMS_Phone_Number__c;
                        u.Street = c.EMS_EM_CAddress_Line_1__c;
                        u.City = c.EMS_EM_CA_City__c;
                        u.State = c.EMS_EM_CA_State__c;
                        //
                        usersToUpdateList.add(u);
                    }
                }
        }
        
        if (!usersToUpdateList.isEmpty()) {
            update usersToUpdateList;
        }
    }
    
    

}