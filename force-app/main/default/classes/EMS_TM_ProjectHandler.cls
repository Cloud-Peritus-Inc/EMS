public class EMS_TM_ProjectHandler {
    
    public static void assignmentStatusUpdate(List<EMS_TM_Project__c> projectList){
        Set<id> projectIds = new set<id>();
        for (EMS_TM_Project__c proj : projectList){
            if(proj.EMS_TM_Status__c == 'Completed'){
                projectIds.add(proj.Id);
            }   
        }
        System.debug('projectIds'+projectIds);
        List<EMS_TM_Assignment__C> assignList = new List<EMS_TM_Assignment__C>();
        for (EMS_TM_Assignment__C assignData: [SELECT Id, EMS_TM_ProjectName_Asgn__c, EMS_TM_Status_Asgn__c 
                                               FROM EMS_TM_Assignment__c where EMS_TM_ProjectName_Asgn__c =:projectIds ]){
                 assignData.EMS_TM_Status_Asgn__c ='Closed' ;
                 assignList.add(assignData);
                                                   
         }
        System.debug('assignList'+assignList);
        if (assignList.size() > 0){
            update assignList;
        }
    }

    public static void assignmentCreate(List<EMS_TM_Assignment__C> assigndata){
        set<id> projectIds = new Set<id>();
        for(EMS_TM_Assignment__C assign :assigndata ){
            if(assign.EMS_TM_ProjectName_Asgn__c != null){
               projectIds.add(assign.EMS_TM_ProjectName_Asgn__c); 
            }
           List<EMS_TM_Project__c> projList = new List<EMS_TM_Project__c>();           
            for(EMS_TM_Project__c p : [Select id, EMS_TM_Status__c from EMS_TM_Project__c where id =:projectIds]){
                
                if(p.EMS_TM_Status__c == 'Completed')
                {
                    projList.add(p);
                }
            }
            
            for(EMS_TM_Assignment__C assignL :assigndata ){
                if(projList.size()!=0)
                {
                    assignL.addError('Assignment create only for ongoing Projects only');
                }
            }
        }
    }
    
}