/**
* @author Jaswanthi Maganti/Mukesh Rawat
* @date 20/03/2023
* @description  BatchToSendBirthdayWishes Batch to send Wishes 
*              @Mukesh
*   			Schedule/Calling this batch class from BirthdayChecker Batch
*
*               Test code coverage provided by the following test class:
*               - BatchToSendBirthdayWishesTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================

**/

global class BatchToSendBirthdayWishes implements Database.Batchable<sObject>{
    //@Mukesh Date: 23/04/2024
	//Defect no. UAT_081
	//passing workLocation from BirthdayChecker Class for location Based scheduled
    private String workLocation;
    
    public BatchToSendBirthdayWishes(String workLocation) {
        this.workLocation = workLocation;
        system.debug('workLocation In BatchToSendBirthdayWishes ----->' + workLocation);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date dt = Date.today();
        Datetime dtGMT = System.now();
        //Convert it into Indian Standard Time(dtIST).
        String dtIST = dtGMT.format('yyyy-MM-dd HH:mm:ss', 'IST');
        If(workLocation == 'Hyderabad - India'){
            // Convert IST datetime string to Date data type
           	dt = Date.valueOf(dtIST);
        }else if(workLocation == 'California - USA'){
            dt = Date.today();
        }
        
        return Database.getQueryLocator([SELECT Id,Name,Email,EMS_EM_DOB__c 
                                         FROM CONTACT WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID
                                         AND Email != NULL 
                                         AND EMS_EM_DOB__c!= NULL 
                                         AND DAY_IN_MONTH(EMS_EM_DOB__c) =:dt.day() 
                                         AND CALENDAR_MONTH(EMS_EM_DOB__c) =:dt.month()
                                         AND EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Notice Period', 'Active - Probation')
                                         AND AccountId != null AND Work_Location__r.Name =: workLocation
                                        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<EmailTemplate> templateId = new List<EmailTemplate>();
        templateId = [SELECT id FROM EmailTemplate WHERE developername LIKE 'Birthday_Emails_%'];
        Integer randomNumber = templateId.size();
        Integer randomId = 0;
        String fromEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where DisplayName = 'Grid'].Id;
        
        for(Contact contactRec : conList){
            randomId = Integer.valueOf(Math.random()*randomNumber);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // Who you are sending the email to
            mail.setTargetObjectId(contactRec.id);
            // The email template ID used for the email
            mail.setTemplateId(templateId[randomId].id);
            mail.setBccSender(false);
            mail.setUseSignature(false);
            
            mail.setOrgWideEmailAddressId(fromEmail);
            mail.setSaveAsActivity(false); 
            mails.add(mail);
        }
        if(mails.size() > 0){
            Messaging.sendEmail(mails);
        }
    }  
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}