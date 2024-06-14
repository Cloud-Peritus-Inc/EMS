/**
* @author Subba
* @date 2/13/2023
* @description  updateTheEmergenyOnlyForOne Class to update only one emergency contact at any point of time.
*              
*
*               Test code coverage provided by the following test class:
*               - updateTheEmergenyOnlyForOneTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class updateTheEmergenyOnlyForOne implements TriggerAction.AfterInsert,TriggerAction.AfterUpdate{

/**
* @author Subba
* @date 2/13/2023
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterInsert(List<Family_Information__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'updateTheEmergenyOnlyForOne.afterInsert() : BEGIN');
        markEmergencyOnlyOneContact(newList,null);
        System.debug(LoggingLevel.DEBUG, 'updateTheEmergenyOnlyForOne.afterInsert() : END');       
    }
    
/**
* @author Subba
* @date 2/13/2023
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<Family_Information__c> newList, List<Family_Information__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'updateTheEmergenyOnlyForOne.afterInsert() : BEGIN');
        markEmergencyOnlyOneContact(newList,new Map<Id,Family_Information__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'updateTheEmergenyOnlyForOne.afterInsert() : END');       
    }
    /**
*   {Purpose} - Method for calculate available leave balance of the employee
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    private void markEmergencyOnlyOneContact(List<Family_Information__c> newList, Map<Id,Family_Information__c> oldMap){
        Map<Id,Family_Information__c> contactWithLatestEmerMap = new Map<Id,Family_Information__c>();
        for(Family_Information__c fiRec : newList){
            if(fiRec.Is_It_Emergency_Contact__c && (oldMap == null || oldMap.get(fiRec.Id).Is_It_Emergency_Contact__c != fiRec.Is_It_Emergency_Contact__c )){
              contactWithLatestEmerMap.put(fiRec.Resource__c,fiRec);  
            }  
        }
        
        List<Family_Information__c> updateFiRecList = new List<Family_Information__c>();
        for(contact conrec : [SELECT Id,(SELECT Id,Is_It_Emergency_Contact__c FROM Family_Informations__r) FROM Contact WHERE Id IN:contactWithLatestEmerMap.keySet()]){
            System.debug('List size => '+conrec.Family_Informations__r.size());
            if(conrec.Family_Informations__r.size()>0){
                for(Family_Information__c fi : conrec.Family_Informations__r){
                    if(fi.Is_It_Emergency_Contact__c && contactWithLatestEmerMap.get(conrec.Id).Id != fi.Id ){
                       updateFiRecList.add(new Family_Information__c(id=fi.Id,Is_It_Emergency_Contact__c=false)); 
                    }
                }
            }
        }
        
        try{
          update updateFiRecList;  
        }catch(exception ex){
           LogException.logHandledException(ex, 'updateTheEmergenyOnlyForOne', 'markEmergencyOnlyOneContact');  
        }
        
        
    }
    

}