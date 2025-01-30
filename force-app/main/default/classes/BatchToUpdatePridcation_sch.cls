/* Smaske : this batch should be run with batch size as 1 only as confirmed by subba on 09/Aug/2024 */
global class BatchToUpdatePridcation_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToUpdatePridcation batchExecute = new BatchToUpdatePridcation(); 
      Database.executeBatch(batchExecute,1);
   }
}