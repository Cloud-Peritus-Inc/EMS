/**
    * @author Shubham Maske
    * @date 26/09/2023
    * 
    * @description After Insert : We are firing Platform Event for those records whose resource total project allocation is more then 100%
    * Hence Firing Platform Event and Subscribing via  LWC component.
    * 
    * @TestClass : showMsgBasedOnToatlProjectAllocationTest
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
public without sharing class showMsgBasedOnToatlProjectAllocation implements TriggerAction.AfterUpdate,TriggerAction.AfterInsert {
	

    public void afterUpdate(List<EMS_TM_Assignment__c> newList,List<EMS_TM_Assignment__c> oldList) {      
       /*System.debug(LoggingLevel.DEBUG, 'showMsgBasedOnToatlProjectAllocation.afterUpdate() : BEGIN');
        Map<id,EMS_TM_Assignment__c> assignmentOldMap = new Map<id,EMS_TM_Assignment__c>(oldList);
        showMsgOnRecordUpdate(newList,assignmentOldMap);
        System.debug(LoggingLevel.DEBUG, 'showMsgBasedOnToatlProjectAllocation.afterUpdate() : END'); */      
    }
    
   /**
 	* @author Shubham Maske
    * @date 26/09/2023
    * @description After Insert 
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public void afterInsert(List<EMS_TM_Assignment__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'showMsgBasedOnToatlProjectAllocation.afterInsert() : BEGIN');
        showMsgOnRecordInsert(newList,Null);
        System.debug(LoggingLevel.DEBUG, 'showMsgBasedOnToatlProjectAllocation.afterInsert() : END');       
    }
    
    /*
    private void showMsgOnRecordUpdate(List<EMS_TM_Assignment__c> newAssignment,Map<Id,EMS_TM_Assignment__c> oldMap){        
    }
    */
    
    private void showMsgOnRecordInsert(List<EMS_TM_Assignment__c> newAssignment,Map<Id,EMS_TM_Assignment__c> oldMap){
		System.debug('*** INSIDE showMsgOnRecordInsert ***');
        Map<Id,EMS_TM_Assignment__c> resAssignMap = new Map<Id,EMS_TM_Assignment__c>(); 
        for(EMS_TM_Assignment__c assignRec: newAssignment){
            if((oldMap != null && (oldMap.get(assignRec.id).Project_Allocation__c != assignRec.Project_Allocation__c)) || oldmap == null ){
                resAssignMap.put(assignRec.EMS_TM_EmployeeName__c,assignRec);
            }
        }
        System.debug('*** resAssignMap ***' + resAssignMap.toString());
        
        Map<Id,String> resNameMap = new Map<Id,String>();
        for(Contact con : [Select Id,Name FROM Contact WHERE Id IN : resAssignMap.keySet() ]){
            resNameMap.put(con.Id,con.Name);
        }
        System.debug('*** resNameMap ***' + resNameMap.toString());

        Map<Decimal,EMS_TM_Assignment__c> prjAllAssignMap = new Map<Decimal,EMS_TM_Assignment__c>();
        for(Id conId : resAssignMap.keySet()){
            String conRecId = conId;
            Decimal totalProjectAllocation = ChangeProjectActionButtonController.getTotalProjectAllocationOfSingleContact(conRecId);
            if (totalProjectAllocation > 100){
                prjAllAssignMap.put(totalProjectAllocation,resAssignMap.get(conId));
            }
        }
        
        System.debug('*** prjAllAssignMap ***' + prjAllAssignMap.toString());
        
        List<projectAssigneeCreated2__e> projectAssigneeCreatedEvents = new List<projectAssigneeCreated2__e>();
        if(!prjAllAssignMap.isEmpty()){
            for(EMS_TM_Assignment__c assmntRec: prjAllAssignMap.values()){                
                projectAssigneeCreated2__e evnt  = new projectAssigneeCreated2__e();
                evnt.projectAssigneeId__c = assmntRec.Id;
                evnt.projectAssigneeProjectName__c = assmntRec.EMS_TM_ProjectName_Asgn__c;
                evnt.projectAssigneeResourceName__c = resNameMap.get(assmntRec.EMS_TM_EmployeeName__c);
                evnt.projectAssigneeTotalProjectAllocation__c = ChangeProjectActionButtonController.getTotalProjectAllocationOfSingleContact(assmntRec.EMS_TM_EmployeeName__c);
                projectAssigneeCreatedEvents.add(evnt);
            }
        }
        
        System.debug('*** projectAssigneeCreatedEvents ***' + projectAssigneeCreatedEvents );
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        try {
            if(!projectAssigneeCreatedEvents.isEmpty()){
                results = EventBus.publish(projectAssigneeCreatedEvents);
            }
        } Catch(Exception excp){
            LogException.logHandledException(excp, 'showMsgBasedOnToatlProjectAllocation', 'showMsgOnRecordInsert');        
        }
    }
    
    
    
}