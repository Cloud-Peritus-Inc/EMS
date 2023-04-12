public class CP_SendServiceRequestEmailToHR implements TriggerAction.AfterInsert{

    public void afterInsert(List<Case> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterInsert() : BEGIN');
         sendemailtoHRonMaternityLeave(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterInsert() : END');       
     }
    
    private void sendemailtoHRonMaternityLeave(List<Case> caselist){
        
        Set<Id> conIds = new Set<Id>();
         for (Case c: caselist) {
        conIds.add(c.ContactId);
    }
    Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id In :conIds]);
        
        //List<case> newcaselist = new List<case>();
      
        for(Case caseRec : caselist){
            if(caseRec.Request_Sub_Type__c =='Maternity' && caseRec.Request_Sub_Type__c !=NULL && caseRec.Type == 'Special Leaves'){
               
                string contactids = caseRec.ContactId;
              //  sendEmailToHR(contactids);
            }
            
}
 }
     public static void sendEmailToHR(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='When an employee raises special leave request - Maternity' LIMIT 1];        
        String hrTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> hrEmailList = new List<String>();
        hrEmailList.add(hrTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = hrEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setOrgWideEmailAddressId(fromEmail);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }

}