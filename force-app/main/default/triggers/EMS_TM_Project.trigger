trigger EMS_TM_Project on EMS_TM_Project__c (after update) {
    EMS_TM_ProjectHandler.assignmentStatusUpdate(trigger.new);

}