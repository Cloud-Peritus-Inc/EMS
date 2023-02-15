/**
* @author Eswar
* @date 25/01/2023
* @description  This batch will run daily, if any applicant DOJ is equal to 10days from today then will create onboarding record as well as send email with 
				onboarding form. 
*
*               Test code coverage provided by the following test class:
*               - CP_ConvertContactToOnboardingTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_ConvertContactToOnboarding implements Database.Batchable<sObject>, schedulable{
    
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new CP_ConvertContactToOnboarding());
    }
    	
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT id, lastName, EMS_EM_JD__c, Email, Personal_Email__c, EMS_RM_LastName__c,Name, Is_Email_Sent__c from Contact WHERE EMS_EM_JD__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-10) == System.today()){
                EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Personal_Email__c;
                applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                applicantsList.add(applicantRec);
                String status = sendOnboardingEmail(contactRec.Personal_Email__c,contactRec.Id);
                if(status == 'success'){
                    sendEmailToHR(contactRec.Id);
                    sendEmailToTA(contactRec.Id);
                }  
            }
        }
        insert applicantsList;
    }
    
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
        message.setSaveAsActivity(false);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        if (results[0].success) {
            return 'success';
        } else {
            return 'failure';
        }
    }
    
    public static void sendEmailToHR(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify To Hr After Onboarding Form Sent' LIMIT 1];
        String hrTeamEmail = [SELECT id, email FROM Contact WHERE name = 'HR Team'].email;
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
        String taTeamEmail = [SELECT id, email FROM Contact WHERE name = 'TA Team'].email;
        List<String> taEmailList = new List<String>();
        taEmailList.add(taTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = taEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}