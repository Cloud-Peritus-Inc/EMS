/**
* @author Jaswanthi Maganti
* @date 20/03/2023
* @description  BatchToSendWorkAnniversaryEmail Batch to send Work Anniversary emails
*              
*               Schedule class 
*               - BatchToSendWorkAnniversaryEmail_sch
*               Test code coverage provided by the following test class
*               - BatchToSendWorkAnniversaryEmailTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================

**/

	global class BatchToSendWorkAnniversaryEmail  implements Database.Batchable<sObject>{
    
     	global Database.QueryLocator start(Database.BatchableContext BC) {
         
        date dt = system.today();
        
        return Database.getQueryLocator([SELECT Id,Name,Email,EMS_EM_JD__c 
                                         FROM CONTACT WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID
                                         AND Email != NULL AND EMS_EM_JD__c!= NULL AND DAY_IN_MONTH(EMS_EM_JD__c) =:dt.day() AND CALENDAR_MONTH(EMS_EM_JD__c) =:dt.month()
                                         AND CALENDAR_YEAR(EMS_EM_JD__c) != :dt.year() ]);
                                        
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templateId = new List<EmailTemplate>();
        templateId = [SELECT id FROM EmailTemplate WHERE developername LIKE 'Work_Anniversary_Emails_%'];
        Integer randomNumber = templateId.size();
        Integer randomId = 0;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;

        for(Contact contactRec : conList){
                
                randomId = Integer.valueOf(Math.random()*randomNumber);
            
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                // Who you are sending the email to
                
                mail.setTargetObjectId(contactRec.id);
                
                // The email template ID used for the email
                
                mail.setTemplateId(templateId[randomId].id);
                mail.setBccSender(false);
                mail.setUseSignature(false);
                
                mail.setOrgWideEmailAddressId(fromEmail);
        		mail.setSaveAsActivity(false); 
                mails.add(mail);
                
            
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails);
        }
    }  
    
    global void finish(Database.BatchableContext BC) {
        
    }
    

}