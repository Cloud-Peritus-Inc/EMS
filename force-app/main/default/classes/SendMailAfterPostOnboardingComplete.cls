/**
* @author Eswar Tangudu
* @date 3/31/2023
* @description  Sends email to hr after post onboarding completed
*
*               Test code coverage provided by the following test class:
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

public class SendMailAfterPostOnboardingComplete implements TriggerAction.AfterUpdate{
/**
* @author Eswar Tangudu
* @date 3/31/2023
* @description After Update
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<Contact> newList, List<Contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'SendMailAfterPostOnboardingComplete.afterUpdate() : BEGIN');
        sendEmailToHr(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'SendMailAfterPostOnboardingComplete.afterUpdate() : END');       
    }
/**
*   {Purpose} -  
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    
    public void sendEmailToHr(List<Contact> newlist,Map<Id,Contact> oldMap){
        
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        for(Contact ContactRec : newlist){
            if(ContactRec.Post_Onboarding_Confirm__c != oldMap.get(ContactRec.Id).Post_Onboarding_Confirm__c){
                Messaging.SingleEmailMessage message = sendMailToHr(ContactRec.Id);
                lstMails.add(message);
            }
        }
        Messaging.sendEmail(lstMails);
    }
    
    public static Messaging.SingleEmailMessage sendMailToHr(String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify HR After PostOnboarding Completion' LIMIT 1];
         
        String hrTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        
        List<String> emailList = new List<String>();
        emailList.add(hrTeamEmail);
        		
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        System.debug('Record Id => '+recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        message.setOrgWideEmailAddressId(fromEmail);
        return message;
    }
}