public without sharing class sendEmailToPM implements TriggerAction.AfterUpdate {
    
    public void afterUpdate(List<EMS_TM_Assignment__c> newList, List<EMS_TM_Assignment__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : BEGIN');
        sendFeedbackEmailToPM(newList,new Map<Id,EMS_TM_Assignment__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'updateKraStatus.afterUpdate() : END');       
    }
    public static void sendFeedbackEmailToPM(List<EMS_TM_Assignment__c> newlist,Map<Id,EMS_TM_Assignment__c> oldMap){
        
        Boolean IsOffshore = false;
        Boolean IsOnshore = false;
        Boolean Isothers = false;
        Set<String> onShoreEmailSet = new Set<String>();
        Set<String> otherEmailSet = new Set<String>();
        Set<Id> emsAssgnSet = new Set<Id>();
        Set<String> EmailSet = new Set<String>();
        
        
        for(EMS_TM_Assignment__c projectassgn : newlist){
            emsAssgnSet.add(projectassgn.Id);
        }
        List<EMS_TM_Assignment__c> emsAssgnList = [SELECT Id,Name,
                                                   EMS_TM_ProjectName_Asgn__r.name,
                                                   EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,
                                                   EMS_TM_ProjectName_Asgn__r.Project_Manager__c,
                                                   Other_Resource_PM_Configure__c,
                                                   Onshore_PM_Configure__c,
                                                   Offshore_PM_Configure__c,
                                                   Other_PM_Configure__c,
                                                   EMS_TM_ProjectName_Asgn__r.Project_Manager__r.Email,
                                                   EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.Email,
                                                   Other_Resource_PM_Configure__r.Email
                                                   from EMS_TM_Assignment__c  where Id IN: emsAssgnSet];
        
        for(EMS_TM_Assignment__c assgnRec : emsAssgnList){
            if(assgnRec.Onshore_PM_Configure__c == True && assgnRec.Onshore_PM_Configure__c != oldMap.get(assgnRec.Id).Onshore_PM_Configure__c  ){ 
                EmailSet.add(assgnRec.EMS_TM_ProjectName_Asgn__r.Project_Manager__r.Email);
                IsOnshore = true;
                system.debug('onshore---'+EmailSet);
                sendEmail(EmailSet,assgnRec,IsOnshore,IsOffshore,Isothers);
                
            }
            if(assgnRec.Offshore_PM_Configure__c == True && assgnRec.Offshore_PM_Configure__c != oldMap.get(assgnRec.Id).Offshore_PM_Configure__c  ){ 
                EmailSet.Clear();
                IsOnshore = false;
                EmailSet.add(assgnRec.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.Email);
                IsOffshore = true;
                system.debug('ofshore---'+EmailSet);
                sendEmail(EmailSet,assgnRec,IsOnshore,IsOffshore,Isothers);
            }
            if(assgnRec.Other_PM_Configure__c == True && assgnRec.Other_PM_Configure__c != oldMap.get(assgnRec.Id).Other_PM_Configure__c){
                EmailSet.add(assgnRec.Other_Resource_PM_Configure__r.Email);
                Isothers = true;
                sendEmail(EmailSet,assgnRec,IsOnshore,IsOffshore,Isothers);
            }
            
        }
        
        // getEmailTemplates(onShoreEmailSet,offShoreEmailSet,otherEmailSet,IsOnshore,IsOffshore,Isothers);
        
        
    }
    
    Public Static Void sendEmail(Set<String> emailSet,EMS_TM_Assignment__c assgnRec,Boolean IsOnshore,Boolean IsOffshore,Boolean IsOthers){
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'no-reply.grid@cloudperitus.com'];
        Id templateId = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName ='Feeback_Request_to_Onshore_PM'].Id;
        Id offShoreTemplateId = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName ='Feeback_Request_to_Offshore_PM'].Id;
        Id othersTemplateId = [SELECT Id,Subject,Description,HtmlValue,DeveloperName,Body FROM EmailTemplate WHERE DeveloperName ='Feeback_Request_to_Others'].Id;

        List<String> cc =new List<String>(emailSet);
        system.debug('Email Address List---'+cc);
        if((String.isNotBlank(templateId) || String.isNotBlank(offShoreTemplateId) || String.isNotBlank(othersTemplateId)) && !cc.IsEmpty()){
            
            System.debug(' IN templateId ' + templateId );
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();           
            message.setToAddresses(cc);
            if(IsOnshore){
                system.debug('IsOnshore----'+IsOnshore);
                message.setTargetObjectId(assgnRec.EMS_TM_ProjectName_Asgn__r.Project_Manager__c);
                message.setTemplateId(templateId);
            }
            else if(IsOffshore){
                 system.debug('IsOffshore----'+IsOffshore);
                message.setTargetObjectId(assgnRec.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c);
                message.setTemplateId(offShoreTemplateId);
            }
            else If(IsOthers){
                message.setTargetObjectId(assgnRec.Other_Resource_PM_Configure__c);
                message.setTemplateId(othersTemplateId);
            }
            message.setWhatId(assgnRec.Id);
            message.setOrgWideEmailAddressId(owea.get(0).Id);
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