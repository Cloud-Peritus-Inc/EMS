global class BatchToUpdateNomsCountOnNoms_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToUpdatePridcation batchExecute = new BatchToUpdatePridcation(); 
      Database.executeBatch(batchExecute,100);
   }
}