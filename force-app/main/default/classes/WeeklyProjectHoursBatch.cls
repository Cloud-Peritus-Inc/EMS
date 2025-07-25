global class WeeklyProjectHoursBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        /*Date weekStart = Date.today().toStartOfWeek() + 1;
        System.debug('Calculated week start date = ' + weekStart);*/
        Date weekStart = Date.today().toStartOfWeek() - 6;
		System.debug('Calculated LAST week start date = ' + weekStart);

        return Database.getQueryLocator([
            SELECT Id, EMS_TM_Project__c, Project_Task__c,
                   EMS_TM_Mon__c, EMS_TM_Tue__c, EMS_TM_Wed__c,
                   EMS_TM_Thu__c, EMS_TM_Fri__c, EMS_TM_Sat__c, EMS_TM_Sun__c,
                   EMS_Timesheet__r.Week_Start_Date__c
            FROM EMS_TM_Timesheet_Record__c
            WHERE EMS_Timesheet__r.Week_Start_Date__c = :weekStart
        ]);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {
        System.debug('Timesheet records received = ' + scope.size());

        Map<Id, Decimal> projectHoursMap = new Map<Id, Decimal>();
        Map<String, Decimal> taskHoursMap = new Map<String, Decimal>();
        Set<Id> allProjectIds = new Set<Id>();
        Set<String> taskNameSet = new Set<String>();

        for (EMS_TM_Timesheet_Record__c record : (List<EMS_TM_Timesheet_Record__c>)scope) {
            Decimal total = 0;
            total += record.EMS_TM_Mon__c != null ? record.EMS_TM_Mon__c : 0;
            total += record.EMS_TM_Tue__c != null ? record.EMS_TM_Tue__c : 0;
            total += record.EMS_TM_Wed__c != null ? record.EMS_TM_Wed__c : 0;
            total += record.EMS_TM_Thu__c != null ? record.EMS_TM_Thu__c : 0;
            total += record.EMS_TM_Fri__c != null ? record.EMS_TM_Fri__c : 0;
            total += record.EMS_TM_Sat__c != null ? record.EMS_TM_Sat__c : 0;
            total += record.EMS_TM_Sun__c != null ? record.EMS_TM_Sun__c : 0;

            System.debug('Record ID: ' + record.Id + ' | Total Hours: ' + total);

            // Project hours aggregation
            if (record.EMS_TM_Project__c != null) {
                allProjectIds.add(record.EMS_TM_Project__c);
                Decimal existing = projectHoursMap.containsKey(record.EMS_TM_Project__c)
                    ? projectHoursMap.get(record.EMS_TM_Project__c) : 0;
                projectHoursMap.put(record.EMS_TM_Project__c, existing + total);
            }

            // Task hours aggregation based on Project_Task__c name
            if (String.isNotBlank(record.Project_Task__c)) {
                String taskName = record.Project_Task__c.trim();
                taskNameSet.add(taskName);
                Decimal existing = taskHoursMap.containsKey(taskName) ? taskHoursMap.get(taskName) : 0;
                taskHoursMap.put(taskName, existing + total);
                System.debug('Task Name: ' + taskName + ' | Aggregated Hours = ' + taskHoursMap.get(taskName));
            }
        }

        System.debug('Project IDs Collected: ' + allProjectIds);
        System.debug('Task Names Collected: ' + taskNameSet);

        // Fetch actual task records using names
        Map<String, Project_Task__c> taskNameToTaskMap = new Map<String, Project_Task__c>();
        for (Project_Task__c task : [
            SELECT Id, Name, Estimated_Hours__c
            FROM Project_Task__c
            WHERE Name IN :taskNameSet
        ]) {
            taskNameToTaskMap.put(task.Name.trim(), task);
        }

        System.debug('Matched Tasks from DB: ' + taskNameToTaskMap.keySet());

        // Prepare task updates
        List<Project_Task__c> tasksToUpdate = new List<Project_Task__c>();
        for (String taskName : taskHoursMap.keySet()) {
            if (taskNameToTaskMap.containsKey(taskName)) {
                Project_Task__c task = taskNameToTaskMap.get(taskName);
                task.Reported_Hours__c = taskHoursMap.get(taskName);
                tasksToUpdate.add(task);
                System.debug('Updating Task ID: ' + task.Id + ' | Name = ' + task.Name + ' | Reported Hours = ' + task.Reported_Hours__c);
            } else {
                System.debug('Task Name not found in DB: ' + taskName);
            }
        }

        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
            System.debug('TASKS UPDATED: ' + tasksToUpdate.size());
        } else {
            System.debug('No tasks to update');
        }

        // Fetch and update project records
        List<EMS_TM_Project__c> projectsToUpdate = new List<EMS_TM_Project__c>();
        for (EMS_TM_Project__c project : [
            SELECT Id, Estimated_Hours__c
            FROM EMS_TM_Project__c
            WHERE Id IN :allProjectIds
        ]) {
            Decimal reported = projectHoursMap.get(project.Id);
            project.Reported_Hours__c = reported;

            if (project.Estimated_Hours__c != null && reported > project.Estimated_Hours__c) {
                project.Comments__c = 'Reported hours (' + reported + ') exceeded estimated hours (' + project.Estimated_Hours__c + ').';
                System.debug('Comment added for Project ID: ' + project.Id + ' | ' + project.Comments__c);
            } else {
                project.Comments__c = null;
            }

            projectsToUpdate.add(project);
        }

        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
            System.debug('PROJECTS UPDATED: ' + projectsToUpdate.size());
        } else {
            System.debug('No projects to update');
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('FINISH METHOD: Batch completed.');
    }
}