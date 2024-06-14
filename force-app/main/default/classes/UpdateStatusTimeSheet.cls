/**
* @author Vamsi
* @date 05/27/2023
* @description  This class for update Timesheet records at time.
*
* CHANGE HISTORY
* ====================================================================================================
* DATE          NAME                    DESCRIPTION
* N/A           N/A                     N/A
* ====================================================================================================
**/
public class UpdateStatusTimeSheet {
    
    public static void Approvealltimesheets(Id recordId){
        list<EMS_TM_Timesheet_Record__c> TimesheetList=new list<EMS_TM_Timesheet_Record__c>();
        List<EMS_TM_Timesheet_Record__c> Timesheetrecords=[select id,status__C from EMS_TM_Timesheet_Record__c where Id=:recordId];
        for(EMS_TM_Timesheet_Record__c Timeshhet:Timesheetrecords){
            Timeshhet.status__c='Approved';
            TimesheetList.add(Timeshhet);
            
        }
        update TimesheetList;
    }
     public static void Rejectalltimesheets(Id recordId){
        list<EMS_TM_Timesheet_Record__c> RejectTimesheetList =new list<EMS_TM_Timesheet_Record__c>();
        List<EMS_TM_Timesheet_Record__c> Rejectrecords=[select id,status__C from EMS_TM_Timesheet_Record__c where Id=:recordId];
        for(EMS_TM_Timesheet_Record__c RejectTime:Rejectrecords){
            RejectTime.status__c='Rejected';
            RejectTimesheetList.add(RejectTime);
            
        }
        update RejectTimesheetList;
    }
    
}