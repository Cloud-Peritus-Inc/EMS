/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  updateTheProbationPeriodOnResource Class to create the portal user
*
*               Test code coverage provided by the following test class:
*               - 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class updateTheProbationPeriodOnResource  implements TriggerAction.BeforeUpdate{
    
    /**
* @author Subba Kalavala
* @date 2/22/2023
* @description beforeUpdate
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeUpdate(List<Contact> newList, List<Contact> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'updateTheProbationPeriodOnResource.beforeUpdate() : BEGIN');
        updateTheProbationDate(newList,new Map<Id,Contact>(oldList));
        System.debug(LoggingLevel.DEBUG, 'updateTheProbationPeriodOnResource.beforeUpdate() : END');       
    }
     /**
*   {Purpose} - Method to create the users
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void updateTheProbationDate(List<Contact> newlist, Map<Id,Contact> oldMap) {
         List<Contact> filteredList = new List<Contact>();
         Set<Id> roleIds = new Set<Id>();
        Map<Id,decimal> roleWithDays = new Map<Id,decimal>();
        for(Contact con : newList){
            contact conold = oldMap.get(con.Id);
            if(con.RecordTypeId == ContactConstant.RESOURCE_RECORDTYPEID 
               && con.EMS_EM_JD__c != null && con.Resource_Role__c != null && (con.Resource_Role__c != conold.Resource_Role__c  || con.RecordTypeId != conold.RecordTypeId || con.EMS_EM_JD__c != conold.EMS_EM_JD__c ) ){
              filteredList.add(con);
              roleIds.add(con.Resource_Role__c);
            }
        }
        
        if(!roleIds.isEmpty()){
            for(Resource_Role__c rr : [SELECT Id,Probation_Days__c FROM Resource_Role__c WHERE Probation_Days__c != null AND Id IN:roleIds]){
               roleWithDays.put(rr.Id,rr.Probation_Days__c); 
            }
            for(Contact con : filteredList){
                if(roleWithDays.containsKey(con.Resource_Role__c)){
                   con.Probationary_Period_End_Date__c = con.EMS_EM_JD__c.adddays(integer.valueOf(roleWithDays.get(con.Resource_Role__c))); 
                }else{
                   con.Probationary_Period_End_Date__c = con.EMS_EM_JD__c.adddays(90);  
                } 
            }
        }
    }

}