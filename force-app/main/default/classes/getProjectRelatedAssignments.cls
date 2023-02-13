public class getProjectRelatedAssignments {

@AuraEnabled

public static List<EMS_TM_Assignment__c> getAssignments(Id projectId){
    System.debug('projectId'+projectId);

List<EMS_TM_Assignment__c> assignmentList =[SELECT Id, 
                                                    EMS_TM_EmployeeName__c,
                                                    Name,
                                                    EMS_TM_Status_Asgn__c,
                                                    EMS_TM_EndDate_Asgn__c,
                                                    EMS_TM_StartDate_Asgn__c,
                                                    EMS_TM_EmployeeName__r.Name
                                                    FROM EMS_TM_Assignment__c
                                                    WHERE EMS_TM_ProjectName_Asgn__c =:projectId];
                                                    try{
                                                    return assignmentList;
                                                    }catch(Exception e){
                                                     String errorOccuredWith = e.getMessage();
                                                     throw new AuraHandledException(errorOccuredWith);
                                                    }

}

}