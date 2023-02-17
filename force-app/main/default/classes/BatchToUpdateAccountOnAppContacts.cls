/**
* @author Subba Kalavala
* @date 2/10/2023
* @description  BatchToUpdateAccountOnAppContacts Batch to update the account and Owner Name.
*              
*               Schedule class 
*               - BatchToUpdateAccountOnAppContacts_SCH
*               Test code coverage provided by the following test class:
*               - BatchToUpdateAccountOnAppContacts_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global without sharing class BatchToUpdateAccountOnAppContacts implements Database.Batchable<sObject> {
 /**
* @author Subba
* @date 22/01/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,EMS_EM_JD__c,AccountId,OwnerId
                                         FROM CONTACT 
                                         WHERE Owner.UserType = 'CSPLitePortal'
                                         AND AccountId = null
                                         AND RecordTypeId =:ContactConstant.APPLICANT_RECORDTYPEID ]);
    }
  
/**
* @author Subba
* @date 22/01/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
         List<Contact> contactUpdate = new List<Contact>();
         List<Account> companyAccount = [SELECT Id,OwnerId FROM Account Where Name = 'Cloud Peritus Inc' LIMIT 1];
        if(companyAccount.size() > 0){
            for(Contact conRec : conList){
                contactUpdate.add(new Contact(Id=conRec.Id,AccountId=companyAccount[0].Id,OwnerId=companyAccount[0].OwnerId));
            }
        }
         
       try{
            if(contactUpdate.size()>0){
                system.debug('===contactUpdate==='+contactUpdate);
                update contactUpdate;   
            }
        }
        Catch(Exception excp){
			LogException.logHandledException(excp, 'BatchToUpdateAccountOnAppContacts', 'execute');        
        } 
    }
    
/**
* @author Subba
* @date 22/01/2023
* @description process the failures.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void finish(Database.BatchableContext BC) {
        
    }

}