/**
* @author Ramakrishna
* @date 03/19/2023
* @description  MyServiceRequest to update the Approver reject comments

*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public  without sharing class MyServiceRequest {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseData(){
        
        User userData = [Select Id,contactId from user where Id =:Userinfo.getUserId()];
        
        List<Case> caseList =[SELECT Id, 
                              CaseNumber,
                              ContactId,
                              Type, 
                              Status, 
                              Reason, 
                              Subject, 
                              Notice_Period__c, 
                              Last_Working_Date__c,
                              Request_Sub_Type__c,
                              Description,
                              Department__c,
                              Designation__c,
                              OwnerId
                              FROM Case
                              WHERE Type ='Resignation' 
                              AND Status ='New'
                              AND Case_Assignee__c =: userData.contactId ORDER BY CaseNumber];
        return caseList;
        
    }
    @AuraEnabled
    Public static List<case> updateRequestAndComments(Id serviceRequestId,Date lasworkingDate,String approveComments){
        List<Case> serviceReqUpdatedList = new List<Case>();
        //SELECT Id, ParentId, CommentBody FROM CaseComment
        List<CaseComment> caseCommentList = new List<CaseComment>();
        for(Case serviceReq:[SELECT Id,Last_Working_Date__c,Status,Reason__c FROM Case WHERE Id =:serviceRequestId]){
            serviceReq.Last_Working_Date__c = lasworkingDate;
            // serviceReq.Reason__c = approveComments;
            serviceReq.Status ='Resignation Approved';
            serviceReqUpdatedList.add(serviceReq);
            CaseComment casecommentRec = new CaseComment();
            casecommentRec.ParentId = serviceRequestId;
            casecommentRec.CommentBody = approveComments;
            caseCommentList.add(casecommentRec);
        }
        try{
            if(!serviceReqUpdatedList.isEmpty()){
                Update serviceReqUpdatedList;
            }
            If(!caseCommentList.isEmpty()){
                Insert caseCommentList;
            }
            return serviceReqUpdatedList;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    @AuraEnabled
    Public static List<case> updateReqRejectComments(Id serviceRequestId,String approveComments){
        System.debug('serviceRequestId'+serviceRequestId);
        List<Case> serviceReqUpdatedList = new List<Case>();
        List<CaseComment> caseCommentList = new List<CaseComment>();
        for(Case serviceReq:[SELECT Id,Last_Working_Date__c,Status,Reason__c FROM Case WHERE Id =:serviceRequestId]){
            //serviceReq.Reason__c = approveComments;
            serviceReq.Status ='Resignation Rejected';
            serviceReqUpdatedList.add(serviceReq);
            CaseComment casecommentRec = new CaseComment();
            casecommentRec.ParentId = serviceRequestId;
            casecommentRec.CommentBody = approveComments;
            caseCommentList.add(casecommentRec);
        }
        try{
            if(!serviceReqUpdatedList.isEmpty()){
                Update serviceReqUpdatedList;
            }
            If(!caseCommentList.isEmpty()){
                Insert caseCommentList;
            }
            return serviceReqUpdatedList;
        }catch(Exception e){
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
    }
}