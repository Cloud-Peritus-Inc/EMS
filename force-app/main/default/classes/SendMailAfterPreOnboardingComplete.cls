/**
* @author Eswar Tangudu
* @date 3/27/2023
* @description  Sends email to hr after pre onboarding completed
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

public class SendMailAfterPreOnboardingComplete implements TriggerAction.AfterUpdate{
/**
* @author Eswar Tangudu
* @date 3/27/2023
* @description After Update
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<EMS_EM_Onboarding_Request__c> newList, List<EMS_EM_Onboarding_Request__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'SendMailAfterPreOnboardingComplete.afterUpdate() : BEGIN');
        sendEmailToHr(newList,new Map<Id,EMS_EM_Onboarding_Request__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'SendMailAfterPreOnboardingComplete.afterUpdate() : END');       
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
    
    public void sendEmailToHr(List<EMS_EM_Onboarding_Request__c> newlist,Map<Id,EMS_EM_Onboarding_Request__c> oldMap){
        
        List<Messaging.SingleEmailMessage> lstMails = new List<Messaging.SingleEmailMessage>();
        
        for(EMS_EM_Onboarding_Request__c onboardingRequestRec : newlist){
            if(oldMap.get(onboardingRequestRec.Id).Is_Confirm__c == False && onboardingRequestRec.Is_Confirm__c == True){
                
                Messaging.SingleEmailMessage message = sendMailToHr(onboardingRequestRec.ContactId1__c);
                lstMails.add(message);
            }
        }
        Messaging.sendEmail(lstMails);
    }
    
    public static Messaging.SingleEmailMessage sendMailToHr(String recordId){
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify HR After PreOnboarding Completion' LIMIT 1];
         
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