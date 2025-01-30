/** 
* @author Vamsi
* @date 05/27/2023
* @description  This classs for getting Timesheet records
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class PedningTimesheet {
    public class WrapperClass {
        
        @AuraEnabled
        public String Id;    
        
        @AuraEnabled
        public String ProjcetName; 
        
        @AuraEnabled
        public String OwnerName;
        
        @AuraEnabled
        public String TimesheetId;
        
        @AuraEnabled
        public Date weekStartDate;
        
        @AuraEnabled
        public Date weekenddate;
        
        @AuraEnabled
        public decimal Hours;
        
        @AuraEnabled
        public Id projectid;
        
        @AuraEnabled
        public string Timesheetname;
        
        @AuraEnabled
        public string OwnerId;
        
        @AuraEnabled
        public string Name;
        
        
        @AuraEnabled
        public decimal NumberOfhours;
    }
    // This method calls list of records status is Submitted
    @AuraEnabled(cacheable=true)
    public static List<WrapperClass> PendingRecords(){
        List<WrapperClass> wrapperOppList=new List<WrapperClass>();
        User user = [SELECT Id,ContactId,ContactId__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug(user.ContactId);
        List <Resource_Resource_Relationship__c> rrrList = [ SELECT Id, 
                                                            Resource__c, 
                                                            Resource_Reports_To__c,
                                                            Resource_Reports_To_User__c, 
                                                            Reports_To_Role__c
                                                            FROM Resource_Resource_Relationship__c 
                                                            WHERE Resource_Reports_To_User__c != null 
                                                          AND  Resource_Reports_To__c =: user.ContactId 
                                                           ];
       Map<Id,Id>  resoucerelationMap=new Map<Id,Id>();
       for(Resource_Resource_Relationship__c rr:rrrList){
           resoucerelationMap.put(rr.Resource__c,rr.Resource_Reports_To__c);
       }                                                  
     list<EMS_TM_Timesheet_Record__c> Timesheet=[SELECT
                                                    Name,
                                                    owner.Name,
                                                    EMS_TM_Project__r.Name,
                                                    EMS_TM_Project__c,
                                                    EMS_Timesheet__r.Resource__r.Name,
                                                    EMS_Timesheet__r.EMS_TM_Total__c,
                                                    EMS_Timesheet__r.Name,
                                                    EMS_Timesheet__c,
                                                    EMS_Timesheet__r.Week_Start_Date__c, 
                                                    EMS_Timesheet__r.Week_End_Date__c,Status__c,
                                                    Number_of_Hours__c
                                                    FROM EMS_TM_Timesheet_Record__c  
                                                    //resoucerelationMap.contains(ownerId)
                                                    where /*( EMS_TM_Project__r.Project_Manager__c=:user.ContactId OR EMS_TM_Project__r.Offshore_Project_Manager__c=:user.ContactId )*/
                                                     Status__c='Submitted']; // AND EMS_TM_Project__r.Type_Of_Project__c!='Global Projects'
        if(Timesheet.size()>0){       
            for(EMS_TM_Timesheet_Record__c myrecords: [SELECT
                                                       Name,
                                                       owner.Name,
                                                       EMS_TM_Project__r.Name,
                                                       EMS_TM_Project__c,
                                                       EMS_Timesheet__r.Resource__r.Name,
                                                       EMS_Timesheet__r.EMS_TM_Total__c,
                                                       EMS_Timesheet__r.Name,
                                                       EMS_Timesheet__c,
                                                       EMS_Timesheet__r.Week_Start_Date__c, 
                                                       EMS_Timesheet__r.Week_End_Date__c,Status__c,
                                                       Number_of_Hours__c
                                                       FROM EMS_TM_Timesheet_Record__c 
                                                       where Timesheet_Approver__c=:user.Id
                                                       AND Status__c='Submitted']){
                                                           
                                                           
                                                           
                                                           WrapperClass wrapItemFld = new WrapperClass();
                                                           wrapItemFld.Id                   =  myrecords.Id;
                                                           wrapItemFld.ProjcetName          =  myrecords.EMS_TM_Project__r.Name;
                                                           wrapItemFld.OwnerName            =  myrecords.owner.Name;
                                                           wrapItemFld.Timesheetname        =  myrecords.EMS_Timesheet__r.Name;
                                                           wrapItemFld.weekStartDate       =  myrecords.EMS_Timesheet__r.Week_Start_Date__c;
                                                           wrapItemFld.weekenddate         =  myrecords.EMS_Timesheet__r.Week_End_Date__c;
                                                           wrapItemFld.Hours               =myrecords.EMS_Timesheet__r.EMS_TM_Total__c;
                                                           wrapItemFld.projectid           =myrecords.EMS_TM_Project__c;
                                                           wrapItemFld.Timesheetid         =myrecords.EMS_Timesheet__c;
                                                           wrapItemFld.OwnerId            =  myrecords.EMS_Timesheet__r.Resource__c;
                                                           wrapItemFld.Name               =myrecords.Name;
                                                           wrapItemFld.NumberOfhours      =myrecords.Number_of_Hours__c;
                                                           wrapperOppList.add(wrapItemFld);
                                                           
                                                           
                                                       }
      /*  
        list<EMS_TM_Timesheet_Record__c> Timesheet=[SELECT
                                                    Name,
                                                    EMS_TM_Project__r.Name,
                                                    EMS_TM_Project__c,
                                                    EMS_Timesheet__r.Resource__r.Name,
                                                    EMS_Timesheet__r.EMS_TM_Total__c,
                                                    EMS_Timesheet__r.Name,
                                                    EMS_Timesheet__c,
                                                    EMS_Timesheet__r.Week_Start_Date__c, 
                                                    EMS_Timesheet__r.Week_End_Date__c,Status__c,
                                                    Number_of_Hours__c
                                                    FROM EMS_TM_Timesheet_Record__c 
                                                    where EMS_TM_Project__r.Offshore_Project_Manager__c=:user.ContactId
                                                    AND Status__c='Submitted' AND EMS_TM_Project__r.Type_Of_Project__c!='Global Projects'];
        if(Timesheet.size()>0){       
            for(EMS_TM_Timesheet_Record__c myrecords: [SELECT
                                                       Name,
                                                       EMS_TM_Project__r.Name,
                                                       EMS_TM_Project__c,
                                                       EMS_Timesheet__r.Resource__r.Name,
                                                       EMS_Timesheet__r.EMS_TM_Total__c,
                                                       EMS_Timesheet__r.Name,
                                                       EMS_Timesheet__c,
                                                       EMS_Timesheet__r.Week_Start_Date__c, 
                                                       EMS_Timesheet__r.Week_End_Date__c,Status__c,
                                                       Number_of_Hours__c
                                                       FROM EMS_TM_Timesheet_Record__c 
                                                       where EMS_TM_Project__r.Offshore_Project_Manager__c=:user.ContactId
                                                       AND Status__c='Submitted' AND EMS_TM_Project__r.Type_Of_Project__c!='Global Projects']){
                                                           
                                                           
                                                           
                                                           WrapperClass wrapItemFld = new WrapperClass();
                                                           wrapItemFld.Id                   =  myrecords.Id;
                                                           wrapItemFld.ProjcetName          =  myrecords.EMS_TM_Project__r.Name;
                                                           wrapItemFld.OwnerName            =  myrecords.EMS_Timesheet__r.Resource__r.Name;
                                                           wrapItemFld.Timesheetname        =  myrecords.EMS_Timesheet__r.Name;
                                                           wrapItemFld.weekStartDate       =  myrecords.EMS_Timesheet__r.Week_Start_Date__c;
                                                           wrapItemFld.weekenddate         =  myrecords.EMS_Timesheet__r.Week_End_Date__c;
                                                           wrapItemFld.Hours               =myrecords.EMS_Timesheet__r.EMS_TM_Total__c;
                                                           wrapItemFld.projectid           =myrecords.EMS_TM_Project__c;
                                                           wrapItemFld.Timesheetid         =myrecords.EMS_Timesheet__c;
                                                           wrapItemFld.OwnerId            =  myrecords.EMS_Timesheet__r.Resource__c;
                                                           wrapItemFld.Name               =myrecords.Name;
                                                           wrapItemFld.NumberOfhours      =myrecords.Number_of_Hours__c;
                                                           wrapperOppList.add(wrapItemFld);
                                                           
                                                           
                                                       }
                                                       */
        }else{
            for(EMS_TM_Timesheet_Record__c myrecords: [SELECT
                                                       Name,
                                                       EMS_TM_Project__r.Name,
                                                       EMS_TM_Project__c,
                                                       EMS_Timesheet__r.Resource__r.Name,
                                                       EMS_Timesheet__r.EMS_TM_Total__c,
                                                       EMS_Timesheet__r.Name,
                                                       EMS_Timesheet__c,
                                                       EMS_Timesheet__r.Week_Start_Date__c, 
                                                       EMS_Timesheet__r.Week_End_Date__c,Status__c,
                                                       Number_of_Hours__c
                                                       FROM EMS_TM_Timesheet_Record__c 
                                                       where Status__c='Submitted' AND EMS_TM_Project__r.Type_Of_Project__c='Global Projects']){
                                                           
                                                           
                                                           
                                                           WrapperClass wrapItemFld = new WrapperClass();
                                                           wrapItemFld.Id                   =  myrecords.Id;
                                                           wrapItemFld.ProjcetName          =  myrecords.EMS_TM_Project__r.Name;
                                                           wrapItemFld.OwnerName            =  myrecords.EMS_Timesheet__r.Resource__r.Name;
                                                           wrapItemFld.Timesheetname        =  myrecords.EMS_Timesheet__r.Name;
                                                           wrapItemFld.weekStartDate       =  myrecords.EMS_Timesheet__r.Week_Start_Date__c;
                                                           wrapItemFld.weekenddate         =  myrecords.EMS_Timesheet__r.Week_End_Date__c;
                                                           wrapItemFld.Hours               =myrecords.EMS_Timesheet__r.EMS_TM_Total__c;
                                                           wrapItemFld.projectid           =myrecords.EMS_TM_Project__c;
                                                           wrapItemFld.Timesheetid         =myrecords.EMS_Timesheet__c;
                                                           wrapItemFld.OwnerId            =  myrecords.EMS_Timesheet__r.Resource__c;
                                                           wrapItemFld.Name               =myrecords.Name;
                                                           wrapItemFld.NumberOfhours      =myrecords.Number_of_Hours__c;
                                                           wrapperOppList.add(wrapItemFld);
                                                           
                                                           
                                                       }
            
        }
    
        system.debug('wrapperOppList========================='+wrapperOppList);
        return  wrapperOppList;
        
    }
    @AuraEnabled(cacheable=true)
    public static integer Recordssize(){
        //
        User user = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug(user.ContactId);
        integer records= [select count() FROM EMS_TM_Timesheet_Record__c where Status__c='Submitted' AND 
                          Timesheet_Approver__c=:user.ID
                          ]; 
        
        system.debug('records.size()' +records);
        return  records;
        
    }
    @AuraEnabled
    public static ProcessInstanceWorkitem Approvetimesheets(Id recordId){
        
        String s = recordId; 
        system.debug(s);
        ProcessInstance pi = [SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId = :recordId];
        list<ProcessInstanceWorkitem> piw =  [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =:pi.Id];
        // List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
        //                                 FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :s LIMIT 1];
        system.debug('SOQL Query --------------------------------->'+s);
        system.debug('piw --------------------------------->'+piw);
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Approve');       
        req.setWorkitemId(piw[0].Id);
        Approval.ProcessResult result = Approval.process(req); 
        system.debug('result --------------------------------->'+result);
        return piw[0];
        
    }
    
    @AuraEnabled
    public static ProcessInstanceWorkitem Rejectatimesheets(Id recordId){
        
        String s = recordId; 
        system.debug('s ======================================================================================'+s);
        ProcessInstance pi = [SELECT Id,Status,TargetObjectId FROM ProcessInstance where Status='Pending' and TargetObjectId = :recordId];
        list<ProcessInstanceWorkitem> piw =  [SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId =:pi.Id];
        // List<ProcessInstanceWorkitem> piwi = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId 
        //                                 FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :s LIMIT 1];
        system.debug('SOQL Query --------------------------------->'+s);
        system.debug('piw --------------------------------->'+piw);
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Reject');       
        req.setWorkitemId(piw[0].Id);
        Approval.ProcessResult result = Approval.process(req); 
        system.debug('result --------------------------------->'+result);
        return piw[0];
        
    }
    
    
    @AuraEnabled
    public static List<ProcessInstanceWorkitem> approvetimesheetsall(List<Id> recordIds) {
        List<ProcessInstanceWorkitem> approvedItems = new List<ProcessInstanceWorkitem>();
        system.debug('recordIds ========================'+recordIds);
        
        for (Id recordId : recordIds) {
            ProcessInstance pi = [SELECT Id, Status, TargetObjectId FROM ProcessInstance WHERE Status = 'Pending' AND TargetObjectId = :recordId];
            system.debug('pi value cheking ---------------------------------------------------------'+pi);
            List<ProcessInstanceWorkitem> piw = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :pi.Id];
            system.debug('piw ---------------------------------------------------------'+piw);
            
            if (!piw.isEmpty()) {
                system.debug('Cheking for inside if@@@@@@-----------'+piw);
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Approve');
                req.setWorkitemId(piw[0].Id);
                Approval.ProcessResult result = Approval.process(req);
                
                if (result.isSuccess()) {
                    approvedItems.add(piw[0]);
                } else {
                    // Handle approval failure if needed
                }
            }
        }
        
        return approvedItems;
    }
    
    
    
    @AuraEnabled
    public static void rejecttimesheetsall(list<String> recordIdsList){
        list<EMS_TM_Timesheet_Record__c> timesheetrejectList=new list<EMS_TM_Timesheet_Record__c>();
        List<EMS_TM_Timesheet_Record__c> timesheetrejectrecords=[select id,status__c from EMS_TM_Timesheet_Record__c where Id in:recordIdsList];
        for(EMS_TM_Timesheet_Record__c Timeshhet:timesheetrejectrecords){
            Timeshhet.status__c='Rejected';
            timesheetrejectList.add(Timeshhet);
            
        }
        update timesheetrejectList;
    }
    @AuraEnabled
    public static void reassignrecord(Id recordId){
        list<EMS_TM_Timesheet_Record__c> timesheetrejectList=new list<EMS_TM_Timesheet_Record__c>();
        List<EMS_TM_Timesheet_Record__c> timesheetrejectrecords=[select id,status__c,owner.Name,EMS_TM_Project__r.Name from EMS_TM_Timesheet_Record__c where Id =:recordId];
        for(EMS_TM_Timesheet_Record__c Timeshhet:timesheetrejectrecords){
            if(Approval.isLocked(Timeshhet.id)){
                Timeshhet.status__c='Rejected';
                system.debug('status__c================================'+Timeshhet.status__c);
                timesheetrejectList.add(Timeshhet);
                system.debug('timesheetrejectList ================'+timesheetrejectList);
                system.debug('timesheetrejectList size ================'+timesheetrejectList.size());
                
            }
        }
        
        //Unlock record
        if(!timesheetrejectList.isEmpty()){
            //Unlock records
            List<Approval.UnlockResult> ulrList = Approval.unlock(timesheetrejectList, true);
            String hrEmail = [SELECT id, DeveloperName, Email__c from Employee_Details__mdt WHERE DeveloperName = 'HR_Team' LIMIT 1].Email__c;
            List<String> hrEmailList = new List<String>();
            hrEmailList.add(hrEmail);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(hrEmailList);
            email.setSubject('Timeshet Reasssign');
            for(EMS_TM_Timesheet_Record__c timesheets:timesheetrejectList){
                email.setPlainTextBody('Dear Employee  your timesheet was reassignd by  '+ timesheets.EMS_TM_Project__r.Name +'please fill the timesheet again');
                //email.setPlainTextBody('Dear reader');
            }
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            
            
            // Iterate through each returned result
            for(Approval.UnlockResult  ulr : ulrList) {
                if (ulr.isSuccess()) {
                    //Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully unlocked timeshhet with ID: ' + ulr.getId());
                }
                else {
                    //Operation failed, so get all errors                
                    for(Database.Error err : ulr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('timeshhet fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        
        update timesheetrejectList;
    }
    
  
    
}