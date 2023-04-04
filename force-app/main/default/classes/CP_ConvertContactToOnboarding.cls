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
        List<Messaging.SingleEmailMessage> adminTeamListForTasks = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> itMailList = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> itMailListForDOJ = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> hrMailList = new List<Messaging.SingleEmailMessage>();
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-10) == System.today() && contactRec.Is_PreOnboarding_Mail_Sent__c == False){
                applicantsToSendMail.add(contactRec);
                String status = sendOnboardingEmail(contactRec.Personal_Email__c,contactRec.Id);
                if(status == 'success'){
                    sendEmailToHR(contactRec.Id);
                    Messaging.SingleEmailMessage message = sendEmailToAdminTeam(contactRec.Id);
                    adminTeamListForTasks.add(message);
                    Messaging.SingleEmailMessage message2 = sendEmailToITTeamForNewJoin(contactRec.Id);
                	itMailList.add(message2);
                    Messaging.SingleEmailMessage message3 = sendEmailToHR(contactRec.Id);
                	hrMailList.add(message3);
                }  
            }
            
            if(contactRec.EMS_EM_JD__c == System.today()){
                Messaging.SingleEmailMessage message = adminTeamDOJTasks(contactRec.Id);
                lstMails.add(message);
                Messaging.SingleEmailMessage message2 = sendEmailToITTeamOnDOJ(contactRec.Id);
                itMailListForDOJ.add(message2);
            }
        }
        
        Messaging.sendEmail(adminTeamListForTasks);
        Messaging.sendEmail(itMailList);
        Messaging.sendEmail(hrMailList);
        Messaging.sendEmail(lstMails);
        Messaging.sendEmail(itMailListForDOJ);
        
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
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
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
    
    public static Messaging.SingleEmailMessage adminTeamDOJTasks(string recordId){
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Admin Team DOJ Tasks' LIMIT 1];
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> adminEmailList = new List<String>();
        adminEmailList.add(taTeamEmail);
         		
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = adminEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
        return message;
    }
    
    public static Messaging.SingleEmailMessage sendEmailToITTeamOnDOJ(string recordId){
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Mail for Create Official Mail'];
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
    
    public void finish(Database.BatchableContext bc){    
    }
}