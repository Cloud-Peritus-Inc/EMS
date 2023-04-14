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
*   {Purpose} - Method to restrict the project manager not to create any assignments for Inactive Projects
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
       
        for(EMS_TM_Timesheet_Record__c newRec : timesheetdata){
            if(newRec.Assignment__c != null){
               assignmentIds.add(newRec.Assignment__c); 
               filteredlist.add(newRec);
            }
        }
        SYstem.debug('**assignmentIds'+assignmentIds);
        SYstem.debug('**filteredlist'+filteredlist);
        
        if(!filteredlist.isEmpty()){
             date todaydate = system.today();
            Date considerDate = todaydate.toStartofWeek();
            Date weekStart = considerDate.toStartofWeek().addDays(1);
            Date weekEnd = considerDate.toStartofWeek().addDays(7);
            for(EMS_TM_Assignment__c ass : [SELECT Id,EMS_TM_StartDate_Asgn__c,EMS_TM_EndDate_Asgn__c,EMS_TM_ProjectName_Asgn__r.name from EMS_TM_Assignment__c WHERE Id IN:assignmentIds ]){
              assMap.put(ass.id,ass);  
            }
            SYstem.debug('**assMap------->'+assMap);
            for(EMS_TM_Timesheet_Record__c newRec : filteredlist){
                EMS_TM_Assignment__c ass = assMap.get(newRec.Assignment__c);
                string projectName = ass.EMS_TM_ProjectName_Asgn__r.name;
                Date assStartDate = ass.EMS_TM_StartDate_Asgn__c;
                System.debug('**assStartDate-------->'+assStartDate);
                Date assEndDate = ass.EMS_TM_EndDate_Asgn__c;
                Boolean endDateCheck = false;
                Boolean startDateCheck = false;
                endDateCheck = assEndDate <= weekEnd ;
                startDateCheck = true;
                System.debug('**assEndDate--->'+assEndDate);
                Datetime startdt = (DateTime)assStartDate;
                System.debug('**startdt--->'+startdt);
                Datetime enddt = (DateTime)assEndDate;
                System.debug('**enddt--->'+enddt);
                boolean throwStartError = false;
                boolean throwEndError = false;
                String startfillTheTimeForDay = startdt.format('EEEE');
                SYstem.debug('**startfillTheTimeForDay-->'+startfillTheTimeForDay);
                String endfillTheTimeForDay = enddt.format('EEEE');
                 SYstem.debug('**endfillTheTimeForDay-->'+endfillTheTimeForDay);
                SYstem.debug('**newRec-->'+newRec);
                if(startDateCheck){
                if(startfillTheTimeForDay == 'Monday'){
                   if(newRec.EMS_TM_Sun__c != null && newRec.EMS_TM_Sun__c != 0){
                        throwStartError = true;
                    }  
                }else if(startfillTheTimeForDay == 'Tuesday'){
                    if((newRec.EMS_TM_Mon__c != null && newRec.EMS_TM_Mon__c != 0) 
                       || (newRec.EMS_TM_Sun__c != null && newRec.EMS_TM_Sun__c != 0)){
                        throwStartError = true;
                    }
                }else if(startfillTheTimeForDay == 'Wednesday'){
                   if((newRec.EMS_TM_Mon__c != null && newRec.EMS_TM_Mon__c != 0) 
                      || (newRec.EMS_TM_Sun__c != null && newRec.EMS_TM_Sun__c != 0) 
                        || (newRec.EMS_TM_Tue__c!= null && newRec.EMS_TM_Tue__c != 0)){
                        throwStartError = true;
                    }
                }else if(startfillTheTimeForDay == 'Thursday'){
                    if((newRec.EMS_TM_Mon__c != null && newRec.EMS_TM_Mon__c != 0) 
                      || (newRec.EMS_TM_Sun__c != null && newRec.EMS_TM_Sun__c != 0) 
                        || (newRec.EMS_TM_Tue__c!= null && newRec.EMS_TM_Tue__c != 0)
                       || (newRec.EMS_TM_Wed__c!= null && newRec.EMS_TM_Wed__c != 0)){
                        throwStartError = true;
                    }
                    
                }else if(startfillTheTimeForDay == 'Friday'){
                    if((newRec.EMS_TM_Mon__c != null && newRec.EMS_TM_Mon__c != 0) 
                      || (newRec.EMS_TM_Sun__c != null && newRec.EMS_TM_Sun__c != 0) 
                        || (newRec.EMS_TM_Tue__c!= null && newRec.EMS_TM_Tue__c != 0)
                       || (newRec.EMS_TM_Wed__c!= null && newRec.EMS_TM_Wed__c != 0)
                       || (newRec.EMS_TM_THU__c!= null && newRec.EMS_TM_THU__c != 0)){
                        throwStartError = true;
                    }  
                }
                }
                if(endDateCheck){
                if(endfillTheTimeForDay == 'Monday'){
                     if((newRec.EMS_TM_FRI__c != null && newRec.EMS_TM_FRI__c != 0)
                        || (newRec.EMS_TM_SAT__c != null && newRec.EMS_TM_SAT__c != 0) 
                        || (newRec.EMS_TM_Tue__c!= null && newRec.EMS_TM_Tue__c != 0)
                       || (newRec.EMS_TM_Wed__c!= null && newRec.EMS_TM_Wed__c != 0)
                       || (newRec.EMS_TM_THU__c!= null && newRec.EMS_TM_THU__c != 0)){
                        throwEndError = true;
                    } 
                    
                }else if(endfillTheTimeForDay == 'Tuesday'){
                    if((newRec.EMS_TM_FRI__c != null && newRec.EMS_TM_FRI__c != 0)
                        || (newRec.EMS_TM_SAT__c != null && newRec.EMS_TM_SAT__c != 0)
                       || (newRec.EMS_TM_Wed__c!= null && newRec.EMS_TM_Wed__c != 0)
                       || (newRec.EMS_TM_THU__c!= null && newRec.EMS_TM_THU__c != 0)){
                        throwEndError = true;
                    } 
                }else if(endfillTheTimeForDay == 'Wednesday'){
                   if((newRec.EMS_TM_FRI__c != null && newRec.EMS_TM_FRI__c != 0)
                        || (newRec.EMS_TM_SAT__c != null && newRec.EMS_TM_SAT__c != 0) 
                       || (newRec.EMS_TM_THU__c!= null && newRec.EMS_TM_THU__c != 0)){
                        throwEndError = true;
                    } 
                }else if(endfillTheTimeForDay == 'Thursday'){
                   if((newRec.EMS_TM_FRI__c != null && newRec.EMS_TM_FRI__c != 0)
                        || (newRec.EMS_TM_SAT__c != null && newRec.EMS_TM_SAT__c != 0) 
                       ){
                        throwEndError = true;
                    } 
                    
                }else if(endfillTheTimeForDay == 'Friday'){
                   if(newRec.EMS_TM_SAT__c != null && newRec.EMS_TM_SAT__c != 0) 
                     {
                        throwEndError = true;
                    } 
                }
                }
                
                if(throwEndError){
                  newRec.addError(projectName +': Please enter time within the start and end dates of your assignment, for other days fill zero hours');  
                }
                if(throwStartError){
                   newRec.addError(projectName +': Please enter time within the start and end dates of your assignment, for other days fill zero hours'); 
                }

            }   
            
        }
        
        
        
    }
}