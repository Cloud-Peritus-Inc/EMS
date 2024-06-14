global class EMS_TM_notifyManger implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
     
      string submittedStatus ='Submitted';
      String approvedStatus ='Approved';
      String soql ='SELECT Id, EMS_TM_Project__c, EMS_Timesheet__c, Assignment__c, Status__c, Week_Start_Date__c, Week_End_Date__c, EMS_TM_Week__c,createddate FROM EMS_TM_Timesheet_Record__c WHERE Status__c=:submittedStatus AND Status__c=:approvedStatus AND (createddate = This_week OR createddate = Last_week)';
      System.debug('soql'+soql);
      return Database.getQueryLocator(soql);
  }

  global void execute(Database.BatchableContext bc, List<EMS_TM_Timesheet_Record__c> timesheetrecordList) {
      
      Map<Id,List<EMS_TM_Timesheet_Record__c>> projectTimesheetRecMap = new Map<Id,List<EMS_TM_Timesheet_Record__c>>();
       Set<Id> userIds = new Set<Id>();
      for(EMS_TM_Timesheet_Record__c timesheetRec:timesheetrecordList){
          userIds.add(timesheetRec.OwnerId);
          if(timesheetRec.EMS_TM_Project__c != Null){
              if(projectTimesheetRecMap.containsKey(timesheetRec.EMS_TM_Project__c)){
                 projectTimesheetRecMap.get(timesheetRec.EMS_TM_Project__c).add(timesheetRec);
              }else{
                  projectTimesheetRecMap.put(timesheetRec.EMS_TM_Project__c,new List<EMS_TM_Timesheet_Record__c>{timesheetRec});
              }              
          }         
      }
      Map<Id,String> managerMailIds = new Map<Id,String>();
      Set<Id> projectManagerIds = new Set<Id>();
     
      for(EMS_TM_Project__c projectRec:[SELECT Id,
                                                Project_Manager__c,
                                                Project_Manager__r.email
                                                FROM EMS_TM_Project__c
                                                WHERE Id IN: projectTimesheetRecMap.keyset()
                                       			]){  
                                                    //projectManagerIds.add(projectRec.Project_Manager__c);
                                                 managerMailIds.put(projectRec.Id,projectRec.Project_Manager__r.email);            
                                                 
               }
      
      

       OrgWideEmailAddress emailid = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName ='Cloud Peritus'];
      List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
     List<Contact> employeeList = new List<Contact>();
      for(contact c: [SELECT Id, LastName,FirstName, Name, EMS_TM_User__c FROM Contact where EMS_TM_User__c IN:userIds]){
          employeeList.add(c);
      }
      System.debug('employeeList'+employeeList);
                 
          Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      //    mail.setToAddresses(toAddresses);
          mail.setOrgWideEmailAddressId(emailid.Id);
          mail.setSubject('Employee timesheets is overdue');
          String messageBody = '';
      messageBody += 'Dear Manager ,<br/>';
      messageBody +='<br/><table border="1" style="border-collapse: collapse"><caption><b>The weekly timesheets of the following employees are overdue:</b></caption><tr><th>EmployeeId</th><th>EmployeeName</th><th>Week</th></tr>';
      for(contact name : employeeList){
       //  date weekStartDate = notSubmittedData.get(name.EMS_TM_User__c).startweek__c;
        // date weekEndDate = notSubmittedData.get(name.EMS_TM_User__c).enddate__c;
     // messageBody += '<tr><td>' + name.EMS_RM_Employee_Id__c+ '</td><td>' + name.Name + '</td><td>' + weekStartDate +'-'+weekEndDate+ '</td>';
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