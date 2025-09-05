global class WeeklyProjectHoursBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date weekStart = Date.today().toStartOfWeek() - 6;
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
        Map<Id, Decimal> projectHoursMap = new Map<Id, Decimal>();
        Set<Id> allProjectIds = new Set<Id>();
        Set<String> taskNameSet = new Set<String>();
        Map<String, Decimal> taskHoursMap = new Map<String, Decimal>();

        // Aggregate hours
        for (EMS_TM_Timesheet_Record__c record : (List<EMS_TM_Timesheet_Record__c>)scope) {
            Decimal total = 0;
            total += record.EMS_TM_Mon__c != null ? record.EMS_TM_Mon__c : 0;
            total += record.EMS_TM_Tue__c != null ? record.EMS_TM_Tue__c : 0;
            total += record.EMS_TM_Wed__c != null ? record.EMS_TM_Wed__c : 0;
            total += record.EMS_TM_Thu__c != null ? record.EMS_TM_Thu__c : 0;
            total += record.EMS_TM_Fri__c != null ? record.EMS_TM_Fri__c : 0;
            total += record.EMS_TM_Sat__c != null ? record.EMS_TM_Sat__c : 0;
            total += record.EMS_TM_Sun__c != null ? record.EMS_TM_Sun__c : 0;

            if (record.EMS_TM_Project__c != null) {
                allProjectIds.add(record.EMS_TM_Project__c);
                Decimal existing = projectHoursMap.containsKey(record.EMS_TM_Project__c)
                    ? projectHoursMap.get(record.EMS_TM_Project__c) : 0;
                projectHoursMap.put(record.EMS_TM_Project__c, existing + total);
            }

            if (String.isNotBlank(record.Project_Task__c)) {
                String taskName = record.Project_Task__c.trim();
                taskNameSet.add(taskName);
                Decimal existing = taskHoursMap.containsKey(taskName) ? taskHoursMap.get(taskName) : 0;
                taskHoursMap.put(taskName, existing + total);
            }
        }

        List<EMS_TM_Project__c> projectsToUpdate = new List<EMS_TM_Project__c>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        EmailTemplate template;
        if (!Test.isRunningTest()) {
            template = [
                SELECT Id FROM EmailTemplate 
                WHERE DeveloperName = 'Estimated_Hours_Exceeds_Email_Notification' 
                LIMIT 1
            ];
        }

        for (EMS_TM_Project__c project : [
            SELECT Id, Name, Estimated_Hours__c,
                   Project_Manager__c, Project_Manager__r.Email,
                   Offshore_Project_Manager__c, Offshore_Project_Manager__r.Email
            FROM EMS_TM_Project__c
            WHERE Id IN :allProjectIds
        ]) {
            Decimal reported = projectHoursMap.get(project.Id);
            project.Reported_Hours__c = reported;

            if (project.Estimated_Hours__c != null && reported > project.Estimated_Hours__c) {
                project.Comments__c = 'Reported hours (' + reported + 
                                      ') exceeded estimated hours (' + project.Estimated_Hours__c + ').';

                if (!Test.isRunningTest()) {
                    List<Id> managerIds = new List<Id>();
                    if (project.Project_Manager__c != null) {
                        managerIds.add(project.Project_Manager__c);
                    }
                    if (project.Offshore_Project_Manager__c != null) {
                        managerIds.add(project.Offshore_Project_Manager__c);
                    }
                    for (Id managerId : managerIds) {
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(managerId);
                        mail.setTemplateId(template.Id);
                        mail.setWhatId(project.Id);
                        mail.setSaveAsActivity(false);
                        emailsToSend.add(mail);
                    }
                }
            } else {
                project.Comments__c = null;
            }
            projectsToUpdate.add(project);
        }

        if (!projectsToUpdate.isEmpty()) {
            update projectsToUpdate;
        }
        if (!emailsToSend.isEmpty() && !Test.isRunningTest()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch completed.');
    }

    // Inner Scheduler class
    global class WeeklyProjectHoursScheduler implements Schedulable {
        global void execute(SchedulableContext sc) {
            WeeklyProjectHoursBatch batch = new WeeklyProjectHoursBatch();
            Database.executeBatch(batch, 200); 
        }
    }
}