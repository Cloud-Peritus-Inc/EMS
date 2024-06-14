/**
* @author Shubham Maske
* @date 04/03/2024
* @description  Send Email to Mentor and Resource Manager of the resource for whom recognition record is created.
*
*               Test code coverage provided by the following test class:
*               - sendEmailToResourceManagerAndMentor_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 04/03/2024    Shubham Maske           Initial Version
* ====================================================================================================
**/
public without sharing class sendEmailToResourceManagerAndMentor implements TriggerAction.AfterInsert {
    
    public static final Id RR_WINNER_RECORDTYPEID = Schema.SObjectType.Reward_And_Recognition__c.getRecordTypeInfosByDeveloperName().get('Winners').getRecordTypeId();
    
/**
* @author Shubham Maske
* @date 04/03/2024
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterInsert(List<Reward_And_Recognition__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'EmailToResourceManagerAndMentor.afterInsert() : BEGIN');
        EmailToResourceManagerAndMentor(newList,null);
        System.debug(LoggingLevel.DEBUG, 'EmailToResourceManagerAndMentor.afterInsert() : END');       
    }
    
/**
*   {Purpose} - Check for Recognition record and get RRR details
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public Static void EmailToResourceManagerAndMentor(List<Reward_And_Recognition__c> recognitionList,Map<Id,Reward_And_Recognition__c> oldMap) {
        System.debug(' IN EmailToResourceManagerAndMentor');
        List<String> resourceManagerAndMentorEmails = new List<String>();
        for (Reward_And_Recognition__c rec : recognitionList) {
            if(rec.RecordTypeId == RR_WINNER_RECORDTYPEID && rec.Type__c == 'Recognize'){
                geRRRDetails(rec);
            }
        }    
    }
    
/**
*   {Purpose} - Check for Resource Manager & Mentor, fetch their email and sendEmailAlert
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public Static Void geRRRDetails(Reward_And_Recognition__c rec) {
        System.debug(' IN geRRRDetails');
        Set<String> emailSet = new Set<String>();
        try {
            List<Resource_Resource_Relationship__c> RRR = [
                SELECT Id, Name, Resource__c, Resource_Reports_To__c, Resource_Reports_To__r.Email, Relationship_Type__c 
                FROM Resource_Resource_Relationship__c 
                WHERE Resource__c = :rec.Resource__c 
                AND Resource_Reports_To__c != NULL 
                AND Relationship_Type__c INCLUDES ('Mentor','Resource Manager')
            ];
            for (Resource_Resource_Relationship__c r : RRR) {
                if (r.Resource_Reports_To__r != null && r.Resource_Reports_To__r.Email != null) {
                    emailSet.add(r.Resource_Reports_To__r.Email);
                }
            }
            System.debug(' IN geRRRDetails emailSet' + emailSet);
            if(!emailSet.isEmpty()){
                getEmailBasedOnRecType(rec,emailSet);
            }
            
        } catch (Exception e) {
            // Handle the exception here, such as logging the error
            System.debug('An error occurred while fetching email IDs: ' + e.getMessage());
        }
    }
    
/**
*   {Purpose} - Send Email based on type of recogniton.
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public static void getEmailBasedOnRecType(Reward_And_Recognition__c rec,Set<String> EmailIds) {
        System.debug(' IN getEmailBasedOnRecType ');
        
        Contact resource = [Select Id,Name,Email from Contact WHERE Id=:rec.Resource__c LIMIT 1];
        
        Id templateId;
        List<EmailTemplate> templates = New List<EmailTemplate>();
        List<String> cc =new List<String>(EmailIds);
        
        if(rec.Types_of_Recognition__c == 'Monetary Rewards'){
            templates = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Monetary_Recognition_Email_template_for_Resource' LIMIT 1];
        }else if(rec.Types_of_Recognition__c == 'Performance-Based Recognition'){
            templates = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Performance_Recognition_Email_template_for_Resource' LIMIT 1];
            
        }else if(rec.Types_of_Recognition__c == 'Peer Recognition'){
            templates = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Peer_Recognition_Email_template_for_Resource' LIMIT 1];
            
        }else if(rec.Types_of_Recognition__c == 'Prize Recognition'){
            templates = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName = 'Prize_Recognition_Email_template_for_Resource' LIMIT 1];
        }
        
        if (!templates.isEmpty()) {
            templateId = templates[0].Id;
        }
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply.grid@cloudperitus.com'];
		System.debug(' IN getEmailBasedOnRecType owea' + owea.get(0).Id);
        System.debug('templateId 111' + templateId );
        if(String.isNotBlank(templateId)){
            
            System.debug(' IN templateId ' + templateId );
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String[] toaddresses = new String[] {resource.Email}; 
                
            message.setToAddresses(toaddresses);
            message.setCcAddresses(cc);
            message.setOrgWideEmailAddressId(owea.get(0).Id);
            message.setTargetObjectId(rec.Resource__c);
            message.setWhatId(rec.Id);
            message.setTemplateId(templateId);
            message.setSaveAsActivity(true);
            
            
            try {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
                
                // Check the results of sending the email
                for (Messaging.SendEmailResult result : results) {
                    if (result.success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: ' + result.errors[0].message);
                    }
                }
            } catch (Exception e) {
                System.debug('An exception occurred while sending the email: ' + e.getMessage());
            }
            
            
        }
        
    } 
    
    
    
}