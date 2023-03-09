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
public class CP_SendOnboardingFormMail implements TriggerAction.AfterInsert{
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
    
    private void sendOnboardingFormMail(List<Contact> contactList){
        
        List<EMS_EM_Onboarding_Request__c> applicantsList = new List<EMS_EM_Onboarding_Request__c>();
        List<Contact> applicantsToSendMail = new List<Contact>();
        Group itGroup = [select Id,Name from Group where  Type = 'Queue' AND NAME = 'TA Team'];
        Id contRecordTypeId = [Select id from RecordType where sObjectType = 'Contact' and developerName ='Applicant' ].id ;
        
        for(Contact contactRec : contactList){
            if(contactRec.RecordTypeId == contRecordTypeId){
                Date today = Date.today();
                Date sobjectDate = contactRec.EMS_EM_JD__c;
                
                EMS_EM_Onboarding_Request__c applicantRec = new EMS_EM_Onboarding_Request__c();
                applicantRec.EMS_EM_Personal_Email__c = contactRec.Personal_Email__c;
                applicantRec.ContactId1__c = contactRec.Id;
                applicantRec.EMS_EM_First_Name__c = contactRec.FirstName;
                applicantRec.EMS_EM_Last_Name__c = contactRec.LastName;
                applicantRec.Phone_Number__c = contactRec.EMS_Phone_Number__c;
                applicantRec.Status__c = 'Triggered';
                applicantsList.add(applicantRec);
                
                if(contactRec.EMS_EM_JD__c != NULL && today.daysBetween(sobjectDate) < 10 && contactRec.EMS_EM_JD__c >= system.today()){
                    sendEmailToHR(contactRec.Id);
                    sendEmailToAdminTeam(contactRec.Id);
                }
            }   
        }
        if(applicantsList.size() > 0){
            insert applicantsList;
        }

        List<ems_EM_Additional_Detail__c> additionalDetailsList = new List<ems_EM_Additional_Detail__c>();
        for(EMS_EM_Onboarding_Request__c onboardingRecords : applicantsList){
            ems_EM_Additional_Detail__c applicantRec = new ems_EM_Additional_Detail__c();
            applicantRec.Onboarding_Request__c = onboardingRecords.id;
            applicantRec.ContactId__c = onboardingRecords.ContactId1__c;
            additionalDetailsList.add(applicantRec);
        }
        insert additionalDetailsList;
    }
    
    public static void sendEmailToHR(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Notify To Hr After Onboarding Form Sent' LIMIT 1];        
        String hrTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team'].Email__c;
        List<String> hrEmailList = new List<String>();
        hrEmailList.add(hrTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = hrEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }

    public static void sendEmailToAdminTeam(string recordId){
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='After Applicant Record Inserted Admin' LIMIT 1];
        
        String taTeamEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'Admin_Team'].Email__c;
        List<String> adminEmailList = new List<String>();
        adminEmailList.add(taTeamEmail);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = adminEmailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setSaveAsActivity(false);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}