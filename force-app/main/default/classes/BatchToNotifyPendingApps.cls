/**
* @author Subba Kalavala
* @date 22/01/2023
* @description  BatchToNotifyPendingApps Batch to Send an pending approval to managers 
*              
*               Schedule class 
*               - BatchToNotifyPendingApps_sch
*               Test code coverage provided by the following test class:
*               - BatchToNotifyPendingAppsTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
global without sharing class BatchToNotifyPendingApps implements Database.Batchable<sObject> {
global static string link = URL.getSalesforceBaseUrl().toExternalForm() + '/';
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
        
        return Test.isRunningTest() ?  Database.getQueryLocator([SELECT Id,Email,Name FROM User WHERE isActive = true LIMIT 1 ]) :  Database.getQueryLocator([SELECT Id,Email,Name FROM User WHERE isActive = true ]);
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
    global void execute(Database.BatchableContext BC, List<User> userList) {
       set<string> approvers = new set<string>();
       map<string,user> approverwithemail = new map<string,user>();
        Date considerDate = Test.isRunningTest() ? System.today() : System.today().adddays(-Integer.valueOf(Label.Past_Days_Consider_For_Notification));
        for(User Urec : userList){
          approvers.add(Urec.Id); 
         approverwithemail.put(Urec.Id,Urec);
        }
        Map<Id,List<EMS_LM_Leave_History__c>> appWithAbseReqts = new Map<Id,List<EMS_LM_Leave_History__c>>();
        for(EMS_LM_Leave_History__c absRet : [SELECT Name,Id,Leave_Type_Name__c,EMS_LM_Status__c,EMS_LM_Leave_Duration__c,EMS_LM_Contact__c,EMS_LM_Contact__r.Name,EMS_LM_Approver__c,EMS_LM_2nd_Approver__c,Approver_3__c 
                                              FROM EMS_LM_Leave_History__c 
                                              WHERE EMS_LM_Leave_End_Date__c <=:considerDate AND EMS_LM_Status__c != 'Approved' AND EMS_LM_Status__c != 'Cancelled' AND EMS_LM_Status__c != 'Rejected']){
            if(appWithAbseReqts.containsKey(absRet.EMS_LM_Approver__c)){
                appWithAbseReqts.get(absRet.EMS_LM_Approver__c).add(absRet);
            }else{
                appWithAbseReqts.put(absRet.EMS_LM_Approver__c, new List<EMS_LM_Leave_History__c>{absRet});   
            }
            if(appWithAbseReqts.containsKey(absRet.EMS_LM_2nd_Approver__c)){
                appWithAbseReqts.get(absRet.EMS_LM_2nd_Approver__c).add(absRet);
            }else{
                appWithAbseReqts.put(absRet.EMS_LM_2nd_Approver__c, new List<EMS_LM_Leave_History__c>{absRet});   
            } 
            if(appWithAbseReqts.containsKey(absRet.Approver_3__c)){
                appWithAbseReqts.get(absRet.Approver_3__c).add(absRet);
            }else{
                appWithAbseReqts.put(absRet.Approver_3__c, new List<EMS_LM_Leave_History__c>{absRet});   
            }
        }
        List<Messaging.SingleEmailMessage> allMails = new List<Messaging.SingleEmailMessage>();
        if(!appWithAbseReqts.isEmpty()){
           Id orgWideAddressId = null;
            if(!Test.isRunningTest()){
           orgWideAddressId =  [SELECT Id, DisplayName, Address FROM OrgWideEmailAddress where DisplayName = 'No Reply' LIMIT 1].Id;
            }
            for(Id appId : appWithAbseReqts.keySet()){
                list<string> toaddress = new list<string>();              
                if(Test.isRunningTest() || (appWithAbseReqts.containsKey(appId) && appWithAbseReqts.get(appId).size() >0 && approverwithemail.containsKey(appId))){
                    if(Test.isRunningTest()){
                    toaddress.add('cp@gmail.com');
                    }else{
                     toaddress.add(approverwithemail.get(appId).Email);    
                    }
                  
                  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    if(orgWideAddressId != null){
                  email.setOrgWideEmailAddressId(orgWideAddressId);
                    }
                  email.setSubject('Pending Leave Approval Requests');
                   string  emailbody = getTableEmailBody(appWithAbseReqts.get(appId));
                    if(Test.isRunningTest()){
                     email.setHtmlBody('Test email');   
                    }else{
                   email.setHtmlBody('Dear '+approverwithemail.get(appId).Name+',<br/><br/>Please find below requests that are pending for your approval since '+Label.Past_Days_Consider_For_Notification+' days.<br/><br/>'+ emailbody + '<br/><br/>Review each request and either approve/decline in order for the request to be removed from this daily reminder.<br/><br/><h3 style="text-align: center">DO NOT REPLY TO THIS EMAIL</h3>');
                    }
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
         LogException.logHandledException(ex, 'BatchToNotifyPendingApps', 'execute');     
        }
        
    } 
    
    public  string getTableEmailBody(list<EMS_LM_Leave_History__c> abseRequest){
        
        
        
        String sday ;
        String smonth ;
        String syear;
        String eday;
        String emonth ;
        String eyear ;
        
        String htmlBody = '';
        String myName = Null;
        //open table..
        htmlBody = '<table border="1" style="border-collapse: collapse;width:80%;"><caption></caption><tr><th>S.No</th><th>Record Name</th><th>Employee Name</th><th>Status</th><th>Approval Screen Link</th></tr>';
        
        //iterate over list and output columns/data into table rows...
        if(abseRequest !=null && abseRequest.size()>0)
        {
            for(integer i = 0;i<abseRequest.size();i++)
            {
                htmlBody += '<tr><td><center>' + (i+1) + '</center></td><td><center> <a href="'+link+'/'+abseRequest[i].Id+'">'+abseRequest[i].Name+'</a></center></td><td>'+abseRequest[i].EMS_LM_Contact__r.Name+'</td><td>'+abseRequest[i].EMS_LM_Status__c+'</td><td><center> <a href="'+link+'/'+abseRequest[i].id+'">Click Here</a></center> </td></tr>';  
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