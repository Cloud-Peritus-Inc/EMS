/**
* @author Sangharsh kamble
* @date 03/30/2023
* @description  restrictAnnualLeavebelow Class to restrict the applying Annual leave below -5
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
public class restrictAnnualLeavebelow implements TriggerAction.BeforeInsert,TriggerAction.BeforeUpdate{
    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictAnnualLeavebelow.beforeInsert() : BEGIN');
        restrictAnnualleave(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictAnnualLeavebelow.beforeInsert() : END');       
    }
    
    public void beforeUpdate(List<EMS_LM_Leave_History__c> newList , List<EMS_LM_Leave_History__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictAnnualLeavebelow.beforeUpdate() : BEGIN');
        restrictAnnualleave(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictAnnualLeavebelow.beforeUpdate() : END');       
    }
    
    public void restrictAnnualleave(List<EMS_LM_Leave_History__c> newlist) {
        Set<Id> parentIds = new Set<Id>();
        for (EMS_LM_Leave_History__c child : newlist) {
            parentIds.add(child.EMS_LM_Contact__c);
        }
        
        Map<Id, Contact> parents = new Map<Id, Contact>([SELECT Id,EMS_LM_No_Of_Availble_Leaves__c,EMS_LM_No_Of_Leaves_Credit__c,EMS_LM_No_Of_Utilized_Leaves__c FROM Contact WHERE Id IN :parentIds]);
        Id AnnualleaveId = [Select Id,Name,(select id,EMS_LM_Contact__c from Leaves_History__r where EMS_LM_Contact__c IN :parentIds) FROM EMS_LM_Leave__c where Name ='Annual Leave' limit 1].Id;
        for(EMS_LM_Leave_History__c his : newlist){
            Contact parent = parents.get(his.EMS_LM_Contact__c);
            system.debug('parent'+parent);
            Decimal balance =parent.EMS_LM_No_Of_Availble_Leaves__c - his.EMS_LM_Leave_Duration__c;
           // Decimal balance =parent.EMS_LM_No_Of_Leaves_Credit__c- parent.EMS_LM_No_Of_Utilized_Leaves__c;
            system.debug('balance'+balance);
            if (parent != null && balance < -5 && his.Leave_Type_Name__c=='Annual Leave') {
            //    his.addError('Sorry!! You do not have enough leave balance. Consider applying for leave of some other type.');
            }
        }
    }
}