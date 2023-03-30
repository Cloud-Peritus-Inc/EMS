/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  restrictOnlyOneDayOnProbation Class to restrict the leave as only one
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
public class restrictOnlyOneDayOnProbation implements TriggerAction.BeforeInsert,TriggerAction.BeforeUpdate {
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
    public void beforeInsert(List<EMS_LM_Leave_History__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictOnlyOneDayOnProbation.beforeInsert() : BEGIN');
        restrictTheProbLeave(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictOnlyOneDayOnProbation.beforeInsert() : END');       
    }
    
     public void beforeUpdate(List<EMS_LM_Leave_History__c> newList , List<EMS_LM_Leave_History__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictOnlyOneDayOnProbation.beforeUpdate() : BEGIN');
        restrictTheProbLeave(newList);
        System.debug(LoggingLevel.DEBUG, 'restrictOnlyOneDayOnProbation.beforeUpdate() : END');       
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
    public void restrictTheProbLeave(List<EMS_LM_Leave_History__c> newlist) {
        set<String> resourcId = new set<String>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        for(EMS_LM_Leave_History__c his : newlist){
                resourcId.add(his.EMS_LM_Contact__c);
        }
        
        for(Contact con : [SELECT Id,Resource_Role__c,Probationary_Period_End_Date__c,(SELECT Id,Leave_Type_Name__c,EMS_LM_Leave_Duration__c,EMS_LM_Leave_End_Date__c,EMS_LM_Leave_Start_Date__c FROM Leaves_History__r 
                                      WHERE EMS_LM_Leave_End_Date__c = THIS_YEAR AND EMS_LM_Status__c != 'Cancelled' AND EMS_LM_Status__c != 'Rejected' AND
                                                                                      EMS_LM_Leave_Type__r.EMS_LM_Leave_Type__c !=:LeaveRequestConstant.WORK_FROM_HOME) 
                           FROM Contact WHERE Id IN:resourcId AND Probationary_Period_End_Date__c != null AND Probationary_Period_End_Date__c > Today]){
          contactMap.put(con.Id,con);  
        }
        
        for(EMS_LM_Leave_History__c his : newlist){
            if(contactMap.containsKey(his.EMS_LM_Contact__c)){
                
                Integer numberDaysDue = his.EMS_LM_Leave_Start_Date__c.daysBetween(his.EMS_LM_Leave_End_Date__c )+1;
                system.debug('numberDaysDue-->'+numberDaysDue);
                if(numberDaysDue > 1){
                    his.addError('During Probation, only one day PTO is allowed per month. Please check the duration and try again.');
                }else{
                    String uniqueMonthYear = String.valueOf((his.EMS_LM_Leave_Start_Date__c).month())+String.valueOf((his.EMS_LM_Leave_Start_Date__c).year());
                    for(EMS_LM_Leave_History__c leave : contactMap.get(his.EMS_LM_Contact__c).Leaves_History__r){
                      String existingUniqueMonthYear = String.valueOf((leave.EMS_LM_Leave_Start_Date__c).month())+String.valueOf((leave.EMS_LM_Leave_Start_Date__c).year());   
                        if(uniqueMonthYear == existingUniqueMonthYear){
                            his.addError('During Probation, only one PTO is allowed Per month. Seems you already availed allowed PTO for this month.');
                            break;
                        }
                    }
                }
            }
        }
        
    }
}