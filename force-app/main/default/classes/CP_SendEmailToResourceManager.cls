/**
* @author Eswar
* @date 07/1/2023
* @description  This batch will run daily,  send reminding email to resource manager 7 days and 2 days prior to DOJ of candidate. 
*
*               Test code coverage provided by the following test class:
*               - CP_SendEmailToResourceManagerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendEmailToResourceManager implements Database.Batchable<sObject>, schedulable{
	
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new CP_SendEmailToResourceManager());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT id,name, EMS_EM_JD__c, Resource_Manager__c, Resource_Manager__r.Personal_Email__c, Resource_Manager__r.name, Designation__r.name FROM Contact WHERE EMS_EM_JD__c != NULL AND Resource_Manager__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        
        List<Contact> updatedContactList = new List<Contact>();
        Group itGroup = [select Id from Group where  Type = 'Queue' AND NAME = 'Resource Manager'];
        List<Task> tskList = new List<Task>();
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-7) == System.today() || contactRec.EMS_EM_JD__c.addDays(-2) == System.today()){
                updatedContactList.add(contactRec);
                Task t = new Task();
                t.OwnerId = itGroup.Id;
                t.Subject = 'Conduct One to One Onboarding for the new employee';
                t.Status = 'Open';
                t.Priority = 'High';
                t.IsReminderSet = true;
                t.WhoId = contactRec.Id;
                t.ActivityDate = contactRec.EMS_EM_JD__c;
                t.ReminderDateTime = DateTime.newInstance(contactRec.EMS_EM_JD__c.year(), contactRec.EMS_EM_JD__c.month(), contactRec.EMS_EM_JD__c.day(), 20, 00, 00);
                tskList.add(t);
            }
        }
        sendOnboardingEmail(updatedContactList);
        if(tskList!=null && tskList.size()>0){
            insert tskList;
        }
    }
    
    public static void sendOnboardingEmail(List<Contact> finalContactList){
        /*EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Onboarding Form Email' LIMIT 1];*/
        //Here we can't use email template because if we use template then we need to use setTargetObjectId, if we use this then email is trigger  
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<String> sendTo = new List<String>();
        for(Contact con : finalContactList){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            sendTo.add(con.Resource_Manager__r.Personal_Email__c);
        	message.toAddresses = sendTo;
            message.setSubject('Cloud Peritus :  Upcoming Employee Onboarding');
            String body = 'Dear '+ con.Resource_Manager__r.name+', <br/><br/>';
            body += 'The following candidate will join our company on '+ con.EMS_EM_JD__c + ': <br/>';
            body += 'Name: '+ con.Name + ' <br/>';
            body += 'Designation: '+ con.Designation__r.name + ' <br/>';
            body += 'Please be prepared to give an orientation session on their first day. Also, ensure that ';
            body += 'training materials/sessions are organized for the employee for the first week, so that ';
            body += 'the employee has all the necessary information to perform well in their new position. <br/><br/>';
            body += 'Regards, <br/>';
            body += 'Team Cloud Peritus';
            message.setHtmlBody(body);
            message.setSaveAsActivity(false);
            mails.add(message);
        }
       Messaging.sendEmail(mails);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}