public without sharing class myTeamController {
    
    
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getMyResources(){
        Map<String,String> resourceMap = new Map<String,String>(); 
        Boolean isPerAdmin = FeatureManagement.checkPermission('Performance_Management_Admin');
        if(isPerAdmin){
            for(Resource_Resource_Relationship__c rrr : [SELECT Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource__c,Resource__r.Name,Resource__r.EMS_TM_User__r.IsPortalEnabled,Resource__r.EMS_RM_ApplicantStatus_Update__c FROM 
                                                         Resource_Resource_Relationship__c WHERE Resource__r.EMS_TM_User__r.isActive = true AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation')
                                                         AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true Order By Resource__r.Name ASC ]){
                                                             resourceMap.put(rrr.Resource__r.Name,rrr.Resource__c); 
                                                         } 
        }else{
            for(Resource_Resource_Relationship__c rrr : [SELECT Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource__c,
                                                         Resource__r.Name FROM Resource_Resource_Relationship__c 
                                                         WHERE Resource_Reports_To__r.EMS_TM_User__c=:Userinfo.getUserId() AND Resource__r.EMS_TM_User__r.isActive = true  
                                                         AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation')
                                                         AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true Order By Resource__r.Name ASC]){
                                                             resourceMap.put(rrr.Resource__r.Name,rrr.Resource__c); 
                                                         }
        }
        return resourceMap;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static boolean checkTheTeam(){
       Boolean isPerAdmin = FeatureManagement.checkPermission('Performance_Management_Admin');
            if(isPerAdmin){
                return false; 
            }
        List<Resource_Resource_Relationship__c> anyteamMembers = [SELECT Id FROM Resource_Resource_Relationship__c 
                                                                  WHERE Resource_Reports_To__r.EMS_TM_User__c =:UserInfo.getUserId()
                                                                  AND Resource__r.EMS_TM_User__r.isActive = true and Relationship_Type__c includes ('Mentor')];
        return anyteamMembers.isEmpty();
    }
}