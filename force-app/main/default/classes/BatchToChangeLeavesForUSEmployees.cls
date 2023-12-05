global without sharing class BatchToChangeLeavesForUSEmployees implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id WORKLOCATION_USA_ID =[select Id, Name From Office_Location__c WHERE Name='California - USA' LIMIT 1].Id;
        return Database.getQueryLocator([SELECT Id,AccountId,EMS_LM_No_Of_Carry_Forward_Leaves__c, EMS_LM_No_Of_Leaves_Credit__c,
                                         EMS_LM_No_Of_Availble_Leaves__c, EMS_LM_No_Of_Available_Paternity_Leave__c,
                                         EMS_LM_No_Of_Available_Maternity_Leave__c, EMS_LM_No_Of_Available_Compensatory_Off__c,EMS_LM_No_Of_Utilized_Leaves__c,
                                         EMS_LM_No_Of_Available_Bereavement_Leave__c,EMS_EM_JD__c,Work_Location__c,Work_Location__r.name,EMS_Employee_Type__c
                                         FROM Contact WHERE RecordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID AND AccountId !=Null AND (EMS_RM_ApplicantStatus_Update__c ='Active' OR EMS_RM_ApplicantStatus_Update__c ='Active - Probation') AND
                                           Work_Location__c =:WORKLOCATION_USA_ID]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        List<Contact> contactsNeedToBeUpdateList=new List<Contact>();
        for(Contact conRec:conList){
            Integer monthsSinceJoin = conRec.EMS_EM_JD__c.monthsBetween(System.today());
            if(monthsSinceJoin>=24 && conRec.EMS_LM_No_Of_Availble_Leaves__c >0){
               conRec.EMS_LM_No_Of_Leaves_Credit__c=0;
                conRec.EMS_LM_No_Of_Utilized_Leaves__c=0;
            }
            contactsNeedToBeUpdateList.add(conRec);
        }
        database.update(contactsNeedToBeUpdateList,false);
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}