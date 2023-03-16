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
        	'SELECT id,name, EMS_EM_JD__c, Resource_Manager__c, Resource_Manager__r.Official_Mail__c, Resource_Manager__r.name, Designation__r.name FROM Contact WHERE EMS_EM_JD__c != NULL AND Resource_Manager__c != NULL AND Resource_Manager__r.Official_Mail__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        
        List<Contact> updatedContactList = new List<Contact>();
        Group itGroup = [select Id from Group where  Type = 'Queue' AND NAME = 'Resource Manager'];
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-7) == System.today() || contactRec.EMS_EM_JD__c.addDays(-2) == System.today()){
                updatedContactList.add(contactRec);
            }else if(contactRec.EMS_EM_JD__c == System.today().addDays(1) || contactRec.EMS_EM_JD__c == System.today()){
                updatedContactList.add(contactRec);
            }
        }
        sendEmailToRM(updatedContactList);
        
    }
    
    public static void sendEmailToRM(List<Contact> finalContactList){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
        	                          where name ='Notify Resource Manager About New Candidate' LIMIT 1];
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        for(Contact con : finalContactList){
            String resourceManagerEmail = con.Resource_Manager__r.Official_Mail__c;
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{resourceManagerEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(con.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setOrgWideEmailAddressId(fromEmail);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        } 
        Messaging.sendEmail(mails);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}