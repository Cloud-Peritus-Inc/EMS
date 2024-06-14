/**
* @author Rakshitha
* @date 13/02/2023
* @description  This class is for send email to HR team after applicant record is inserted.
*
*               Test code coverage provided by the following test class:
*               - CP_SendEmailToAdminTeamNewApplicantTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendEmailToAdminTeamNewApplicant implements TriggerAction.AfterInsert{
	
    /**
    * @author Rakshitha
    * @date 13/02/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterInsert(List<Contact> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_SendEmailToAdminTeamNewApplicant.afterInsert() : BEGIN');
         sendEmailToAdminTeam(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendEmailToAdminTeamNewApplicant.afterInsert() : END');       
     }
    
    private void sendEmailToAdminTeam(List<Contact> contactList){
       
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;      
        String adminTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        List<String> emailList = new List<String>();
        emailList.add(adminTeamEmail);
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted Admin'];
        
        for(Contact contactRec : contactList){
            if(contactRec.RecordTypeId == contRecordTypeId){
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
                mail.setToAddresses(emailList);
                mail.setTemplateID(emailTemplate.Id);
                mail.setTargetObjectId(contactRec.id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setSaveAsActivity(false);         
                mails.add(mail);
            }   
        }
        Messaging.sendEmail(mails);
    }
    
}