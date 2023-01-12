trigger CustomContactUpdateFromStdTrigger on Contact (after update) {
    
    
	If (Trigger.isAfter && Trigger.isUpdate && CustomContactUpdateHandler.iscontactTriggerExecuted == false){
        CustomContactUpdateHandler.updateCustomContact(Trigger.New);
    }
}