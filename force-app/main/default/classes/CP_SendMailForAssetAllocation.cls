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
        	'SELECT id, EMS_EM_JD__c, Resource_Manager__c, Is_Email_Sent_To_IT_Team__c FROM Contact WHERE EMS_EM_JD__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        List<Contact> updatedContactList = new List<Contact>();
        List<Contact> contactListForIT = new List<Contact>();
        List<Contact> contactListForRM = new List<Contact>();
       
        for(Contact contactRec : contactList){
            Date today = Date.today();
        	Date sobjectDate = contactRec.EMS_EM_JD__c;
            
            if(contactRec.EMS_EM_JD__c.addDays(-10) == System.today()){
                updatedContactList.add(contactRec);
            }else if(today.daysBetween(sobjectDate) < 10 && contactRec.Is_Email_Sent_To_IT_Team__c == False){
                updatedContactList.add(contactRec);
            }
            if(contactRec.EMS_EM_JD__c == System.today()){
                contactListForIT.add(contactRec);
            }  
        }
        
        if(updatedContactList.size() > 0){
            String status = sendEmailToITTeamForNewJoin(updatedContactList);
            if(status == 'success'){
                List<Contact> finalContactList = new List<Contact>();
                for(Contact con : updatedContactList){
                    con.Is_Email_Sent_To_IT_Team__c = True;
                    finalContactList.add(con);
                }
                update finalContactList;
            }
        }
        if(contactListForIT.size() > 0){
            sendEmailToITTeam(contactListForIT);
        	sendEmailToITTeamToAddCandidate(contactListForIT);
        }
    }
    
    public static String sendEmailToITTeamForNewJoin(List<Contact> contactRecordsList){
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
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
        if (results[0].success) {
            return 'success';
        } else {
            return 'failure';
        }
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
    
    public void finish(Database.BatchableContext bc){
    }
}