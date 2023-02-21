public without sharing class batchLauncherController {
    @AuraEnabled
    public static List<AsyncApexJob> getJobDetails(String jobId){
        try {
            List<AsyncApexJob> asyncJobList = [SELECT Id, Status, JobItemsProcessed, TotalJobItems,
                                                NumberOfErrors FROM AsyncApexJob where Id =: jobId ];
            return asyncJobList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   }

   @AuraEnabled
   public static string executeBatch(String className, Integer chunkSize){
        try {
            Type batchInstance = Type.forName(className);
            Id batchJobId = Database.executeBatch((Database.Batchable<sObject>)batchInstance.newInstance(), chunkSize);
            return batchJobId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
   }
    
   @AuraEnabled(cacheable=true)
    public static Map<String,String> getExistingBatchDetails(){
        Map<String,String> mapreturns = new Map<String,String>();
        for(Batch_Job__mdt bj : [SELECT Batch_Class_Name__c,Label__c FROM Batch_Job__mdt]){
          mapreturns.put(bj.Label__c,bj.Batch_Class_Name__c);  
        }
        system.debug('==mapreturns==='+mapreturns);
        return mapreturns;
    }
}