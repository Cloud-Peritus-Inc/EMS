public class NotifyTesting {
    public static void getingcont(){
         Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        System.debug('===weekStart==='+weekStart);
        System.debug('===weekEnd==='+weekEnd);
       List<Contact> Contctwotc = [select id,name from contact where id not in(select resource__c from EMS_Timesheet__C where Week_Start_Date__c>=:weekStart AND Week_End_Date__c<=:weekEnd)];
                                 system.debug('Contctwotc==========='+Contctwotc);
// Map to store project manager Ids and their corresponding projects
Map<Id, List<EMS_TM_Project__c>> managerToProjectsMap = new Map<Id, List<EMS_TM_Project__c>>();

// Map to store project Ids and their corresponding contacts
Map<Id, List<Id>> projectToContactsMap = new Map<Id, List<Id>>();

// Map to store contact Ids and their corresponding timesheets
Map<Id, List<EMS_Timesheet__c>> contactToTimesheetsMap = new Map<Id, List<EMS_Timesheet__c>>();

// Query for projects assigned to project managers
for (EMS_TM_Project__c project : [SELECT Id, Project_Manager__c, Offshore_Project_Manager__c
                                   FROM EMS_TM_Project__c where EMS_TM_Status__c='Active'
                                   ]) {
    if (!managerToProjectsMap.containsKey(project.Project_Manager__c)) {
        managerToProjectsMap.put(project.Project_Manager__c, new List<EMS_TM_Project__c>());
    }
    managerToProjectsMap.get(project.Project_Manager__c).add(project);

if (!managerToProjectsMap.containsKey(project.Offshore_Project_Manager__c)) {
        managerToProjectsMap.put(project.Offshore_Project_Manager__c, new List<EMS_TM_Project__c>());
    }
    managerToProjectsMap.get(project.Offshore_Project_Manager__c).add(project);
}
    
// Query for contacts assigned to projects
for (EMS_TM_Assignment__c assignment : [SELECT Id, EMS_TM_EmployeeName__c, EMS_TM_ProjectName_Asgn__c FROM EMS_TM_Assignment__c WHERE EMS_TM_ProjectName_Asgn__c IN :managerToProjectsMap.keySet()]) {
    if (!projectToContactsMap.containsKey(assignment.EMS_TM_ProjectName_Asgn__c)) {
        projectToContactsMap.put(assignment.EMS_TM_ProjectName_Asgn__c, new List<Id>());
    }
    projectToContactsMap.get(assignment.EMS_TM_ProjectName_Asgn__c).add(assignment.EMS_TM_EmployeeName__c);
}
/*
for (EMS_Timesheet__c timesheet : [SELECT Id, Resource__c FROM EMS_Timesheet__c WHERE Resource__c IN :projectToContactsMap.values()]) {
    if (!contactToTimesheetsMap.containsKey(timesheet.Resource__c)) {
        contactToTimesheetsMap.put(timesheet.Resource__c, new List<EMS_Timesheet__c>());
    }
    contactToTimesheetsMap.get(timesheet.Resource__c).add(timesheet);
}
*/
//List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

// Prepare email messages for each project manager
List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

for (Contact manager : Contctwotc) {
    List<String> employeesWithoutTimesheets = new List<String>();
    for (EMS_TM_Project__c project : managerToProjectsMap.get(manager.Id)) {
        for (Id contactId : projectToContactsMap.get(project.Id)) {
            if (!contactToTimesheetsMap.containsKey(contactId) || contactToTimesheetsMap.get(contactId).isEmpty()) {
                employeesWithoutTimesheets.add(contactId);
            }
        }
    }

    // Prepare email message
    if (!employeesWithoutTimesheets.isEmpty()) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject('Employees without timesheets');
        email.setHtmlBody('Dear ' + manager.Name + ',<br><br>' +
                         'The following employees have not submitted their timesheets:<br>' +
                         String.join(employeesWithoutTimesheets, ', ') +
                         '<br><br>Regards,<br>Your Company');
        email.setToAddresses(new List<String>{manager.Email});
        emailMessages.add(email);
    }
}

// Send the email messages
if (!emailMessages.isEmpty()) {
    Messaging.sendEmail(emailMessages);
}
        /*
         Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        System.debug('===weekStart==='+weekStart);
        System.debug('===weekEnd==='+weekEnd);
        list<string> Project=new list<string>();
        set<string> pmid=new set<string>();
        map<id,list<string>> mangerwithcontact=new map<id,list<string>>();
         Map<Id, List<Contact>> projectContactMap = new Map<Id, List<Contact>>();
        list<contact> con=[select id,Name from contact where id not in(select Resource__c FROM EMS_Timesheet__c where Week_Start_Date__c>=:weekStart AND Week_End_Date__c<=:weekEnd)];
        for(EMS_TM_Assignment__c ass:[select id,EMS_TM_ProjectName_Asgn__c,EMS_TM_EmployeeName__c,EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c from EMS_TM_Assignment__c where EMS_TM_EmployeeName__c In:Con]){
            Project.Add(ass.EMS_TM_ProjectName_Asgn__c);
            Id projectId = ass.EMS_TM_ProjectName_Asgn__c;
            ID contact = ass.EMS_TM_EmployeeName__c;
             if (!projectContactMap.containsKey(projectId)) {
                projectContactMap.put(projectId, new List<Contact>());
            }
            
            // Add the contact to the list associated with the project
            projectContactMap.get(projectId).add(contact);
            
            //mangerwithcontact.put(ass.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,ass.EMS_TM_EmployeeName__c);
        }
        */
    }

    
}