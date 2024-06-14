public class restrictAssignmentTimePreandPost implements triggerAction.BeforeInsert,TriggerAction.BeforeUpdate {
    public void beforeInsert(List<EMS_TM_Timesheet_Record__c> newList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictAssignmentTimePreandPost.beforeInsert() : BEGIN');
        restrictAssCreationForClosedProjects(newList,null);
        System.debug(LoggingLevel.DEBUG, 'restrictAssignmentTimePreandPost.beforeInsert() : END');       
    }
    
    public void beforeUpdate(List<EMS_TM_Timesheet_Record__c> newList,List<EMS_TM_Timesheet_Record__c> oldList) {      
        System.debug(LoggingLevel.DEBUG, 'restrictAssignmentTimePreandPost.beforeUpdate() : BEGIN');
        restrictAssCreationForClosedProjects(newList,new Map<Id,EMS_TM_Timesheet_Record__c>(oldList));
        System.debug(LoggingLevel.DEBUG, 'restrictAssignmentTimePreandPost.beforeUpdate() : END');       
    }
    
    
    /**
*
*   CHANGE HISTORY
*   ====================================================================================================
*   Date        Name                    Description
*   N/A         N/A                     N/A
*   ====================================================================================================
**/
    private void restrictAssCreationForClosedProjects(List<EMS_TM_Timesheet_Record__c> timesheetdata, Map<Id,EMS_TM_Timesheet_Record__c> oldMap) {
        set<Id> assignmentIds = new set<Id>();
        List<EMS_TM_Timesheet_Record__c> filteredlist = new List<EMS_TM_Timesheet_Record__c>();
        Map<Id,EMS_TM_Assignment__c> assMap = new Map<Id,EMS_TM_Assignment__c>();
        Set<Id> TimeSheetId = New Set<Id>();
        Map<Id,EMS_Timesheet__c> Timesheetmap = new Map<Id,EMS_Timesheet__c>();
        
        
        for(EMS_TM_Timesheet_Record__c newRec : timesheetdata){
            if(newRec.Assignment__c != null){
                assignmentIds.add(newRec.Assignment__c); 
                TimeSheetId.add(newRec.EMS_Timesheet__c);
                filteredlist.add(newRec);
            }
        }
        SYstem.debug('**assignmentIds'+assignmentIds);
        SYstem.debug('**filteredlist'+filteredlist);
        
        if(!filteredlist.isEmpty()){
            Timesheetmap = new Map<ID, EMS_Timesheet__c>([SELECT Id, Name, Week_End_Date__c, Week_Start_Date__c FROM EMS_Timesheet__c WHERE Id IN: TimeSheetId]);
            for(EMS_TM_Assignment__c ass : [SELECT Id,EMS_TM_StartDate_Asgn__c,EMS_TM_EndDate_Asgn__c,EMS_TM_ProjectName_Asgn__r.name,EMS_TM_ProjectName_Asgn__r.EMS_TM_EndDate__c from EMS_TM_Assignment__c WHERE Id IN:assignmentIds ]){
                assMap.put(ass.id,ass);  
            }
            SYstem.debug('**assMap------->'+assMap);
            for(EMS_TM_Timesheet_Record__c newRec : filteredlist){
                EMS_TM_Assignment__c ass = assMap.get(newRec.Assignment__c);
                string projectName = ass.EMS_TM_ProjectName_Asgn__r.name;
                Date assStartDate = ass.EMS_TM_StartDate_Asgn__c;
                //Date assEndDate = ass.EMS_TM_EndDate_Asgn__c;
                Date assEndDate = (ass.EMS_TM_EndDate_Asgn__c != null) ? ass.EMS_TM_EndDate_Asgn__c : ass.EMS_TM_ProjectName_Asgn__r.EMS_TM_EndDate__c;
                Date weekStart = Timesheetmap.get(newRec.EMS_Timesheet__c).Week_Start_Date__c;
                Date weekEnd = Timesheetmap.get(newRec.EMS_Timesheet__c).Week_End_Date__c;
                boolean throwError = false;
                
                if((newRec.EMS_TM_Mon__c != null && newRec.EMS_TM_Mon__c != 0) && (weekStart < assStartDate || weekStart > assEndDate)){
                    
                    throwError = true;
                }
                else if((newRec.EMS_TM_Tue__c != null && newRec.EMS_TM_Tue__c != 0) && (weekStart.addDays(1) < assStartDate || weekStart.addDays(1) > assEndDate)){
                    throwError = true;
                }
                else if((newRec.EMS_TM_Wed__c != null && newRec.EMS_TM_Wed__c != 0) && (weekStart.addDays(2) < assStartDate || weekStart.addDays(2) > assEndDate)){
                    throwError = true;
                }
                else if((newRec.EMS_TM_THU__c != null && newRec.EMS_TM_THU__c != 0) && (weekStart.addDays(3) < assStartDate || weekStart.addDays(3) > assEndDate)){
                    throwError = true;
                }
                else if((newRec.EMS_TM_FRI__c != null && newRec.EMS_TM_FRI__c != 0) && (weekStart.addDays(4) < assStartDate || weekStart.addDays(4) > assEndDate)){
                    throwError = true;
                }
                else if((newRec.EMS_TM_SAT__c != null && newRec.EMS_TM_SAT__c != 0) && (weekStart.addDays(5) < assStartDate || weekStart.addDays(5) > assEndDate)){
                    throwError = true;
                }
                else if((newRec.EMS_TM_Sun__c != null && newRec.EMS_TM_Sun__c != 0) && (weekStart.addDays(6) < assStartDate || weekStart.addDays(6) > assEndDate)){
                    throwError = true;
                }
                
                if (throwError) {
                    String errorMessage = projectName + ': Please enter time within the start (' + String.valueOf(assStartDate.day()) + '/' + String.valueOf(assStartDate.month()) + '/' + String.valueOf(assStartDate.year())
                        + ') and end (' + String.valueOf(assEndDate.day()) + '/' + String.valueOf(assEndDate.month()) + '/' + String.valueOf(assEndDate.year())
                        + ') dates of your assignment, for other days fill zero hours.';
                    /*String errorMessage='You are not allowed to fill hours to this project as you are not designated for it on the chosen date.'; */
                    newRec.addError(errorMessage);
                    
                }
                
                
            }   
            
        }
    }
}