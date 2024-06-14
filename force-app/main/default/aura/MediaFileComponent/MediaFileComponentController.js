({
	doInit : function(component, event, helper) {
		component.set('v.mycolumns', [
            { label: 'File name', fieldName: 'name', type: 'text'},
            { label: 'Type', fieldName: 'type', type: 'text'},
            { label : 'Action', type: 'button-icon', typeAttributes: { iconName: 'utility:play', name:'play', title: 'Action', iconAlternativeText: 'Play' }}
        ]);
        // component.set("v.mediaFiles",mediaFileList);
    },
    
    playFile : function(component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        if(action.name === 'play') {
            console.log('Play file: ' + JSON.stringify(row));
            component.set("v.mediaFile", row);
            component.set("v.showModal", true);
        }
        
    },
    
    closeModal : function(component) {
        component.set("v.showModal", false);
        component.set("v.mediaFile", null);
    }
})