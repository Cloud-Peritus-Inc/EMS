/**
* @author Subba
* @date 09/01/2023
* @description  createProjectAfterOppWon Class to create new project when Opportunity is Closed Won 
*              
*               Test code coverage provided by the following test class:
*               - createProjectAfterOppWonTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class createProjectAfterOppWon implements TriggerAction.AfterUpdate {
/**
* @author Subba
* @date 09/01/2023
* @description After Update 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void afterUpdate(List<Opportunity> newList, List<Opportunity> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'createProjectAfterOppWon.afterUpdate() : BEGIN');
        createNewProject(newList,new Map<Id, Opportunity>(oldList));
        System.debug(LoggingLevel.DEBUG, 'createProjectAfterOppWon.afterUpdate() : END');       
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
    private void createNewProject(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        Map<Id,Opportunity> filteredOppMap = new Map<Id,Opportunity>();
        List<EMS_TM_Project__c> projectInsert = new List<EMS_TM_Project__c>();
        for(Opportunity opp : newList){
            if(opp.StageName == 'Closed Won' && opp.StageName != oldMap.get(opp.Id).StageName ){
               filteredOppMap.put(opp.Id,opp); 
            }
        } 
        List<Opportunity_to_Project_Mapping__mdt> oppPrjMap = new List<Opportunity_to_Project_Mapping__mdt>(); 
        oppPrjMap = [SELECT Id,Opportunity_Field_API__c,Project_Field_API__c FROM Opportunity_to_Project_Mapping__mdt];
        SYstem.debug('oppPrjMap'+oppPrjMap);
           
        if(!filteredOppMap.isEmpty() && !oppPrjMap.isEmpty()){
          
         //  Id clientProjectRecordTypeId = Schema.SObjectType.EMS_TM_Project__c.getRecordTypeInfosByName().get('Client Projects').getRecordTypeId();
            for(Opportunity opp : filteredOppMap.values()){
                 EMS_TM_Project__c  proj = new EMS_TM_Project__c();
            //     proj.RecordTypeId = clientProjectRecordTypeId;
                   proj.Type_Of_Project__c ='Client Projects';
                //smaske: Required Fields ON/OFF Shore Manager field was missing so test class was failing .
                proj.Offshore_Project_Manager__c = opp.Project_Manager__c;
                proj.Project_Manager__c = opp.Project_Manager__c; 
                
                for(Opportunity_to_Project_Mapping__mdt ppm : oppPrjMap){
                    System.debug('ppm'+ppm);
                 proj.put(ppm.Project_Field_API__c,opp.get(ppm.Opportunity_Field_API__c)); 
                } 
                projectInsert.add(proj);
            }
        }
        System.debug('projectInsert'+projectInsert);
        try{
         insert projectInsert;  
            System.debug('projectInsert'+projectInsert);
        }catch(exception ex){
            SYstem.debug('eeee'+ex.getMessage());
         LogException.logHandledException(ex, 'createProjectAfterOppWon', 'CreateProject');   
        }  
    }
}