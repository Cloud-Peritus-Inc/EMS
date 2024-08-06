global class BatchToUpdatePridcation_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToUpdatePridcation batchExecute = new BatchToUpdatePridcation(); 
      Database.executeBatch(batchExecute,200);
   }
}