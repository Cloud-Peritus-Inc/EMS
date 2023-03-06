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
public class CP_SendOnboardingFormMail implements TriggerAction.AfterInsert{
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
    
    private void sendOnboardingFormMail(List<Contact> contactList){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        //List<Task> tskList = new List<Task>();
        Group itGroup = [select Id,Name from Group where  Type = 'Queue' AND NAME = 'TA Team'];
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        
        for(Contact contactRec : contactList){
            if(contactRec.RecordTypeId == contRecordTypeId){
                    EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                    applicantRec.EMS_EM_Personal_Email__c = contactRec.Personal_Email__c;
                    applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                    applicantRec.ContactId1__c = contactRec.Id;
                    applicantRec.Status__c = 'Triggered';
                    applicantsList.add(applicantRec); 
                    
                    /*Date reminderDate = contactRec.EMS_EM_JD__c.addDays(2);
                    
                    Task t = new Task();
                    t.OwnerId = itGroup.Id;
                    t.Subject = 'Send joining date confirmation to the respective Resource Manager';
                    t.Status = 'Open';
                    t.Priority = 'Normal';
                    t.IsReminderSet = true;
                    t.WhoId = contactRec.Id;
                    t.ActivityDate = contactRec.EMS_EM_JD__c.addDays(1);
                    t.ReminderDateTime = DateTime.newInstance(reminderDate.year(), reminderDate.month(), reminderDate.day(), 20, 00, 00);
                    tskList.add(t);*/
            }   
        }
        if(applicantsList.size() > 0){
            insert applicantsList;
        }
        /*if(tskList!=null && tskList.size()>0){
            insert tskList;
        }*/
        List<ems_EM_Additional_Detail__c> additionalDetailsList = new List<ems_EM_Additional_Detail__c>();
        for(EMS_EM_Onboarding_Request__c onboardingRecords : applicantsList){
            ems_EM_Additional_Detail__c applicantRec = new ems_EM_Additional_Detail__c();
            applicantRec.Onboarding_Request__c = onboardingRecords.id;
            applicantRec.ContactId__c = onboardingRecords.ContactId1__c;
            additionalDetailsList.add(applicantRec);
        }
        insert additionalDetailsList;
    }
    
  /*  private void sendOnboardingFormMailUpdate(List<Contact> newlist, Map<Id,Contact> oldMap){
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id;
        List<Contact> updatedContactList = new List<Contact>();
        for (Contact c : newlist){
            if(c.RecordTypeId == contRecordTypeId){
                c.EMS_EM_JD__c = oldMap.get(c.Id).EMS_EM_JD__c;
                updatedContactList.add(c);
            }
        }
        update updatedContactList;
    }*/
    
    public static String sendOnboardingEmail(String email,string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Onboarding Form Email' LIMIT 1];
        List<string> emailList = new List<string>();
        emailList.add(email);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        if (results[0].success) {
            return 'success';
        } else {
            return 'failure';
        }
    }
    
  /*  public static void sendEmailToHR(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify To Hr After Onboarding Form Sent' LIMIT 1];        
        String hrTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team'].Email__c;
        List<String> hrEmailList = new List<String>();
        hrEmailList.add(hrTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = hrEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public static void sendEmailToTA(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify TA After Onboarding Form Sent' LIMIT 1];
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'TA_Team'].Email__c;
        List<String> taEmailList = new List<String>();
        taEmailList.add(taTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = taEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }*/
    
    public static void sendEmailToAdminTeam(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted Admin' LIMIT 1];
        
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        List<String> adminEmailList = new List<String>();
        adminEmailList.add(taTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = adminEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}