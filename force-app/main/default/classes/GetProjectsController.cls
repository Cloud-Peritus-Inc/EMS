public class GetProjectsController {
    @AuraEnabled(cacheable=true)
    public static List<EMS_TM_Project__c> getProjects(){
        List<EMS_TM_Project__c> projectsList = new List<EMS_TM_Project__c>();
        Contact contactRecord = new Contact();
        List<EMS_TM_Assignment__c> leadAssignmentRecList = new List<EMS_TM_Assignment__c>();
        User currentUser =[SELECT Id, Lead_Access__c FROM User WHERE Lead_Access__c = true AND Id =: UserInfo.getUserId()];
        if(currentUser != null){
            contactRecord = [SELECT Id, EMS_TM_User__c FROM Contact WHERE EMS_TM_User__c =: currentUser.Id];
        }
        System.debug('-----contactRecord ---->'+contactRecord);
        Set<Id> teamLeadAssignmentIdSet = new Set<Id>();
        Set<Id> projectsId = new Set<Id>();
        if(contactRecord != null){
            
        for(EMS_TM_Assignment__c assignRec : [SELECT Id,
                                              EMS_TM_ProjectName_Asgn__c,
                                              EMS_TM_EmployeeName__c,
                                              Employee_Name__c,
                                              EMS_TM_StartDate_Asgn__c,
                                              EMS_TM_EndDate_Asgn__c,
                                              EMS_TM_Status_Asgn__c
                                              FROM EMS_TM_Assignment__c
                                              WHERE EMS_TM_EmployeeName__c =: contactRecord.Id]){
                                                  teamLeadAssignmentIdSet.add(assignRec.Id);
                                                  projectsId.add(assignRec.EMS_TM_ProjectName_Asgn__c);
                                              } 
        }
        
        if(!projectsId.isEmpty()){
                     projectsList = [SELECT Id,Name,
                                            EMS_TM_Billable__c,
                                            EMS_TM_EndDate__c,
                                            EMS_TM_StartDate__c,
                                            EMS_TM_Status__c,
                                            (SELECT Id,Name,
                                                    EMS_TM_ProjectName_Asgn__c,
                                                    EMS_TM_EmployeeName__c,
                                                    Employee_Name__c,
                                                    EMS_TM_StartDate_Asgn__c,
                                                    EMS_TM_EndDate_Asgn__c,
                                                    EMS_TM_Status_Asgn__c
                                             FROM Assignments__r)
                                     FROM EMS_TM_Project__c 
                                     WHERE Id IN : projectsId];
        }
//){  
                                            //     projectsList.add(projectRec);
                                            //     leadAssignmentRecList.add(projectRec.Assignments__r);
                                            // }
        
        //System.debug('-----assignmentRecList ---->'+leadAssignmentRecList);
        
        
        
        System.debug('-----project List ---->'+projectsList);
        return projectsList;
    }
    
}