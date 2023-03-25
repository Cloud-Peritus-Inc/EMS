/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  AssignServiceRequests Class to assign case owners
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
public without sharing class AssignServiceRequests  implements TriggerAction.BeforeInsert{
    
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
        System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : BEGIN');
        assignTheOwnerToQueue(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictSameDateLeaves.beforeInsert() : END');       
    }
    
    
        /**
*   {Purpose} - Method to assign the service request
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    public void assignTheOwnerToQueue(List<Case> newlist) {
        Map<String,Id> queueMap = new Map<String,Id>();
        for(Group grp : [SELECT Id,Name FROM Group WHERE Type = 'Queue']){
            queueMap.put(grp.Name,grp.id);
        }
        
        for(Case cnew : newlist){
            if(cnew.Type != null){
                if(cnew.Type == 'Problem' || cnew.Type == 'Others'){
                    if(queueMap.containsKey('Grid Support')){
                      cnew.OwnerId =  queueMap.get('Grid Support'); 
                    } 
                }else if(cnew.Type == 'Change Of Details' || cnew.Type == 'Request for Special Leaves'){
                    if(queueMap.containsKey('HR Executive Queue')){
                      cnew.OwnerId =  queueMap.get('HR Executive Queue'); 
                    } 
                }else if(cnew.Type == 'Apply Resignation'){
                    if(queueMap.containsKey('HR Executive Queue')){
                      cnew.OwnerId =  queueMap.get('HR Executive Queue'); 
                    }
                } 
            }
        }
        
    }

}
