public class timesheettestingapprovestatus {
    /*set<Id> Timesheetid=new set<Id>();
    Map<Id,string> resourcemangermap=new map<Id,string>();
    set<Id> contactid=new set<Id>();
     Map<Id,EMS_TM_Timesheet_Record__c> projectRecMap = new Map<Id,EMS_TM_Timesheet_Record__c>();
    Map<Id,EMS_TM_Timesheet_Record__c> timesheetrecmap = new Map<Id,EMS_TM_Timesheet_Record__c>();
    set<Id> timesheetrecordId=new set<Id>();
private void timesheetRecAutoUpdate(List<EMS_TM_Timesheet_Record__c> newTimeSheetList,Map<Id,EMS_TM_Timesheet_Record__c> oldMap){
      for(EMS_TM_Timesheet_Record__c timesheetRec: newTimeSheetList){
            if((oldMap != null && oldMap.get(timesheetRec.Id).Status__c != timesheetRec.Status__c && timesheetRec.Status__c != 'Saved' && timesheetRec.Status__c != 'Approved'  && timesheetRec.Status__c !='Rejected' && timesheetRec.Status__c != null ) || (oldmap ==null && timesheetRec.Status__c != 'Saved' && timesheetRec.Status__c != 'Approved'  && timesheetRec.Status__c !='Rejected' && timesheetRec.Status__c != null&&timesheetRec.EMS_TM_Project__c=='others' )){
                System.debug('If Passed');
                Timesheetid.add(timesheetRec.EMS_Timesheet__c);
                timesheetrecordId.add(timesheetRec.Id);
                projectRecMap.put(timesheetRec.EMS_TM_Project__c,timesheetRec); 
                timesheetrecmap.put(timesheetRec.EMS_Timesheet__r.Resource__c,timesheetRec);
               
            }           
        }
    for(EMS_Timesheet__c timesheet:[select id,Name,Resource__c,Resource__r.Resource_Manager__c from EMS_Timesheet__c where Id IN:Timesheetid]){
        contactid.add(timesheet.Resource__c);
    }
    for(contact con:[select id,name,Resource_Manager__r.Official_Mail__c from contact where Id IN:contactid]){
        resourcemangermap.put(con.Id,con.Resource_Manager__r.Official_Mail__c);
             Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(timesheetrecmap.get(con.Id).Id);
              //  System.debug('contactId'+timeSheetRecMap.get(contactRec.Id).Id+'>>>>>OwnerId'+timeSheetRecMap.get(contactRec.Id).OwnerId);
                req1.setSubmitterId(con.Id);
               // req1.setNextApproverIds(new Id[] {contactRec.EMS_TM_User__c});

                req1.setProcessDefinitionNameOrId('Timesheet_Records_Approval');
                req1.setSkipEntryCriteria(false);
                try{
               Approval.ProcessResult result = Approval.process(req1);
                     Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
                    message.setTargetObjectId(con.id);
                    message.setSenderDisplayName('Grid');
                     message.setReplyTo('no-reply.grid@cloudperitus.com');
                      message.setUseSignature(false);
                         message.setBccSender(false);
                         message.setSaveAsActivity(false);
       
   
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate];
                                 
                                 
                                
   //Get templete id for set the templete.

   message.setTemplateID(emailTemplate.Id);
   message.setWhatId(timesheetrecmap.get(con.Id).Id); //This is important for the merge
                                  
   message.toAddresses = new String[] {con.Resource_Manager__r.Official_Mail__c};

   Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
   

   Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages);
  
 
 if (results[0].success)
 {
   System.debug('The email was sent successfully.');
 }
 else
 {
   System.debug('The email failed to send:' +
   results[0].errors[0].message);
 }
                }catch(Exception e){
                    System.debug('timesheetRecordApprovalProcess'+e.getMessage()+e.getLineNumber());
                     LogException.logHandledException(e, 'timesheetRecordApprovalProcess', 'submitAndProcessApprovalRequest');
                }               
        
    }
}
    public class TimesheetTestingApproveStatus {
*/
    

    public void timesheetRecAutoUpdate(List<EMS_TM_Timesheet_Record__c> newTimeSheetList, Map<Id, EMS_TM_Timesheet_Record__c> oldMap) {
         Set<Id> timesheetIds = new Set<Id>();
        Map<Id, String> resourceManagerMap = new Map<Id, String>();
        Map<Id, EMS_TM_Timesheet_Record__c> timesheetRecMap = new Map<Id, EMS_TM_Timesheet_Record__c>();
        Set<Id> timesheetRecordIds = new Set<Id>();
        for (EMS_TM_Timesheet_Record__c timesheetRec : newTimeSheetList) {
            if ((oldMap != null && oldMap.get(timesheetRec.Id).Status__c != timesheetRec.Status__c && timesheetRec.Status__c != 'Saved' && timesheetRec.Status__c != 'Approved' && timesheetRec.Status__c != 'Rejected' && timesheetRec.Status__c != null) || (oldMap == null && timesheetRec.Status__c != 'Saved' && timesheetRec.Status__c != 'Approved' && timesheetRec.Status__c != 'Rejected' && timesheetRec.Status__c != null && timesheetRec.EMS_TM_Project__c == 'others')) {
                System.debug('If Passed');
                timesheetIds.add(timesheetRec.EMS_Timesheet__c);
                timesheetRecordIds.add(timesheetRec.Id);
                timesheetRecMap.put(timesheetRec.EMS_TM_Project__c, timesheetRec);
                timesheetRecMap.put(timesheetRec.EMS_Timesheet__r.Resource__c, timesheetRec);
            }
        }
        
        Map<Id, EMS_Timesheet__c> timesheetMap = new Map<Id, EMS_Timesheet__c>([SELECT Id, Name, Resource__c, Resource__r.Resource_Manager__c FROM EMS_Timesheet__c WHERE Id IN :timesheetIds]);
        for (EMS_Timesheet__c timesheet : timesheetMap.values()) {
            resourceManagerMap.put(timesheet.Resource__c, timesheet.Resource__r.Resource_Manager__c);
        }

        for (Contact con : [SELECT Id, Name, Resource_Manager__r.Official_Mail__c FROM Contact WHERE Id IN :resourceManagerMap.keySet()]) {
            String managerEmail = resourceManagerMap.get(con.Id);

            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setObjectId(timesheetRecMap.get(con.Id).Id);
            req.setSubmitterId(con.Id);
            req.setProcessDefinitionNameOrId('Timesheet_Records_Approval');
            req.setSkipEntryCriteria(false);

            try {
                Approval.ProcessResult result = Approval.process(req);

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(con.Id);
                message.setSenderDisplayName('Grid');
                message.setReplyTo('no-reply.grid@cloudperitus.com');
                message.setUseSignature(false);
                message.setBccSender(false);
                message.setSaveAsActivity(false);

                EmailTemplate emailTemplate = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate where Name='Timesheet Approval Aprocess Email to Reporing Manger'];

                message.setTemplateID(emailTemplate.Id);
                message.setWhatId(timesheetRecMap.get(con.Id).Id);
                message.setWhatId(con.Id);

                message.toAddresses = new String[] { managerEmail };

                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };

               Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages);
  
 
                  if (results[0].success)
                    {
                  System.debug('The email was sent successfully.');
                  }
                 else
                       {
                             System.debug('The email failed to send:' +
                                 results[0].errors[0].message);
                          }
                }catch(Exception e){
                    System.debug('timesheetRecordApprovalProcess'+e.getMessage()+e.getLineNumber());
                     LogException.logHandledException(e, 'timesheetRecordApprovalProcess', 'submitAndProcessApprovalRequest');
                }               
        
    }

}
        }