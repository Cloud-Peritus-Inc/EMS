global class EMS_TM_EmployeeescalationScheduleBatch implements Database.Batchable<sObject>,schedulable{

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
     
      String submitted ='Submitted';
      String soql ='SELECT Id, OwnerId, owner.name,owner.email,enddate__c, startweek__c FROM EMS_Timesheet__c where EMS_TM_Status__c !=:submitted AND (createddate = This_week OR createddate = Last_week)';
      System.debug('soql'+soql);
      return Database.getQueryLocator(soql);
  }

  global void execute(Database.BatchableContext bc, List<EMS_Timesheet__c> timesheetList) {
      System.debug('timesheetList'+timesheetList);
        
        map<id,EMS_Timesheet__c> userMap = new map<id,EMS_Timesheet__c>();
        for(EMS_Timesheet__c timesheetRec : timesheetList){
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
                                               WHERE name ='Escalation Mail Send To Employee'];
        OrgWideEmailAddress emailid = [SELECT Id, 
                                               Address, 
                                               DisplayName 
                                               FROM OrgWideEmailAddress 
                                               WHERE DisplayName ='Grid'];
              for(contact contactRec :[SELECT Id,
                                                 LastName,
                                                 FirstName, 
                                                 Official_Mail__c,
                                                 EMS_TM_USER__C FROM contact 
                                                  WHERE EMS_TM_USER__C =: userMap.keyset() 
                                                  AND Email != null
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

  global void finish(Database.BatchableContext bc) {
      
  }
    global void execute(SchedulableContext SC) {
 	database.executebatch(new EMS_TM_EmployeeescalationScheduleBatch());
    }

}