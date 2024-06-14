/**
* @author Subba Kalavala
* @date 01/03/2023
* @description  AssignmentTileController Class to show the data on Home page for Assignment
*
*               Test code coverage provided by the following test class:
*               - AssignmentTileControllerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class AssignmentTileController {
    
@AuraEnabled(cacheable=true)
    public static List<dataWrapper> getMyProjectDetails(){
       User Urec = [SELECT Id,ContactId FROM User WHERE Id=:Userinfo.getUserId()];
       Map<String,String> projectWithRole = new Map<String,String>(); 
       Map<String,Boolean> projectWithInfo = new Map<String,Boolean>();
        List<dataWrapper> dataWrapList = new List<dataWrapper>();
        for(EMS_TM_Assignment__c assn : [SELECT Id, EMS_TM_ProjectName_Asgn__r.EMS_TM_Billable__c , EMS_TM_ProjectName_Asgn__r.Name,EMS_TM_AssignedAs__c  
                                         FROM EMS_TM_Assignment__c 
                                         WHERE EMS_TM_EmployeeName__c =:Urec.ContactId 
                                         AND EMS_TM_Status_Asgn__c ='Active']){
           projectWithRole.put(assn.EMS_TM_ProjectName_Asgn__r.Name,assn.EMS_TM_AssignedAs__c);
           projectWithInfo.put(assn.EMS_TM_ProjectName_Asgn__r.Name,assn.EMS_TM_ProjectName_Asgn__r.EMS_TM_Billable__c);
        } 
        
        for(String prj : projectWithRole.keySet()){
            if(dataWrapList.size()<3){
           dataWrapper dw = new dataWrapper();
           dw.projectName = prj;
           dw.projectRole = projectWithRole.get(prj);
           dw.isClient = projectWithInfo.get(prj);
           dataWrapList.add(dw);
            }
        }
        return dataWrapList;
    }

    public class dataWrapper {
     @AuraEnabled
     public string projectName;
     @AuraEnabled
     public string projectRole;
     @AuraEnabled
     public boolean isClient;
    }    

}