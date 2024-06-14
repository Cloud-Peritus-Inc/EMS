public without sharing class GetContactWhoReportToManger {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts(){

        List<Contact> contactist =  [SELECT Id,Name 
                                     			FROM Contact 
                                     			WHERE recordTypeId =:ContactConstant.RESOURCE_RECORDTYPEID];
        return contactist;
    }
     @AuraEnabled 
    public static List<EMS_TM_Assignment__c> insertMultipleAssignments(Date startDate,Date endDate, List<Id> contactIds,Id projectId,String assignedAs){
        System.debug('startDate'+startDate);
        System.debug('endDate'+endDate);
        System.debug('contactIds'+contactIds);
        System.debug('projectIdmultipleassignments'+projectId);
        List<EMS_TM_Assignment__c> assignmentList = new List<EMS_TM_Assignment__c>();

        for(Id contactId:contactIds){
            System.debug('contactId'+contactId);
         EMS_TM_Assignment__c assignmentRec = new EMS_TM_Assignment__c();
         assignmentRec.EMS_TM_EndDate_Asgn__c = endDate;
         assignmentRec.EMS_TM_StartDate_Asgn__c = startDate;
         assignmentRec.EMS_TM_ProjectName_Asgn__c = projectId;
         assignmentRec.EMS_TM_EmployeeName__c = contactId;
         assignmentRec.EMS_TM_AssignedAs__c = assignedAs;
         assignmentList.add(assignmentRec);   
        }
        try{
           insert assignmentList;
            return assignmentList;
        }catch(Exception e){
            System.debug(e.getmessage());
              throw new AuraHandledException(e.getMessage());
        }
    }
}