/**
* @author Mukesh Rawat
* @date 
* @description  this is batch class to post birthday message in Post
*            
*
*               Test code coverage provided by the following test class:
*               - BirthdayCheckerTest
*				
*				schedule Class
*				- BirthdayCheckerPST_sch
*				- BirthdayCheckerIST_sch
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class BirthdayChecker implements Database.Batchable<sObject> {
    private String workLocation;
    
    public BirthdayChecker(String workLocation) {
        this.workLocation = workLocation;
        system.debug('workLocation ----->' + workLocation);
    }
    public Database.QueryLocator start(Database.BatchableContext context) {
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
        return Database.getQueryLocator([
            SELECT Id, AccountId, Name, EMS_EM_DOB__c, Work_Location__c, EMS_RM_ApplicantStatus_Update__c
            FROM Contact
            WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID
            AND EMS_EM_DOB__c != null
            AND DAY_IN_MONTH(EMS_EM_DOB__c) = :dt.day()
            AND CALENDAR_MONTH(EMS_EM_DOB__c) = :dt.month()
            AND EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Notice Period', 'Active - Probation')
            AND AccountId != null AND Work_Location__r.Name =: workLocation
        ]);
    }
    
    public void execute(Database.BatchableContext context, List<Contact> scope) {
        
        List<FeedItem> feedItems = new List<FeedItem>();
        for (Contact c : scope) {
            String birthdayMessage = 'Happy Birthday ' + c.Name + '! We wish you a fantastic day filled with love and laughter.';
            
            FeedItem post = new FeedItem();
            post.ParentId = c.AccountId;
            post.Body = birthdayMessage;
            post.Visibility = 'AllUsers';
            
            feedItems.add(post);
        }
        insert feedItems;
    }
    public void finish(Database.BatchableContext context) {
        BatchToSendBirthdayWishes obj = new BatchToSendBirthdayWishes(workLocation);
        Database.executeBatch(obj);
    }
}