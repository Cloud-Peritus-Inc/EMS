/**
* @author Eswar
* @date 30/01/2023
* @description  This batch will run daily, on date of joining one task will create and send mail to IT team regarding generation of 
				the official email ID of the candidate.

*               Test code coverage provided by the following test class:
*               - CP_CreateTaskForOffcialEmailCreationTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_CreateTaskForOffcialEmailCreation implements Database.Batchable<sObject>, schedulable{
	
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new CP_CreateTaskForOffcialEmailCreation());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date todayDate = System.today();
        return Database.getQueryLocator(
        	'SELECT id, EMS_EM_JD__c FROM Contact WHERE EMS_EM_JD__c =:todayDate AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        
        Group itGroup = [select Id from Group where  Type = 'Queue' AND NAME = 'IT Department'];
        List<Task> tskList = new List<Task>();
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c == System.today()){
                Task t = new Task();
                t.OwnerId = itGroup.Id;
                t.Subject = 'Create an official email ID for the new employee';
                t.Status = 'Open';
                t.Priority = 'High';
                t.IsReminderSet = true;
                t.WhoId = contactRec.Id;
                t.ActivityDate = contactRec.EMS_EM_JD__c;
                t.ReminderDateTime = DateTime.newInstance(contactRec.EMS_EM_JD__c.year(), contactRec.EMS_EM_JD__c.month(), contactRec.EMS_EM_JD__c.day(), 20, 00, 00);
                tskList.add(t);
            }
        }
        
        if(tskList!=null && tskList.size()>0){
            insert tskList;
            sendOnboardingEmail(contactList);
        }
    }
    
    public static Void sendOnboardingEmail(List<Contact> contactRecordsList){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Mail for Create Official Mail'];
        String emailList = [SELECT id, email FROM Contact WHERE name = 'IT Departement'].email;
        for(Contact contactRec : contactRecordsList){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{emailList});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(contactRec.id);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}