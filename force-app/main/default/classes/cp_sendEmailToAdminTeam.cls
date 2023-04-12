/**
* @author Eswar
* @date 02/02/2023
* @description  Send email to admin team.
*
*               Test code coverage provided by the following test class:
*               - cp_sendEmailToAdminTeamTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class cp_sendEmailToAdminTeam implements TriggerAction.AfterUpdate{
    
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
        List<Messaging.SingleEmailMessage> adminMailList = new List<Messaging.SingleEmailMessage>();
        
        for(Contact contactRec : contactList){
            
            Date today = Date.today();
            Date sobjectDate = contactRec.EMS_EM_JD__c;

            if(contactRec.RecordTypeId == contRecordTypeId && contactRec.EMS_EM_JD__c != NULL && today.daysBetween(sobjectDate) < 10 && 
               contactRec.EMS_EM_JD__c >= system.today() && (oldMap.get(contactRec.Id).EMS_EM_JD__c == NULL && contactRec.EMS_EM_JD__c != NULL)){
                  
                
                Messaging.SingleEmailMessage message1 = sendEmailToAdminTeam(contactRec.Id);
                adminMailList.add(message1);
                
                  
            }   
        }
        
        if(!Test.isRunningTest()){
            Messaging.sendEmail(adminMailList);
        }
        
        System.debug('adminMailList' + adminMailList.size());
    }
    
    

    public static Messaging.SingleEmailMessage sendEmailToAdminTeam(string recordId){
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted Admin' LIMIT 1];
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<String> adminEmailList = new List<String>();
        adminEmailList.add(taTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = adminEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setOrgWideEmailAddressId(fromEmail);
        message.setSaveAsActivity(false);
        return message;
    }
    
    
}