global class BatchToCreateKRAforQuaterly_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCreateKRAforQuaterly batchExecute = new BatchToCreateKRAforQuaterly(); 
      Database.executeBatch(batchExecute,10);
    
      BatchToCreateKRAforQuaterly2 batchExecute2 = new BatchToCreateKRAforQuaterly2(); 
      Database.executeBatch(batchExecute2,10);
   }
}