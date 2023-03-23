trigger CustomLeadUpdateFromStdTrigger on Lead (after update) {
	If (Trigger.isAfter && Trigger.isUpdate && CustomLeadUpdateHandler.isLeadTriggerExecuted == false){
        CustomLeadUpdateHandler.updateCustomLead(Trigger.New);
    }
}