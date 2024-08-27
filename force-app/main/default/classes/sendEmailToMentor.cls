/**
* @author Ravitheja
* @date 15/07/2024
* @description Send the email to mentor if the KRA has been Rejected or Submitted by Project Manager
* 
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/

public class sendEmailToMentor implements TriggerAction.AfterUpdate {
    
    public void afterUpdate(List<PM_Configure__c> newList, List<PM_Configure__c> oldList) {  
        
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : BEGIN');
        sendRejectionEmailToMentor(newList, new Map<Id, PM_Configure__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : END');       
    }
    
    public static void sendRejectionEmailToMentor(List<PM_Configure__c> newList, Map<Id, PM_Configure__c> oldMap) {
        
        Set<Id> resourceId = new Set<Id>();
        Set<Id> reporteeId = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        List<PM_Configure__c> rejectedVsSubmittedPMConfigs = new List<PM_Configure__c>();
        Map<Id, PM_Configure__c> kraToPmConfigMap = new Map<Id, PM_Configure__c>();
        Id menteeUserId = null;
        Id mentorUserId = null;
        
        for (PM_Configure__c pmConfig : newList) { 
            contactIdSet.add(pmConfig.Mentee__c);
            contactIdSet.add(pmConfig.Mentor__c);
        }
        
        Map<Id, Contact> contactMap = new Map<Id, Contact>([
            SELECT Id, EMS_TM_User__c 
            FROM Contact 
            WHERE Id IN :contactIdSet
        ]);
        
        
        for (PM_Configure__c pmConfig : newList) { 
            if (contactMap.containsKey(pmConfig.Mentee__c)) {
                menteeUserId = contactMap.get(pmConfig.Mentee__c).EMS_TM_User__c; 
            }
            if (contactMap.containsKey(pmConfig.Mentor__c)) {
                mentorUserId = contactMap.get(pmConfig.Mentor__c).EMS_TM_User__c;
            }
            
            if ((pmConfig.Status__c == 'Rejected' || pmConfig.Status__c == 'Submitted') 
                && pmConfig.Status__c != oldMap.get(pmConfig.Id).Status__c 
                && pmConfig.KRA__c != null
                && menteeUserId != null
                && mentorUserId != null
               	&& pmConfig.LastModifiedById != menteeUserId  
               	&& pmConfig.LastModifiedById != mentorUserId
                && pmConfig.Reporting_Contact__c != null) {
                if (!kraToPmConfigMap.containsKey(pmConfig.KRA__c)) {
                     kraToPmConfigMap.put(pmConfig.KRA__c, pmConfig);
                     rejectedVsSubmittedPMConfigs.add(pmConfig);
                }
            }
        }
        
        if (!kraToPmConfigMap.isEmpty()) {
            
            for (Goal__c gl : [SELECT Id, Resource__c FROM Goal__c WHERE Id IN :kraToPmConfigMap.keySet() AND Resource__c != NULL LIMIT 1]) {
                resourceId.add(gl.Resource__c);
            }
            
            for (Resource_Resource_Relationship__c rrr : [SELECT Id, Resource__c, Resource_Reports_To__c 
                                                          FROM Resource_Resource_Relationship__c 
                                                          WHERE Resource__c IN :resourceId 
                                                          AND Resource__c != NULL
                                                          AND Relationship_Type__c = 'Mentor'
                                                          AND Resource_Reports_To__c != NULL]) {    
                reporteeId.add(rrr.Resource_Reports_To__c);
            }
            
            Contact contact = [SELECT Id, Name, Email FROM Contact WHERE Id IN :reporteeId LIMIT 1];
            sendEmail(contact, rejectedVsSubmittedPMConfigs[0]); 
            OffshoreOnshoresendEmail(rejectedVsSubmittedPMConfigs[0]);
        }
    }
    
    //for mentor
    public static void sendEmail(Contact contact, PM_Configure__c pmConfig) {
        
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply.grid@cloudperitus.com' LIMIT 1];
        Id templateIdOfReject = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Notifying_Mentor_On_Project_Manager_Declining_The_Feedback_Request'].Id;
        Id templateIdOfSubmit = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Notifying_Mentor_On_Feedback_Submission'].Id;
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.setOrgWideEmailAddressId(owea.Id);
        message.setToAddresses(new String[] { contact.Email });
        
        if (pmConfig.Status__c == 'Rejected') {
            message.setTemplateId(templateIdOfReject);
        } else if (pmConfig.Status__c == 'Submitted'){
            message.setTemplateId(templateIdOfSubmit);
        }
        
        message.setTargetObjectId(contact.Id); 
        message.setWhatId(pmConfig.Id); 
        message.setSaveAsActivity(true);
        
        Messaging.SendEmailResult result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message })[0];
        
        if (result.isSuccess()) {
            System.debug('Email sent successfully to: ' + contact.Email);
        } else {
            System.debug('Failed to send email to: ' + contact.Email + '. Error: ' + result.getErrors()[0].getMessage());
        }
    }
    
	//@sangharsh for offshore and onshore and other reporting manager
    public static void OffshoreOnshoresendEmail(PM_Configure__c pmConfig) {
        
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply.grid@cloudperitus.com' LIMIT 1];
        Id templateIdOfReject = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Notifying_Project_Manager_Others_On_their_Declining_The_Feedback_Request'].Id;
        Id templateIdOfSubmit = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Notifying_PM_other_On_Feedback_Submission'].Id;
        Set<Id> reportingContactId = new Set<Id>();
        
        if(pmConfig.Reporting_Contact__c != NULL){
            reportingContactId.add(pmConfig.Reporting_Contact__c);
        }
        
        Contact cont = [SELECT Id, Name, Email FROM Contact WHERE Id IN :reportingContactId LIMIT 1];
       
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.setOrgWideEmailAddressId(owea.Id);
        message.setToAddresses(new String[] { cont.Email });
        
        if (pmConfig.Status__c == 'Rejected') {
            message.setTemplateId(templateIdOfReject);
        } else if (pmConfig.Status__c == 'Submitted'){
            message.setTemplateId(templateIdOfSubmit);
        }
        
        message.setTargetObjectId(cont.Id); 
        message.setWhatId(pmConfig.Id); 
        message.setSaveAsActivity(true);
        
        Messaging.SendEmailResult result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message })[0];
        
        if (result.isSuccess()) {
            System.debug('Email sent successfully to: ' + cont.Email);
        } else {
            System.debug('Failed to send email to: ' + cont.Email + '. Error: ' + result.getErrors()[0].getMessage());
        }
    }
}