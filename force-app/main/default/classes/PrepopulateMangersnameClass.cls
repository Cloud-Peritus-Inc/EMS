public class PrepopulateMangersnameClass implements triggerAction.BeforeInsert { 
    
    private static String HYDERABAD = 'Hyderabad - India';
    private static String USA = 'California - USA';
    private static String Client_Projects = 'Client Projects';
    private static String Global_Projects = 'Global Projects';
    private static String Internal_Projects = 'Internal Projects';

    
    public void beforeInsert(List<EMS_TM_Timesheet_Record__c> timeSheetLineItemrec) {      
        System.debug(LoggingLevel.DEBUG, 'PrepopulateMangersnameClass.beforeInsert() : BEGIN');
        populatingthemanagersMethod(timeSheetLineItemrec);
        System.debug(LoggingLevel.DEBUG, 'PrepopulateMangersnameClass.beforeInsert() : END');       
    }
    
    public  void populatingthemanagersMethod(List<EMS_TM_Timesheet_Record__c> timeSheetLineItemrec){
        System.debug(' *** INSIDE submitAndProcessApprovalRequestHelper ***  ');
       
        for (EMS_TM_Timesheet_Record__c timesheetproject : timeSheetLineItemrec) {
                EMS_TM_Project__c tslProjRec = [SELECT Id,Type_Of_Project__c,Project_Manager__c,Project_Manager__r.EMS_TM_User__c,Offshore_Project_Manager__c,
                                                Offshore_Project_Manager__r.EMS_TM_User__c
                                                From EMS_TM_Project__c
                                                WHERE Id =: timesheetproject.EMS_TM_Project__c];
                System.debug('Project Record' + tslProjRec);
                System.debug('Project Record 1 ' + tslProjRec.Project_Manager__r.EMS_TM_User__c);
                System.debug('Project Record 2 ' + tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c);
                /*List<User> users = [ SELECT Id, Name, ContactId, SenderEmail 
                                    FROM User 
                                    WHERE Id IN (:tslProjRec.Project_Manager__r.EMS_TM_User__c, :tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c)];
                System.debug('users' + users.toString()); */
            
            List<Contact> resConList = new List<Contact>();
            if(timesheetproject.Assignment__c != null){
               resConList = [SELECT Id,Name,Work_Location__c,Work_Location__r.Name,
                                            Ems_tm_user__c,
                                            Ems_tm_user__r.Name,
                                            Ems_tm_user__r.Email,
                                            Ems_tm_user__r.UserName
                                            FROM contact
                                            WHERE Id IN ( SELECT EMS_TM_EmployeeName__c FROM EMS_TM_Assignment__c WHERE Id =: timesheetproject.Assignment__c)];
                System.debug('resConList Values :' + resConList); 
            }else{
               
                 resConList = [SELECT Id,Name,Work_Location__c,Work_Location__r.Name,
                                            Ems_tm_user__c,
                                            Ems_tm_user__r.Name,
                                            Ems_tm_user__r.Email,
                                            Ems_tm_user__r.UserName
                                            FROM contact
                                            WHERE Id IN ( Select  Resource__c from EMS_Timesheet__c where Id =: timesheetproject.EMS_Timesheet__c)];
                System.debug('resConList Values1 :' + resConList.toString()); 
            }
            
                
                //resConList iteration end
                For(Contact con : resConList){
                    System.debug('Inside Contact For Loop');
                    Map<Id, Resource_Resource_Relationship__c> resourceMap = new Map<Id, Resource_Resource_Relationship__c>();
                    for (Resource_Resource_Relationship__c resource : [SELECT Id, Resource__r.Name, Resource__r.Email, Resource__c, Resource_Reports_To__r.EMS_TM_User__c, Resource_Reports_To__r.Email, Resource_Reports_To__c, Resource_Reports_To__r.Name, Resource__r.EMS_TM_User__c,Relationship_Type__c
                                                                       FROM Resource_Resource_Relationship__c
                                                                       WHERE Resource__c = :con.Id]) { 
                                                                           //smaske: [25/Sep/2024] :[PM_Def_208] : Replacing 'Leave Approver' with 'Resource Manager'
                                                                         if(resource.Relationship_Type__c.contains('Resource Manager')){
                                                                               resourceMap.put(resource.Resource_Reports_To__r.EMS_TM_User__c, resource);
																			}
                                                                       }
                    System.debug('resourceMap Value 1' + resourceMap.toString());
                    system.debug('thte tsl project type'+tslProjRec.Type_Of_Project__c);
                    system.debug('thte tsl con.Work_Location__r.Name '+con.Work_Location__r.Name);
                    system.debug('thte tsl project type'+con.Work_Location__c);
                    
                    if(tslProjRec.Type_Of_Project__c == Global_Projects && !resourceMap.isEmpty()){
                            List<Id> idList = new List<Id>(resourceMap.Keyset());
                            timesheetproject.Timesheet_Approver__c=idList[0];
                        String approverName = getUserName(timesheetproject.Timesheet_Approver__c);
                        System.debug('## approverName' + approverName);
                            timesheetproject.ApproverLastName__c = getUserName(timesheetproject.Timesheet_Approver__c);
                    }else{
                        //Location Based Approval for CLIENT PROJECTS 
                        if(con.Work_Location__c != null && con.Work_Location__r.Name == HYDERABAD && (tslProjRec.Type_Of_Project__c ==Client_Projects || tslProjRec.Type_Of_Project__c == Internal_Projects)){
                              timesheetproject.Timesheet_Approver__c = tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c;
                              timesheetproject.ApproverLastName__c = getUserName(timesheetproject.Timesheet_Approver__c);
                        }else if(con.Work_Location__c != null && con.Work_Location__r.Name ==USA && (tslProjRec.Type_Of_Project__c ==Client_Projects || tslProjRec.Type_Of_Project__c == Internal_Projects)){
                               timesheetproject.Timesheet_Approver__c=tslProjRec.Project_Manager__r.EMS_TM_User__c;
                               timesheetproject.ApproverLastName__c = getUserName(timesheetproject.Timesheet_Approver__c);
                        }
                    }
                } 
            
        } 
    } 
    
    public static String getUserName(Id approverId){
    User users1 = [SELECT Id, FirstName, LastName FROM User WHERE Id = :approverId LIMIT 1];
    if (users1 != null) {
        if (!String.isBlank(users1.FirstName)) {
            return users1.FirstName + ' ' + users1.LastName;
        } else {
            return users1.LastName;
        }
    }
    return null;
}
}