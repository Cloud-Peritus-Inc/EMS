({
    closeQuickAction_AuraMethod : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleSuccess: function (component, event, helper) {
    console.log("Handling success event in Aura component:", event.getParam("message"));
	}
})