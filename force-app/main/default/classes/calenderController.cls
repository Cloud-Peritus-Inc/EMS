/**
* @author Subba Kalavala
* @date 01/03/2023
* @description  calenderController Class to show the data on Home page for Org Calender
*
*               Test code coverage provided by the following test class:
*               - calenderControllerTest
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public without sharing class calenderController {
    @AuraEnabled(cacheable=true)
    public static List<datawrapper> getEvents() {
        List<datawrapper> dataWrap = new List<datawrapper>();
        
        //----------
        
        Id loggedinUserId = UserInfo.getUserId();
        List<Contact> contactRec = [select id, EMS_TM_User__c, 
                                    (Select id, EMS_TM_ProjectName_Asgn__r.Name, EMS_TM_Status_Asgn__c, EMS_TM_EmployeeName__c from Assignments__r) 
                                    from Contact 
                                    where EMS_TM_User__c =: loggedinUserId]; // '0056t0000030ynEAAQ'];         
        List<String> currentLoggedinUserProjects = new List<String>();
        Id loggedinContact = [Select id, EMS_TM_User__c from Contact where EMS_TM_User__c =: loggedinUserId].id; //'0056t0000030ynEAAQ'].id;
        
        for (Contact conRec : contactRec) {
            List<EMS_TM_Assignment__c> assignments = conRec.Assignments__r;
            for (EMS_TM_Assignment__c assignment : assignments) {
                if(assignment.EMS_TM_Status_Asgn__c == 'Active'){
                    currentLoggedinUserProjects.add(assignment.EMS_TM_ProjectName_Asgn__r.Name);   
                }
            }   
        }
        System.debug('currentLoggedinUserProjects => '+ currentLoggedinUserProjects);
        
        List<Contact> allContacts = [select id, Name, 
                                     (Select id, EMS_TM_ProjectName_Asgn__c, EMS_TM_ProjectName_Asgn__r.Name, EMS_TM_EmployeeName__c 
                                      from Assignments__r) 
                                     from Contact];
        List<Contact> contactsWithSameProject = new List<Contact>();
        
        for(Contact con : allContacts){
            List<EMS_TM_Assignment__c> assignments2 = con.Assignments__r;
                for (EMS_TM_Assignment__c assignment : assignments2) {
                    if(currentLoggedinUserProjects.contains(assignment.EMS_TM_ProjectName_Asgn__r.Name)){
                        System.debug('Contact Name ==> '+ con.Name + '   '+ 'Project Name ==> '+assignment.EMS_TM_ProjectName_Asgn__r.Name);
                        contactsWithSameProject.add(con);
                    } 
                }
        }
        
        List<EMS_LM_Leave_History__c> evtList = new List<EMS_LM_Leave_History__c>();
        if(contactsWithSameProject.size() > 0){
            evtList = [SELECT Id,EMS_LM_Contact__c,EMS_LM_Contact__r.Name, EMS_LM_Leave_Start_Date__c,
                                                 EMS_LM_Leave_End_Date__c,EMS_LM_Status__c ,EMS_LM_Approved_On__c, EMS_LM_Final_Approver__c  ,EMS_LM_Leave_Duration__c , EMS_LM_Reason__c  
                                                 FROM EMS_LM_Leave_History__c WHERE EMS_LM_Contact__c IN: contactsWithSameProject and EMS_LM_Status__c  != 'Cancelled' AND EMS_LM_Status__c  != 'Rejected' AND Leave_Type_Name__c != 'Work From Home'   ORDER BY CreatedDate DESC
                                                ];
        }else{
            evtList = [SELECT Id,EMS_LM_Contact__c,EMS_LM_Contact__r.Name, EMS_LM_Leave_Start_Date__c,
                                                 EMS_LM_Leave_End_Date__c,EMS_LM_Status__c ,EMS_LM_Approved_On__c, EMS_LM_Final_Approver__c  ,EMS_LM_Leave_Duration__c , EMS_LM_Reason__c  
                                                 FROM EMS_LM_Leave_History__c WHERE EMS_LM_Contact__c =: loggedinContact and EMS_LM_Status__c  != 'Cancelled' AND EMS_LM_Status__c  != 'Rejected' AND Leave_Type_Name__c != 'Work From Home'   ORDER BY CreatedDate DESC
                                                ];
        }
        
        
        For(EMS_LM_Leave_History__c evt :  evtList){
            datawrapper dw = new datawrapper();
            dw.Id = evt.Id;
            dw.title = evt.EMS_LM_Contact__r.Name;
            // dw.start = convertTimeToOtherTimeZone(DateTime.newInstance(evt.EMS_LM_Leave_Start_Date__c, Time.newInstance(0, 0, 0, 0)));
            // dw.endTime = convertTimeToOtherTimeZone(DateTime.newInstance(evt.EMS_LM_Leave_End_Date__c, Time.newInstance(0, 0, 0, 0)));
            dw.start = evt.EMS_LM_Leave_Start_Date__c;
            dw.endTime = evt.EMS_LM_Leave_End_Date__c.adddays(1);
            dw.allDay = true;
            dataWrap.add(dw);
        }
        return dataWrap;
    }
    
    @AuraEnabled 
    public static EMS_LM_Leave_History__c getRecordInfo(id recid){
        system.debug('===recid===='+recid);
        return [SELECT Id,EMS_LM_Contact__c,EMS_LM_Contact__r.Name, EMS_LM_Leave_Start_Date__c,
                EMS_LM_Leave_End_Date__c FROM EMS_LM_Leave_History__c WHERE Id=:recid]; 
    }
    
    
    
    public static DateTime convertTimeToOtherTimeZone(DateTime dttime)
    {
        TimeZone tz = Timezone.getTimeZone('GMT');
        System.debug('Display name: ' + tz.getDisplayName());
        System.debug('ID: ' + tz.getID());
        
        Integer offset=tz.getOffset(dttime);
        System.debug('Offset: ' + offset);
        
        // target Timezone.
        TimeZone targetTZ = Timezone.getTimeZone(UserInfo.getTimeZone().getID());
        System.debug('Display name: ' + targetTZ.getDisplayName());
        integer offsetTotargetTZ = targetTZ.getOffset(dttime);
        integer correction = offsetTotargetTZ- offset;
        
        DateTime targetDT = dttime.addMinutes(correction / (1000 * 60));
        
        return targetDT;
    }
    
    
    public class datawrapper {
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public string title;
        @AuraEnabled
        public date start;
        @AuraEnabled
        public date endTime;
        @AuraEnabled
        public boolean allDay;   
    }
}