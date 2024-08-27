/*
 * Smaske : this schedule class is for Contacts with INDIA location
 * 
 * 
 * 
 *
*/
global class BatchToCreateKRAforQuaterly_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchToCreateKRAforQuaterly batchExecute = new BatchToCreateKRAforQuaterly(); 
      Database.executeBatch(batchExecute,10);
   }
}