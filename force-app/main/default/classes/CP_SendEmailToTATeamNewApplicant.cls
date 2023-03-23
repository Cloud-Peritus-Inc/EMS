/**
* @author Eswar
* @date 07/02/2023
* @description  This class is for send email to TA team after applicant record is inserted.
*
*               Test code coverage provided by the following test class:
*               - CP_SendEmailToTATeamNewApplicantTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendEmailToTATeamNewApplicant implements TriggerAction.AfterInsert{
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
         System.debug(LoggingLevel.DEBUG, 'CP_SendEmailToTATeamNewApplicant.afterInsert() : BEGIN');
         sendEmailToTATeam(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendEmailToTATeamNewApplicant.afterInsert() : END');       
     }
    
    private void sendEmailToTATeam(List<Contact> contactList){
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        /*String taTeamEmail = [SELECT id, email FROM Contact WHERE name = 'TA Team'].email;
        List<String> emailList = new List<String>();
        emailList.add(taTeamEmail);*/
        //List<String> emailList = new List<String>{'tets@gmail.com', 'bhb@gmail.com'};
        
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'TA_Team'].Email__c;
        List<String> emailList = new List<String>();
        emailList.add(taTeamEmail);
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted TA'];
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        
        for(Contact contactRec : contactList){
            if(contactRec.RecordTypeId == contRecordTypeId){
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
                mail.setToAddresses(emailList);
                mail.setTemplateID(emailTemplate.Id);
                mail.setTargetObjectId(contactRec.id);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setOrgWideEmailAddressId(fromEmail);
                mail.setSaveAsActivity(false);         
                mails.add(mail);
            }   
        }
        Messaging.sendEmail(mails);
    }
}