/*
 * Smaske : this schedule class is for Contacts with NON-INDIA location
 * 
 * 
 * 
 *
*/
global class BatchToCreateKRAforQuaterly2_Sch implements Schedulable {
global void execute(SchedulableContext sc) {
        
          BatchToCreateKRAforQuaterly2 batchExecute2 = new BatchToCreateKRAforQuaterly2(); 
          Database.executeBatch(batchExecute2,10);
    }
}