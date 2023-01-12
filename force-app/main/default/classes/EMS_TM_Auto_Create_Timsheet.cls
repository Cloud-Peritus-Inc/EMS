global class EMS_TM_Auto_Create_Timsheet implements Schedulable {
    global void execute(SchedulableContext cnt) {

        List<Id> newTimesheetUsers = new List<Id>();
        List<Id> timesheetUsers = new List<Id>();
        List<Id> profileIds = new List<Id>();
        List<EMS_Timesheet__c> newTimeSheets = new List<EMS_Timesheet__c>();

        Date today = Date.today();
        Date weekStart = today.toStartofWeek().addDays(1);
        Date weekEnd = today.toStartofWeek().addDays(7);
        String completeWeek = weekStart + ' - ' + weekEnd;

        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name IN :EMS_TM_GlobalConstants.USERPROFILES];
        for (Profile profile : profileList) {
            profileIds.add(profile.Id);
        }

        List<EMS_Timesheet__c> timeSheets = [SELECT Id, User__c, EMS_TM_Week__c
                                                FROM EMS_Timesheet__c
                                                WHERE EMS_TM_Week__c = :weekStart];
        for (EMS_Timesheet__c timesheet : timeSheets) {
            timesheetUsers.add(timesheet.user__c);
        }

        List<User> usersList = [SELECT Id, ProfileId, FirstName, LastName, Name FROM User WHERE ProfileId IN :profileIds AND UserRole.name !='Leadership' And isActive = true];
        for (User user : usersList) {
            if (!(timesheetUsers.contains(user.Id))) {
                newTimesheetUsers.add(user.Id);
            }
        }

        for (Id userId : newTimesheetUsers) {
            EMS_Timesheet__c timesheet = new EMS_Timesheet__c();
            timesheet.EMS_TM_Sun__c                         = 0;
            timesheet.EMS_TM_Mon__c                         = 0;
            timesheet.EMS_TM_Tue__c                         = 0;
            timesheet.EMS_TM_Wed__c                         = 0;
            timesheet.EMS_TM_Thu__c                         = 0;
            timesheet.EMS_TM_Fri__c                         = 0;
            timesheet.EMS_TM_Sat__c                         = 0;
            timesheet.EMS_TM_Week__c                        = weekStart;
         //   timesheet.Complete_Week__c                      = completeWeek;
            timesheet.EMS_TM_Status__c                      = EMS_TM_GlobalConstants.STATUS_SAVED;
            timesheet.User__c                               = userId;
            timesheet.OwnerId                               = userId;
            newTimeSheets.add(timesheet);
        }

        Database.insert(newTimeSheets, false);
    }
}