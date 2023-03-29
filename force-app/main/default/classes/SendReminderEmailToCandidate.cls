/**
* @author Eswar
* @date 29/03/2023
* @description  This batch will run daily, if any applicant havn't fill the pre onboarding form then reminder email should send. 
*
*               Test code coverage provided by the following test class:
*               - CP_ConvertContactToOnboardingTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class SendReminderEmailToCandidate implements Database.Batchable<sObject>, schedulable{
    
    public void execute(System.SchedulableContext sc){
    	Database.executeBatch(new SendReminderEmailToCandidate());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query for candidate records where onboarding is incomplete and DOJ is 3 days away
        return Database.getQueryLocator([
            SELECT Id, Date_of_Joining__c, EMS_EM_Personal_Email__c, Is_Confirm__c, 
                   CreatedDate, Reminder_Email_Sent__c, ContactId1__c
            FROM EMS_EM_Onboarding_Request__c
            WHERE Is_Confirm__c = false 
            AND Date_of_Joining__c = NEXT_N_DAYS:3
        ]);
    }

    public void execute(Database.BatchableContext bc, List<EMS_EM_Onboarding_Request__c> candidates) {
        
        List<Messaging.SingleEmailMessage> reminderMailsList = new List<Messaging.SingleEmailMessage>();
        
        for (EMS_EM_Onboarding_Request__c candidate : candidates) {
            // Check if candidate was added more than 3 days before DOJ
            if (candidate.CreatedDate < candidate.Date_of_Joining__c.addDays(-3)) {
                // Send reminder email
                if (!candidate.Reminder_Email_Sent__c) {
                    Messaging.SingleEmailMessage message = sendReminderEmail(candidate.ContactId1__c, candidate.EMS_EM_Personal_Email__c);
                    reminderMailsList.add(message);
                    candidate.Reminder_Email_Sent__c = true;
                }
            }
            // Check if candidate was added to portal with DOJ ≤ 3 days but more than 1 day
            else if (candidate.CreatedDate >= candidate.Date_of_Joining__c.addDays(-3) 
                     && candidate.CreatedDate < candidate.Date_of_Joining__c.addDays(-1)) {
                // Check if 12 hours have passed since record was created
                if (candidate.CreatedDate.addHours(12) < Datetime.now()) {
                    // Send reminder email
                    if (!candidate.Reminder_Email_Sent__c) {
                        Messaging.SingleEmailMessage message = sendReminderEmail(candidate.ContactId1__c, candidate.EMS_EM_Personal_Email__c);
                        reminderMailsList.add(message);
                        candidate.Reminder_Email_Sent__c = true;
                    }
                }
            }
        }
        Messaging.sendEmail(reminderMailsList);
        update candidates;
    }

    public void finish(Database.BatchableContext bc) {
    }

    // Method to send reminder email
    private Messaging.SingleEmailMessage sendReminderEmail(String recordId, String email) {
        
        EmailTemplate emailTemplate =[Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate
                                      where name ='Reminder Email To Candidate' LIMIT 1];
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        List<string> emailList = new List<string>();
        emailList.add(email);
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = emailList;
        message.setTemplateID(emailTemplate.Id);
        message.setTargetObjectId(recordId);
        message.setTreatTargetObjectAsRecipient(false);
        message.setOrgWideEmailAddressId(fromEmail);
        message.setSaveAsActivity(false);
        return message;
        
    }

}