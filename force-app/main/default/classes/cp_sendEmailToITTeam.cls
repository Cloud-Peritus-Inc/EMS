/**
* @author Eswar
* @date 02/02/2023
* @description  Send email to IT team.
*
*               Test code coverage provided by the following test class:
*               - cp_sendEmailToITTeamTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class cp_sendEmailToITTeam implements TriggerAction.AfterUpdate{
    
/**
* @author Eswar Tangudu
* @date 3/28/2023
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
        //sendOnboardingFormMailAfterUpdate(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'CP_SendOnboardingFormMail.afterUpdate() : END');       
    }
    
    private void sendOnboardingFormMailAfterUpdate(List<Contact> contactList, Map<Id,Contact> oldMap){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        Group itGroup = [select Id,Name from Group where  Type = 'Queue' AND NAME = 'TA Team'];
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        
        List<Messaging.SingleEmailMessage> itMailList = new List<Messaging.SingleEmailMessage>();
        
        for(Contact contactRec : contactList){
            
            Date today = Date.today();
            Date sobjectDate = contactRec.EMS_EM_JD__c;
            
            if(contactRec.RecordTypeId == contRecordTypeId && contactRec.EMS_EM_JD__c != NULL && today.daysBetween(sobjectDate) < 10 && 
               contactRec.EMS_EM_JD__c >= system.today() && (oldMap.get(contactRec.Id).EMS_EM_JD__c == NULL && contactRec.EMS_EM_JD__c != NULL)){
                  
                
                Messaging.SingleEmailMessage message2 = sendEmailToITTeamForNewJoin(contactRec.Id);
                itMailList.add(message2);
                  
            }   
        }
        
        Messaging.sendEmail(itMailList);
        
   
    }
        
    public static Messaging.SingleEmailMessage sendEmailToITTeamForNewJoin(string recordId){
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Email To IT Team For Assets' LIMIT 1];
        String itEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'IT_Team' LIMIT 1].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> itEmailList = new List<String>();
        itEmailList.add(itEmail);
        
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();   
            mail.toAddresses = itEmailList;
            mail.setTemplateID(emailTemplate.Id);
            mail.setTargetObjectId(recordId);
            mail.setOrgWideEmailAddressId(fromEmail);
            mail.setTreatTargetObjectAsRecipient(false);
            mail.setSaveAsActivity(false);   
            return mail;
    }
}