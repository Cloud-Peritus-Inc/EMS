public with sharing class ChangeProjectActionButtonController {
    
    @AuraEnabled
    public static List<WrapperClass> fetchAssignmentRecordsData(List<Id> assignmenyIdList){
        
        List<WrapperClass> wrapperAssignmentList=new List<WrapperClass>();
        List<EMS_TM_Assignment__c> assignmentRecProjects = [Select id, EMS_TM_ProjectName_Asgn__r.Name, EMS_TM_Status_Asgn__c, Project_Allocation__c, EMS_TM_EmployeeName__r.Id, EMS_TM_EmployeeName__r.Name, EMS_TM_Billable__c from EMS_TM_Assignment__c
                                                            where id IN: assignmenyIdList];
        
        for(EMS_TM_Assignment__c assignment : assignmentRecProjects){
            WrapperClass wrapItem = new WrapperClass();
            wrapItem.Id = assignment.id;
            wrapItem.EmployeeName = assignment.EMS_TM_EmployeeName__r.Name;
            wrapItem.ProjectName = assignment.EMS_TM_ProjectName_Asgn__r.Name;
            wrapItem.Billable = assignment.EMS_TM_Billable__c;
            wrapItem.Status = assignment.EMS_TM_Status_Asgn__c;
            wrapItem.ProjectAllocation = assignment.Project_Allocation__c != null ? assignment.Project_Allocation__c : 0;
            wrapItem.OldProjectAllocation = assignment.Project_Allocation__c;
            wrapItem.NewProjectName = '';
            wrapItem.NewProjectAllocation = null;
            wrapItem.NewEmployeeName = assignment.EMS_TM_EmployeeName__r.Id;
            wrapItem.NewAssignAs = '';
            wrapItem.NewStatus = '';
            wrapItem.NewBillable = false;
            wrapItem.NewStartDate = null;
            wrapItem.NewCloseDate = null;
            wrapItem.TotalProjectAllocation = getTotalProjectAllocationOfSingleContact(assignment.EMS_TM_EmployeeName__r.Id);
            
            
            wrapperAssignmentList.add(wrapItem);
        }  
        system.debug('wrapperAssignmentList' +wrapperAssignmentList);
        //}
        return wrapperAssignmentList;
    }
    
    // To create new assignments
    @AuraEnabled
    public static List<WrapperClass> saveAssignmentRecords(String assignmentData) {
        List<WrapperClass> assignmentList = (List<WrapperClass>) JSON.deserialize(assignmentData, List<WrapperClass>.class);
        
        List<EMS_TM_Assignment__c> newAssignments = new List<EMS_TM_Assignment__c>();
        List<EMS_TM_Assignment__c> updatedAssignments = new List<EMS_TM_Assignment__c>();
        
        for (WrapperClass assignment : assignmentList) {
            
                // New record, create a new assignment object
                EMS_TM_Assignment__c newAssignment = new EMS_TM_Assignment__c();
                newAssignment.EMS_TM_EmployeeName__c = assignment.NewEmployeeName;
                newAssignment.EMS_TM_ProjectName_Asgn__c = assignment.NewProjectName;
                newAssignment.EMS_TM_AssignedAs__c = assignment.NewAssignAs;
                newAssignment.EMS_TM_Status_Asgn__c = assignment.NewStatus;
                newAssignment.EMS_TM_StartDate_Asgn__c = assignment.NewStartDate;
                newAssignment.EMS_TM_EndDate_Asgn__c = assignment.NewCloseDate;
                newAssignment.EMS_TM_Billable__c = assignment.NewBillable;
                newAssignment.Project_Allocation__c = assignment.NewProjectAllocation;
                newAssignments.add(newAssignment);
            
                // Update Existing record
                EMS_TM_Assignment__c existingAssignment = new EMS_TM_Assignment__c();
                existingAssignment.Id = assignment.Id;
                existingAssignment.Project_Allocation__c = assignment.ProjectAllocation;
            	existingAssignment.EMS_TM_Status_Asgn__c = assignment.Status;
            	//existingAssignment.EMS_TM_EndDate_Asgn__c = system.today() ;
                updatedAssignments.add(existingAssignment);
        }
        insert newAssignments;
        update updatedAssignments;
        
        return assignmentList;
    }

    
    @AuraEnabled(cacheable=true)
    public static List<EMS_TM_Project__c> fetchActiveProjectsList(){
        return [select id, name, EMS_TM_Status__c from EMS_TM_Project__c where EMS_TM_Status__c = 'Ongoing'];
    }
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> picklistValues = new List<String>();
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        if (objectType != null) {
            Schema.SObjectField objectField = objectType.getDescribe().fields.getMap().get(fieldName);
            if (objectField != null) {
                Schema.DescribeFieldResult fieldResult = objectField.getDescribe();
                if (fieldResult.getType() == Schema.DisplayType.Picklist) {
                    List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
                    for (Schema.PicklistEntry picklistEntry : picklistEntries) {
                        picklistValues.add(picklistEntry.getValue());
                    }
                }
            }
        }
        return picklistValues;
    }
    
    //------------
    
    //To get toatal project allocations for single contact
    @AuraEnabled(cacheable=true)
    public static Decimal getTotalProjectAllocationOfSingleContact(String contactId){
        //String contactId = '0035200000nwG3nAAE';
        Decimal totalProjectAllocation = 0;
        List<EMS_TM_Assignment__c> assignmentList = [select id, Project_Allocation__c, EMS_TM_Status_Asgn__c, EMS_TM_EmployeeName__c 
                                                     from EMS_TM_Assignment__c 
                                                     where EMS_TM_Status_Asgn__c = 'Active' AND Project_Allocation__c != null AND EMS_TM_EmployeeName__c =: contactId];
        
        for(EMS_TM_Assignment__c assignmentRec : assignmentList){
            totalProjectAllocation += assignmentRec.Project_Allocation__c;
        }
        System.debug('totalProjectAllocation => '+ totalProjectAllocation);
        
        return totalProjectAllocation;
    }

    //To get total project allocations for List of contact records
    @AuraEnabled(cacheable=true)
    public static String  getTotalProjectAllocationContactRecords(String assignmentRecordString){
        
        Map<Id,String> returnMap = new Map<Id,String>();
        Set<Id> resourceIdSet = new Set<Id>();

        List<EMS_TM_Assignment__c> assList = (List<EMS_TM_Assignment__c>)System.JSON.deserializeStrict(assignmentRecordString, List<EMS_TM_Assignment__c>.Class);
        for(EMS_TM_Assignment__c assignmentRec : assList){
            resourceIdSet.add(assignmentRec.EMS_TM_EmployeeName__c);
        }
        
        Decimal totalProjectAllocation = 0;
        List<EMS_TM_Assignment__c> assignmentList = [select id, Project_Allocation__c, EMS_TM_Status_Asgn__c, EMS_TM_EmployeeName__c 
                                                     from EMS_TM_Assignment__c 
                                                     where EMS_TM_Status_Asgn__c = 'Active' AND Project_Allocation__c != null AND EMS_TM_EmployeeName__c IN : resourceIdSet];
        // Create a map to store the cumulative Project Allocation for each employee
        Map<Id, Decimal> employeeAllocationMap = new Map<Id, Decimal>();
        
        // Iterate through the assignment records and update the map
        for (EMS_TM_Assignment__c assignmentRec : assignmentList) {
            Id employeeId = assignmentRec.EMS_TM_EmployeeName__c;
            Decimal projectAllocation = assignmentRec.Project_Allocation__c;
            
            // Check if the employee is already in the map
            if (employeeAllocationMap.containsKey(employeeId)) {
                // Increment the cumulative allocation
                Decimal cumulativeAllocation = employeeAllocationMap.get(employeeId) + projectAllocation;
                employeeAllocationMap.put(employeeId, cumulativeAllocation);
            } else {
                // Add a new entry to the map
                employeeAllocationMap.put(employeeId, projectAllocation);
            }
        }

        List<Contact> contactList = [SELECT Id, Name FROM Contact WHERE Id IN :employeeAllocationMap.keySet()];
        // Create a comma-separated string of Contact names
        List<String> contactNames = new List<String>();
        // Populate the return map with Contact IDs and Names
        for (Contact contactRec : contactList) {
            contactNames.add(contactRec.Name);
        }
        // Join the contact names into a comma-separated string
        String commaSeparatedNames = String.join(contactNames, ', ');
        return commaSeparatedNames;
    }
    
    //To update old project allocation for single contact
    @AuraEnabled
    public static void updateOldProjectAllocationOfSingleContact(String assignmentId, Decimal oldProjectAllocationUpdatedValue, String oldProjectStatus){
        EMS_TM_Assignment__c assignmentRec = [select id, Project_Allocation__c, EMS_TM_Status_Asgn__c, EMS_TM_EmployeeName__c 
                                                     from EMS_TM_Assignment__c 
                                                     where id =: assignmentId limit 1];
        assignmentRec.Project_Allocation__c = oldProjectAllocationUpdatedValue;
        assignmentRec.EMS_TM_Status_Asgn__c = oldProjectStatus;
        update assignmentRec;
    }

    //this method is invoked by the "Confirm" button from the "showCloseProjectModal" modal.
    // onClick = handleCloseProjectRecord
    // Status = Closed 
    //At whatever capacity(current project allocation) the employee is allocated the project which is being closed, employee should be free from project allocation by that much percentage
    //End date = Date on which employee status is changed from active to closed
    @AuraEnabled
    public static void closeProjectForSingleContact(String assignmentId, String OldProjectId,String contactId){

        List<EMS_TM_Assignment__c> assignmentToUpdate = new List<EMS_TM_Assignment__c>();

        List<EMS_TM_Assignment__c> assignmentList = [select id, Project_Allocation__c, EMS_TM_Status_Asgn__c, EMS_TM_EmployeeName__c,EMS_TM_ProjectName_Asgn__r.Id,EMS_TM_EndDate_Asgn__c
                                                     from EMS_TM_Assignment__c 
                                                     where ( EMS_TM_ProjectName_Asgn__r.Id =: OldProjectId AND EMS_TM_EmployeeName__c =: contactId AND id =: assignmentId) LIMIT 1];
        
        for( EMS_TM_Assignment__c assignment : assignmentList ){
            assignment.EMS_TM_Status_Asgn__c = 'Closed';
            assignment.EMS_TM_EndDate_Asgn__c = Date.today();
            assignmentToUpdate.add(assignment);
        }
        System.debug(' ## Updated assignments :: ' + assignmentToUpdate);
        UPDATE assignmentToUpdate;
    }
@AuraEnabled
Public static void fetchContactRecordsData(){
}
    
    //------------
    
    public class WrapperClass
    {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String EmployeeName;
        @AuraEnabled
        public String ProjectName;
        @AuraEnabled
        public Decimal ProjectAllocation;
        @AuraEnabled
        public Decimal OldProjectAllocation;
        @AuraEnabled 
        public Boolean Billable;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String NewProjectName;
        @AuraEnabled
        public String NewEmployeeName;
        @AuraEnabled
        public Decimal NewProjectAllocation;
        @AuraEnabled
        public String NewAssignAs;
        @AuraEnabled
        public String NewStatus;
        @AuraEnabled 
        public Boolean NewBillable;
        @AuraEnabled
        public Date NewStartDate;
        @AuraEnabled
        public Date NewCloseDate;
        @AuraEnabled
        public Decimal TotalProjectAllocation;
        
    }
}
