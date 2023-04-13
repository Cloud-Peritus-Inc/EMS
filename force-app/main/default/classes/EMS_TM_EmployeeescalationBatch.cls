/**
* @author Ramakrishna Papana
* @date 27/02/2023
* @description  Schedule class to schedule EMS_TM_EmployeeescalationBatch
*              
*                 Schedule class 
*               - EMS_TM_EmployeeescalationBatch_Sch
*               Test code coverage provided by the following test class:
*               - EMS_TM_EmployeeescalationBatch_test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class EMS_TM_EmployeeescalationBatch implements Database.Batchable<sObject>{
    
    /**
* @author Ramakrishna
* @date 27/02/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/ 
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        String submitted ='Submitted';
        String soql ='SELECT Id, OwnerId, owner.name,owner.email,enddate__c, startweek__c FROM EMS_Timesheet__c where EMS_TM_Status__c !=:submitted AND (createddate = This_week OR createddate = Last_week)';
        System.debug('soql'+soql);
        return Database.getQueryLocator(soql);
    }
    
    /**
* @author Ramakrishna
* @date 27/02/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
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
                                         Email,
                                         EMS_TM_USER__C FROM contact 
                                         WHERE EMS_TM_USER__C =: userMap.keyset() 
                                         AND Email != null
                                         AND IsEmailBounced = false]){              
                                             Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();               
                                             mail.setToAddresses(new list<string>{contactRec.Email});                
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
        try{
        Messaging.sendEmail(mailsList);
        }catch(Exception e){
            
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
    
}