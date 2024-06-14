global class ScheduleBatch implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Create an instance of the batch class
        UpdateHRAccessBatch updateBatch = new UpdateHRAccessBatch();
        // Execute the batch class
        Database.executeBatch(updateBatch);
    }
}