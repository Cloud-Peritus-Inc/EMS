//
//Description : Approved request record attached file/Attacment to the related contacts
//Author: Sreedhar

//

trigger TriggerTiLinkFiles on EMS_EM_Request__c (After Insert, after update) {
    Set<Id> reqIds = New Set<Id>();
    Set<Id> conIds = New Set<Id>();
    if(Trigger.IsUpdate || Trigger.IsInsert){
        for(EMS_EM_Request__c er:Trigger.new){
            if(er.EMS_EM_Request_Status__c =='Approved' || er.EMS_EM_Request_Status__c == 'Auto-Approved'){
                reqIds.add(er.Id);
                conIds.add(er.Contact__c);
            }
        }
        try{
        list<attachment> accatt=new list<attachment>();
        Map<Id, Id> addDetailsIdMap =new Map<Id, Id>();
        List<ContentDocumentLink> lstOfFiles=[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink where LinkedEntityId IN:reqIds Limit 1];
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        List<ems_EM_Additional_Detail__c> addDetailsList=[Select ContactId__c,Id from ems_EM_Additional_Detail__c where ContactId__c IN :conIds];
        for(ems_EM_Additional_Detail__c ad: addDetailsList){
            addDetailsIdMap.put(ad.ContactId__c,ad.Id);
        }
        system.debug('@@Add-->'+addDetailsList +'@@Attch-->'+ lstOfFiles);
        
        if(lstOfFiles.size()>0){
            for(EMS_EM_Request__c er:Trigger.new){
            
           for(ContentDocumentLink cl:lstOfFiles){
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = cl.ContentDocumentId;
                cdl.LinkedEntityId = addDetailsIdMap.get(er.Contact__c);
                cdl.ShareType = 'V';
                cdlList.add(cdl);
            }
            
            }
        }
        if(cdlList.size()>0){
             insert cdlList;
               
        }
        }catch(exception ex){
            system.debug('@@Ex-->'+ex);
        }
  }
}