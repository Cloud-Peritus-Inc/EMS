/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  restrictDuplicateOffboardingRequests Class to restrict the duplicate resignations
*
*               Test code coverage provided by the following test class:
*               -restrictDuplicateOffboardingReqTest 
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
        List<string> caseReqSubTypeName = new List<string>();
        Map<Id, Case> caseWithExistingOffMap = new Map<Id, Case>();
        Map<String, String> requestSubTypeMap = new Map<String, String>{'Paternity' => 'Paternity Leave',
            'Maternity' => 'Maternity Leave',
            'Marriage' => 'Marriage Leave',
            'Bereavement' => 'Bereavement Leave'};
                
                for (Case cnew : newlist) {
                    contactIds.add(cnew.contactId);
                    caseReqSubTypeName.add(cnew.Request_Sub_Type__c);
                }
        List<String> excludedTypes = new List<String>{'Educational Details', 'Other', 'Problem','Compensatory Off'};
        for (Case exiCase : [SELECT Id, 
                             		Type, 
                             		ContactId, 
                             		Request_Sub_Type__c
                             FROM Case
                             WHERE ContactId IN :contactIds
                             AND Request_Sub_Type__c = :caseReqSubTypeName
                             AND Request_Sub_Type__c NOT IN :excludedTypes 
                             AND Status NOT IN ('Resignation Rejected', 'Closed')
                            ]) {
                                caseWithExistingOffMap.put(exiCase.ContactId, exiCase);
                            }
        
        for (Case cnew : newlist) {
            if (excludedTypes.contains(cnew.Request_Sub_Type__c)) {
            continue;
            }
            if (!requestSubTypeMap.containsKey(cnew.Request_Sub_Type__c) && cnew.Request_Sub_Type__c == 'Family/Dependent Information' && !cnew.Is_it_Dependant_Contact__c){
                System.debug('### here');
                List<Family_Information__c> existingFamilyInfo = [SELECT ID,
                                            							 Is_It_Emergency_Contact__c,
                                                                         Resource__c
                                             					  FROM Family_Information__c
                                                                  WHERE Is_It_Emergency_Contact__c = true
                                                                  AND Resource__c =: cnew.ContactId
                                                                  ];

                if (existingFamilyInfo.size()>=1) {
                   cnew.addError('Only one emergency contact allowed at a time.'); 
                }
            }	
            if (caseWithExistingOffMap.containsKey(cnew.ContactId) && !requestSubTypeMap.containsKey(cnew.Request_Sub_Type__c)) {
                cnew.addError('Only one request allowed at a time. Seems there is an already existing ' + cnew.Request_Sub_Type__c  + ' request is In-Progress or Closed.');
            } else if (requestSubTypeMap.containsKey(cnew.Request_Sub_Type__c)) {
                Date currentDate = Date.today();
                String requestSubTypeName = requestSubTypeMap.get(cnew.Request_Sub_Type__c);
                List<EMS_LM_Leave_History__c> existingRequests = [SELECT Id, 
                                                                  		 EMS_LM_Leave_Start_Date__c, 
                                                                  		 EMS_LM_Contact__c
                                                           FROM EMS_LM_Leave_History__c
                                                           WHERE EMS_LM_Contact__c = :cnew.ContactId
                                                           AND EMS_LM_Leave_Type__r.Name = :requestSubTypeName
                                                           AND EMS_LM_Leave_Start_Date__c >= :System.now().addYears(-1).date()];
                if (!existingRequests.isEmpty()) {
                    cnew.addError('Only one ' + cnew.Request_Sub_Type__c + ' request is allowed within a year from the previous request.');
                }
            }
        }
    }
    
}