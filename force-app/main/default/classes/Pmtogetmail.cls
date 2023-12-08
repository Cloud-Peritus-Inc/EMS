public class Pmtogetmail {
    
    @AuraEnabled
    public static void getemails(Id conId,Id Leaveid){
  /*      
        contact con=[select id,lastname,EMS_TM_User__c from contact where id =:conId];
        
        list<string> emaillist=new list<string>();
        list<EMS_TM_Assignment__c> assignment=[select EMS_TM_ProjectName_Asgn__c, EMS_TM_ProjectName_Asgn__r.Project_Manager__r.Email, EMS_TM_EmployeeName__c,EMS_TM_Status_Asgn__c from EMS_TM_Assignment__c where EMS_TM_Status_Asgn__c = 'Active' AND EMS_TM_ProjectName_Asgn__r.Type_Of_Project__c!='Global Projects' AND EMS_TM_EmployeeName__c=:conId];
        for(EMS_TM_Assignment__c assign:assignment){
            emaillist.add(assign.EMS_TM_ProjectName_Asgn__r.Project_Manager__r.Email);
        }
        system.debug('email======================================================='+emaillist);
        system.debug('email size()======================================================='+emaillist.size());
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();  
          message.setTargetObjectId(con.Id);
        message.setSenderDisplayName('Grid');
        message.setReplyTo('no-reply@Grid.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName='PMtoGetEmployeeLeave'];
         message.setTemplateID(emailTemplate.Id);
        message.setWhatId(Leaveid); //This is important for the merge
          message.settoAddresses(emaillist);     
         Messaging.SingleEmailMessage[] messages = new    List<Messaging.SingleEmailMessage> {message};
             Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages);
       
          */    
               
        
    }
}
