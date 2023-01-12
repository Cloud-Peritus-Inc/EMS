global class EMS_TM_notifyManger implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
     
      string submitted ='Submitted';
      String soql ='SELECT Id, OwnerId, Submitted__c,startweek__c, enddate__c,User__c, Name, EMS_TM_Status__c, Assignment__c,user__r.contactId FROM EMS_Timesheet__c WHERE EMS_TM_Status__c != : submitted AND CreatedDate = THIS_WEEK';
      System.debug('soql'+soql);
      return Database.getQueryLocator(soql);
  }

  global void execute(Database.BatchableContext bc, List<EMS_Timesheet__c> recs) {
       List<String> toAddresses = new List<String>();
      for(contact c:[SELECT Id, AccountId, LastName, FirstName, EMS_RM_Current_Job_Role__c, Official_Mail__c FROM Contact 
                     where EMS_RM_Current_Job_Role__c= 'Senior Project Manager - Salesforce']){
                         if (c.Official_Mail__c != null){
                            toAddresses.add(c.Official_Mail__c); 
                             System.debug('ofc'+c.Official_Mail__c);
                         }
                     }
      System.debug('recs'+recs);
      System.debug('size'+ recs.size());
       OrgWideEmailAddress emailid = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName ='Cloud Peritus'];
     // List<String> toAddresses = new List<String>{'viswanath.malayathi@cloudperitus.com'}; 
          System.debug('toaddress'+ toaddresses);
      List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
      set<id> contactIds = new set<id>();
      Map<id, EMS_Timesheet__c> notSubmittedData = new Map<id, EMS_Timesheet__c>();
      System.debug('notSubmittedDataSIZE'+notSubmittedData.size());
      for(EMS_Timesheet__c m : recs) {
          if(m.EMS_TM_Status__c != 'Submitted'){
             contactIds.add(m.OwnerId);  
              notSubmittedData.put(m.OwnerId,m);
          }
          
      }
      
      System.debug('contactIds'+contactIds);
     list<Contact> employeeList = new list<Contact>();
      for(contact c: [SELECT Id, LastName,FirstName, Name, EMS_TM_User__c FROM Contact where EMS_TM_User__c IN:notSubmittedData.keyset()]){
          employeeList.add(c);
      }
      System.debug('employeeList'+employeeList);
                 
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         // toAddresses.add(m);
          mail.setToAddresses(toAddresses);
          mail.setOrgWideEmailAddressId(emailid.Id);
          mail.setSubject('Employee timesheets is overdue');
          String messageBody = '';
 //     Dear [Manager's First Name],

      messageBody += 'Dear Manager ,<br/>';
      messageBody +='<br/><table border="1" style="border-collapse: collapse"><caption><b>The weekly timesheets of the following employees are overdue:</b></caption><tr><th>EmployeeId</th><th>EmployeeName</th><th>Week</th></tr>';
      for(contact name : employeeList){
         date weekStartDate = notSubmittedData.get(name.EMS_TM_User__c).startweek__c;
         date weekEndDate = notSubmittedData.get(name.EMS_TM_User__c).enddate__c;
    //  messageBody += '<tr><td>' + name.EMS_RM_Employee_Id__c+ '</td><td>' + name.Name + '</td><td>' + weekStartDate +'-'+weekEndDate+ '</td>';
      }
      
      messageBody += '</table> <br/><br/>';
      
      messageBody +='Regards, <br/>';
      messageBody +='HR Compliance <br/><br/>';
      messageBody +='This is an automatically generated e-mail. Please do not reply.';

          mail.setHtmlBody(messageBody);
          mailList.add(mail);         
      
      Messaging.sendEmail(mailList);
  }

  global void finish(Database.BatchableContext bc) {
  }

}