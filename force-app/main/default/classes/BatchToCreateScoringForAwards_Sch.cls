global class BatchToCreateScoringForAwards_Sch implements Schedulable {
  global void execute(SchedulableContext sc) {
      BatchToCreateScoringForAwards batchExecute = new BatchToCreateScoringForAwards(); 
      Database.executeBatch(batchExecute,1000);
   }
}