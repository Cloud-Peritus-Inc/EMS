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
        	'SELECT id, EMS_EM_JD__c FROM Contact WHERE EMS_EM_JD__c != NULL AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c.addDays(-10) == System.today()){
                sendOnboardingEmail();
            }
        }
    }
    
    public static Void sendOnboardingEmail(){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Email To IT Team For Assets' LIMIT 1];
        List<string> emailList = new List<string>();
        for(Contact contactRec : [SELECT id, email FROM Contact WHERE name = 'IT Departement' LIMIT 1]){
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.setToAddresses(new list<string>{contactRec.email});
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