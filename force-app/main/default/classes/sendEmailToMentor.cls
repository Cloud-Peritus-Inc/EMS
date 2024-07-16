/**
* @author Ravitheja
* @date 15/07/2024
* @description Send the email to mentor if the KRA has been rejected by Project Manager
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
        sendRejectionEmailToMentor(newList,new Map<Id,PM_Configure__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : END');       
    }
    
    public static void sendRejectionEmailToMentor(List<PM_Configure__c> newlist, Map<Id, PM_Configure__c> oldMap) {
        
        Set<Id> resourceId = new Set<Id>();
        Set<Id> reporteeId = new Set<Id>();
        List<PM_Configure__c> rejectedVsSubmittedPMConfigs = new List<PM_Configure__c>();
        Map<Id, PM_Configure__c> kraToPmConfigMap = new Map<Id, PM_Configure__c>();
        
        for (PM_Configure__c pmConfig : newlist) {
            
            if ((pmConfig.Status__c == 'Rejected' || pmConfig.Status__c == 'Submitted') 
                && pmConfig.Status__c != oldMap.get(pmConfig.Id).Status__c 
                && pmConfig.KRA__c != null) {
                    
                if (!kraToPmConfigMap.containsKey(pmConfig.KRA__c)) {
                     kraToPmConfigMap.put(pmConfig.KRA__c, pmConfig);
                     rejectedVsSubmittedPMConfigs.add(pmConfig);
                }
            }
        }
        
        for (Goal__c gl : [SELECT Id, Name, Resource__c FROM Goal__c WHERE Id IN :kraToPmConfigMap.keySet() AND Resource__c != NULL LIMIT 1]) {
            
            resourceId.add(gl.Resource__c);
        }
        
        for (Resource_Resource_Relationship__c rrr : [SELECT Id, Resource__c, Resource_Reports_To__c 
                                                      FROM Resource_Resource_Relationship__c 
                                                      WHERE Resource__c IN :resourceId 
                                                      AND Resource__c != NULL
                                                      AND Relationship_Type__c = 'Mentor'
                                                      AND Resource_Reports_To__c != NULL]){    
                                                          
                                                          reporteeId.add(rrr.Resource_Reports_To__c);
                                                      }
        
        List<Contact> conList = [SELECT Id, Name, Email FROM Contact WHERE Id IN :reporteeId LIMIT 1];
        
        sendEmail(conList, rejectedVsSubmittedPMConfigs);
    }
    
    
    public static void sendEmail(List<Contact> conList, List<PM_Configure__c> pmConfigList){
        
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply.grid@cloudperitus.com'];
        Id templateIdOfReject = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Notifying_Mentor_On_Project_Manager_Declining_The_Feedback_Request'].Id;
        Id templateIdOfSubmit = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Notifying_Mentor_On_Feedback_Submission'].Id;
        
        for (Contact con : conList){
            
            for (PM_Configure__c pmConfig : pmConfigList) {
                
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(new String[] { con.Email });
                message.setOrgWideEmailAddressId(owea[0].Id);
                
                if(pmConfig.Status__c == 'Rejected'){
                    message.setTemplateId(templateIdofReject);
                }else{
                    message.setTemplateId(templateIdOfSubmit);
                }
                
                message.setTargetObjectId(con.Id); 
                message.setWhatId(pmConfig.Id); 
                message.setSaveAsActivity(true);
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
                
                for (Messaging.SendEmailResult result : results) {
                    
                    if (result.isSuccess()) {
                        System.debug('Email sent successfully to: ' + con.Email);
                    } else {
                        System.debug('Failed to send email to: ' + con.Email + '. Error: ' + result.getErrors()[0].getMessage());
                    }
                }
            }
        }
    }
}