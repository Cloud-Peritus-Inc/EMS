/**
* @author Ramakrishna 
* @date 24/01/2023
* @description  timesheetRecordApprovalProcess to Send  TimesheetRecord  to related Project Manager for Approval.
*
*               Test code coverage provided by the following test class:
*               - timesheetRecordApprovalProcessTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class timesheetRecordApprovalProcess implements TriggerAction.AfterUpdate,TriggerAction.AfterInsert {
    /**
* @author Ramakrishna
* @date 24/01/2023
* @description After Update 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    private static Boolean processing = false;
    private static String HYDERABAD = 'Hyderabad - India';
    private static String USA = 'California - USA';
    private static String Client_Projects = 'Client Projects';
    private static String Global_Projects = 'Global Projects';
    private static String Internal_Projects = '	Internal Projects';
    private static String TimesheetLineItemsApproval = 'Timesheet_Records_Approval';
    
    
    public void afterUpdate(List<EMS_TM_Timesheet_Record__c> newList,List<EMS_TM_Timesheet_Record__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterUpdate() : BEGIN');
        Map<id,EMS_TM_Timesheet_Record__c> timesheetOldMap = new Map<id,EMS_TM_Timesheet_Record__c>(oldList);
        if (!processing) {
            processing = true;
            try {
                submitAndProcessApprovalRequest(newList, timesheetOldMap);
            } finally {
                processing = false;
            }
        }
        //submitAndProcessApprovalRequest(newList,timesheetOldMap);
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterUpdate() : END');       
    }
    
    /**
* @author Ramakrishna
* @date 24/01/2023
* @description After Insert 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    
    public void afterInsert(List<EMS_TM_Timesheet_Record__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterInsert() : BEGIN');
        
        if (!processing) {
            processing = true;
            try {
                submitAndProcessApprovalRequest(newList, Null);
            } finally {
                processing = false;
            }
        }
        
        //submitAndProcessApprovalRequest(newList,Null);
        System.debug(LoggingLevel.DEBUG, 'submitAndProcessApprovalRequest.afterInsert() : END');    
        System.debug(LoggingLevel.DEBUG, 'timesheetRecAutoUpdate.afterInsert() : END');    
    }
    /**
* @author Ramakrishna
* @date 24/01/2023
* @description In this method we send timsheet record for approval for respective Manager 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    
    
    
    public void submitAndProcessApprovalRequest(List<EMS_TM_Timesheet_Record__c> newList,Map<Id,EMS_TM_Timesheet_Record__c> oldMap) {
        Map<Id,EMS_TM_Timesheet_Record__c> timeSheetLineItemIdRecMap = new Map<Id,EMS_TM_Timesheet_Record__c>();
        Map<Id,EMS_TM_Timesheet_Record__c> projectRecMap = new Map<Id,EMS_TM_Timesheet_Record__c>();
        system.debug('newlist ========================================='+newlist);
        list<Id> projectsid=new list<Id>();
        list<Id> timesheetids=new list<Id>();
        map<Id,string> projectandtype=new map<Id,string>();
        map<Id,list<EMS_Timesheet__c>> Resourcemapping=new map<Id,list<EMS_Timesheet__c>>();
        list<EMS_TM_Project__c> project=new list<EMS_TM_Project__c>();
        
        for(EMS_TM_Timesheet_Record__c timesheetproject:newList){
            
            if((oldMap != null && oldMap.get(timesheetproject.Id).Status__c != timesheetproject.Status__c && timesheetproject.Status__c != 'Saved' && timesheetproject.Status__c != 'Approved'  && timesheetproject.Status__c !='Rejected' && timesheetproject.Status__c != null) || (oldmap ==null && timesheetproject.Status__c != 'Saved' && timesheetproject.Status__c != 'Approved'  && timesheetproject.Status__c !='Rejected' && timesheetproject.Status__c != null )){
                system.debug('myproject------'+timesheetproject.EMS_TM_Project__r.Type_Of_Project__c);
                system.debug('project================'+timesheetproject.EMS_TM_Project__c);
                projectsid.add(timesheetproject.EMS_TM_Project__c);
                timesheetids.add(timesheetproject.EMS_Timesheet__c);
                projectRecMap.put(timesheetproject.EMS_TM_Project__c,timesheetproject);
                system.debug('timesheetids===================================='+timesheetids);
                //smaske
                timeSheetLineItemIdRecMap.put(timesheetproject.Id,timesheetproject);
            }
            
            // Commenting the OLD CODE as new method is implemented BELOW in HELPER
            /* 
            list<EMS_Timesheet__c> timesheets=[select Id,Name,Resource__c from EMS_Timesheet__c where Id IN :timesheetids];
            for(EMS_Timesheet__c timeshett:timesheets){
                if(Resourcemapping.containskey(timeshett.Resource__c)){
                    list<EMS_Timesheet__c> templist=Resourcemapping.get(timeshett.Resource__c);
                    templist.add(timeshett);
                    Resourcemapping.put(timeshett.Resource__c,templist);
                    //Resourcemapping.put(timeshett.Resource__c,list<EMS_Timesheet__c> timeshett);
                }else{
                    Resourcemapping.put(timeshett.Resource__c,new list<EMS_Timesheet__c> {timeshett});
                }
            }
            system.debug('Resourcemapping======================='+Resourcemapping);
            
            for(EMS_TM_Project__c projects:[select id,Type_Of_Project__c from EMS_TM_Project__c where Id IN:projectsid]){
                projectandtype.put(projects.Id,projects.Type_Of_Project__c);
            }
            
            
            Map<Id,list<EMS_TM_Timesheet_Record__c>> timeSheetRecMap = new Map<Id,list<EMS_TM_Timesheet_Record__c>>();
            System.debug('projectRecMap'+projectRecMap);
            System.debug('projectmanager query============'+[SELECT Id,Offshore_Project_Manager__c FROM EMS_TM_Project__c  WHERE Id IN:projectRecMap.keyset()]);
            for(EMS_TM_Project__c projectRec:[SELECT Id, 
                                              Offshore_Project_Manager__c
                                              FROM EMS_TM_Project__c
                                              WHERE Id IN:projectRecMap.keyset()]){
                                                  if(projectRec.Offshore_Project_Manager__c!=null){
                                                      if(timeSheetRecMap.containskey(projectRec.Offshore_Project_Manager__c)){
                                                          list<EMS_TM_Timesheet_Record__c> temlist=timeSheetRecMap.get(projectRec.Offshore_Project_Manager__c);
                                                          temlist.add(projectRecMap.get(projectRec.Id));
                                                          timeSheetRecMap.put(projectRec.Offshore_Project_Manager__c,temlist);
                                                      }else{
                                                          timeSheetRecMap.put(projectRec.Offshore_Project_Manager__c,new list<EMS_TM_Timesheet_Record__c> {projectRecMap.get(projectRec.Id)});
                                                      }
                                                  }
                                              }
            System.debug('timeSheetRecMap==================='+timeSheetRecMap);
            map<Id,Id> Resourcerequestmap=new map<Id,Id>();
            for(Resource_Resource_Relationship__c  resource : [select id,Resource__r.Name, Resource__c,Resource_Reports_To__r.EMS_TM_User__c,Resource_Reports_To__r.Email,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource__r.EMS_TM_User__c from Resource_Resource_Relationship__c WHERE Resource__c IN :Resourcemapping.keyset()]) {
                Resourcerequestmap.put(resource.Resource__c,resource.Resource_Reports_To__r.EMS_TM_User__c);
                
            } */
            
            //Calling submitAndProcessApprovalRequestHelper method
            System.debug('timeSheetLineItemIdRecMap' + timeSheetLineItemIdRecMap.toString());
            if (timeSheetLineItemIdRecMap != null && !timeSheetLineItemIdRecMap.isEmpty()) {
                submitAndProcessApprovalRequestHelper(timeSheetLineItemIdRecMap);
            }
        }
    } //submitAndProcessApprovalRequest ends
    
    /**
    * @author Shubham Maske
    * @date 15/09/2023
    * @description In this method we send timsheet record for approval based on RESOURCE(Contact) work Location.
    * NOTE 1 : IF Project Type is GLOBAL Approver will be Reporting Manager only.
	* NOTE 2 : IF Project Type is CLIENT , then APPROVER will be decided based on Contact Work Location.
    * Work Location HYDERABAD - OffShoreManager from PROJECT
    * Work Location USA - OnShoreManager from PROJECT
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    //submitAndProcessApprovalRequestHelper start
    Private Static void submitAndProcessApprovalRequestHelper(Map<Id,EMS_TM_Timesheet_Record__c> timeSheetLineItemIdRecMap){
        System.debug(' *** INSIDE submitAndProcessApprovalRequestHelper ***  ');
        //Map iteration start here
        for (EMS_TM_Timesheet_Record__c timesheetproject : timeSheetLineItemIdRecMap.values()) {
            //Status check end here
            if(timesheetproject.Status__c != 'Saved' && timesheetproject.Status__c != 'Approved'  && timesheetproject.Status__c !='Rejected' && timesheetproject.Status__c != null){
                
                List<User> onShoreUser = new List<User>();
                List<User> offShoreUser = new List<User>();
                List<User> bothOnShoreAndOffShoreUsers = new List<User>();
                Approval.ProcessSubmitRequest reqApr = new Approval.ProcessSubmitRequest();
                reqApr.setComments('Submitting request for approval.');
                reqApr.setProcessDefinitionNameOrId(TimesheetLineItemsApproval);
                reqApr.setSkipEntryCriteria(false);
                
                EMS_TM_Project__c tslProjRec = [SELECT Id,Type_Of_Project__c,Project_Manager__c,Project_Manager__r.EMS_TM_User__c,Offshore_Project_Manager__c,
                                                Offshore_Project_Manager__r.EMS_TM_User__c
                                                From EMS_TM_Project__c
                                                WHERE Id =: timesheetproject.EMS_TM_Project__c];
                System.debug('Project Record' + tslProjRec);
                System.debug('Project Record 1 ' + tslProjRec.Project_Manager__r.EMS_TM_User__c);
                System.debug('Project Record 2 ' + tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c);
                List<User> users = [ SELECT Id, Name, ContactId, SenderEmail 
                                    FROM User 
                                    WHERE Id IN (:tslProjRec.Project_Manager__r.EMS_TM_User__c, :tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c)];
                System.debug('users' + users.toString());
                for (User user : users) {
                    if (user.Id == tslProjRec.Project_Manager__r.EMS_TM_User__c && user.Id == tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c) {
                        // User is both onshore and offshore
                        bothOnShoreAndOffShoreUsers.add(user);
                    } else if (user.Id == tslProjRec.Project_Manager__r.EMS_TM_User__c) {
                        onShoreUser.add(user);
                    } else if (user.Id == tslProjRec.Offshore_Project_Manager__r.EMS_TM_User__c) {
                        offShoreUser.add(user);
                    }
                }
                
                System.debug('onShoreUser ' + onShoreUser.toString());
                System.debug('offShoreUser ' + offShoreUser.toString());
                System.debug('bothOnShoreAndOffShoreUsers ' + bothOnShoreAndOffShoreUsers.toString());
                System.debug('Project Type ' + tslProjRec.Type_Of_Project__c);
                List<Contact> resConList = new List<Contact>();
                if(timesheetproject.Assignment__c != null){
                    resConList = [SELECT Id,Name,Work_Location__c,Work_Location__r.Name,
                                  Ems_tm_user__c,
                                  Ems_tm_user__r.Name,
                                  Ems_tm_user__r.Email,
                                  Ems_tm_user__r.UserName
                                  FROM contact
                                  WHERE Id IN ( SELECT EMS_TM_EmployeeName__c FROM EMS_TM_Assignment__c WHERE Id =: timesheetproject.Assignment__c)];
                    System.debug('resConList Values1 :' + resConList);
                }else{
                    resConList = [SELECT Id,Name,Work_Location__c,Work_Location__r.Name,
                                  Ems_tm_user__c,
                                  Ems_tm_user__r.Name,
                                  Ems_tm_user__r.Email,
                                  Ems_tm_user__r.UserName
                                  FROM contact
                                  WHERE Id IN ( Select  Resource__c from EMS_Timesheet__c where Id =: timesheetproject.EMS_Timesheet__c)];
                    System.debug('resConList Values2 :' + resConList.toString());
                }
                //resConList iteration end
                For(Contact con : resConList){
                    System.debug('Inside Contact For Loop');
                    Map<Id, Resource_Resource_Relationship__c> resourceMap = new Map<Id, Resource_Resource_Relationship__c>();
                    //smaske : [PM_Def_208] : 24/Sep/2024 : Updating Querry to fetch 'Resource Manager' value as a approver.
                    for (Resource_Resource_Relationship__c resource : [SELECT Id, Resource__r.Name, Resource__r.Email, Resource__c, Resource_Reports_To__r.EMS_TM_User__c, Resource_Reports_To__r.Email, Resource_Reports_To__c, Resource_Reports_To__r.Name, Resource__r.EMS_TM_User__c,Relationship_Type__c
                                                                       FROM Resource_Resource_Relationship__c
                                                                       WHERE Resource__c = :con.Id AND Relationship_Type__c includes ('Resource Manager')]) {
                                                                           resourceMap.put(resource.Resource_Reports_To__r.EMS_TM_User__c, resource);
                                                                       }
                    System.debug('resourceMap Value 1' + resourceMap.toString());
                    
                    List<ProcessInstance> activeProcesses2 = [SELECT Id FROM ProcessInstance 
                                                              WHERE TargetObjectId = :timesheetproject.Id 
                                                              AND ( Status = 'Pending')];
                    //( Status = 'Submitted' OR Status = 'Pending')
                    System.debug('activeProcesses2 : ' + activeProcesses2);
                    
                    //GLOBAL PROJECTS APPROVAL WILL BE SET TO REPORTING MANAGER ONLY ie Related List :  (Resource Relationships (Resource))
                    if(tslProjRec.Type_Of_Project__c == Global_Projects && !resourceMap.isEmpty()){
                        System.debug('INSIDE GLOBAL PROJECTS');
                        if (activeProcesses2.isEmpty()) {
                            System.debug('INSIDE activeProcesses2');
                            reqApr = configureApprovalSubmitRequest(reqApr,timesheetproject,null,null,Global_Projects,resourceMap);
                            processApprovalRequest(reqApr);
                        }
                    }else{
                        //Location Based Approval for CLIENT PROJECTS 
                        if(con.Work_Location__c != null && con.Work_Location__r.Name == HYDERABAD && !resourceMap.isEmpty() && tslProjRec.Type_Of_Project__c == Client_Projects){
                            System.debug('INSIDE HYDERABAD');
                            if (activeProcesses2.isEmpty()) {
                                System.debug('INSIDE activeProcesses2');
                                reqApr = configureApprovalSubmitRequest(reqApr,timesheetproject,offShoreUser,bothOnShoreAndOffShoreUsers,Client_Projects,resourceMap);
                                processApprovalRequest(reqApr);
                            }
                        }else if(con.Work_Location__c != null && con.Work_Location__r.Name == USA && !resourceMap.isEmpty() && tslProjRec.Type_Of_Project__c == Client_Projects){
                            System.debug('INSIDE USA');
                            if (activeProcesses2.isEmpty()) {
                                System.debug('INSIDE activeProcesses2');
                                reqApr = configureApprovalSubmitRequest(reqApr,timesheetproject,onShoreUser,bothOnShoreAndOffShoreUsers,Client_Projects,resourceMap);
                                processApprovalRequest(reqApr);
                            }
                        }
                    }
                } //resConList iteration end
            } //Status check end here
        } //Map iteration end here
    } //submitAndProcessApprovalRequestHelper end
    
    /**
    * @author Shubham Maske
    * @date 15/09/2023
    * @description : Helper method to configure Approval.ProcessSubmitRequest Object.
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    //configureApprovalSubmitRequest starts
    public static Approval.ProcessSubmitRequest configureApprovalSubmitRequest(Approval.ProcessSubmitRequest reqApr,EMS_TM_Timesheet_Record__c timesheetproject,List<User> ShoreUser,List<User> bothOnShoreAndOffShoreUsers,String ProjectType,Map<Id, Resource_Resource_Relationship__c> resourceMap) {
        System.debug(' *** INSIDE configureApprovalSubmitRequest ***  ');
        
        if(ProjectType != Global_Projects){
            reqApr.setObjectId(timesheetproject.Id);
            reqApr.setSubmitterId(timesheetproject.OwnerId);                              
            if(ShoreUser.isEmpty()){
                reqApr.setNextApproverIds(new Id[] {bothOnShoreAndOffShoreUsers[0].Id});
            }else{
                reqApr.setNextApproverIds(new Id[] {ShoreUser[0].Id});
            }
        }else{
            reqApr.setObjectId(timesheetproject.Id);
            reqApr.setSubmitterId(timesheetproject.OwnerId);
            reqApr.setNextApproverIds(new List<Id>(resourceMap.keySet() ) );
        }                                     
        return reqApr;
    }
    //configureApprovalSubmitRequest ends
    
    /**
    * @author Shubham Maske
    * @date 15/09/2023
    * @description : Helper method to Process Approval.ProcessSubmitRequest Object.
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    //processApprovalRequest starts
    public static void processApprovalRequest(Approval.ProcessSubmitRequest reqApr) {
        System.debug(' *** INSIDE processApprovalRequest ***  ');
        System.debug(' reqApr ' + reqApr);
        try{
            Approval.ProcessResult result = Approval.process(reqApr);
            system.debug('Approval.ProcessResult.Result =========================='+result);
        }catch(Exception e){
            System.debug('Approval.ProcessResult.Exception  ------------- >>> '+e.getMessage()+e.getLineNumber());
            LogException.logHandledException(e, 'timesheetRecordApprovalProcess', 'submitAndProcessApprovalRequest');
        }
    }
    //processApprovalRequest ends
}