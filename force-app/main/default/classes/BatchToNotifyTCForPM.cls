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
global without sharing class BatchToNotifyTCForPM implements Database.Batchable<sObject> {
global static string link = URL.getSalesforceBaseUrl().toExternalForm() + '/'; //this link navigate to salesforce
global static string Cmlink=system.Label.Grid_Portal_Link  + '/';
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
        
        //smaske : Creating New Map to store Project Manager details with Contact
        map<Id,Set<contact>> mangerwithcontact = new map<Id,Set<contact>>();

        
        for(Contact Urec : conList){
          managerIds.add(Urec.Id); 
         pmwithemail.put(Urec.Id,Urec);
        }
        System.debug('***pmwithemail'+pmwithemail);
         System.debug('***managerIds'+managerIds);
        Map<Id,List<EMS_TM_Project__c>> pmWithProjects = new Map<Id,List<EMS_TM_Project__c>>();
        Map<Id,List<String>> prjWithTimeCards = new Map<Id,List<String>>();
        Map<Id,List<EMS_LM_Leave_History__c>> appWithAbseReqts = new Map<Id,List<EMS_LM_Leave_History__c>>();
        Map<String,List<EMS_Timesheet__c>> resourceWithTimeCard = new Map<String,List<EMS_Timesheet__c>>();
        set<string> resourceIds = new set<String>();
        for(EMS_TM_Project__c prj : [SELECT Id,Project_Manager__c,Project_Manager__r.Id,
                                     (SELECT Id,EMS_TM_EmployeeName__c,EMS_TM_EmployeeName__r.Id,EMS_TM_EmployeeName__r.Name,EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c, Resource_User_Id__c FROM Assignments__r WHERE EMS_TM_Status_Asgn__c = 'Active'),
                                     (SELECT Id, Status__c, EMS_TM_Project__c, EMS_Timesheet__c,
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
                                                 //smaske : Populating mangerwithcontact
                                                 if(mangerwithcontact.containsKey(prj.Project_Manager__c)){
                                                     mangerwithcontact.get(prj.Project_Manager__r.Id).add(assig.EMS_TM_EmployeeName__r);
                                                 }else{
                                                     mangerwithcontact.put(prj.Project_Manager__r.Id, new Set<Contact>{assig.EMS_TM_EmployeeName__r}); 
                                                 }
                                                 //smaske : Populating mangerwithcontact
                                             }
                                         }
        }
        
        //smaske : Searching for Contact Not Created/Saved/Submited TimeSheet Record on GRID
        List<Contact> Contctwotc = [select Id,Name,Email,EMS_RM_Employee_Id__c from contact where id not in(select resource__c from EMS_Timesheet__C where Week_Start_Date__c>=:weekStart AND Week_End_Date__c<=:weekEnd)];
        system.debug('contact without timesheet==========='+Contctwotc);
        
        for(Contact Urec : Contctwotc){
            managerIds.add(Urec.Id); 
            pmwithemail.put(Urec.Id,urec);
        }

        for(EMS_TM_Project__c prj : [SELECT id,Project_Manager__c,Project_Manager__r.Id,
                                     (SELECT Id,EMS_TM_EmployeeName__c,EMS_TM_EmployeeName__r.Id,EMS_TM_EmployeeName__r.Name,EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c,Resource_User_Id__c FROM Assignments__r WHERE EMS_TM_Status_Asgn__c = 'Active' AND EMS_TM_EmployeeName__c IN:managerIds)
                                     FROM EMS_TM_Project__c WHERE EMS_TM_Status__c = 'Ongoing']){
                                         System.debug('DATA_Proj'+prj);
                                         if(prj.assignments__r.size() >0){
                                             for(EMS_TM_Assignment__c assig : prj.assignments__r){
                                                 if(mangerwithcontact.containsKey(prj.Project_Manager__c)){
                                                     mangerwithcontact.get(prj.Project_Manager__r.Id).add(assig.EMS_TM_EmployeeName__r);
                                                 }else{
                                                     mangerwithcontact.put(prj.Project_Manager__r.Id, new Set<Contact>{assig.EMS_TM_EmployeeName__r}); 
                                                 }
                                             }
                                         }
                                     }
        //smaske : Searching for Contact Not Created/Saved/Submited TimeSheet Record on GRID

        
         
        SYstem.debug('***pmWithProjects'+pmWithProjects+'.....'+pmWithProjects.size());
        SYstem.debug('***resourceIds'+resourceIds+'.....'+resourceIds.size());
        SYstem.debug('***prjIds'+prjIds+'....'+prjIds);
         Map<Id,set<EMS_TM_Timesheet_Record__c>> prjWithTsheets = new  Map<Id,set<EMS_TM_Timesheet_Record__c>>();
        if(!pmWithProjects.isEmpty()){
            for(String pm : pmWithProjects.keySet()){
                System.debug('pm'+pm);
               set<EMS_TM_Timesheet_Record__c> timesheetsList = new set<EMS_TM_Timesheet_Record__c>(); 
              if(pmWithProjects.containsKey(pm)){
                    for(EMS_TM_Project__c proj : pmWithProjects.get(pm)){
                        System.debug('proj'+proj);
                        if(proj.Timecard_Splits__r.size() >0){
                           for(EMS_TM_Timesheet_Record__c ts : proj.Timecard_Splits__r){
                               timesheetsList.add(ts);
                              }
                         }
                        
                    } 
                }
                SYstem.debug('timesheetsList'+timesheetsList +'.......'+timesheetsList.size());
              prjWithTsheets.put(pm,timesheetsList);  
            }
        }
        
        System.debug('====prjWithTsheets==='+prjWithTsheets);
        System.debug('====SIZEprjWithTsheets==='+prjWithTsheets.size());
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        
        //smaske : Commented below method as we will be using Contact Data to Populate the Data Table in Email Body.
        /*
        if(!prjWithTsheets.isEmpty()){
           Id orgWideAddressId =[SELECT Id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Grid' LIMIT 1].Id;
            for(Id pmId : prjWithTsheets.keySet()){
                System.debug('***pmId***'+pmId);
                list<string> toaddress = new list<string>();
                if(prjWithTsheets.containsKey(pmId)&& pmwithemail.containsKey(pmId)&&prjWithTsheets.get(pmId).size() > 0){
                    System.debug('toadress EMAil'+pmwithemail.get(pmId).Email);
                   toaddress.add(pmwithemail.get(pmId).Email);
                    System.debug('***ToAddress'+toaddress);
                  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                  email.setOrgWideEmailAddressId(orgWideAddressId);
                  email.setSubject('Employee timesheets overdue');
                    System.debug('**TimesheetData'+prjWithTsheets.get(pmId));
                   string  emailbody = getTableEmailBody(prjWithTsheets.get(pmId));
                    system.debug('size of records==' +prjWithTsheets.get(pmId).size());
                   email.setHtmlBody('Dear '+pmwithemail.get(pmId).Name+',<br/><br/>The weekly timesheets of the following employees are overdue:<br/><br/>'+ emailbody + '<br/><br/><h3 style="text-align: center">DO NOT REPLY TO THIS EMAIL</h3>');
                   email.setToAddresses(toaddress);
                   email.setSaveAsActivity(false);
                   allMails.add(email); 
                }
            }
        } */
        
        //Smaske : This method replaces above method for Generating email body Data table using contact data.
        if(!mangerwithcontact.isEmpty()){
           Id orgWideAddressId =[SELECT Id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Grid' LIMIT 1].Id;
            for(Id pmId : mangerwithcontact.keySet()){
                System.debug('***pmId***'+pmId);
                list<string> toaddress = new list<string>();   
                //if(prjWithTsheets.containsKey(pmId) && prjWithTsheets.get(pmId).size() >0 && pmwithemail.containsKey(pmId)){
                if(mangerwithcontact.containsKey(pmId)&& pmwithemail.containsKey(pmId)&& mangerwithcontact.get(pmId).size() > 0){
                    //System.debug('toadress EMAil'+pmwithemail.get(pmId).Email);
                    toaddress.add(pmwithemail.get(pmId).Email);

                    System.debug('***ToAddress'+toaddress);
                  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                  email.setOrgWideEmailAddressId(orgWideAddressId);
                  email.setSubject('Employee timesheets overdue');
                       string ManagerName=pmwithemail.get(pmId).Name;
                   string  emailbody = getTableEmailBody(mangerwithcontact.get(pmId),ManagerName); // NEED TO WORK HERE
                    system.debug('size of records==' +mangerwithcontact.get(pmId).size());
                    
                   email.setHtmlBody(emailbody);
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
    
    
    //Original Method
   
    public  string getTableEmailBody(set<EMS_TM_Timesheet_Record__c> timesheetsList,string ManagerName){
        /*	Vamsi
         * Here I am changing set to list beacause In email body we are using list indexs  
         * 
         */  
        String gridLogo = System.label.Grid_Logo;
        String cpLogo = System.label.CP_Logo;
        
        List<EMS_TM_Timesheet_Record__c> timesheets = new List<EMS_TM_Timesheet_Record__c>(timesheetsList);

        System.debug('timesheets'+timesheets);
        
        String sday ;
        String smonth ;
        String syear;
        String eday;
        String emonth ;
        String eyear ;
        
        String htmlBody = '';
        String myName = Null;
                htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';

        //open table..
                  htmlBody += '<table border="2" style="width:70%; border-collapse: collapse; margin-left:0px; margin-right: auto; text-align: center;"><tr><th style="width:15%; background-color:#590099; color: #FFFFFF;">Employee Id</th><th style="width:40%; background-color:#590099; color: #FFFFFF;">Employee Name</th><th style="width:20%; background-color:#590099; color: #FFFFFF;">Week</th></tr>';
                  // htmlBody = '<table border="1" style="border-collapse: collapse;width:70%;"><caption></caption><tr><th style="width:15%; background-color:#590099; color: #FFFFFF;">S.No</th><th>Employee Id</th><th>Employee Name</th><th>Week</th></tr>';
                //htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';
        //iterate over list and output columns/data into table rows...
        if(timesheets !=null && timesheets.size()>0)
        {
            for(integer i = 0;i<timesheets.size();i++)
            {
                htmlBody += '<tr><td><center> <a href="'+link+'/'+timesheets[i].Id+'">'+timesheets[i].EMS_Timesheet__r.Resource__r.EMS_RM_Employee_Id__c	+'</a></center></td><td>'+timesheets[i].EMS_Timesheet__r.Resource__r.Name+'</td><td><center> '+timesheets[i].EMS_Timesheet__r.Week_End_Date__c +'</center> </td></tr>';  
            }
        }
        //close table...
        //htmlBody += '</table>';
        
        system.debug('Email Body: ' + htmlBody);   
         htmlBody += '</table>';
        htmlBody += '<br>';
        htmlBody += 'Regards,';
        htmlBody += '<br>';
        htmlBody += 'The Cloud Peritus Team';
        htmlBody += '<br><br>';
        htmlBody += '<p style="margin-left:220px;" ><img src="' + cpLogo + '" alt="Image Description"' + 'width="'+ 120 + '"' + ' height="' + 80+ '"></p>';
        htmlBody += '</body></html>';
        return htmlBody;
        
    }   
    
    //Smaske : New getTableEmailBody method based on Contact Data
    public Static string getTableEmailBody(Set<Contact> contactList,string ManagerName){
        Date todayval = system.today(); 
        Date considerDate = todayval.toStartofWeek().addDays(-2);
        Date weekStart = considerDate.toStartofWeek().addDays(1);
        Date weekEnd = considerDate.toStartofWeek().addDays(7);
        /*	Vamsi
         * Here I am changing set to list beacause In email body we are using list indexs  
         * 
         */  
        String gridLogo = System.label.Grid_Logo;
        String cpLogo = System.label.CP_Logo;
        
        List<Contact> contactsData = new List<Contact>(contactList);

        System.debug('contactsData ::: '+contactsData);
        
        String sday ;
        String smonth ;
        String syear;
        String eday;
        String emonth ;
        String eyear ;
        
        String htmlBody = '';
        String myName = Null;
                htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';
                htmlBody += '<br><br>';
                htmlBody +='Dear '+ManagerName +',<br/><br/>The weekly timesheets of the following employees are overdue:<br/><br/>';
        //open table..
                          htmlBody += '<table border="2" style="width:70%; border-collapse: collapse; margin-left:0px; margin-right: auto; text-align: center;"><tr><th style="width:15%; background-color:#590099; color: #FFFFFF;">Employee Id</th><th style="width:40%; background-color:#590099; color: #FFFFFF;">Employee Name</th><th style="width:20%; background-color:#590099; color: #FFFFFF;">Week</th></tr>';

        //htmlBody = '<table border="1" style="border-collapse: collapse;width:80%;"><caption></caption><tr><th>Employee Id</th><th>Employee Name</th><th>Week</th></tr>';
                //htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';
        //iterate over list and output columns/data into table rows...
        if(contactsData !=null && contactsData.size()>0)
        {
            for(integer i = 0;i<contactsData.size();i++)
            {
                htmlBody += '<tr><td><center> <a href="'+Cmlink+'/'+contactsData[i].Id+'">'+contactsData[i].EMS_RM_Employee_Id__c+'</a></center></td><td>'+contactsData[i].Name+'</td><td><center> '+weekEnd +'</center> </td></tr>';  
            }
        }
        //close table...
        //htmlBody += '</table>';
        
        system.debug('Email Body: ' + htmlBody);   
         htmlBody += '</table>';
        htmlBody += '<br>';
        htmlBody += 'Regards,';
        htmlBody += '<br>';
        htmlBody += 'The Cloud Peritus Team';
        htmlBody += '<br><br>';
        htmlBody += '<p style="margin-left:220px; "><img src="' + cpLogo + '" alt="Image Description"' + 'width="'+ 120 + '"' + ' height="' + 80+ '"></p>';
        htmlBody += '</body></html>';
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