/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  createPortalUserForResource Class to create the portal user
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
public without sharing class createPortalUserForResource implements TriggerAction.AfterUpdate{
    /**
* @author Subba Kalavala
* @date 2/22/2023
* @description afterUpdate
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<Contact> newList, List<Contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'createPortalUserForResource.afterUpdate() : BEGIN');
        createPortalUser(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'createPortalUserForResource.afterUpdate() : END');       
    }
    
     /**
*   {Purpose} - Method to create the users
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void createPortalUser(List<Contact> newlist, Map<Id,Contact> oldMap) {
        List<user> usrList = new List<user>();
        List<Contact> filteredList = new List<Contact>();
        Date dt = system.today();
        for(Contact con : newList){
            contact conold = oldMap.get(con.Id);
            system.debug('===con.RecordTypeId==='+con.RecordTypeId);
            system.debug('===con.RecordTypeId==='+con.Email);
            system.debug('===con.RecordTypeId==='+con.EMS_EM_JD__c);
             system.debug('===con.RecordTypeId==='+con.EMS_TM_User__c);
            if(con.RecordTypeId == ContactConstant.RESOURCE_RECORDTYPEID 
               && con.EMS_EM_JD__c != null && con.Email != null 
               && con.EMS_TM_User__c == null && con.EMS_EM_JD__c == dt && (con.RecordTypeId != conold.RecordTypeId || con.EMS_EM_JD__c != conold.EMS_EM_JD__c ) ){
              filteredList.add(con);  
            }
        }
        system.debug('====filteredList====='+filteredList);
        if(!filteredList.isEmpty()){
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Employee - Resource(Community)' LIMIT 1];
            
            for(Contact con : filteredList){
                       
              User newUser = new User(
                    alias = (con.LastName).length() > 8 ? (con.LastName).substring(0,8) : con.LastName,
                    email = con.email,
                    emailencodingkey = 'UTF-8',
                    firstname = con.firstName,
                    lastname = con.lastname,
                    languagelocalekey = 'en_US',
                    localesidkey = 'en_US',
                    contactId = con.Id,
                    timezonesidkey = 'America/Los_Angeles',
                    username = con.email+System.now().millisecond(),
                    CommunityNickname = con.firstName+con.LastName,
                    ProfileId = communityProfile.Id,
                    IsActive = true);
                    usrList.add(newUser);        
            }
        }
         system.debug('====usrList====='+usrList);
        try{
        if(!usrList.isEmpty()){
         processTheDML(usrList);   
        }
        }catch(exception ex){
           system.debug('==ex=='+ex); 
        }
             
    }
    
    
    public static void processTheDML(List<User> usrList){
       Insert usrList;
        system.debug('==w==usrList====='+usrList);
        List<Contact> contactUpdate = new List<Contact>();
        for(User urec : usrList){
            contactUpdate.add(new contact(id=urec.contactId,EMS_TM_User__c=urec.id));
        }
         system.debug('==w==contactUpdate====='+contactUpdate);
        update contactUpdate;
    }
}