global class EMS_TM_EmployeeEscalation implements Schedulable {
    global void execute(SchedulableContext cnt) {

  list<EMS_Timesheet__c> listofNotSubimmetdData =[SELECT Id, OwnerId, owner.name,owner.email, Name, Submitted__c, createddate, EMS_TM_Status__c, EMS_TM_Total__c, enddate__c, startweek__c 
                 FROM EMS_Timesheet__c 
                 where createddate = this_week 
                 AND EMS_TM_Status__c !='Submitted'];
        map<id,EMS_Timesheet__c> userMap = new map<id,EMS_Timesheet__c>();
        for(EMS_Timesheet__c ee : listofNotSubimmetdData){
            if( ee.EMS_TM_Status__c != 'Submitted'){
                userMap.put(ee.OwnerId,ee);
            }
        }
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
         EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Escalation Email to Employee'];
        OrgWideEmailAddress emailid = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName ='Cloud Peritus'];
      //  List<string>  oficialMailIds = new List<string>(); 
     /*   for(user et :[SELECT Id, Username, LastName, FirstName, Email, IsActive FROM User 
                      where UserRole.name !='Leadership' 
                      AND id =: userMap.keyset()]){ */
              for(contact et :[SELECT Id,LastName, FirstName, Official_Mail__c,EMS_TM_USER__C FROM contact 
                      where  
                      EMS_TM_USER__C =: userMap.keyset() 
                      and Official_Mail__c != null
                      and IsEmailBounced = false]){              
                          
               // oficialMailIds.add(et.email);   
               // System.debug('oficialMailIds'+oficialMailIds);
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                
                mail.setToAddresses(new list<string>{et.Official_Mail__c});
                
                mail.setOrgWideEmailAddressId(emailid.Id);
                mail.setTemplateID(emailTemplate.Id);
                mail.setTargetObjectId(et.id);
                mail.setSaveAsActivity(false);         
               // mail.setTreatTargetObjectAsRecipient(true);      
                System.debug('mail '+mail); 
                mails.add(mail);
                
            
        }
           System.debug('mails'+mails);
        System.debug('mailssize'+mails.size());
        Messaging.sendEmail(mails);
        
             
}
}