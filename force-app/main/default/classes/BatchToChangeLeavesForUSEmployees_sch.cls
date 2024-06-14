global class BatchToChangeLeavesForUSEmployees_sch implements Schedulable{
    global void execute(SchedulableContext sc) {
 BatchToChangeLeavesForUSEmployees objbatch2=new BatchToChangeLeavesForUSEmployees();
  database.executeBatch(objbatch2);
    }
}