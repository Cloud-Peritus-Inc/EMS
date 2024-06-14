/**
* @author vamsi
* @date 26/06/23
* @description  Sum of project allocations in all the active projects should always be less than or equal to 100%. s
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
public without sharing class SumOfprojectallcotion implements TriggerAction.BeforeInsert {
/**
* @author vamsi
* @date 26/06/23
* @description Before Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    public void beforeInsert(List<EMS_TM_Assignment__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictDuplicateApplicantRecords.beforeInsert() : BEGIN');
        projectallcotion(newList);
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
     public static void projectallcotion(list<EMS_TM_Assignment__c> assigmnentlist){
         Decimal projectallocation=0;
         decimal projectallocationvalue;
         set<Id> contactid=new set<Id>();
         set<Id> projectId=new set<Id>();
        
         system.debug('assigmnentlist======================================================='+assigmnentlist);
      for(EMS_TM_Assignment__c assignment:assigmnentlist){
         
           contactid.add(assignment.EMS_TM_EmployeeName__c);
             projectallocationvalue=assignment.Project_Allocation__c;
            system.debug('projectallocationvalue  ============================================================='+projectallocationvalue);
             system.debug('contactid======================================================='+contactid);
      //    if(assignment.EMS_TM_ProjectName_Asgn__r.EMS_TM_Status__c!=null){
              projectId.add(assignment.EMS_TM_ProjectName_Asgn__c);
               system.debug('contactid======================================================='+contactid);
               system.debug('projectId======================================================='+projectId);
        //  }
      }
         for(EMS_TM_Assignment__c assigncontact:[select id,name,EMS_TM_EmployeeName__c,EMS_TM_ProjectName_Asgn__c,Project_Allocation__c from EMS_TM_Assignment__c where EMS_TM_EmployeeName__c IN:contactid]){
                system.debug('assigncontact======================================================='+assigncontact);
             if(assigncontact.Project_Allocation__c>0){
                 
                               projectallocation += assigncontact.Project_Allocation__c+projectallocationvalue;
             system.debug('assigncontact======================================================='+assigncontact);
             system.debug('projectallocation===================================='+projectallocation);
             }else{
                 projectallocation=0;
             }
             
         }
              /*if(projectallocation>100){
                  for(EMS_TM_Assignment__c assign:assigmnentlist){
                        assign.adderror('An empoloyee can \'t be allocated beyond 100%.');
                  }
         
                  
         }*/
         
        
    }

}