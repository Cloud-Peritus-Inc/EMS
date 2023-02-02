/**
* @author Eswar
* @date 02/02/2023
* @description  This class is for if DOJ less than 10days then on which date DOJ is updated on that day itself create onboarding record as well as send 
				email with onboarding form.
*
*               Test code coverage provided by the following test class:
*               - CP_SendOnboardingFormMailTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_SendOnboardingFormMail implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{
    /**
    * @author Eswar
    * @date 02/02/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
	public void afterInsert(List<Contact> newList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterInsert() : BEGIN');
         sendOnboardingFormMail(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterInsert() : END');       
     }
    
    /**
    * @author Eswar
    * @date 02/02/2023
    * @description After Update
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    
    public void afterUpdate(List<Contact> newList, List<Contact> oldList) {      
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterUpdate() : BEGIN');
         sendOnboardingFormMail(newList);
         System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterUpdate() : END');       
     }
    
    private void sendOnboardingFormMail(List<Contact> contactList){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        
        for(Contact contactRec : contactList){
        
            if(contactRec.EMS_EM_JD__c != NULL && contactRec.RecordTypeId == '0125e000000qrLRAAY'){
                Date today = Date.today();
                Date sobjectDate = contactRec.EMS_EM_JD__c;
                if(today.daysBetween(sobjectDate) < 10){
                    EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                    applicantRec.EMS_EM_Personal_Email__c = contactRec.Email;
                    applicantRec.Date_of_Joining__c = contactRec.EMS_EM_JD__c;
                    applicantsList.add(applicantRec);
                    sendOnboardingEmail(contactRec.Email,contactRec.Id);    
                }
            }   
        }
        insert applicantsList;
    }
    
    public static String sendOnboardingEmail(String email,string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Onboarding Form Email' LIMIT 1];
        List<string> emailList = new List<string>();
        emailList.add(email);
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        if (results[0].success) {
            return 'success';
        } else {
            return 'failure';
        }
    }
}