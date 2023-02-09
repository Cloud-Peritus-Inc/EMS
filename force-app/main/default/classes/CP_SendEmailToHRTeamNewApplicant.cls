/**
* @author Eswar
* @date 07/02/2023
* @description  This class is for send email to HR team after applicant record is inserted.
*
*               Test code coverage provided by the following test class:
*               - CP_SendEmailToHRTeamNewApplicantTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendEmailToHRTeamNewApplicant implements TriggerAction.AfterInsert{
	
    /**
    * @author Eswar
    * @date 07/02/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterInsert(List<Contact> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_SendEmailToHRTeamNewApplicant.afterInsert() : BEGIN');
         sendEmailToHRTeam(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendEmailToHRTeamNewApplicant.afterInsert() : END');       
     }
    
    private void sendEmailToHRTeam(List<Contact> contactList){
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        String hrTeamEmail = [SELECT id, email FROM Contact WHERE name = 'HR Team'].email;
        //String taTeamEmail = [SELECT id, email FROM Contact WHERE name = 'TA Team'].email;
        List<String> emailList = new List<String>();
        emailList.add(hrTeamEmail);
        //emailList.add(taTeamEmail);
        //List<String> emailList = new List<String>{'tets@gmail.com', 'bhb@gmail.com'};
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted HR'];
        
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