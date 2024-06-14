/**
    * @author vamsi
    * @date 24/01/2023
    * @description   Send Email to Manager for when employe edit the leave request[USA ONLY];
    *
    *               Test code coverage provided by the following test class:
    *               - US_leaveUpdateMail
    *
    * CHANGE HISTORY
    * ====================================================================================================
    * DATE          NAME                    DESCRIPTION
    * N/A           N/A                     N/A
    * ====================================================================================================
    **/
    public class US_leaveUpdateMail implements TriggerAction.AfterUpdate{
        
        public string enddate{get;set;}  
         public Map<Id,string> managermap;
         public Map<Id,string> getcontact;
        public void afterUpdate(list<EMS_LM_Leave_History__c> leavelist,list<EMS_LM_Leave_History__c> oldList) {
            Map<id,EMS_LM_Leave_History__c> timesheetOldMap = new Map<id,EMS_LM_Leave_History__c>(oldList);
            
            sendemails(leavelist,timesheetOldMap);
        }
        
        public static void sendemails(list<EMS_LM_Leave_History__c> leavelist,map<Id,EMS_LM_Leave_History__c> oldmap){
            set<Id> setid=new set<Id>();
                Map<Id,string> getcontact =new map<Id,string>();
            system.debug('leavelist-----------------------------------------------'+leavelist);
            system.debug('oldmap-----------------------------------------------'+oldmap);
            
            for(EMS_LM_Leave_History__c leave:leavelist){
                if((oldmap!=null&&oldmap.get(leave.Id).EMS_LM_Leave_Start_Date__c!=leave.EMS_LM_Leave_Start_Date__c)||(oldmap.get(leave.Id).EMS_LM_Leave_End_Date__c!=leave.EMS_LM_Leave_End_Date__c&& oldmap!=null)){
                    setid.add(leave.EMS_LM_Contact__c);
                    system.debug('setid-----------------------------------------------'+setid);
                     string annualtype= leave.Leave_Type_Name__c; 
                    gettingtid(setid,leavelist,annualtype,getcontact);
                    changerequest(setid);
                    getcontact.put(leave.EMS_LM_Contact__c,leave.EMS_LM_Contact__r.Name);
                    system.debug('getcontact name=============='+getcontact);
                }
            }
            
        }
        public static void gettingtid(set<id> setid,list<EMS_LM_Leave_History__c> leavelist,string annualtype,Map<Id,string> getcontact){
            list<string> maillist=new list<string>();
            String gridLogo = System.label.Grid_Logo;
            String cpLogo = System.label.CP_Logo;
               Map<Id,string> managermap =new map<Id,string>();
            system.debug('records==========================='+[select id,Resource__c,Resource_Reports_To__c,Resource_Reports_To__r.email from Resource_Resource_Relationship__c where Resource__c = :setid]);
            for(Resource_Resource_Relationship__c res:[select id,Resource__c,Resource_Reports_To__c,Resource_Reports_To__r.Name,Resource_Reports_To__r.email from Resource_Resource_Relationship__c where Resource__c  =:setid]){
               managermap.put(res.Resource__c,res.Resource_Reports_To__r.Name);
                system.debug('manager======='+managermap);
                 
                maillist.add(res.Resource_Reports_To__r.email);
                sendemail(maillist,leavelist,managermap,annualtype,getcontact);   
            }
            system.debug('maillist==========================='+maillist);
        }
        public static void sendemail(list<string> maillist,list<EMS_LM_Leave_History__c> leavelist,map<Id,string> managermap,string annualtype,Map<Id,string> getcontact){
            String emailContent = prepareEmailContent(leavelist,managermap,getcontact);
            
           
            // Send the email to HR with the employee anniversary details
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(maillist);
            email.setSubject(annualtype + ' leave type request is edit by employname');
            email.setHtmlBody(emailContent);
            system.debug('email+++++++++++++++++++++++++++++++++'+email);
            email.setSenderDisplayName('Grid');
            email.setReplyTo('no-reply@Grid.com');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
        private static String prepareEmailContent(List<EMS_LM_Leave_History__c> leavelist,map<Id,string> managermap,Map<Id,string> getcontact) {
            String gridLogo = System.label.Grid_Logo;
            String cpLogo = System.label.CP_Logo;        
            string htmlBody='';
            for(EMS_LM_Leave_History__c leave : leavelist){
               system.debug('contact name========='+getcontact.get(leave.EMS_LM_Contact__c));
              htmlBody = '<html><body style="padding: 25px; border-style: groove;">';
            htmlBody += '<img src="' + gridLogo + '" alt="Image Description"' + 'width="'+ 60 + '"' + ' height="' + 90+ '" >';
            htmlBody += '<br>';
            htmlBody += 'Dear '+managermap.get(leave.EMS_LM_Contact__c);
            htmlBody += '<br><br>';
            htmlBody += 'The   '+ leave.EMS_LM_Leave_Type_Name__c + 'request of  '+getcontact.get(leave.EMS_LM_Contact__c) +  '  has been edited by '+leave.EMS_LM_Contact__c + '';
            htmlBody += '<br><br>';
            htmlBody += '<table border="2" style="width:80%; border-collapse: collapse; margin-left: auto; margin-right: auto; text-align: center;"><tr><th style="width:20%; background-color:#6904c8; color: #FFFFFF;">Field Name</th><th style="width:40%; background-color:#6904c8; color: #FFFFFF;">Field Value</th></tr>';
           
                list<EMS_LM_Leave_History__history> leavechanges=[SELECT ParentId, OldValue, NewValue, Field, CreatedById, CreatedDate FROM EMS_LM_Leave_History__history];
                system.debug('leavechanges===================================================='+leavechanges);
                   //Date startDatevalue=Date.valueOf(leave.EMS_LM_Leave_Start_Date__c);
                     Datetime startDatevalue=Leave.EMS_LM_Leave_Start_Date__c;
                     date startday=startDatevalue.date();
                     String startformattedDate =  String.valueOf(startday);
                    system.debug('dates-=-==================================='+startformattedDate);
                     Datetime enddatevalue=Leave.EMS_LM_Leave_End_Date__c;
                     date endday=startDatevalue.date();
                     String endformattedDate =  String.valueOf(endday);
                    system.debug('dates-=-==================================='+endformattedDate); 
                   string dayvalue=Leave.EMS_LM_Day__c;
                   Map<String,Schema.SobjectField> schemaMap = Schema.EMS_LM_Leave_History__c.SobjectType.getDescribe().fields.getmap();
                  schema.Describefieldresult endresult=schemaMap.get('EMS_LM_Leave_End_Date__c').getdescribe();
                   schema.Describefieldresult startresult=schemaMap.get('EMS_LM_Leave_Start_Date__c').getdescribe();
                schema.Describefieldresult dayresult=schemaMap.get('EMS_LM_Day__c').getdescribe();
                 system.debug('result========'+endresult.getLabel());
                  string startDate=startresult.getLabel();
                    string Enddate=endresult.getLabel();
                    string day=dayresult.getLabel();
                htmlBody += '<tr><td>' + startDate+ '</td><td>' + startformattedDate + '</td></tr>';  
                 htmlBody += '<tr><td>' + enddate + '</td><td>' + endformattedDate + '</td></tr>'; 
                 htmlBody += '<tr><td>' + day+ '</td><td>' + dayvalue + '</td></tr>'; 
            htmlBody += '</table>';
            htmlBody += '<br>';
            htmlBody += 'Regards,';
            htmlBody += '<br>';
            htmlBody += 'The Cloud Peritus Team';
            htmlBody += '<br><br>';
            htmlBody += '<p style="text-align:center;" ><img src="' + cpLogo + '" alt="Image Description"' + 'width="'+ 100 + '"' + ' height="' + 50+ '"></p>';
            htmlBody += '</body></html>';
            
       }
            return htmlBody;
            
        }
        public static map<Id,EMS_LM_Leave_History__history> changerequest(set<id> setid){
            map<Id,EMS_LM_Leave_History__history> historymap=new map<Id,EMS_LM_Leave_History__history>();
            for(EMS_LM_Leave_History__history history:[select id,parentid,oldvalue,newvalue from EMS_LM_Leave_History__history where parentid IN:setid]){
                historymap.put(history.Id,history);
            }
            return historymap;
        }
        
    }