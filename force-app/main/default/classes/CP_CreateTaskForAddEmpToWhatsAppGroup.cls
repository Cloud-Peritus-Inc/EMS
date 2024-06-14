/**
* @author Eswar
* @date 07/02/2023
* @description  This batch will run daily, on date of joining one task will create to add the new employee to company Whatsapp groups.

*               Test code coverage provided by the following test class:
*               - CP_CreateTaskForAddEmpToWhatsAppGroupTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class CP_CreateTaskForAddEmpToWhatsAppGroup implements Database.Batchable<sObject>, schedulable{
	
    public void execute(System.SchedulableContext sc){
        Database.executeBatch(new CP_CreateTaskForAddEmpToWhatsAppGroup());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date todayDate = System.today();
        return Database.getQueryLocator(
        	'SELECT id, EMS_EM_JD__c FROM Contact WHERE EMS_EM_JD__c =:todayDate AND RecordType.Name = \'Applicant\'' 
        );
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        Group itGroup = [select Id from Group where  Type = 'Queue' AND NAME = 'HR Team'];
        List<Task> tskList = new List<Task>();
        
        for(Contact contactRec : contactList){
            if(contactRec.EMS_EM_JD__c == System.today()){
                Task t = new Task();
                t.OwnerId = itGroup.Id;
                t.Subject = 'Add the new employee to company Whatsapp groups';
                t.Status = 'Open';
                t.Priority = 'Normal';
                t.IsReminderSet = true;
                t.WhoId = contactRec.Id;
                t.ActivityDate = contactRec.EMS_EM_JD__c;
                t.ReminderDateTime = DateTime.newInstance(contactRec.EMS_EM_JD__c.year(), contactRec.EMS_EM_JD__c.month(), contactRec.EMS_EM_JD__c.day(), 20, 00, 00);
                tskList.add(t);
            }
        }
        
        if(tskList!=null && tskList.size()>0){
            insert tskList;
        }
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
}