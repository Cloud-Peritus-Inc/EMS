public with sharing class ProjectAllocationTabController {
    @AuraEnabled(cacheable=true)
    public static List<AssignmentWrapper> getActiveAssignments(String searchTerm, String searchProject) {
        String searchQuery = '%' + searchTerm + '%';
        String searchProjectQuery = '%' + searchProject + '%';
        List<EMS_TM_Assignment__c> assignments = [SELECT Id,Name,EMS_TM_ProjectName_Asgn__r.Name, EMS_TM_AssignedAs__c, EMS_TM_EmployeeName__r.Name, EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c, EMS_TM_EmployeeName__r.id, EMS_TM_EmployeeName__r.Email, Project_Allocation__c, EMS_TM_StartDate_Asgn__c, EMS_TM_EndDate_Asgn__c, 
                                                  EMS_TM_Status_Asgn__c, EMS_TM_Billable__c
                                                  FROM EMS_TM_Assignment__c
                                                  WHERE EMS_TM_Status_Asgn__c = 'Active' AND EMS_TM_EmployeeName__r.Name LIKE :searchQuery AND EMS_TM_ProjectName_Asgn__r.Name LIKE: searchProjectQuery ORDER BY LastModifiedDate desc];
        
        
        List<AssignmentWrapper> assignmentWrappers = new List<AssignmentWrapper>();
        
        for (EMS_TM_Assignment__c assignment : assignments) {
            AssignmentWrapper wrapper = new AssignmentWrapper();
            wrapper.assignmentId = assignment.Id;
            wrapper.Name = assignment.Name;
            wrapper.projectName = assignment.EMS_TM_ProjectName_Asgn__r.Name;
            wrapper.projectid = assignment.EMS_TM_ProjectName_Asgn__r.Id;
            wrapper.assignedAs = assignment.EMS_TM_AssignedAs__c;
            wrapper.employeeName = assignment.EMS_TM_EmployeeName__r.Name;
            wrapper.employeeId = assignment.EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c;
            wrapper.contactId = assignment.EMS_TM_EmployeeName__r.Id;
            wrapper.employeeEmail = assignment.EMS_TM_EmployeeName__r.Email;
            wrapper.projectAllocation = assignment.Project_Allocation__c != null ? assignment.Project_Allocation__c : 0;
            wrapper.Billable = assignment.EMS_TM_Billable__c;
            wrapper.startDate = assignment.EMS_TM_StartDate_Asgn__c;
            wrapper.endDate = assignment.EMS_TM_EndDate_Asgn__c;
            wrapper.status = assignment.EMS_TM_Status_Asgn__c;
            assignmentWrappers.add(wrapper);
        }
        
        return assignmentWrappers;
    }
    
    @AuraEnabled(cacheable=true)
    public static AssignmentWrapper getAssignmentWrapperWithProjectOptions() {
        AssignmentWrapper optionsWrapper = new AssignmentWrapper();
        optionsWrapper.projectOptions = getActiveProjectsList();
        return optionsWrapper;
    }
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getActiveProjectsList() {
        List<String> projectOptions = new List<String>();
        List<EMS_TM_Project__c> projects = fetchActiveProjectsList();
        
        for (EMS_TM_Project__c project : projects) {
            projectOptions.add(project.Name);
        }
        
        return projectOptions;
    }
    
    public static List<EMS_TM_Project__c> fetchActiveProjectsList(){
        return [SELECT Id, Name, EMS_TM_Status__c FROM EMS_TM_Project__c WHERE EMS_TM_Status__c = 'Ongoing' AND Type_Of_Project__c != 'Global Projects'];
    }
    
    @AuraEnabled
    public static string dmlOnAssignments(Object data) {
        List<EMS_TM_Assignment__c> updateAssignments = (List<EMS_TM_Assignment__c>) JSON.deserialize(JSON.serialize(data), List<EMS_TM_Assignment__c>.class);
        
        
        try {
            if(updateAssignments != null && !updateAssignments.isEmpty()){
                upsert updateAssignments;
            }
            return 'Success: Assignment(s) upsert successfully';
        }
        catch (Exception e) {
            String errorMsg = 'The following exception has occurred: ' + e.getMessage();
            throw new AuraHandledException(ErrorMsg);
        }
    }
    
    
    public class AssignmentWrapper {
        @AuraEnabled public Id assignmentId;
        @AuraEnabled public Id projectid;
        @AuraEnabled public String projectName;
        @AuraEnabled public String assignedAs;
        @AuraEnabled public String employeeName;
        @AuraEnabled public String employeeId;
        @AuraEnabled public String contactId;
        @AuraEnabled public String employeeEmail;
        @AuraEnabled public Decimal projectAllocation;
        @AuraEnabled public Boolean Billable;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public String status;
        @AuraEnabled public String Name;
        @AuraEnabled public List<String> projectOptions;
    }
}