//This Clss is The orginal backup of BatchToNotifyTCForPM
/**
* @author Subba Kalavala
* @date 2/22/2023
* @description  BatchToNotifyTCForPM Batch to Send an pending timecards to managers 
*              
*               Schedule class 
*               - BatchToNotifyTCForPM_sch
*               Test code coverage provided by the following test class:
*               - BatchToNotifyTCForPM_Test
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global without sharing class Testingnotify implements Database.Batchable<sObject> {
//global static string link = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        global static string link=system.Label.Grid_Portal_Link  + '/';

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
        return Database.getQueryLocator([SELECT Id,Email,Name FROM Contact WHERE RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID ]);
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
       set<string> managerIds = new set<string>();
        set<string> prjIds = new set<string>();
       map<string,Contact> pmwithemail = new map<string,Contact>();
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        System.debug('===weekStart==='+weekStart);
        System.debug('===weekEnd==='+weekEnd);
        
        for(Contact Urec : conList){
          managerIds.add(Urec.Id); 
         pmwithemail.put(Urec.Id,Urec);
        }
        System.debug('***pmwithemail'+pmwithemail);
         System.debug('***managerIds'+managerIds);
        Map<Id,List<EMS_TM_Project__c>> pmWithProjects = new Map<Id,List<EMS_TM_Project__c>>();
        Map<Id,List<String>> prjWithTimeCards = new Map<Id,List<String>>();
        //timesheet
                Map<Id,set<String>> contactswithtsproject = new Map<Id,set<String>>();
        //testing
        Map<Id,List<EMS_LM_Leave_History__c>> appWithAbseReqts = new Map<Id,List<EMS_LM_Leave_History__c>>();
        Map<String,List<EMS_Timesheet__c>> resourceWithTimeCard = new Map<String,List<EMS_Timesheet__c>>();
        set<string> resourceIds = new set<String>();
        for(EMS_TM_Project__c prj : [SELECT id,Project_Manager__c,
                                     (SELECT Id,EMS_TM_EmployeeName__c,Resource_User_Id__c FROM Assignments__r WHERE EMS_TM_Status_Asgn__c = 'Active' ),
                                     (SELECT Id, Status__c, EMS_TM_Project__c, EMS_Timesheet__c,EMS_Timesheet__r.EMS_TM_Project__r.Name,
                                        EMS_Timesheet__r.Week_Start_Date__c,EMS_Timesheet__r.Week_End_Date__c,EMS_Timesheet__r.User__r.isActive,
                                        EMS_TM_Project__r.Name,EMS_Timesheet__r.Resource__r.Name,
                                        EMS_Timesheet__r.Resource__r.EMS_RM_Employee_Id__c FROM Timecard_Splits__r 
                                      WHERE EMS_Timesheet__r.User__r.isActive = true 
                                      AND EMS_Timesheet__r.Week_Start_Date__c>=:weekStart 
                                      AND EMS_Timesheet__r.Week_End_Date__c<=:weekEnd AND (EMS_Timesheet__r.EMS_TM_Total__c < 40 
                                     OR EMS_Timesheet__r.EMS_TM_Status__c = 'NEW' OR EMS_Timesheet__r.EMS_TM_Status__c = 'Saved' 
                                     OR EMS_Timesheet__r.EMS_TM_Status__c = 'Not Approved'))
                                     FROM EMS_TM_Project__c WHERE Project_Manager__c IN:managerIds AND EMS_TM_Status__c = 'Ongoing']){
                                         System.debug('DATA_Proj'+prj);
            prjIds.add(prj.Id);
            if(pmWithProjects.containsKey(prj.Project_Manager__c)){
                pmWithProjects.get(prj.Project_Manager__c).add(prj);
            }else{
                pmWithProjects.put(prj.Project_Manager__c, new List<EMS_TM_Project__c>{prj}); 
            }
              if(prj.assignments__r.size() >0){
               for(EMS_TM_Assignment__c assig : prj.assignments__r){
                   resourceIds.add(assig.Resource_User_Id__c);
                   }
               }
        }
        SYstem.debug('***pmWithProjects'+pmWithProjects+'.....'+pmWithProjects.size());
        SYstem.debug('***resourceIds'+resourceIds+'.....'+resourceIds.size());
        SYstem.debug('***prjIds'+prjIds+'....'+prjIds);
         Map<Id,List<EMS_TM_Timesheet_Record__c>> prjWithTsheets = new  Map<Id,List<EMS_TM_Timesheet_Record__c>>();
        if(!pmWithProjects.isEmpty()){
            system.debug('pmWithProjects.keySet()========================='+pmWithProjects.keySet());
            for(String pm : pmWithProjects.keySet()){
                System.debug('pm'+pm);
               List<EMS_TM_Timesheet_Record__c> timesheetsList = new List<EMS_TM_Timesheet_Record__c>(); 
             //   List<EMS_TM__Timesheet__c> timesheet=
              if(pmWithProjects.containsKey(pm)){
                    for(EMS_TM_Project__c proj : pmWithProjects.get(pm)){
                        System.debug('proj'+proj);
                        if(proj.Timecard_Splits__r.size() >0){
                           for(EMS_TM_Timesheet_Record__c ts : proj.Timecard_Splits__r){
                               system.debug('ts======================'+ts);
                               if(contactswithtsproject.containskey(ts.EMS_Timesheet__r.Resource__c)){
                                   contactswithtsproject.get(ts.EMS_Timesheet__r.Resource__c).add(ts.EMS_TM_Project__r.Name);
                               }else{
                                   list<string> tslistwithcon=new list<string>();
                                  // tslistwithcon.add(ts.EMS_Timesheet__r.EMS_TM_Project__r.Name);
                               contactswithtsproject.put(ts.EMS_Timesheet__r.Resource__c,new set<String>{ts.EMS_TM_Project__r.Name});
                                   system.debug('contactswithtsproject==========='+contactswithtsproject);
                               }
                               timesheetsList.add(ts);
                               
                              }
                         }
                        
                    } 
                }
                System.debug('timesheetsList'+timesheetsList +'.......'+timesheetsList.size());
             
              prjWithTsheets.put(pm,timesheetsList);  
            }
        }        
        System.debug('====prjWithTsheets==='+prjWithTsheets);
        System.debug('====SIZEprjWithTsheets==='+prjWithTsheets.size());
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        if(!prjWithTsheets.isEmpty()){
           Id orgWideAddressId =[SELECT Id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Grid' LIMIT 1].Id;
            for(Id pmId : prjWithTsheets.keySet()){
                System.debug('***pmId***'+pmId);
                list<string> toaddress = new list<string>();   
                //if(prjWithTsheets.containsKey(pmId) && prjWithTsheets.get(pmId).size() >0 && pmwithemail.containsKey(pmId)){
                if(prjWithTsheets.containsKey(pmId)&& pmwithemail.containsKey(pmId)){
                    System.debug('toadress EMAil'+pmwithemail.get(pmId).Email);
                   toaddress.add(pmwithemail.get(pmId).Email);
                    System.debug('***ToAddress'+toaddress);
                  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                  email.setOrgWideEmailAddressId(orgWideAddressId);
                  email.setSubject('Employee timesheets overdue');
                    System.debug('**TimesheetData'+prjWithTsheets.get(pmId));
                   string  emailbody = getTableEmailBody(prjWithTsheets.get(pmId),contactswithtsproject);
                   email.setHtmlBody('Dear '+pmwithemail.get(pmId).Name+',<br/><br/>The weekly timesheets of the following employees are overdue:<br/><br/>'+ emailbody + '<br/><br/><h3 style="text-align: center">DO NOT REPLY TO THIS EMAIL</h3>');
                   email.setToAddresses(toaddress);
                   email.setSaveAsActivity(false);
                   allMails.add(email); 
                }
            }
        }
       system.debug('====allMails===='+allMails);
        try{
            Messaging.sendEmail(allMails); 
        }catch(exception ex){
         LogException.logHandledException(ex, 'BatchToNotifyTCForPM', 'execute');     
        }
        
    } 
    
    public  string getTableEmailBody(list<EMS_TM_Timesheet_Record__c> timesheets,map<Id,set<string>> contactswithtsproject){
        
        System.debug('timesheets'+timesheets);
        
        String sday ;
        String smonth ;
        String syear;
        String eday;
        String emonth ;
        String eyear ;
        
        String htmlBody = '';
        String myName = Null;
        //open table..
        htmlBody = '<table border="1" style="border-collapse: collapse;width:80%;"><caption></caption><tr><th>S.No</th><th>Employee Id</th><th>Employee Name</th><th>Week</th></tr>';
        
        //iterate over list and output columns/data into table rows...
        if(timesheets !=null && timesheets.size()>0)
        {
            for(integer i = 0;i<timesheets.size();i++)
            {
                htmlBody += '<tr><td><center>' + (i+1) + '</center></td><td><center> <a href="'+link+'/'+timesheets[i].Id+'">'+timesheets[i].EMS_Timesheet__r.Resource__r.Name+'</a></center></td><td>'+timesheets[i].EMS_Timesheet__r.Resource__r.Name+'</td><td><center> '+timesheets[i].EMS_Timesheet__r.Week_End_Date__c +'</center> </td><td><center> '+contactswithtsproject.get(timesheets[i].EMS_Timesheet__r.Resource__r.Id)+'</center> </td></tr>';  
            }
        }
        //close table...
        htmlBody += '</table>';
        
        system.debug('Email Body: ' + htmlBody);   
        
        return htmlBody;
        
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