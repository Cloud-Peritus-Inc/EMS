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
        	'SELECT id, EMS_EM_JD__c, Name, Personal_Email__c, RecordType.Name, Post_Onboarding_Confirm__c, Email from Contact WHERE EMS_EM_JD__c != NULL AND (Email != NULL OR Personal_Email__c != NULL)' 
        );
    }    
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> reminderMailsList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> monthiversaryMailsList = new List<Messaging.SingleEmailMessage>();
        //List<Messaging.SingleEmailMessage> dojMailsList = new List<Messaging.SingleEmailMessage>();
        for(Contact contactRec : contactList){
           /* Integer monthNumber = contactRec.EMS_EM_JD__c.month();
            Integer days = Date.today().daysBetween(contactRec.EMS_EM_JD__c);
            System.debug('Month => '+monthNumber);
            System.debug('Days => '+days);
            if(monthNumber == 2 && days == -26 && contactRec.RecordType.Name == 'Resource'){
                //sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                Messaging.SingleEmailMessage message = sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                monthiversaryMailsList.add(message);
            }else if((monthNumber == 1 || monthNumber == 3 || monthNumber == 5 || monthNumber == 8 || monthNumber == 10 || monthNumber == 12) && days == -29 && contactRec.RecordType.Name == 'Resource'){
                //sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                Messaging.SingleEmailMessage message = sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                monthiversaryMailsList.add(message);
            }else if((monthNumber == 2 || monthNumber == 4 || monthNumber == 6 || monthNumber == 7 || monthNumber == 9 || monthNumber == 11) && days == -28 && contactRec.RecordType.Name == 'Resource'){
                //sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                Messaging.SingleEmailMessage message = sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                monthiversaryMailsList.add(message);
            }*/
            
            if(contactRec.EMS_EM_JD__c.addDays(30) == System.today() && contactRec.RecordType.Name == 'Resource'){
                Messaging.SingleEmailMessage message = sendMonthiversaryEmail(contactRec.Email, contactRec.Id);
                monthiversaryMailsList.add(message);
            }
                        
            /*if(contactRec.EMS_EM_JD__c == System.today() && contactRec.Email != NULL && contactRec.RecordType.Name == 'Resource'){
                //sendEmailOnDOJ(contactRec.Email, contactRec.Id);
                Messaging.SingleEmailMessage message = sendEmailOnDOJ(contactRec.Email, contactRec.Id);
                dojMailsList.add(message);
            }*/
            if(contactRec.EMS_EM_JD__c.addDays(-1) == System.today() && contactRec.RecordType.Name == 'Applicant'){
                System.debug('Inside condition');
                Messaging.SingleEmailMessage message = sendReminderEmail(contactRec.Personal_Email__c, contactRec.Id);
                reminderMailsList.add(message);
            }
            if(contactRec.Post_Onboarding_Confirm__c == False  && contactRec.Email != NULL && contactRec.RecordType.Name == 'Resource' && contactRec.EMS_EM_JD__c != System.today()){
               // sendReminderEmailToEmployee(contactRec.Email, contactRec.Id);
                Messaging.SingleEmailMessage message = sendReminderEmailToEmployee(contactRec.Email, contactRec.Id);
                lstMails.add(message);
            }
            
        }
        Messaging.sendEmail(monthiversaryMailsList);
        Messaging.sendEmail(reminderMailsList);
        Messaging.sendEmail(lstMails);
        //Messaging.sendEmail(dojMailsList);
    }
    
    public static Messaging.SingleEmailMessage sendMonthiversaryEmail(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Monthiversary Email' LIMIT 1];
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
      
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
        return message;
    }
    
   /* public static Messaging.SingleEmailMessage sendEmailOnDOJ(String email, String recordId){
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
    }*/
    
    public static Messaging.SingleEmailMessage sendReminderEmail(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Gentle Reminder Email' LIMIT 1];
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist 3 => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
        return message;
    }
    
    public static Messaging.SingleEmailMessage sendReminderEmailToEmployee(String email, String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Send Reminder Email To Employee' LIMIT 1];
       // List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        
        List<String> emailList = new List<String>();
        emailList.add(email);
        system.debug('Enaillist 4 => '+emailList);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setOrgWideEmailAddressId(fromEmail);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        return message;
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
}