/**
* @author Subba Kalavala
* @date 8/7/2023
* @description  BatchToCreateKRAforQuaterly Batch to performance KRA's
*              
*               Schedule class 
*               
*               Test code coverage provided by the following test class:
*               - BatchToCreateKRAforQuaterly_Test
*
* CHANGE HISTORY
 Shubham Maske : Updated the Start querry to fetch contacts whose work location country value is INDIA.
 This batch will create KRA for Contact from INDIA 
 Date : 26/Aug/2024
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* 15/Oct/2024   Shubham Maske       	Updating code to use Database.SaveResult class for Inserting records.Hence commenting try-catch block.
* 17/Oct/2024	Shubham Maske			Updating code to create KRA for contacts with Mentor assigned.
* ====================================================================================================
**/
global class BatchToCreateKRAforQuaterly implements Database.Batchable<sObject>,Database.Stateful {
    
    //smaske : 15/Oct/2024 : UAT_Smoke_006 : List to store failed records across all batches
    private List<Goal__c> failedRecords = new List<Goal__c>();
    private List<String> errorMessages = new List<String>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id,Appraisal_Date__c,EMS_TM_User__c,Work_Location_Country__c,(Select Id,Resource_Reports_To__c FROM Resource_Resource_Relationships__r WHERE Relationship_Type__c INCLUDES ('Mentor')),(SELECT Id,Resource__c,Fiscal_Year__c FROM Fulfillments__r) FROM Contact WHERE EMS_TM_User__r.isActive = true and Work_Location_Country__c = 'India' ]);
    }
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        Fiscal_Year__c currentFY = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Fiscal_Year__c where Start_Date__c = THIS_FISCAL_YEAR Order BY Start_Date__c ASC];
        List<Contact> conThatRequiresFulments = new List<Contact>();
        List<Fulfillment__c> fulinserts = new List<Fulfillment__c>();
        Map<Id,Id> contactWithFul = new Map<Id,Id>();
        Map<Id,String> resourcewithMentor = new Map<Id,String>();
        //Set<Id> kraSet = new Set<Id>();
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
            for(Fulfillment__c fi : [SELECT Id,Fiscal_Year__c,Resource__c,OwnerId,(SELECT Id,Type__c,Quarter_Start_Date__c,Quarter_End_Date__c FROM Goals__r WHERE Type__c = 'KRA' AND Quarter_Start_Date__c= THIS_FISCAL_QUARTER) FROM Fulfillment__c WHERE Id IN:contactWithFul.values()]){
                if(fi.Goals__r.isEmpty()){
                    fulList.add(fi);  
                } 
            }
        }
        if(fulList.size() > 0){
            Period pd = [Select StartDate,EndDate,FullyQualifiedLabel From Period Where type = 'Quarter' and StartDate = THIS_FISCAL_QUARTER];
            for(Fulfillment__c fis : fulList){
               //Smsake :[17-Oct-2024]: UAT_Smoke_015 : Updating code to create KRA for contacts with Mentor assigned.
               if(resourcewithMentor.containsKey(fis.Resource__c)){ 
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
                //smaske : [10-July-2024] : Changing default status from "Active" to "In Progress" as discussed with subba on 09-July-2024
                gol.Status__c = 'In Progress';
                gol.Fulfillment__c = fis.Id;
                gol.RecordTypeId = kraRecordTypeId;
                //kraSet.add(gol.Id);
                //system.debug('KraIDs >>>>>  '+kraSet);
                goalsInsert.add(gol);
                
                system.debug('goalsInsert >>>>> '+goalsInsert);
               }
            } 
        }  
        
        //smaske : 15/Oct/2024 : UAT_Smoke_006 : Updating code to use Database.SaveResult class for Inserting records.Hence commenting try-catch block.
        /*try{
            insert goalsInsert; 
        }catch(exception ex){
            LogException.logHandledException(ex, 'BatchToCreateKRAforQuaterly', 'execute');  
        }*/
        
        if(!goalsInsert.isEmpty()) {
            // Perform the DML operation with allOrNone set to false
            Database.SaveResult[] saveResults = Database.insert(goalsInsert, false);
            System.debug('saveResults :' + saveResults);
            // Iterate over the save results to separate successful and failed records
            for(Integer i = 0; i < saveResults.size(); i++) {
                Database.SaveResult sr = saveResults[i];
                if(!sr.isSuccess()) {
                    // Add the failed contact to the list and log the errors
                    failedRecords.add(goalsInsert[i]);
                    for(Database.Error error : sr.getErrors()) {
                        errorMessages.add('Error for record ' + goalsInsert[i].Resource__c + ': ' + error.getMessage());
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('IN finish');
        //smaske : 15/Oct/2024 : UAT_Smoke_006 : Updating finish method for handling errors.
        if(!failedRecords.isEmpty()) {
            System.debug('Failed records: ' + failedRecords);
            for(String errorMsg : errorMessages) {
                System.debug('Error: ' + errorMsg);
            }
        }
        
    }
}