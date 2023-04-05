global class BatchtoUpdateLeavesInTimesheet implements Database.Batchable<sObject>{
    
    
global date weekStart ;
global date weekEnd ;    
    
  global  BatchtoUpdateLeavesInTimesheet(){
        date todaydate = system.today();
        Date considerDate = todaydate.toStartofWeek();
        this.weekStart = considerDate.toStartofWeek().addDays(1);
        this.weekEnd = considerDate.toStartofWeek().addDays(7); 
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        date dt = system.today().adddays(1);
        Id annualLeaveType = [SELECT Id FROM EMS_LM_Leave__c WHERE Name = 'Annual Leave'].Id;
        return Database.getQueryLocator([SELECT Id,Email,Name,EMS_TM_user__c,Work_Location__c,
                                         (SELECT Id,Week_Start_Date__c,Week_End_Date__c,EMS_TM_Week__c,User__c FROM Timesheets__r 
                                          WHERE Week_Start_Date__c =:weekStart AND Week_End_Date__c =:weekEnd LIMIT 1 ),
                                         (SELECT Id, EMS_LM_Leave_Start_Date__c,EMS_LM_Leave_End_Date__c
                                                FROM Leaves_History__r
                                                WHERE  EMS_LM_Status__c = 'Approved' AND EMS_LM_Leave_Type__c =:annualLeaveType
                                                AND (EMS_LM_Leave_Start_Date__c <=:dt OR  EMS_LM_Leave_End_Date__c>=:dt))
                                         FROM Contact 
                                         WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                                          AND EMS_RM_ApplicantStatus_Update__c = 'Active' AND Timesheet_NoNeed__c = false AND id='0035200000n04s2AAA' ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        System.debug('=====conList======='+conList);
        date tmrDate = system.today().adddays(1);
        EMS_TM_Project__c projRec =[SELECT Id, Name FROM EMS_TM_Project__c where Name ='OOO' limit 1];
        Map<Id,EMS_TM_Timesheet_Record__c> timesheetLineWithTs = new Map<Id,EMS_TM_Timesheet_Record__c>();
        Map<string,EMS_TM_Timesheet_Record__c> mapExistingCheck1 = new Map<String,EMS_TM_Timesheet_Record__c>();
        set<Id> timesheetIdSet = new set<Id>();
         set<Id> locationIdSet = new set<Id>();
        Map<Id,EMS_TM_Calendar__c> holidayMap = new Map<Id,EMS_TM_Calendar__c>();
        List<EMS_TM_Timesheet_Record__c> upldateList = new List<EMS_TM_Timesheet_Record__c>();
        List<EMS_TM_Timesheet_Record__c> insertList = new List<EMS_TM_Timesheet_Record__c>();
        for(Contact con : conList){
            locationIdSet.add(con.Work_Location__c);
             system.debug('==conRec===='+con.Name);
             system.debug('==conRec===='+con);
             system.debug('==conRec.Timesheets__r===='+con.Timesheets__r);
              system.debug('==conRec.Holiday===='+con.Leaves_History__r);
            if(!con.Timesheets__r.isEmpty() && !con.Leaves_History__r.isEmpty()){
               timesheetIdSet.add(con.Timesheets__r[0].Id); 
            } 
        }
         System.debug('=====timesheetIdSet======='+timesheetIdSet);
        for(EMS_TM_Timesheet_Record__c tlineItems : [SELECT Id,EMS_Timesheet__c,EMS_TM_Project__c FROM EMS_TM_Timesheet_Record__c 
                                                     WHERE EMS_TM_Project__c=:projRec.Id 
                                                     AND EMS_TM_ProjectTask__c = 'Paid time-off'
                                                     AND EMS_Timesheet__c IN:timesheetIdSet]){
            timesheetLineWithTs.put(tlineItems.EMS_Timesheet__c,tlineItems);
        } 
        System.debug('=====timesheetLineWithTs======='+timesheetLineWithTs);
         for(EMS_TM_Calendar__c calendar :[SELECT Id,Office_Location__c,EMS_TM_Calendar_Date__c 
                                          FROM EMS_TM_Calendar__c 
                                          WHERE  Office_Location__c IN:locationIdSet AND EMS_TM_Calendar_Date__c =:tmrDate ]){
           holidayMap.put(calendar.Office_Location__c,calendar);
               }
         System.debug('=====holidayMap======='+holidayMap);
        for(Contact con : conList){
            if(!con.Timesheets__r.isEmpty() && !con.Leaves_History__r.isEmpty() && !holidayMap.containsKey(con.Work_Location__c)){
               String fillTheTimeForDay=null;
                EMS_Timesheet__c currentWeekTimeSheet = con.Timesheets__r[0];
                
            for(EMS_LM_Leave_History__c leaveRec : con.Leaves_History__r){
                Date startDate = leaveRec.EMS_LM_Leave_Start_Date__c;
                Date endDate = leaveRec.EMS_LM_Leave_End_Date__c;
                integer leaveduration = endDate.daysBetween(startDate);
                for(Integer i=0 ; i<=leaveduration; i++){
                    Date processDate = startDate;
                    if(processDate == tmrDate){
                       Date d = startDate;
                      Datetime dt = (DateTime)d;
                       fillTheTimeForDay = dt.format('EEEE'); 
                       break;  
                    }
                    processDate.adddays(i);
                }           
            }
                if(fillTheTimeForDay != null && timesheetLineWithTs.containsKey(currentWeekTimeSheet.Id)){
                   EMS_TM_Timesheet_Record__c lineitem =  timesheetLineWithTs.get(currentWeekTimeSheet.Id);
                    If(fillTheTimeForDay =='Monday'){
                        lineitem.EMS_TM_Mon__c = 8;
                    } else if(fillTheTimeForDay =='Tuesday'){
                        lineitem.EMS_TM_Tue__c = 8;
                    }else if(fillTheTimeForDay =='Wednesday'){
                        lineitem.EMS_TM_Wed__c = 8;
                    }else If(fillTheTimeForDay =='Thursday'){
                        lineitem.EMS_TM_Thu__c = 8;
                    }else If(fillTheTimeForDay =='Friday'){
                        lineitem.EMS_TM_Fri__c = 8;
                    } 
                    upldateList.add(lineitem);
                }else{
                    EMS_TM_Timesheet_Record__c lineitem = new EMS_TM_Timesheet_Record__c();
                    lineitem.EMS_Timesheet__c = currentWeekTimeSheet.Id;
                    lineitem.OwnerId = currentWeekTimeSheet.user__c;
                    lineitem.EMS_TM_ProjectTask__c = 'Paid time-off';
                    lineitem.EMS_TM_Project__c = projRec.Id;
                    lineitem.EMS_TM_Mon__c = 0;
                    lineitem.EMS_TM_Wed__c = 0;
                    lineitem.EMS_TM_Tue__c = 0;
                    lineitem.EMS_TM_Thu__c = 0;
                    lineitem.EMS_TM_Fri__c = 0;
                    If(fillTheTimeForDay =='Monday'){
                        lineitem.EMS_TM_Mon__c = 8;
                    } else if(fillTheTimeForDay =='Tuesday'){
                        lineitem.EMS_TM_Tue__c = 8;
                    }else if(fillTheTimeForDay =='Wednesday'){
                        lineitem.EMS_TM_Wed__c = 8;
                    }else If(fillTheTimeForDay =='Thursday'){
                        lineitem.EMS_TM_Thu__c = 8;
                    }else If(fillTheTimeForDay =='Friday'){
                        lineitem.EMS_TM_Fri__c = 8;
                    }                               
                    lineitem.Status__c = 'Saved'; 
                    insertList.add(lineitem);
                } 
            }
        }
        system.debug('=====upldateList===='+upldateList);
        system.debug('=====insertList===='+insertList);
        try{
            update upldateList;
            insert insertList;
        }catch(exception ex){
            system.debug('=====LeaveEx===='+ex);
            LogException.logHandledException(ex, 'BatchtoUpdateLeavesInTimesheet', 'execute');
        }
        
        List<EMS_Timesheet__c> finaltimesheetrollup = new List<EMS_Timesheet__c>();
        for(AggregateResult finalhours : [SELECT EMS_Timesheet__c timeva,
                                          SUM(EMS_TM_Mon__c) mon,
                                          SUM(EMS_TM_TUE__c) tues,
                                          SUM(EMS_TM_WED__c) wed,
                                          SUM(EMS_TM_Thu__c) thrus,
                                          SUM(EMS_TM_FRI__c) fri
                                          FROM EMS_TM_Timesheet_Record__c WHERE Id IN:timesheetIdSet GROUP BY EMS_Timesheet__c]){
            
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
    
    global void finish(Database.BatchableContext BC) {
        
    }

}