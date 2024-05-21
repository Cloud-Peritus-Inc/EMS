public without sharing class myTeamController {
        
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getMyResources(){
        Map<String,String> resourceMap = new Map<String,String>(); 
        Boolean isPerAdmin = FeatureManagement.checkPermission('Performance_Management_Admin');
        //smaske : Show Resource to HR based on HR's work location.
        String workLocationName = null;
        Contact contactRecord = [SELECT Id,Name,EMS_TM_User__c,Work_Location__c,Work_Location__r.Name FROM Contact WHERE Work_Location__c != Null AND EMS_TM_User__c =: Userinfo.getUserId() LIMIT 1];
        if (contactRecord != null && contactRecord.Work_Location__r != null) {
            workLocationName = contactRecord.Work_Location__r.Name; // Assign the Work Location Name to the variable
        }
        System.debug('workLocationName ::' + workLocationName);
        if(isPerAdmin){
            //search RESOURCE based on HR's Work location
            for(Resource_Resource_Relationship__c rrr : [SELECT Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource__c,Resource__r.Name,Resource__r.EMS_TM_User__r.IsPortalEnabled,Resource__r.EMS_RM_ApplicantStatus_Update__c,Resource__r.Work_Location__c,Resource__r.Work_Location__r.Name FROM 
                                                         Resource_Resource_Relationship__c WHERE Resource__r.EMS_TM_User__r.isActive = true AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation')
                                                         AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true AND Resource__r.EMS_TM_User__c !=: Userinfo.getUserId() AND Resource__r.Work_Location__r.Name =: workLocationName Order By Resource__r.Name ASC ]){
                                                             resourceMap.put(rrr.Resource__r.Name,rrr.Resource__c); 
                                                         }             
        }else{
            for(Resource_Resource_Relationship__c rrr : [SELECT Id,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource__c,
                                                         Resource__r.Name FROM Resource_Resource_Relationship__c 
                                                         WHERE Resource_Reports_To__r.EMS_TM_User__c=:Userinfo.getUserId() AND Resource__r.EMS_TM_User__r.isActive = true  
                                                         AND Resource__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation')
                                                         AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true AND Resource__r.EMS_TM_User__c !=: Userinfo.getUserId() Order By Resource__r.Name ASC]){
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
    
    //smaske : [EN_13]
    @AuraEnabled
    public static Map<String,String> getReporteesInHierarchy(String selectedResourceId){
        try {
            System.debug('# IN getReporteesInHierarchy Apex');
            Map<String,String> resourceMap = new Map<String,String>();
            
            Contact startingContact = [SELECT Id,Name FROM Contact WHERE Id=:selectedResourceId LIMIT 1];
            //mukesh
            List<Contact> reportees = [SELECT Id, Name 
                                    FROM Contact 
                                    WHERE Id IN (
                                        SELECT Resource__c
                                        FROM Resource_Resource_Relationship__c 
                                        WHERE Resource_Reports_To__c = :selectedResourceId 
                                        AND Relationship_Type__c INCLUDES ('Mentor')
                                        AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true 
                                        AND Resource__r.EMS_RM_ApplicantStatus_Update__c != 'Inactive'
                                    )];
            
            for (Contact con : reportees) {
                if (con.Id != startingContact.Id) {
                    resourceMap.put(con.Name, con.Id);
                }
        }
        //@Mukesh: For new requirement commented the below code
            /* List<Contact> allReportees = getAllReportees(startingContact);           
            
            for (Contact con : allReportees) {
                if (con.Id != startingContact.Id) {
                    resourceMap.put(con.Name, con.Id);
                }
            } */
            return resourceMap;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    //smaske : [EN_13] Method to retrieve all reportees starting from a specific contact
    /* public static List<Contact> getAllReportees(Contact startingContact) {
        System.debug('# IN getAllReportees Apex');
        List<Contact> allReportees = new List<Contact>();
        Set<Id> visitedContacts = new Set<Id>();
        // Start the recursive traversal
        getAllReporteesRecursive(startingContact, allReportees, visitedContacts);
        System.debug('# IN getAllReportees allReportees ' + allReportees );
        return allReportees;
    } */
    
    //smaske:[EN_13] Recursive method to fetch all reportees
    /* private static void getAllReporteesRecursive(Contact contact, List<Contact> allReportees, Set<Id> visitedContacts) {
        // Add the current contact to the list of reportees
        System.debug('# IN getAllReporteesRecursive Apex');
        allReportees.add(contact);
        visitedContacts.add(contact.Id);
        
        // Fetch all reportees of the current contact
        List<Contact> reportees = [
            SELECT Id, Name 
            FROM Contact 
            WHERE Id IN (
                SELECT Resource__c
                FROM Resource_Resource_Relationship__c 
                WHERE Resource_Reports_To__c = :contact.Id 
                AND Relationship_Type__c includes ('Mentor')
                AND Resource__r.EMS_TM_User__r.IsPortalEnabled = true 
                AND Resource__r.EMS_RM_ApplicantStatus_Update__c != 'Inactive'
            )
        ];
        
        System.debug('# IN getAllReporteesRecursive reportees');
        // Iterate through the reportees and recursively fetch their reportees
        for (Contact reportee : reportees) {
            // Check if we've already visited this contact to avoid infinite loops in case of circular references
            if (!visitedContacts.contains(reportee.Id)) {
                // Recursively call the method and pass the updated allReportees list
                getAllReporteesRecursive(reportee, allReportees, visitedContacts);
            }
        }
    } */
    
    
}