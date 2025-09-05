@isTest
public class WeeklyProjectHoursSchedulerTest {

    @isTest
    static void testSchedulerRunsBatch() {

        Resource_Role__c role = new Resource_Role__c(Name = 'Dev Role');
        insert role;

        Account acc = new Account(Name = 'Scheduler Test Account');
        insert acc;

        Id recTypeId = [SELECT Id FROM RecordType 
                        WHERE SObjectType = 'Contact' 
                        AND DeveloperName = 'Resource' 
                        LIMIT 1].Id;

        Contact con = new Contact(
            LastName = 'Scheduler Contact',
            AccountId = acc.Id,
            Resource_Role__c = role.Id,
            RecordTypeId = recTypeId,
            Email = 'sched@test.com'
        );
        insert con;

        EMS_TM_Project__c project = new EMS_TM_Project__c(
            Name = 'Scheduled Project',
            Estimated_Hours__c = 5,
            Project_Manager__c = con.Id,
            Offshore_Project_Manager__c = con.Id,
            EMS_TM_StartDate__c = System.today(),
            EMS_TM_EndDate__c = System.today().addDays(7),
            Type_Of_Project__c = 'Client Projects'
        );
        insert project;

        EMS_Timesheet__c timesheet = new EMS_Timesheet__c(
            Week_Start_Date__c = Date.today().toStartOfWeek() - 6
        );
        insert timesheet;

        EMS_TM_Timesheet_Record__c record = new EMS_TM_Timesheet_Record__c(
            EMS_TM_Project__c = project.Id,
            EMS_TM_Mon__c = 2, EMS_TM_Tue__c = 2, EMS_TM_Wed__c = 2,
            EMS_TM_Thu__c = 0, EMS_TM_Fri__c = 0,
            EMS_Timesheet__c = timesheet.Id,
            Project_Task__c = 'Development'
        );
        insert record;

        Test.startTest();
        String cron = '0 0 0 * * ?'; 
        String jobId = System.schedule('Test Weekly Scheduler', cron, new WeeklyProjectHoursScheduler());
        Test.stopTest();

        EMS_TM_Project__c updatedProject = [
            SELECT Reported_Hours__c, Comments__c 
            FROM EMS_TM_Project__c 
            WHERE Id = :project.Id
        ];
    }
}