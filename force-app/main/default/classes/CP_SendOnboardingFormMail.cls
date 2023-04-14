/**
* @author Eswar
* @date 02/02/2023
* @description  This class is for if DOJ less than 10days then on which date DOJ is updated on that day itself create onboarding record as well as send 
				email with onboarding form.
*
*               Test code coverage provided by the following test class:
*               - CP_SendOnboardingFormMailTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendOnboardingFormMail implements TriggerAction.AfterInsert, TriggerAction.AfterUpdate{
    /**
    * @author Eswar
    * @date 02/02/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
	public void afterInsert(List<Contact> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterInsert() : BEGIN');
         sendOnboardingFormMail(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterInsert() : END');       
     }
    
/**
* @author Eswar Tangudu
* @date 3/28/2023
* @description After Update
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<Contact> newList, List<Contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterUpdate() : BEGIN');
        sendOnboardingFormMailAfterUpdate(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterUpdate() : END');       
    }
    
    /**
    * @author Eswar
    * @date 02/02/2023
    * @description After Update
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public static void sendOnboardingFormMail(List<Contact> contactList){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        Group itGroup = [select Id,Name from Group where  Type = 'Queue' AND NAME = 'TA Team'];
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        List<Messaging.SingleEmailMessage> hrMailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> adminMailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> itMailList = new List<Messaging.SingleEmailMessage>();
        
        for(Contact contactRec : contactList){
            
            Date today = Date.today();
            Date sobjectDate = contactRec.EMS_EM_JD__c;
            
            if(contactRec.RecordTypeId == contRecordTypeId && contactRec.EMS_EM_JD__c != NULL && today.daysBetween(sobjectDate) < 10 
               && contactRec.EMS_EM_JD__c >= system.today()){
                  
                EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Personal_Email__c;
                applicantRec.ContactId1__c = contactRec.Id;
                applicantRec.EMS_EM_First_Name__c = contactRec.FirstName;
                applicantRec.EMS_EM_Last_Name__c = contactRec.LastName;
                applicantRec.Phone_Number__c = contactRec.EMS_Phone_Number__c;
                applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                applicantRec.Status__c = 'Triggered';
                applicantsList.add(applicantRec);
                
                Messaging.SingleEmailMessage message = sendEmailToHR(contactRec.Id);
                hrMailList.add(message);
                Messaging.SingleEmailMessage message1 = sendEmailToAdminTeam(contactRec.Id);
                adminMailList.add(message1);
                Messaging.SingleEmailMessage message2 = sendEmailToITTeamForNewJoin(contactRec.Id);
                itMailList.add(message2);
                
            }   
        }
        
        if(applicantsList.size() > 0){
            insert applicantsList;
        }
        /*try{
            if(applicantsList.size()>0){
            	update applicantsList;
        	}
        }catch(exception ex){
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                contactList[0].adderror(ex.getMessage().substring(89, 400));
            }else{
                contactList[0].adderror(ex.getMessage());
            }  
        }*/
        
        /*List<ems_EM_Additional_Detail__c> additionalDetailsList = new List<ems_EM_Additional_Detail__c>();
        for(EMS_EM_Onboarding_Request__c onboardingRecords : applicantsList){
            ems_EM_Additional_Detail__c applicantRec = new ems_EM_Additional_Detail__c();
            applicantRec.Onboarding_Request__c = onboardingRecords.id;
            applicantRec.ContactId__c = onboardingRecords.ContactId1__c;
            additionalDetailsList.add(applicantRec);
        }
        insert additionalDetailsList;*/
        
        if(!Test.isRunningTest()){
            Messaging.sendEmail(hrMailList);
            Messaging.sendEmail(adminMailList);
            Messaging.sendEmail(itMailList);
        }
    }
    
    private void sendOnboardingFormMailAfterUpdate(List<Contact> contactList, Map<Id,Contact> oldMap){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        Group itGroup = [select Id,Name from Group where  Type = 'Queue' AND NAME = 'TA Team'];
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        List<Messaging.SingleEmailMessage> hrMailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> adminMailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> itMailList = new List<Messaging.SingleEmailMessage>();
        
        for(Contact contactRec : contactList){
            
            Date today = Date.today();
            Date sobjectDate = contactRec.EMS_EM_JD__c;
            
            if(contactRec.RecordTypeId == contRecordTypeId && contactRec.EMS_EM_JD__c != NULL && 
               (oldMap.get(contactRec.Id).EMS_EM_JD__c == NULL && contactRec.EMS_EM_JD__c != NULL)){
                   
                EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Personal_Email__c;
                applicantRec.ContactId1__c = contactRec.Id;
                applicantRec.EMS_EM_First_Name__c = contactRec.FirstName;
                applicantRec.EMS_EM_Last_Name__c = contactRec.LastName;
                applicantRec.Phone_Number__c = contactRec.EMS_Phone_Number__c;
                applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                applicantRec.Status__c = 'Triggered';
                applicantsList.add(applicantRec);
                   
            }
            
            if(applicantsList.size() > 0){
                insert applicantsList;
            }
            
            /*try{
                 if(applicantsList.size() > 0){
                	insert applicantsList;
            	 }
            }
            catch(exception ex){
                contactList[0].adderror(ex.getMessage()); 
            } */
            
            List<ems_EM_Additional_Detail__c> additionalDetailsList = new List<ems_EM_Additional_Detail__c>();
            for(EMS_EM_Onboarding_Request__c onboardingRecords : applicantsList){
                ems_EM_Additional_Detail__c applicantRec = new ems_EM_Additional_Detail__c();
                applicantRec.Onboarding_Request__c = onboardingRecords.id;
                applicantRec.ContactId__c = onboardingRecords.ContactId1__c;
                additionalDetailsList.add(applicantRec);
            }
            insert additionalDetailsList;
            
            if(contactRec.RecordTypeId == contRecordTypeId && contactRec.EMS_EM_JD__c != NULL && today.daysBetween(sobjectDate) < 10 && 
               contactRec.EMS_EM_JD__c >= system.today() && (oldMap.get(contactRec.Id).EMS_EM_JD__c == NULL && contactRec.EMS_EM_JD__c != NULL)){
                  
                Messaging.SingleEmailMessage message = sendEmailToHR(contactRec.Id);
                hrMailList.add(message);
                Messaging.SingleEmailMessage message1 = sendEmailToAdminTeam(contactRec.Id);
                adminMailList.add(message1);
                Messaging.SingleEmailMessage message2 = sendEmailToITTeamForNewJoin(contactRec.Id);
                itMailList.add(message2);
                  
            }   
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(hrMailList);
            Messaging.sendEmail(adminMailList);
            Messaging.sendEmail(itMailList);
        }
    }
    
    public static Messaging.SingleEmailMessage sendEmailToHR(string recordId){
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify To Hr After Onboarding Form Sent' LIMIT 1];        
        String hrTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> hrEmailList = new List<String>();
        hrEmailList.add(hrTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = hrEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setOrgWideEmailAddressId(fromEmail);
        message.setSaveAsActivity(false);
        return message;
    }

    public static Messaging.SingleEmailMessage sendEmailToAdminTeam(string recordId){
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted Admin' LIMIT 1];
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> adminEmailList = new List<String>();
        adminEmailList.add(taTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = adminEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setOrgWideEmailAddressId(fromEmail);
        message.setSaveAsActivity(false);
        return message;
    }
    
    public static Messaging.SingleEmailMessage sendEmailToITTeamForNewJoin(string recordId){
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Email To IT Team For Assets' LIMIT 1];
        String itEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'IT_Team' LIMIT 1].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> itEmailList = new List<String>();
        itEmailList.add(itEmail);
        
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.toAddresses = itEmailList;
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(recordId);
            mail.setOrgWideEmailAddressId(fromEmail);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);   
            return mail;
    }
}