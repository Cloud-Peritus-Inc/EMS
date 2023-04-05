global class BatchtoUpdateLeavesInTimesheet_sch implements Schedulable {
global void execute(SchedulableContext sc) {
      BatchtoUpdateLeavesInTimesheet batchExecute = new BatchtoUpdateLeavesInTimesheet(); 
      Database.executeBatch(batchExecute,10);
   }
}