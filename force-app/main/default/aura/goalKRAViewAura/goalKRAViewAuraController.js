({
    doInit : function(component, event, helper) {
        // Access the record ID using the force:hasRecordId interface
        var recordId = component.get("v.recordId");
        console.log("Record ID: " + recordId);
        
        // You can use this recordId to fetch and display record details using Apex or other methods.
    }
})