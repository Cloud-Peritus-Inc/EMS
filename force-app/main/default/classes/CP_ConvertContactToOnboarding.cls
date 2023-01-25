/**
* @author Eswar
* @date 25/01/2023
* @description  This batch will run daily, if any applicant DOJ is equal to 10days from today then will create onboarding record as well as send email with 
				onboarding form. Or if DOJ less than 10days then on which date DOJ is updated on that day itself create onboarding record as well as send 
				email with onboarding form.
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
        	'SELECT id, lastName, EMS_EM_JD__c, Email, EMS_RM_LastName__c,Name, Is_Email_Sent__c from Contact WHERE EMS_EM_JD__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-10) == System.today() && contactRec.Is_Email_Sent__c == false){
                EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Email;
                applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                applicantsList.add(applicantRec);
                string status = sendOnboardingEmail(contactRec.Email,contactRec.Id);
                if(status=='success'){
                  contactRec.Is_Email_Sent__c=true; 
                  applicantsToSendMail.add(contactRec);
               	}
                else{
                   contactRec.Is_Email_Sent__c=false;   
                }
            }
            else if(contactRec.EMS_EM_JD__c < (System.today().addDays(10)) && contactRec.Is_Email_Sent__c == false && contactRec.EMS_EM_JD__c.addDays(-10) != System.today()){
                EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Email;
                applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                applicantsList.add(applicantRec);
                string status =  sendOnboardingEmail(contactRec.Email,contactRec.Id);
                if(status=='success'){
                   	contactRec.Is_Email_Sent__c=true;
                    applicantsToSendMail.add(contactRec); 
                }
               	else{
                   	system.debug('status'+ status);
               	}
            }
        }
        insert applicantsList;
        if(applicantsToSendMail.size()>0){
			update applicantsToSendMail; 
        }
    }
    
    public static String sendOnboardingEmail(String email,string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Onboarding Form Email'];
        List<string> emailList = new List<string>();
        emailList.add(email);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        if (results[0].success) {
            return 'success';
        } else {
            return 'failure';
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}