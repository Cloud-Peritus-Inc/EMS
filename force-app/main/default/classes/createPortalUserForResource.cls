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
         List<user> usrUpdateList = new List<user>();
        List<Contact> filteredList = new List<Contact>();
        Date dt = system.today();
        Set<Id> conIds = new Set<Id>();
        Map<Id,User> userContactMap = new Map<Id,User>();
        for(Contact con : newList){
            contact conold = oldMap.get(con.Id);
            system.debug('===con.RecordTypeId==='+con.RecordTypeId);
            system.debug('===con.RecordTypeId==='+con.Email);
            system.debug('===con.RecordTypeId==='+con.EMS_EM_JD__c);
             system.debug('===con.RecordTypeId==='+con.EMS_TM_User__c);
            if(con.RecordTypeId == ContactConstant.RESOURCE_RECORDTYPEID 
               && con.EMS_EM_JD__c != null && con.Email != null 
               && con.EMS_TM_User__c == null && con.EMS_EM_JD__c == dt && (con.Email != conold.Email  || con.RecordTypeId != conold.RecordTypeId || con.EMS_EM_JD__c != conold.EMS_EM_JD__c ) ){
              filteredList.add(con);
                   conIds.add(con.Id);
            }
        }
        system.debug('====filteredList====='+filteredList);
        if(!filteredList.isEmpty()){
            /*if(!System.isBatch() && !System.isFuture()){
            BatchToCreatePostOnboardingTasks batchExecute = new BatchToCreatePostOnboardingTasks(); 
            Database.executeBatch(batchExecute,5);
            }*/
            for(User urec : [SELECT Id,ContactId,IsActive FROM User WHERE ContactId=:conIds]){
               userContactMap.put(urec.contactId,urec); 
            }
            system.debug('====userContactMap====='+userContactMap);
            Profile communityProfile = [SELECT Id FROM Profile WHERE Name = 'Employee - Resource(Community)' LIMIT 1];
            List<Messaging.SingleEmailMessage> dojMailsList = new List<Messaging.SingleEmailMessage>();

            for(Contact con : filteredList){
                if(!userContactMap.containsKey(con.id)){         
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
                    CommunityNickname = con.firstName+' '+con.LastName,
                    CompanyName = 'Cloud Peritus Inc',
                    ProfileId = communityProfile.Id,
                    IsActive = true);
                    usrList.add(newUser); 
                }else{
                    User urec = userContactMap.get(con.id);
                    if(!urec.IsActive){
                       usrUpdateList.add(new User(id=urec.id,isActive=true)); 
                    }
                }
                Messaging.SingleEmailMessage message = sendEmailOnDOJ(con.Email, con.Id);
                dojMailsList.add(message);
                Messaging.sendEmail(dojMailsList);
            }
            
        }
         system.debug('====usrList====='+usrList);
        try{
            if(!usrList.isEmpty() || !usrUpdateList.isEmpty() || !userContactMap.isEmpty()){
        processTheDML(JSON.serialize(usrList),JSON.serialize(usrUpdateList),JSON.serialize(userContactMap));
            }
        	BatchToCreatePostOnboardingTasks batchExecute = new BatchToCreatePostOnboardingTasks(); 
            Database.executeBatch(batchExecute,5);
        }catch(exception ex){
           system.debug('==ex=='+ex);
             LogException.logHandledException(ex, 'createPortalUserForResource', 'createPortalUser');  
        }
      
    }
    
    public static Messaging.SingleEmailMessage sendEmailOnDOJ(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Welcome Email' LIMIT 1];
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
      
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist 2 => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        return message;
    }
    
    @future
    public static void processTheDML(string usernew,string userupdate,String userConStr){
         List<User> usrList = (List<User>) JSON.deserialize(usernew, List<User>.class);
         List<User> usrUpdateList = (List<User>) JSON.deserialize(userupdate, List<User>.class);
         Map<Id,user> userConMap = (Map<Id,user> ) JSON.deserialize(userConStr, Map<Id,user>.class);
         
       Insert usrList;
       update usrUpdateList;
       
        List<Contact> contactUpdate = new List<Contact>();
        for(User urec : usrList){
            contactUpdate.add(new contact(id=urec.contactId,EMS_TM_User__c=urec.id));
        }
        for(Id conid : userConMap.keySet()){
              contactUpdate.add(new contact(id=conid,EMS_TM_User__c=userConMap.get(conid).id));
        }
        
         system.debug('==w==contactUpdate====='+contactUpdate);
        if(!contactUpdate.isEmpty()){
             createPortalQueueable q = new createPortalQueueable(JSON.serialize(contactUpdate));
            system.debug('job -->');
        	 System.enqueueJob(q);

                
            }
            
        }
            
        
    
}