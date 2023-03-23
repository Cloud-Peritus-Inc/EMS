/**
* @author Subba Kalavala
* @date 17/02/2023
* @description  restrictDuplicateApplicantRecords Class to restrict the duplicate applicats
*
*               Test code coverage provided by the following test class:
*               - contactTriggerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class restrictDuplicateApplicantRecords implements TriggerAction.BeforeInsert {
/**
* @author Subba Kalavala
* @date 10/01/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<Contact> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictDuplicateApplicantRecords.beforeInsert() : BEGIN');
        checkTheEmailofApplicant(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictDuplicateApplicantRecords.beforeInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to populate the approver details on leave request after insert 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    private void checkTheEmailofApplicant(List<Contact> newlist) {
        set<String> emailSet = new set<String>();
        List<Contact> filteredList = new List<contact>();
        for(Contact conRec : newlist){
            if(conRec.Personal_Email__c != null && conRec.RecordTypeId == ContactConstant.APPLICANT_RECORDTYPEID){
              filteredList.add(conRec); 
              emailSet.add(conRec.Personal_Email__c);
            }
        }
        if(!filteredList.isEmpty()){
            Map<String,String> existingConMap = new Map<String,String>();
            for(Contact conRec : [SELECT Id,Name,Personal_Email__c FROM Contact WHERE Personal_Email__c IN:emailSet]){
               existingConMap.put(conRec.Personal_Email__c,conRec.Name); 
            }
            for(Contact con : filteredList){
                if(existingConMap.containsKey(con.Personal_Email__c)){
                  con.addError('You are creating a duplicate record. We recommend you to use an existing record with contact as '+existingConMap.get(con.Id));  
                }
            }
        }
        
    }
}