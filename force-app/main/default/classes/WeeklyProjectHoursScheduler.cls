global class WeeklyProjectHoursScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        WeeklyProjectHoursBatch batch = new WeeklyProjectHoursBatch();
        Database.executeBatch(batch, 200); 
    }
}