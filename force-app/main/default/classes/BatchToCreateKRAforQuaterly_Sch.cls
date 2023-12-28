global class BatchToCreateKRAforQuaterly_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCreateKRAforQuaterly batchExecute = new BatchToCreateKRAforQuaterly(); 
      Database.executeBatch(batchExecute,10);
   }
}