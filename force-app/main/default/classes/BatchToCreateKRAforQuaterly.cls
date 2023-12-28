/**
* @author Subba Kalavala
* @date 8/7/2023
* @description  BatchToCreateKRAforQuaterly Batch to performance KRA's
*              
*               Schedule class 
*               - BatchToCreateKRAforQuaterly_Sch
*               Test code coverage provided by the following test class:
*               - BatchToCreateKRAforQuaterly_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global class BatchToCreateKRAforQuaterly implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
         return Database.getQueryLocator([SELECT Id,Appraisal_Date__c,EMS_TM_User__c,(Select Id,Resource_Reports_To__c FROM Resource_Resource_Relationships__r WHERE Relationship_Type__c INCLUDES ('Mentor')),(SELECT Id,Resource__c,Fiscal_Year__c FROM Fulfillments__r) FROM Contact WHERE EMS_TM_User__r.isActive = true]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
      Fiscal_Year__c currentFY = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c where Start_Date__c = THIS_FISCAL_YEAR Order BY Start_Date__c ASC];
        List<Contact> conThatRequiresFulments = new List<Contact>();
        List<Fulfillment__c> fulinserts = new List<Fulfillment__c>();
        Map<Id,Id> contactWithFul = new Map<Id,Id>();
        Map<Id,String> resourcewithMentor = new Map<Id,String>();
        for(Contact con : conList){
            if(!con.Resource_Resource_Relationships__r.isEmpty()){
                resourcewithMentor.put(con.Id,con.Resource_Resource_Relationships__r[0].Resource_Reports_To__c);
            }
            if(con.Fulfillments__r.isEmpty()){
              conThatRequiresFulments.add(con);   
            }else{
                for(Fulfillment__c ful : con.Fulfillments__r){
                    if(ful.Fiscal_Year__c == currentFY.Id){
                       contactWithFul.put(con.Id,ful.Id); 
                       break;
                    }
                } 
                if(!contactWithFul.containsKey(con.Id)){
                  conThatRequiresFulments.add(con);  
                }
            }
        }
        Id appRecordTypeId = Schema.SObjectType.Fulfillment__c.getRecordTypeInfosByName().get('Appraisal').getRecordTypeId();
        Id kraRecordTypeId = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('KRA').getRecordTypeId();
        if(!conThatRequiresFulments.isEmpty()){
            for(Contact con : conThatRequiresFulments){
                Fulfillment__c ful = new Fulfillment__c();
                ful.Appraisal_Date__c = con.Appraisal_Date__c;
                ful.Fiscal_Year__c = currentFY.Id;
                ful.OwnerId = con.EMS_TM_User__c;
                ful.Recognization_Type__c = 'Performance';
                ful.RecordTypeId = appRecordTypeId;
                ful.Resource__c = con.Id;
                ful.Status__c = 'Active';
                fulinserts.add(ful);
            }
            insert fulinserts;
            for(Fulfillment__c fulmp : fulinserts){
               contactWithFul.put(fulmp.Resource__c,fulmp.Id);  
            }
        }
        List<Goal__c> goalsInsert = new List<Goal__c>();
         List<Fulfillment__c> fulList = new List<Fulfillment__c>();
        if(!contactWithFul.isEmpty()){
            for(Fulfillment__c fi : [SELECT Id,Fiscal_Year__c,Resource__c,OwnerId,(SELECT Id,Type__c,Quarter_Start_Date__c,Quarter_End_Date__c FROM Goals__r WHERE Type__c = 'KRA' AND Quarter_Start_Date__c=THIS_FISCAL_QUARTER) FROM Fulfillment__c WHERE Id IN:contactWithFul.values()]){
                if(fi.Goals__r.isEmpty()){
                  fulList.add(fi);  
                } 
            }
        }
        if(fulList.size() > 0){
            Period pd = [Select StartDate,EndDate,FullyQualifiedLabel From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
            for(Fulfillment__c fis : fulList){
               Goal__c gol = new Goal__c();
               gol.Quarter_Start_Date__c = pd.StartDate;
               gol.Quarter_End_Date__c = pd.EndDate;
               gol.Type__c = 'KRA';
               gol.Goal_Name__c = pd.FullyQualifiedLabel;  
               gol.Start_Date__c = pd.StartDate;
               gol.End_Date__c = pd.EndDate; 
               gol.Resource__c = fis.Resource__c;
               if(resourcewithMentor.containsKey(fis.Resource__c)){
                 gol.Check_In_By__c = resourcewithMentor.get(fis.Resource__c);
               }
               gol.Status__c = 'Active';
               gol.Fulfillment__c = fis.Id;
               gol.RecordTypeId = kraRecordTypeId;
               goalsInsert.add(gol);
            } 
        }  
        
        try{
           insert goalsInsert; 
        }catch(exception ex){
           LogException.logHandledException(ex, 'BatchToCreateKRAforQuaterly', 'execute');  
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}