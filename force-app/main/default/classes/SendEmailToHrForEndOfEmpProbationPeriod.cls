/**
* @author Eswar
* @date 16/03/2023
* @description  This batch will run daily, 2 days before probation period ends send email to hr.

*               Test code coverage provided by the following test class:
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class SendEmailToHrForEndOfEmpProbationPeriod implements Database.Batchable<sObject>, schedulable{

    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new SendEmailToHrForEndOfEmpProbationPeriod());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(
        	'SELECT id, EMS_EM_PP__c, EMS_EM_JD__c FROM Contact WHERE EMS_EM_PP__c != NULL AND RecordType.Name = \'Resource\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        List<Contact> updatedContactList = new List<Contact>();
        for(Contact contactRec : contactList){
            Integer probationDays = (Integer)contactRec.EMS_EM_PP__c;
            Date prodationEndDate = contactRec.EMS_EM_JD__c.addDays(probationDays);
            if(prodationEndDate == System.today().addDays(2)){
                updatedContactList.add(contactRec);
            }
        }
        if(updatedContactList.size() > 0){
            sendEmailToEmployee(updatedContactList);
        }
    }
    
    public static Void sendEmailToEmployee(List<Contact> contactRecordsList){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Probation end announcement'];
        String hrEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team' LIMIT 1].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        for(Contact contactRec : contactRecordsList){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{hrEmail});
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(contactRec.id);
            mail.setOrgWideEmailAddressId(fromEmail);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);         
            mails.add(mail);
        }
        Messaging.sendEmail(mails);
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}