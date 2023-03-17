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
        	'SELECT id, lastName, EMS_EM_JD__c, Email, Is_PreOnboarding_Mail_Sent__c, Personal_Email__c, EMS_RM_LastName__c,Name, Is_Email_Sent__c from Contact WHERE EMS_EM_JD__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        
        List<Contact> applicantsToSendMail = new List<Contact>();
        List<Contact> finalContactList = new List<Contact>();
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        
        for(Contact contactRec : contactList){
            if((contactRec.EMS_EM_JD__c.addDays(-10) == System.today() || contactRec.EMS_EM_JD__c.addDays(-11) == System.today()) && contactRec.Is_PreOnboarding_Mail_Sent__c == False){
                applicantsToSendMail.add(contactRec);
                System.debug('Today ==> '+system.today());
                System.debug('DOJ ==> '+contactRec.EMS_EM_JD__c);
                System.debug('DOJ minus 10days ==> '+contactRec.EMS_EM_JD__c.addDays(-10));
                String status = sendOnboardingEmail(contactRec.Personal_Email__c,contactRec.Id);
                if(status == 'success'){
                    sendEmailToHR(contactRec.Id);
                    Messaging.SingleEmailMessage message = sendEmailToAdminTeam(contactRec.Id);
                    lstMails.add(message);
                }  
            }
        }
        Messaging.sendEmail(lstMails);
        
        if(applicantsToSendMail.size() > 0){
            for(Contact con : applicantsToSendMail){
                con.Is_PreOnboarding_Mail_Sent__c = True;
                finalContactList.add(con);
            }
            update finalContactList;
        }
        
    }
    
    public static String sendOnboardingEmail(String email,string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Onboarding Form Email' LIMIT 1];
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<string> emailList = new List<string>();
        emailList.add(email);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setOrgWideEmailAddressId(fromEmail);
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
        mails.add(message);
        
        Messaging.sendEmail(mails);
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
     public static Messaging.SingleEmailMessage sendEmailToAdminTeam(string recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted Admin' LIMIT 1];
         
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> adminEmailList = new List<String>();
        adminEmailList.add(taTeamEmail);
         
        //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = adminEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
        return message;
    }
    public void finish(Database.BatchableContext bc){
        
    }
}