/**
* @author Eswar
* @date 15/02/2023
* @description  This batch will run daily, if any employee completes one month then happy monthiversary mail should be trigger. 
*
*               Test code coverage provided by the following test class:
*               - CP_MonthiversaryEmailTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_MonthiversaryEmail implements Database.Batchable<sObject>, schedulable{
    
	public void execute(System.SchedulableContext sc){
        Database.executeBatch(new CP_MonthiversaryEmail());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT id, EMS_EM_JD__c, Name, Personal_Email__c, Is_Email_Sent_Post_Onborading_Mail__c, Post_Onboarding_Confirm__c, Official_Mail__c from Contact WHERE EMS_EM_JD__c != NULL AND (Official_Mail__c != NULL OR Personal_Email__c != NULL) AND RecordType.Name = \'Resource\'' 
        );
    }    
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        for(Contact contactRec : contactList){
            Integer monthNumber = contactRec.EMS_EM_JD__c.month();
            system.debug('Joining month => '+monthNumber);
            Integer days = Date.today().daysBetween(contactRec.EMS_EM_JD__c);
            system.debug('Days => '+days);
            system.debug('Joining date => '+contactRec.EMS_EM_JD__c);
            system.debug('Name => '+contactRec.Name);
            if(monthNumber == 2 && days == -28){
                sendMonthiversaryEmail(contactRec.Official_Mail__c, contactRec.Id);
            }else if((monthNumber == 1 || monthNumber == 3 || monthNumber == 5 || monthNumber == 8 || monthNumber == 10 || monthNumber == 12) && days == -31){
                sendMonthiversaryEmail(contactRec.Official_Mail__c, contactRec.Id);
            }else if((monthNumber == 2 || monthNumber == 4 || monthNumber == 6 || monthNumber == 7 || monthNumber == 9 || monthNumber == 11) && days == -30){
                sendMonthiversaryEmail(contactRec.Official_Mail__c, contactRec.Id);
            }else if(contactRec.EMS_EM_JD__c == System.today()){
                sendEmailOnDOJ(contactRec.Official_Mail__c, contactRec.Id);
            }else if(contactRec.EMS_EM_JD__c.addDays(-1) == System.today()){
                System.debug('in gentele reminder 1 => '+contactRec.EMS_EM_JD__c.addDays(-1));
                sendReminderEmail(contactRec.Personal_Email__c, contactRec.Id);
            }
            if(contactRec.Post_Onboarding_Confirm__c == False){
                sendReminderEmailToEmployee(contactRec.Official_Mail__c, contactRec.Id);
            }
            
        }
    }
    
    public static void sendMonthiversaryEmail(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Monthiversary Email' LIMIT 1];
      
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public static void sendEmailOnDOJ(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Welcome Email' LIMIT 1];
      
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist 2 => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public static void sendReminderEmail(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Gentle Reminder Email' LIMIT 1];
      
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist 3 => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public static void sendReminderEmailToEmployee(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Send Reminder Email To Employee' LIMIT 1];
      
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist 3 => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}