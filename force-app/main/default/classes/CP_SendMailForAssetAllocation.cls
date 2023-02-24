/**
* @author Eswar
* @date 30/01/2023
* @description  This batch will run daily, if any applicant DOJ is equal to 10days from today then mail will be triggered for asset allocation 
				to IT department.

*               Test code coverage provided by the following test class:
*               - CP_SendMailForAssetAllocationTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendMailForAssetAllocation implements Database.Batchable<sObject>, schedulable{
	
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new CP_SendMailForAssetAllocation());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT id, EMS_EM_JD__c, Resource_Manager__c, Resource_Manager__r.Official_Mail__c, Resource_Manager__r.name FROM Contact WHERE EMS_EM_JD__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        List<Contact> updatedContactList = new List<Contact>();
        List<Contact> contactListForIT = new List<Contact>();
        List<Contact> contactListForRM = new List<Contact>();
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-10) == System.today()){
                updatedContactList.add(contactRec);
            }
            if(contactRec.EMS_EM_JD__c == System.today()){
                contactListForIT.add(contactRec);
            }  
            if((contactRec.EMS_EM_JD__c.addDays(-7) == System.today() || contactRec.EMS_EM_JD__c.addDays(-2) == System.today()) && contactRec.Resource_Manager__c != NULL && contactRec.Resource_Manager__r.Official_Mail__c != NULL){
                contactListForRM.add(contactRec);
            }
        }
        
        if(updatedContactList.size() > 0){
            sendEmailToITTeamForNewJoin(updatedContactList);
        }
        if(contactListForIT.size() > 0){
            sendEmailToITTeam(contactListForIT);
        	sendEmailToITTeamToAddCandidate(contactListForIT);
        }
        if(contactListForRM.size() > 0){
            sendEmailToRM(contactListForRM);
        }
        
    }
    
    public static Void sendEmailToITTeamForNewJoin(List<Contact> contactRecordsList){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Email To IT Team For Assets' LIMIT 1];
        String itEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'IT_Team' LIMIT 1].Email__c;
        for(Contact contactRec : contactRecordsList){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{itEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(contactRec.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
    public static Void sendEmailToITTeam(List<Contact> contactRecordsList){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Mail for Create Official Mail'];
        //String emailList = [SELECT id, email FROM Contact WHERE name = 'IT Departement'].email;
        String itEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'IT_Team' LIMIT 1].Email__c;
        for(Contact contactRec : contactRecordsList){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{itEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(contactRec.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
    public void sendEmailToITTeamToAddCandidate(List<Contact> contactRecordsList){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where DeveloperName = 'Mail_for_Add_Email_to_Company_Mail_Group'];
        //String emailList = [SELECT id, email FROM Contact WHERE name = 'IT Departement'].email;
        String itEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'IT_Team' LIMIT 1].Email__c;
        for(Contact contactRec : contactRecordsList){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{itEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(contactRec.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        }
          Messaging.sendEmail(mails);  
    }
    
    public static void sendEmailToRM(List<Contact> finalContactList){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
        	                          where name ='Notify Resource Manager About New Candidate' LIMIT 1];
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        
        for(Contact con : finalContactList){
            String resourceManagerEmail = con.Resource_Manager__r.Official_Mail__c;
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{resourceManagerEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(con.id);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        } 
        Messaging.sendEmail(mails);
    }
    
    public void finish(Database.BatchableContext bc){
    }
}