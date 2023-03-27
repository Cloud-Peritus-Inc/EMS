/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  restrictDuplicateOffboardingRequests Class to restrict the duplicate resignations
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
public class restrictDuplicateOffboardingRequests implements TriggerAction.BeforeInsert {
    /**
* @author Subba Kalavala
* @date 2/22/2023
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<Case> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictDuplicateOffboardingRequests.beforeInsert() : BEGIN');
        restrictTheResign(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictDuplicateOffboardingRequests.beforeInsert() : END');       
    }
    
    
    /**
*   {Purpose} - Method to restrict the same date leaves 
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void restrictTheResign(List<Case> newlist) {
         Set<Id> contactIds = new Set<Id>();
         Map<Id,Case> caseWithExistingOffMap = new Map<Id,Case>(); 
         for (Case cnew : newlist) {
            contactIds.add(cnew.contactId);
         }
        
        for(Case exiCase :[SELECT Id,Type,ContactId 
                          FROM Case 
                          WHERE ContactId IN :contactIds 
                          AND Type = 'Resignation'
                          AND Status NOT IN ('Resignation Rejected','Closed')
                          ]){
            caseWithExistingOffMap.put(exiCase.contactId,exiCase);
        }
        
        for (Case cnew : newlist) {
            if(caseWithExistingOffMap.containsKey(cnew.ContactId)){
              cnew.addError('Only one request allowed at a time. Seems there is an already existing resignation request is In-Progress or Approved.');  
            }
        }
        
        
    }

}