global class EMS_TM_EmployeeEscalation implements Queueable {
    global void execute(QueueableContext cnt) {
        
        map<id,EMS_Timesheet__c> userMap = new map<id,EMS_Timesheet__c>();
        for(EMS_Timesheet__c timesheetRec : [SELECT Id, 
                                           OwnerId, 
                                           owner.name,
                                           owner.email,
                                           enddate__c, 
                                           startweek__c 
                                           FROM EMS_Timesheet__c 
                                           where createddate = this_week 
                                           AND EMS_TM_Status__c !='Submitted']){

                userMap.put(timesheetRec.OwnerId,timesheetRec);
            
        }
        List<Messaging.SingleEmailMessage> mailsList =  new List<Messaging.SingleEmailMessage>(); 
         EmailTemplate emailTemplate =[Select Id,
                                               Subject,
                                               Description,
                                               HtmlValue,
                                               DeveloperName,
                                               Body 
                                               FROM EmailTemplate
                                               WHERE name ='Escalation Email to Employee'];
        OrgWideEmailAddress emailid = [SELECT Id, 
                                               Address, 
                                               DisplayName 
                                               FROM OrgWideEmailAddress 
                                               WHERE DisplayName ='Cloud Peritus'];
              for(contact contactRec :[SELECT Id,
                                                 LastName,
                                                 FirstName, 
                                                 Official_Mail__c,
                                                 EMS_TM_USER__C FROM contact 
                                                  WHERE EMS_TM_USER__C =: userMap.keyset() 
                                                  AND Official_Mail__c != null
                                                  AND IsEmailBounced = false]){              
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();               
                mail.setToAddresses(new list<string>{contactRec.Official_Mail__c});                
                mail.setOrgWideEmailAddressId(emailid.Id);
                mail.setTemplateID(emailTemplate.Id);
                mail.setTargetObjectId(contactRec.id);
                mail.setSaveAsActivity(false);         
               // mail.setTreatTargetObjectAsRecipient(true);      
                System.debug('mail '+mail); 
                mailsList.add(mail);                           
        }
           System.debug('mailsList'+mailsList);
        System.debug('mailssize'+mailsList.size());
        Messaging.sendEmail(mailsList);
                     
}
}