/**
* @author Rakshitha 
* @date 9/2/2023
* @description  To add comments and send mail to the applicant with edit access to the portal 
*
*               Test code coverage provided by the following test class:
*               - ems_EM_AddCommentsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

public class ems_EM_AddComments {
    @AuraEnabled
    public static void sendOnboardingFormReopenEmail(String recordId, String comments){
        List<Messaging.Email> emailsToSendList = new List<Messaging.Email>();
        Id templateId = getEmailTemplate('Resubmit_onboarding_detail');
        EMS_EM_Onboarding_Request__c onBoardingRequest = EMS_EM_CreationOnboard.returnOnboardingDetailsBasedOnRecordId(recordId);
        onBoardingRequest.Comments__c = comments;
        onBoardingRequest.Is_Confirm__c = false;
        onBoardingRequest.Status__c = 'Reopened';
        Update onBoardingRequest;
       /* Messaging.singleEmailMessage emailMessage = new Messaging.singleEmailMessage();
        emailMessage.setToAddresses(new List<String>{onBoardingRequest.EMS_EM_Personal_Email__c});
        emailMessage.setTargetObjectId(onBoardingRequest.ContactId1__c);
        emailMessage.setWhatId(onBoardingRequest.id);
        emailMessage.setTemplateId(templateId);
        emailMessage.saveAsActivity = False;
        emailMessage.setTreatTargetObjectAsRecipient(false);
        emailsToSendList.add(emailMessage); 
        try{
            messaging.sendEmail(emailsToSendList);
            return 'Email Sent successfully';
        }catch(Exception ex){
            return ex.getMessage();
        }*/
        
    }
    
    @AuraEnabled
    public static Id getEmailTemplate(String emailTemplateName){
        return [ select Id, 
                developername
                from 
                EmailTemplate 
                where developerName =: emailTemplateName]?.Id;
    }
    
}