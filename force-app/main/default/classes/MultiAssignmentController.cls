public with sharing class MultiAssignmentController {
    
    @AuraEnabled(cacheable=true)
    public static List<EMS_TM_Assignment__c> getRelatedAssignments(Id prjId){
        system.debug('====prjId====='+prjId);
        return [Select Id,EMS_TM_Status_Asgn__c,Resource_Full_Name__c, EMS_TM_AssignedAs__c,EMS_TM_ProjectName_Asgn__c,EMS_TM_StartDate_Asgn__c,EMS_TM_EndDate_Asgn__c,EMS_TM_EmployeeName__c, EMS_TM_ProjectName_Asgn__r.Name from EMS_TM_Assignment__c where EMS_TM_ProjectName_Asgn__c = :prjId];
    }

    @AuraEnabled
    public static List<EMS_TM_Assignment__c> deleteAssignmentHandler(Id assId, Id projId){
         Database.delete(assId);
         return getRelatedAssignments(projId);
    }

    @AuraEnabled
    public static List<EMS_TM_Assignment__c> saveAssignmentData(String assignmentDataString,Id projId){
        List<EMS_TM_Assignment__c> assList = (List<EMS_TM_Assignment__c>)System.JSON.deserializeStrict(assignmentDataString, List<EMS_TM_Assignment__c>.Class);
        system.debug('====assignmentDataString======='+assignmentDataString);
         system.debug('====assList======='+assList);
        try{
            for(EMS_TM_Assignment__c aa : assList){
               aa.EMS_TM_ProjectName_Asgn__c = projId;
            }
            insert assList;      
           return getRelatedAssignments(projId);
        }catch(exception ex){
            system.debug('=====error========'+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
     
    }
}