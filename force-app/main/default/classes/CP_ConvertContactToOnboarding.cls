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
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        List<Contact> finalContactList = new List<Contact>();
        
        for(Contact contactRec : contactList){
            if((contactRec.EMS_EM_JD__c.addDays(-10) == System.today() || contactRec.EMS_EM_JD__c.addDays(-11) == System.today()) && contactRec.Is_PreOnboarding_Mail_Sent__c == False){
               EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Personal_Email__c;
                applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                applicantRec.ContactId1__c = contactRec.Id;
                applicantsList.add(applicantRec);
                applicantsToSendMail.add(contactRec);
                String status = sendOnboardingEmail(contactRec.Personal_Email__c,contactRec.Id);
                if(status == 'success'){
                    sendEmailToHR(contactRec.Id);
                    sendEmailToAdminTeam(contactRec.Id);                
                }  
            }
        }
        insert applicantsList;
        if(applicantsToSendMail.size() > 0){
            for(Contact con : applicantsToSendMail){
                con.Is_PreOnboarding_Mail_Sent__c = True;
                finalContactList.add(con);
            }
            update finalContactList;
        }
        List<ems_EM_Additional_Detail__c> additionalDetailsList = new List<ems_EM_Additional_Detail__c>();
        for(EMS_EM_Onboarding_Request__c onboardingRecords : applicantsList){
            ems_EM_Additional_Detail__c applicantRec = new ems_EM_Additional_Detail__c();
            applicantRec.Onboarding_Request__c = onboardingRecords.id;
            applicantRec.ContactId__c = onboardingRecords.ContactId1__c;
            additionalDetailsList.add(applicantRec);
        }
        insert additionalDetailsList;
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
        message.setTreatTargetObjectAsRecipient(false);
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
    public void finish(Database.BatchableContext bc){
        
    }
}