({
   closeQuickAction_AuraMethod : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
	handleSuccess : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})