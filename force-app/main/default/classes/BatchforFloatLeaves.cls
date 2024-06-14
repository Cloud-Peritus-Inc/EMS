global class BatchforFloatLeaves implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Name,UtlizedFloatLeaves__c FROM contact where Work_Location__r.Name='California - USA']);
    }
    global void execute(Database.BatchableContext bc, List<contact> records){
        for(contact con:records){
            con.UtlizedFloatLeaves__c=0;
        }
        try{
           update records;
        }catch(exception e){
             System.debug('error=========================='+e.getMessage());
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }  
}