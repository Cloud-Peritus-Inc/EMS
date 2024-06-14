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
       // global static string link = URL.getSalesforceBaseUrl().toExternalForm() + '/'; //this link navigate to salesforce
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
            return Database.getQueryLocator([SELECT Id,Email,Name,Work_Location__c,Work_Location__r.Name,EMS_RM_ApplicantStatus_Update__c,EMS_TM_User__c,EMS_TM_User__r.IsActive 
                                             FROM Contact 
                                             WHERE 
                                             RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                                             AND EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation', 'Active - Notice Period') 
                                             AND EMS_TM_User__r.IsActive = TRUE]);
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
             set<string> NoTcConId = new set<string>();
            map<string,Contact> pmwithemail = new map<string,Contact>();
            Date todayval = system.today();
            map<Id,set<string>> contactwithproject = new map<Id,set<string>>();
            map<Id,set<string>> emplyewithproject = new map<Id,set<string>>();
            Date considerDate = todayval.toStartofWeek().addDays(-2);
            Date weekStart = considerDate.toStartofWeek().addDays(1);
            Date weekEnd = considerDate.toStartofWeek().addDays(7);
            System.debug('===weekStart==='+weekStart);
            System.debug('===weekEnd==='+weekEnd);
            
            //smaske : Creating New Map to store Project Manager details with Contact
            map<Id,Set<contact>> mangerwithcontact = new map<Id,Set<contact>>();
            map<Id,list<EMS_TM_Assignment__c>> mangerwithassignment = new map<Id,list<EMS_TM_Assignment__c>>();
            
            
            for(Contact Urec : conList){
                managerIds.add(Urec.Id); 
                pmwithemail.put(Urec.Id,Urec);
            }
            System.debug('***pmwithemail'+pmwithemail);
            System.debug('***managerIds'+managerIds);
                      map<Id,set<string>> ConwithProj = new map<Id,set<string>>();
            Map<Id,List<EMS_TM_Project__c>> pmWithProjects = new Map<Id,List<EMS_TM_Project__c>>();
            Map<Id,set<string>> mangerwithcontactsprojects = new Map<Id,set<string>>();
            Map<Id,List<String>> prjWithTimeCards = new Map<Id,List<String>>();
            Map<Id,List<EMS_LM_Leave_History__c>> appWithAbseReqts = new Map<Id,List<EMS_LM_Leave_History__c>>();
            Map<String,List<EMS_Timesheet__c>> resourceWithTimeCard = new Map<String,List<EMS_Timesheet__c>>();
            set<string> resourceIds = new set<String>();
             Set<Id> contactIdWithTimeSheet=new set<Id>();
             Set<Id> TimeSheetProjectsId=new set<Id>();
             List<EMS_Timesheet__c> timesheets = [
                                                   select id, Week_End_Date__c, Week_Start_Date__c, Resource__c, EMS_TM_Status__c,Resource__r.Name,
                                                   (select id, EMS_TM_Project__c, Status__c,EMS_TM_Project__r.Name
                                                     from Employee_Projects__r
                                                     where Status__c = 'SAVED')
                                                     from EMS_Timesheet__c
                                                     where Week_Start_Date__c >= :weekStart
                                                     AND Week_End_Date__c <= :weekEnd
                                                     AND (EMS_TM_Status__c = 'SAVED' OR EMS_TM_Status__c = 'Not Approved')
                                                            AND Resource__c IN:managerIds
                                                              ];
    
    for (EMS_Timesheet__c timesheet : timesheets) {
        system.debug('resource Name========'+timesheet.Resource__r.Name);
        contactIdWithTimeSheet.Add(timesheet.Resource__c);
        for(EMS_TM_Timesheet_Record__c timesheetLineitem:timesheet.Employee_Projects__r){
                TimeSheetProjectsId.Add(timesheetLineitem.EMS_TM_Project__c);
            if(ConwithProj.containskey(timesheet.Resource__c)){
                ConwithProj.get(timesheet.Resource__c).add(timesheetLineitem.EMS_TM_Project__r.Name);
            }else{
                ConwithProj.put(timesheet.Resource__c,new set<string>{timesheetLineitem.EMS_TM_Project__r.Name});
            }
            system.debug('TimesheetwithSAVE===================='+ConwithProj);

        }
        
    }
    
            
            for(EMS_TM_Project__c prj : [SELECT Id,Name,Project_Manager__c,Project_Manager__r.Id,Offshore_Project_Manager__c,Offshore_Project_Manager__r.Id,Offshore_Project_Manager__r.work_location__r.Name,Project_Manager__r.work_location__r.Name,
                                         (SELECT Id,EMS_TM_EmployeeName__c,EMS_TM_EmployeeName__r.Id,EMS_TM_EmployeeName__r.Name,EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c,EMS_TM_EmployeeName__r.work_location__r.Name,
                                          EMS_TM_EmployeeName__r.EMS_RM_ApplicantStatus_Update__c,EMS_TM_EmployeeName__r.EMS_TM_User__r.IsActive,Resource_User_Id__c,EMS_TM_ProjectName_Asgn__r.Name,
                                          EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,EMS_TM_ProjectName_Asgn__r.Project_Manager__c,EMS_TM_ProjectName_Asgn__r.Project_Manager__r.work_location__r.Name,EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.work_location__r.Name FROM Assignments__r WHERE EMS_TM_Status_Asgn__c = 'Active' AND EMS_TM_EmployeeName__c IN:contactIdWithTimeSheet AND EMS_TM_EmployeeName__r.EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation', 'Active - Notice Period') 
                                             AND EMS_TM_EmployeeName__r.EMS_TM_User__r.IsActive = TRUE )
                                         FROM EMS_TM_Project__c WHERE Project_Manager__c IN:managerIds AND Offshore_Project_Manager__c IN:managerIds AND EMS_TM_Status__c = 'Ongoing' AND Type_Of_Project__c!='Global Projects' AND Id IN:TimeSheetProjectsId]){
                                             System.debug('DATA_Proj'+prj);
                                             
                                             prjIds.add(prj.Id);
                                             if(pmWithProjects.containsKey(prj.Project_Manager__c)){
                                                 pmWithProjects.get(prj.Project_Manager__c).add(prj);
                                                 //mangerwithcontactsprojects.get(prj.Project_Manager__c).add(prj.Name);
                                             }else{
                                                 pmWithProjects.put(prj.Project_Manager__c, new List<EMS_TM_Project__c>{prj}); 
                                                 //mangerwithcontactsprojects.put(prj.Project_Manager__c,new set<string>{prj.Name});
                                                 
                                             }
                                             if(pmWithProjects.containsKey(prj.Offshore_Project_Manager__c)){
                                                 pmWithProjects.get(prj.Offshore_Project_Manager__c).add(prj);
                                                 // mangerwithcontactsprojects.get(prj.Offshore_Project_Manager__c).add(prj.Name);
                                                 
                                             }else{
                                                 pmWithProjects.put(prj.Offshore_Project_Manager__c,new List<EMS_TM_Project__c>{prj});
                                                 // mangerwithcontactsprojects.put(prj.Offshore_Project_Manager__c,new set<string>{prj.Name});
                                                 
                                             }
                                             
                                             if(prj.assignments__r.size() >0){
                                                 for(EMS_TM_Assignment__c assig : prj.assignments__r){
                                                     system.debug('resource Name===='+assig.EMS_TM_EmployeeName__r.Name);
                                                     if(contactwithproject.containsKey(assig.EMS_TM_EmployeeName__c)){
                                                         contactwithproject.get(assig.EMS_TM_EmployeeName__c).add(assig.EMS_TM_ProjectName_Asgn__r.Name);
                                                     }else{
                                                         contactwithproject.put(assig.EMS_TM_EmployeeName__c,new set<string>{assig.EMS_TM_ProjectName_Asgn__r.Name});
                                                     }
                                                     system.debug('contactwithproject=================================='+contactwithproject);
                                                     //contactwithproject.put(assig.EMS_TM_EmployeeName__c,new list<string>{assig.EMS_TM_ProjectName_Asgn__r.Name});
                                                     resourceIds.add(assig.Resource_User_Id__c);
                                                     if((assig.EMS_TM_EmployeeName__r.work_location__r.Name=='California - USA')&&(assig.EMS_TM_ProjectName_Asgn__r.Project_Manager__r.work_location__r.Name=='California - USA')){
                                                         if(mangerwithcontactsprojects.containsKey(assig.EMS_TM_ProjectName_Asgn__r.Project_Manager__c)){
                                                             mangerwithcontactsprojects.get(assig.EMS_TM_ProjectName_Asgn__r.Project_Manager__c).add(assig.EMS_TM_ProjectName_Asgn__r.Name);
                                                         }else{
                                                             mangerwithcontactsprojects.put(assig.EMS_TM_ProjectName_Asgn__r.Project_Manager__c,new set<string>{assig.EMS_TM_ProjectName_Asgn__r.Name});
                                                             
                                                         }
                                                         //smaske : Populating mangerwithcontact
                                                         if(mangerwithcontact.containsKey(prj.Project_Manager__c)&&!mangerwithcontact.get(prj.Project_Manager__r.Id).contains((assig.EMS_TM_EmployeeName__r))){
                                                             
                                                             mangerwithcontact.get(prj.Project_Manager__r.Id).add(assig.EMS_TM_EmployeeName__r);
                                                             
                                                         }else{
                                                             mangerwithcontact.put(prj.Project_Manager__r.Id, new Set<Contact>{assig.EMS_TM_EmployeeName__r}); 
                                                             
                                                         }
                                                                system.debug('mangerwithproject USA========='+mangerwithcontact);
                                                                system.debug('USA EMPLOYES====='+mangerwithcontact.values());
                                                     }
                                                     if((assig.EMS_TM_EmployeeName__r.work_location__r.Name=='Hyderabad - India')&&(assig.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.work_location__r.Name=='Hyderabad - India')){
                                                         if(mangerwithcontactsprojects.containsKey(assig.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c)){
                                                             mangerwithcontactsprojects.get(assig.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c).add(assig.EMS_TM_ProjectName_Asgn__r.Name);
                                                             
                                                         }else{
                                                             mangerwithcontactsprojects.put(assig.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,new set<string>{assig.EMS_TM_ProjectName_Asgn__r.Name});
                                                             
                                                             
                                                         }
                                                         if(mangerwithcontact.containsKey(prj.Offshore_Project_Manager__c)){
                                                             mangerwithcontact.get(prj.Offshore_Project_Manager__r.Id).add(assig.EMS_TM_EmployeeName__r);
                                                             
                                                         }else{
                                                             mangerwithcontact.put(prj.Offshore_Project_Manager__r.Id, new Set<Contact>{assig.EMS_TM_EmployeeName__r});
                                                             
                                                             
                                                         }
                                                         system.debug('mangerwithproject india========='+mangerwithcontact);
                                                         
                                                     }
                                                     //smaske : Populating mangerwithcontact
                                                 }
                                             }
                                         } 
            
            //smaske : Searching for Contact Not Created/Saved/Submited TimeSheet Record on GRID
            List<Contact> Contctwotc = [select Id,Name,Email,EMS_RM_Employee_Id__c,RecordTypeId,EMS_RM_ApplicantStatus_Update__c,EMS_TM_User__c,EMS_TM_User__r.IsActive FROM
                                        contact WHERE 
                                        RecordTypeId=:ContactConstant.RESOURCE_RECORDTYPEID 
                                        AND EMS_RM_ApplicantStatus_Update__c IN ('Active', 'Active - Probation', 'Active - Notice Period') 
                                        AND EMS_TM_User__r.IsActive = TRUE
                                        AND id not in(select resource__c from EMS_Timesheet__C where Week_Start_Date__c>=:weekStart AND Week_End_Date__c<=:weekEnd AND EMS_TM_Status__c	='Submitted')];
            system.debug('contact without timesheet==========='+Contctwotc);
            
            for(Contact Urec : Contctwotc){
                system.debug('Urec======='+Urec.Name);
                NoTcConId.add(Urec.Id);
                managerIds.add(Urec.Id); 
                system.debug('managerIds====='+managerIds);
                pmwithemail.put(Urec.Id,urec);
            }
            
            for(EMS_TM_Project__c prj : [SELECT id,Name,Project_Manager__c,Project_Manager__r.Id,Offshore_Project_Manager__c,Offshore_Project_Manager__r.Id,Offshore_Project_Manager__r.work_location__r.Name,Project_Manager__r.work_location__r.Name,
                                         
                                         (SELECT Id,EMS_TM_EmployeeName__c,EMS_TM_EmployeeName__r.Id,EMS_TM_EmployeeName__r.Name,EMS_TM_EmployeeName__r.EMS_RM_Employee_Id__c,Resource_User_Id__c,EMS_TM_EmployeeName__r.work_location__r.Name,
                                          EMS_TM_ProjectName_Asgn__r.Name,EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__c,EMS_TM_ProjectName_Asgn__r.Project_Manager__c,EMS_TM_ProjectName_Asgn__r.Project_Manager__r.work_location__r.Name,
                                            EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.work_location__r.Name FROM Assignments__r WHERE EMS_TM_Status_Asgn__c = 'Active' AND EMS_TM_EmployeeName__c IN:NoTcConId)
                                         FROM EMS_TM_Project__c WHERE EMS_TM_Status__c = 'Ongoing' AND Type_Of_Project__c!='Global Projects']){
                                             System.debug('DATA_Proj'+prj);
                                             if(prj.assignments__r.size() >0){
                                                 for(EMS_TM_Assignment__c assig : prj.assignments__r){
                                                     system.debug('ASSIGNMENT NAME======='+assig.EMS_TM_EmployeeName__r.Name);
                                                     if(contactwithproject.containsKey(assig.EMS_TM_EmployeeName__c)){
                                                         contactwithproject.get(assig.EMS_TM_EmployeeName__c).add(assig.EMS_TM_ProjectName_Asgn__r.Name);
                                                         
                                                     }else{
                                                         contactwithproject.put(assig.EMS_TM_EmployeeName__c,new set<string>{assig.EMS_TM_ProjectName_Asgn__r.Name});
                                                     }
                                                     system.debug('contactwithproject=================================='+contactwithproject);
                                                     if((assig.EMS_TM_EmployeeName__r.work_location__r.Name=='California - USA')&&(assig.EMS_TM_ProjectName_Asgn__r.Project_Manager__r.work_location__r.Name=='California - USA')){
                                                         if(mangerwithcontact.containsKey(prj.Project_Manager__c)){
                                                             mangerwithcontact.get(prj.Project_Manager__r.Id).add(assig.EMS_TM_EmployeeName__r);
                                                         }else{
                                                             mangerwithcontact.put(prj.Project_Manager__r.Id, new Set<Contact>{assig.EMS_TM_EmployeeName__r});
                                                         }
                                                         if(mangerwithcontactsprojects.containsKey(prj.Project_Manager__c)){
                                                             mangerwithcontactsprojects.get(prj.Project_Manager__r.Id).add(prj.Name);
                                                             
                                                         }else{
                                                             mangerwithcontactsprojects.put(prj.Project_Manager__r.Id, new Set<string>{prj.Name}); 
                                                             
                                                         }
                                                         system.debug('mangerwithproject usa========='+mangerwithcontact);
                                                          system.debug('USA EMPLOYES========='+mangerwithcontact.values());
                                                          if(ConwithProj.containsKey(assig.EMS_TM_EmployeeName__c)){
                                                             ConwithProj.get(assig.EMS_TM_EmployeeName__r.Id).add(prj.Name);
                                                             
                                                         }else{
                                                             ConwithProj.put(assig.EMS_TM_EmployeeName__r.Id, new Set<string>{prj.Name}); 
                                                             
                                                         }
                                                          
                                                         
                                                     }
                                                     
                                                     if((assig.EMS_TM_EmployeeName__r.work_location__r.Name=='Hyderabad - India')&&(assig.EMS_TM_ProjectName_Asgn__r.Offshore_Project_Manager__r.work_location__r.Name=='Hyderabad - India')){
                                                         if(mangerwithcontact.containsKey(prj.Offshore_Project_Manager__c)){
                                                             mangerwithcontact.get(prj.Offshore_Project_Manager__r.Id).add(assig.EMS_TM_EmployeeName__r);
                                                             
                                                         }else{
                                                             mangerwithcontact.put(prj.Offshore_Project_Manager__r.Id, new Set<Contact>{assig.EMS_TM_EmployeeName__r});
                                                             
                                                         }
                                                         if(mangerwithcontactsprojects.containsKey(prj.Offshore_Project_Manager__c)){
                                                             mangerwithcontactsprojects.get(prj.Offshore_Project_Manager__r.Id).add(prj.Name);
                                                             
                                                         }else{
                                                             mangerwithcontactsprojects.put(prj.Offshore_Project_Manager__r.Id, new Set<string>{prj.Name}); 
                                                             
                                                         }
                                                         system.debug('mangerwithproject india========='+mangerwithcontact);
                                                          if(ConwithProj.containsKey(assig.EMS_TM_EmployeeName__c)){
                                                             ConwithProj.get(assig.EMS_TM_EmployeeName__r.Id).add(prj.Name);
                                                             
                                                         }else{
                                                             ConwithProj.put(assig.EMS_TM_EmployeeName__r.Id, new Set<string>{prj.Name}); 
                                                             
                                                         }
                                                         
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
            
            
            List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
            
            
            
            //Smaske : This method replaces above method for Generating email body Data table using contact data.
            System.debug('***mangerwithcontact.keyset***'+mangerwithcontact.keyset());
            System.debug('***mangerwithcontact.values***'+mangerwithcontact.values());
            
            if(!mangerwithcontact.isEmpty()){
                Id orgWideAddressId =[SELECT Id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'Grid' LIMIT 1].Id;
                for(Id pmId : mangerwithcontact.keySet()){
                    System.debug('***pmId***'+pmId);
                    list<string> toaddress = new list<string>();   
                    if(mangerwithcontact.containsKey(pmId)&& pmwithemail.containsKey(pmId)&& mangerwithcontact.get(pmId).size() > 0){
                        //System.debug('toadress EMAil'+pmwithemail.get(pmId).Email);
                        toaddress.add(pmwithemail.get(pmId).Email);
                        
                        System.debug('***ToAddress'+toaddress);
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setOrgWideEmailAddressId(orgWideAddressId);
                        email.setSubject('Employee timesheets overdue');
                        string ManagerName=pmwithemail.get(pmId).Name;
                        Id Managerid=pmwithemail.get(pmId).Id;
                        system.debug('my projet===='+contactwithproject);
                        string  emailbody = getTableEmailBody(mangerwithcontact.get(pmId),ManagerName,contactwithproject,Managerid,ConwithProj); // NEED TO WORK HERE
                        system.debug('size of records==' +mangerwithcontact.get(pmId).size());
                        
                        email.setHtmlBody(emailbody);
                        email.setToAddresses(toaddress);
                        email.setSaveAsActivity(false);
                        allMails.add(email); 
                    }
                }
            }
            
            system.debug('====allMails===='+allMails);
            system.debug('====allMails===='+allMails.size());
            
            try{
                
                Messaging.sendEmail(allMails); 
                
            }catch(exception ex){
                LogException.logHandledException(ex, 'BatchToNotifyTCForPM', 'execute');     
            }
            
        } 
        
        
        
        //Smaske : New getTableEmailBody method based on Contact Data
        public Static string getTableEmailBody(Set<Contact> contactList,string ManagerName,map<Id,set<string>> contactwithproject,Id Managerid,map<Id,set<string>> ConwithProj){
            system.debug('contactList======='+contactList);
            for(Contact con:contactList){
                system.debug('con========'+con);
            }
            Map<contact,Integer> countMap = new Map<contact,Integer>();
            Date todayval = system.today(); 
            Date considerDate = todayval.toStartofWeek().addDays(-2);
            Date weekStart = considerDate.toStartofWeek().addDays(1);
            Date weekEnd = considerDate.toStartofWeek().addDays(7);
            system.debug('todayval========'+todayval);
            system.debug('considerDate========'+considerDate);
            system.debug('weekStart========'+weekStart);
            system.debug('weekEnd========'+weekEnd);
            
            
            
            
            /*	Vamsi
    * Here I am changing set to list beacause In email body we are using list indexs  
    * 
    */  
            
            // String gridLogo = System.label.Grid_Logo;
            String cpLogo = System.label.CP_Logo;
            String gridLogo = System.label.Grid_Logo;
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
            htmlBody += '<br><br>';
            htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 120 + '"' + ' height="' + 50+ '" >';
            htmlBody += '<br><br>';
            htmlBody +='Dear '+ManagerName +',<br/><br/>The weekly timesheets of the following employees are overdue:<br/><br/>';
            //open table..
            htmlBody += '<table border="2" style="width:70%; border-collapse: collapse; margin-left:0px; margin-right: auto; text-align: center;"><tr><th style="width:15%; background-color:#590099; color: #FFFFFF;">Employee ID</th><th style="width:40%; background-color:#590099; color: #FFFFFF;">Employee Name</th><th style="width:20%; background-color:#590099; color: #FFFFFF;">Project Name</th><th style="width:20%; background-color:#590099; color: #FFFFFF;">Week</th></tr>';
            
            //htmlBody = '<table border="1" style="border-collapse: collapse;width:80%;"><caption></caption><tr><th>Employee Id</th><th>Employee Name</th><th>Week</th></tr>';
            //htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';
            //iterate over list and output columns/data into table rows...
            if(contactsData !=null && contactsData.size()>0)
            {
                for(Contact contact : contactsData){
                    system.debug('projectss--'+contactwithproject.get(contact.Id));
                    //  string projct =contactwithproject.get(contact.Id);
                    String projct = ConwithProj.containsKey(contact.Id) ? String.join(new List<String>(ConwithProj.get(contact.Id)), ', ') : '';
                    
                    //   if (!countMap.containsKey(contact)) {
                  //  String projects = mangerwithcontactsprojects.containsKey(Managerid) ? String.join(new List<String>(mangerwithcontactsprojects.get(Managerid)), ', ') : '';
                    //string emlproject=
                    //  for(integer i = 0;i<contactsData.size();i++)
                    // {
                    string week= String.valueOf(weekEnd).removeEnd(' 00:00:00');
                    htmlBody += '<tr><td><center> <a href="'+Cmlink+'/'+contact.Id+'">'+contact.EMS_RM_Employee_Id__c+'</a></center></td><td>'+contact.Name+'</td><td><center> '+projct +'</center></td><td><center> '+week +'</center> </td></tr>'; 
                    // countMap.put(contact, 1);
                    
                    // }
                    //  }
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