/**
* @author Shubham Maske
* @date 03/Aug/2024
* @description : this trigger is used for sending email alerts to Project Managers/Other Managers when the requested PM CONFIG records are cancelled when MENTOR submits his own KRA PM ANSWER records 
* Test class : sendPmAnswerCancellationEmail_Test
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 
* ====================================================================================================
**/
// Test Class : sendPmAnswerCancellationEmail_Test
public class sendPmAnswerCancellationEmail implements TriggerAction.AfterUpdate {
    
    public void afterUpdate(List<PM_Configure__c> newList, List<PM_Configure__c> oldList) {  
        System.debug(LoggingLevel.DEBUG, 'sendPmAnswerCancellationEmail.afterUpdate() : BEGIN');
        getRecordCancellationEmailsData(newList, new Map<Id, PM_Configure__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'sendPmAnswerCancellationEmail.afterUpdate() : END');       
    }
    
    public static void getRecordCancellationEmailsData(List<PM_Configure__c> newList, Map<Id, PM_Configure__c> oldMap) {
        Id answerRecordTypeId = Schema.SObjectType.PM_Configure__c.getRecordTypeInfosByName().get('Answer').getRecordTypeId();
        
        Set<Id> pmConfigRecordIds = new Set<Id>();
        Map<String, List<PM_Configure__c>> projectPMConfigData = new Map<String, List<PM_Configure__c>>();
        Map<String, Map<String, List<PM_Configure__c>>> managerProjPmAnsRecMap = new Map<String, Map<String, List<PM_Configure__c>>>();
        
        
        for (PM_Configure__c pm : newList) {
            pmConfigRecordIds.add(pm.Id);
        }
        
        List<PM_Configure__c> cancelledRecords = [Select Id,RecordTypeId,Name,Status__c,Project_Name__c,Mentor__c,Mentee__c,Reporting_Contact__c,KRA__c,KRA__r.Status__c,
                                                  Mentor__r.Email,Mentee__r.Email,Reporting_Contact__r.Email
                                                  FROM PM_Configure__c 
                                                  WHERE Reporting_Contact__c != null
                                                  AND Project_Name__c != null
                                                  AND Status__c = 'Cancelled'
                                                  AND RecordTypeId =: answerRecordTypeId
                                                  AND KRA__r.Status__c = 'KRA Inreview'
                                                  AND Id IN :pmConfigRecordIds];
        
        System.debug('Total cancelledRecords size ' +  cancelledRecords.size());
        if(cancelledRecords.size() > 0 || !cancelledRecords.isEmpty()){
            
            for(PM_Configure__c pm : cancelledRecords){
                if (!projectPMConfigData.containsKey(pm.Project_Name__c)) {
                    projectPMConfigData.put(pm.Project_Name__c, new List<PM_Configure__c>());
                }
                projectPMConfigData.get(pm.Project_Name__c).add(pm);
            }
            System.debug('projectPMConfigData ' +  projectPMConfigData);
            System.debug('cancelledRecords ' +  cancelledRecords);
            System.debug('pmConfigRecordIds ' +  pmConfigRecordIds.size());
            
            
            for (String projName : projectPMConfigData.keySet()) {
                List<PM_Configure__c> pmConfigRecs = projectPMConfigData.get(projName);
                for (PM_Configure__c pmRec : pmConfigRecs) {
                    if (!managerProjPmAnsRecMap.containsKey(pmRec.Reporting_Contact__c)) {
                        managerProjPmAnsRecMap.put(pmRec.Reporting_Contact__c, new Map<String, List<PM_Configure__c>>());
                    }
                    if (!managerProjPmAnsRecMap.get(pmRec.Reporting_Contact__c).containsKey(projName)) {
                        managerProjPmAnsRecMap.get(pmRec.Reporting_Contact__c).put(projName, new List<PM_Configure__c>());
                    }
                    managerProjPmAnsRecMap.get(pmRec.Reporting_Contact__c).get(projName).add(pmRec);
                }
            }
            
            System.debug('#54 managerProjPmAnsRecMap keys ' +  managerProjPmAnsRecMap.keySet());
            System.debug('#55 managerProjPmAnsRecMap values' +  managerProjPmAnsRecMap.values());
            System.debug('#56 managerProjPmAnsRecMap map ' +  managerProjPmAnsRecMap.toString());
            sendEmail(managerProjPmAnsRecMap); 
        }
        
    }
    
    
    public static void sendEmail(Map<String, Map<String, List<PM_Configure__c>>> managerProjPmAnsRecMap) {
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'no-reply.grid@cloudperitus.com'];
        //smaske : [23/Aug/2024] : Commented below email alerts as we will not send them
        //Id templateIdForNotifyingMentee = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notifying_Mentee_On_Project_Manager_feedback_cancellation'].Id;
        //Id templateIdForNotifyingMentor = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notifying_Mentor_On_Project_Manager_feedback_cancellation'].Id;
        Id templateIdForNotifyingProjManager = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Notifying_Project_Manager_Other_On_Project_Manager_feedback_cancellation'].Id;
        
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
        
        //for templateIdForNotifyingProjManager       
        for (String managerId : managerProjPmAnsRecMap.keySet()) {
            Map<String, List<PM_Configure__c>> projectMap = managerProjPmAnsRecMap.get(managerId);
            for (String projectName : projectMap.keySet()) {
                List<PM_Configure__c> pmConfigRecs = projectMap.get(projectName);
                // Create a new email message for each project
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                Set<String> toAddresses = new Set<String>();
                for (PM_Configure__c pmConfigRec : pmConfigRecs) {               
                    toAddresses.add(pmConfigRec.Reporting_Contact__r.Email);
                    msg.setTargetObjectId(pmConfigRec.Reporting_Contact__c);
                    msg.setWhatId(pmConfigRec.Id);
                }
                msg.setToAddresses(new List<String>(toAddresses));
                msg.setOrgWideEmailAddressId(owea[0].Id); // Make sure 'owea' is properly defined
                msg.setTemplateId(templateIdForNotifyingProjManager); // Make sure 'templateIdForNotifyingProjManager' is properly defined
                msg.setSaveAsActivity(true);
                System.debug('ProjectManager  msg :: ' +  msg );
                emailListToSend.add(msg);
            }
        }
        
        /*for templateIdForNotifyingMentee       
        for (String managerId : managerProjPmAnsRecMap.keySet()) {
            Map<String, List<PM_Configure__c>> projectMap = managerProjPmAnsRecMap.get(managerId);
            for (String projectName : projectMap.keySet()) {
                List<PM_Configure__c> pmConfigRecs = projectMap.get(projectName);
                // Create a new email message for each project
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                Set<String> toAddresses = new Set<String>();
                for (PM_Configure__c pmConfigRec : pmConfigRecs) {               
                    toAddresses.add(pmConfigRec.Mentee__r.Email);
                    msg.setTargetObjectId(pmConfigRec.Mentee__c);
                    msg.setWhatId(pmConfigRec.Id);
                }
                msg.setToAddresses(new List<String>(toAddresses));
                msg.setOrgWideEmailAddressId(owea[0].Id); // Make sure 'owea' is properly defined
                msg.setTemplateId(templateIdForNotifyingMentee); // Make sure 'templateIdForNotifyingMentee' is properly defined
                msg.setSaveAsActivity(true);
                System.debug('Mentees  msg :: ' +  msg );
                emailListToSend.add(msg);
            }
        }
        
        
        for templateIdForNotifyingMentor       
        for (String managerId : managerProjPmAnsRecMap.keySet()) {
            Map<String, List<PM_Configure__c>> projectMap = managerProjPmAnsRecMap.get(managerId);
            for (String projectName : projectMap.keySet()) {
                List<PM_Configure__c> pmConfigRecs = projectMap.get(projectName);
                // Create a new email message for each project
                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                Set<String> toAddresses = new Set<String>();
                for (PM_Configure__c pmConfigRec : pmConfigRecs) {               
                    toAddresses.add(pmConfigRec.Mentor__r.Email);
                    msg.setTargetObjectId(pmConfigRec.Mentor__c);
                    msg.setWhatId(pmConfigRec.Id);
                }
                msg.setToAddresses(new List<String>(toAddresses));
                msg.setOrgWideEmailAddressId(owea[0].Id); // Make sure 'owea' is properly defined
                msg.setTemplateId(templateIdForNotifyingMentor); // Make sure 'templateIdForNotifyingMentor' is properly defined
                msg.setSaveAsActivity(true);
                System.debug('Mentors  msg :: ' +  msg );
                emailListToSend.add(msg);
            }
        }*/
        
        System.debug('emailListToSend size :: ' +  emailListToSend.size());
        System.debug('emailListToSend :: ' +  emailListToSend.toString() );
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailListToSend);
        for (Messaging.SendEmailResult result : results) {
            if (result.isSuccess()) {
                System.debug('Email sent successfully.');
            } else {
                System.debug('Failed to send email. Error: ' + result.getErrors()[0].getMessage());
            }
        }
    }
    
    
}