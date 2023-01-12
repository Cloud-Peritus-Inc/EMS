trigger EMS_TM_Assignmenttrigger on EMS_TM_Assignment__c (before insert,after insert,after update) {
    if(trigger.isbefore && trigger.isinsert)
     {    EMS_TM_ProjectHandler.assignmentCreate(trigger.new);
 
 }
      if(trigger.isafter &&(trigger.isupdate)){
         EMS_TM_ContactBillableclose.closeBillableCheckbox(trigger.new);
     }
 }