/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToCreateTimesheets Batch to send  
*              
*               Schedule class 
*               - BatchToCreateTimesheets_sch
*               Test code coverage provided by the following test class:
*               - BatchToCreateTimesheets_Test 
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global without sharing class BatchToCreateTimesheets implements Database.Batchable<sObject> {
global date weekStart ;
global date weekEnd ;    
    
  global  BatchToCreateTimesheets(){
        date todaydate = system.today();
        Date considerDate = todaydate.toStartofWeek();
        this.weekStart = considerDate.toStartofWeek().addDays(1);
        this.weekEnd = considerDate.toStartofWeek().addDays(7); 
    }
 /**
* @author Subba
* @date 22/01/2023
* @description start query to get the data of the object that required to process.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        date dt = system.today();
        return Database.getQueryLocator([SELECT Id,Email,Name,EMS_TM_user__c,Work_Location__c,
                                         (SELECT Id,EMS_TM_ProjectName_Asgn__c,EMS_TM_EmployeeName__c,EMS_TM_AssignedAs__c FROM Assignments__r 
                                         	WHERE EMS_TM_StartDate_Asgn__c <=:dt AND (EMS_TM_EndDate_Asgn__c >=:dt OR EMS_TM_EndDate_Asgn__c =NULL)),
                                         (SELECT Id,Week_Start_Date__c,Week_End_Date__c,EMS_TM_Week__c FROM Timesheets__r 
                                          WHERE Week_Start_Date__c >=:weekStart AND Week_End_Date__c<=:weekEnd  ),
                                         (SELECT Id, EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_End_Date__c
                                                FROM Leaves_History__r
                                                WHERE EMS_LM_Status__c = 'Approved' AND EMS_LM_Leave_Type_Name__c !='Work From Home'
                                                AND EMS_LM_Leave_Start_Date__c >=:weekStart AND EMS_LM_Leave_End_Date__c <=:weekEnd)
                                         FROM Contact 
                                         WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                                          AND EMS_RM_ApplicantStatus_Update__c = 'Active' AND Timesheet_NoNeed__c = false  ]);
    }


/**
* @author Subba
* @date 22/01/2023
* @description  Execute method to process the business logic.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
       
       Map<Id,Id>  contactWorkLocIds = new map<Id,Id>();
        Set<Id> contactIdSet = new Set<Id>();
       List<EMS_Timesheet__c> timesheetList = new List<EMS_Timesheet__c>();
       List<EMS_TM_Timesheet_Record__c> timesheetlineItemsList = new List<EMS_TM_Timesheet_Record__c>();
       List<EMS_TM_Timesheet_Record__c> finaltimesheetlineItemsList = new List<EMS_TM_Timesheet_Record__c>();
       List<Contact> filteredList = new List<Contact>();
       
        for(Contact conRec : conList){
          
            if(conRec.Timesheets__r.isEmpty() && !conRec.Assignments__r.isEmpty()){
                contactWorkLocIds.put(conRec.Work_Location__c,conRec.Id);
                filteredList.add(conRec);
                contactIdSet.add(conRec.Id);
                EMS_Timesheet__c timesheet = new EMS_Timesheet__c();
                timesheet.Resource__c = conRec.Id;
                timesheet.User__c = conRec.EMS_TM_user__c;
                timesheet.EMS_TM_Sun__c = 0;
                timesheet.EMS_TM_Mon__c = 0;
                timesheet.EMS_TM_Tue__c = 0;
                timesheet.EMS_TM_Wed__c = 0;
                timesheet.EMS_TM_Thu__c = 0;
                timesheet.EMS_TM_Fri__c = 0;
                timesheet.EMS_TM_Sat__c = 0;
                timesheet.EMS_TM_Status__c = EMS_TM_GlobalConstants.STATUS_SAVED;
                timesheet.Week_Start_Date__c = this.weekStart;
                timesheet.Week_End_Date__c = this.weekEnd;
                timesheet.EMS_TM_Week__c = this.weekStart;
                timesheet.OwnerId = conRec.EMS_TM_user__c;
                
                timesheetList.add(timesheet);
            }
        }
       
        database.insert(timesheetList,false);
        
        Map<Id,EMS_Timesheet__c> timesheetMap = new Map<Id,EMS_Timesheet__c>();
        
        for(EMS_Timesheet__c etc : timesheetList){
            timesheetMap.put(etc.Resource__c,etc);
        }
       
        //Insert the records for an assignment.
        for(Contact con : filteredList){
            if(timesheetMap.containsKey(con.id)){
            for(EMS_TM_Assignment__c assignments : con.Assignments__r){
                EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
                lineitem.EMS_Timesheet__c = timesheetMap.get(con.id).Id;
                lineitem.OwnerId = timesheetMap.get(con.id).User__c;
                lineitem.EMS_TM_ProjectTask__c = assignments.EMS_TM_AssignedAs__c;
                lineitem.Assignment__c = assignments.Id;
                lineitem.EMS_TM_Project__c = assignments.EMS_TM_ProjectName_Asgn__c;
                lineitem.EMS_TM_Mon__c = 0;
                lineitem.EMS_TM_Wed__c = 0;
                lineitem.EMS_TM_Tue__c = 0;
                lineitem.EMS_TM_Thu__c = 0;
                lineitem.EMS_TM_Fri__c = 0;
                lineitem.Status__c = 'Saved';
                timesheetlineItemsList.add(lineitem);
                
            }
            }
        }
        system.debug('=====timesheetlineItemsList===='+timesheetlineItemsList);
        try{
            insert timesheetlineItemsList;
            finaltimesheetlineItemsList.addAll(timesheetlineItemsList);
        }catch(exception ex){
            system.debug('=====ex===='+ex);
            LogException.logHandledException(ex, 'BatchToCreateTimesheets', 'execute');
        }
        
        /*
Holidays  calander START
*/ 
        EMS_TM_Project__c projRec =[SELECT Id, Name FROM EMS_TM_Project__c where Name ='OOO' limit 1];
        Map<Id,List<EMS_TM_Calendar__c>> contactReladMapDates = new Map<Id,List<EMS_TM_Calendar__c>>();
        for(EMS_TM_Calendar__c calendar :[SELECT Id,Office_Location__c,EMS_TM_Calendar_Date__c 
                                          FROM EMS_TM_Calendar__c 
                                          WHERE  Office_Location__c IN:contactWorkLocIds.keySet() AND EMS_TM_Calendar_Date__c>=:weekStart and EMS_TM_Calendar_Date__c<=:weekEnd ]){
                              
                                              if(contactReladMapDates.containskey(contactWorkLocIds.get(calendar.Office_Location__c))){
                                                  contactReladMapDates.get(contactWorkLocIds.get(calendar.Office_Location__c)).add(calendar);                         
                                              }else{
                                                  contactReladMapDates.put(contactWorkLocIds.get(calendar.Office_Location__c),new List<EMS_TM_Calendar__c>{calendar});
                                              }
                                          }
        Map<string,EMS_TM_Timesheet_Record__c> mapExistingCheck = new Map<String,EMS_TM_Timesheet_Record__c>();
        for(EMS_Timesheet__c timesheetRec :timesheetList){
            if(contactReladMapDates.containsKey(timesheetRec.Resource__c)){
            for(EMS_TM_Calendar__c holiday :contactReladMapDates.get(timesheetRec.Resource__c)){
                     Date d = holiday.EMS_TM_Calendar_Date__c;
                   
                    Datetime dt = (DateTime)d;
                   
                    String dayOfWeek = dt.format('EEEE');
                   
                    String uniqueKey = timesheetRec.Id+'-'+projRec.Id;
                    
                if(!mapExistingCheck.containsKey(uniqueKey)){
                    EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
                    lineitem.EMS_Timesheet__c =timesheetRec.Id;
                    lineitem.OwnerId = timesheetRec.User__c;
                    lineitem.EMS_TM_ProjectTask__c = 'Holiday';
                    lineitem.EMS_TM_Project__c = projRec.Id;
                    lineitem.EMS_TM_Mon__c = 0;
                    lineitem.EMS_TM_Wed__c = 0;
                    lineitem.EMS_TM_Tue__c = 0;
                    lineitem.EMS_TM_Thu__c = 0;
                    lineitem.EMS_TM_Fri__c = 0;
                    If(dayOfWeek =='Monday'){
                        lineitem.EMS_TM_Mon__c = 8;
                    } else if(dayOfWeek =='Tuesday'){
                        lineitem.EMS_TM_Tue__c = 8;
                    }else if(dayOfWeek =='Wednesday'){
                        lineitem.EMS_TM_Wed__c = 8;
                    }else If(dayOfWeek =='Thursday'){
                        lineitem.EMS_TM_Thu__c = 8;
                    }else If(dayOfWeek =='Friday'){
                        lineitem.EMS_TM_Fri__c = 8;
                    }                               
                    lineitem.Status__c = 'Saved';
                   mapExistingCheck.put(uniqueKey,lineitem);
                   
                }else{
                    EMS_TM_Timesheet_Record__c lineitem =  mapExistingCheck.get(uniqueKey);
                    If(dayOfWeek =='Monday'){
                        lineitem.EMS_TM_Mon__c = 8;
                    } else if(dayOfWeek =='Tuesday'){
                        lineitem.EMS_TM_Tue__c = 8;
                    }else if(dayOfWeek =='Wednesday'){
                        lineitem.EMS_TM_Wed__c = 8;
                    }else If(dayOfWeek =='Thursday'){
                        lineitem.EMS_TM_Thu__c = 8;
                    }else If(dayOfWeek =='Friday'){
                        lineitem.EMS_TM_Fri__c = 8;
                    }
                     mapExistingCheck.put(uniqueKey,lineitem);
                }
             
            }
            }
            
        }
        
      
        try{
            insert mapExistingCheck.values();
            finaltimesheetlineItemsList.addAll(mapExistingCheck.values());
        }catch(exception ex){
            system.debug('=====ex===='+ex);
            LogException.logHandledException(ex, 'BatchToCreateTimesheets1', 'execute');
        }
        
 /* Leavs
        for(Contact con : filteredList){
            if(timesheetMap.containsKey(con.id)){
            for(EMS_LM_Leave_History__c leaveRec : con.Leaves_History__r){
                    Date dt = leavREc.starDate;
                    Date d1 = endadte;
                    Date d2 = Dt-d1; 2
d2 null  {

}
for(1=1; I<= d2; i++){



}
                EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
                lineitem.EMS_Timesheet__c = timesheetMap.get(con.id).Id;
                lineitem.OwnerId = timesheetMap.get(con.id).User__c;
                lineitem.EMS_TM_ProjectTask__c = 'Paid time-off';
                lineitem.EMS_TM_Project__c = projRec.Id;
                lineitem.EMS_TM_Mon__c = 0;
                lineitem.EMS_TM_Wed__c = 0;
                lineitem.EMS_TM_Tue__c = 0;
                lineitem.EMS_TM_Thu__c = 0;
                lineitem.EMS_TM_Fri__c = 0;
                lineitem.Status__c = 'Saved';
                timesheetlineItemsList.add(lineitem);
                
            }
            }
        }
              
        
       /* LEaves ENd *///
 
        List<EMS_Timesheet__c> finaltimesheetrollup = new List<EMS_Timesheet__c>();
        for(AggregateResult finalhours : [SELECT EMS_Timesheet__c timeva,
                                          SUM(EMS_TM_Mon__c) mon,
                                          SUM(EMS_TM_TUE__c) tues,
                                          SUM(EMS_TM_WED__c) wed,
                                          SUM(EMS_TM_Thu__c) thrus,
                                          SUM(EMS_TM_FRI__c) fri
                                          FROM EMS_TM_Timesheet_Record__c WHERE Id IN:finaltimesheetlineItemsList GROUP BY EMS_Timesheet__c]){
            
        EMS_Timesheet__c timesheet = new EMS_Timesheet__c();
        timesheet.Id = (Id)finalhours.get('timeva');
        timesheet.EMS_TM_Mon__c = (Decimal)finalhours.get('mon');
        timesheet.EMS_TM_TUE__c = (Decimal)finalhours.get('tues');
        timesheet.EMS_TM_WED__c = (Decimal)finalhours.get('wed');
        timesheet.EMS_TM_Thu__c = (Decimal)finalhours.get('thrus');
        timesheet.EMS_TM_FRI__c = (Decimal)finalhours.get('fri');
         finaltimesheetrollup.add(timesheet);
                                          }
        
        database.update(finaltimesheetrollup,false);
        
    }
    
      /**
* @author Subba
* @date 22/01/2023
* @description process the failures.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
    global void finish(Database.BatchableContext BC) {
        
    }
    

}