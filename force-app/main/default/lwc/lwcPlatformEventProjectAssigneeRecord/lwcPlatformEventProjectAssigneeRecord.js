import { LightningElement,wire,api,track } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
//import PROJECT_ASSIGNEE_CREATED_CHANNEL from '@salesforce/schema/projectAssigneeCreated2__e';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class lwcPlatformEventProjectAssigneeRecord extends LightningElement {

    libInitialized = false;
    @track sessionId;
    @track error;

    @api recordId;
    @api channelName = 'projectAssigneeCreated2__e';
    @api message = 'You are allocating more than 100% for the Resource';
    subscription = {};
    
    // CODE FOR COMMETD

     connectedCallback() {
        console.log('Successfully connectedCallback');
         //this.showCustomToast();
    }

    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            this.sessionId = data;
            this.error = undefined;
            loadScript(this, cometdlwc)
                .then(() => {
                    this.initializecometd()
                });
        } else if (error) {
            console.log(error);
            this.error = error;
            this.sessionId = undefined;
        }
    }

     showCustomToast() {
        const evt = new ShowToastEvent({
            title: 'Hello',
            message: 'This is a custom toast message',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }


    initializecometd() {

        const self = this;

        if (this.libInitialized) {
          return;
        }
      
       this.libInitialized = true;
      
       //inintializing cometD object/class
       var cometdlib = new window.org.cometd.CometD();
              
      //Calling configure method of cometD class, to setup authentication which will be used in handshaking
        cometdlib.configure({
          url: window.location.protocol + '//' + window.location.hostname + '/cometd/58.0/',
          requestHeaders: { Authorization: 'OAuth ' + this.sessionId},
          appendMessageTypeToURL : false,
          logLevel: 'debug'
      });
      
      cometdlib.websocketEnabled = false;
      
        cometdlib.handshake(function (status) {

            if (status.successful) {
                // Successfully connected to the server.
                // Now it is possible to subscribe or send messages
                console.log('Successfully connected to server');
                console.log('/event/'+ self.channelName);
                    cometdlib.subscribe('/event/projectAssigneeCreated2__e', function (message) {
                    console.log('subscribed to message!' + message);
                    console.log('subscribed to message!'+ JSON.stringify(message));
                    var obj = JSON.parse(JSON.stringify(message));
                    let objData = obj.data.payload;
                    let projectAssigneeId = objData.projectAssigneeId__c;
                    let resourceName = objData.projectAssigneeResourceName__c;
                    let totalProjectAllocation = objData.projectAssigneeTotalProjectAllocation__c;
                    console.log('projectAssigneeId'+  projectAssigneeId);
                    console.log('resourceName'+  resourceName);
                    console.log('totalProjectAllocation'+  totalProjectAllocation);
                    self.message = `You are allocating ${resourceName} more than 100%, the current Total Allocation is ${totalProjectAllocation}%`;
                                        
                    if(projectAssigneeId){
                        console.log('Inside Toast lwcPlatformEventProjectAssigneeRecord');
                        console.log('self.message :: '+ self.message);
                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: self.message,
                            variant: 'success',
                            mode: 'pester'
                        });
                        self.dispatchEvent(evt);  
                        console.log('After Toast');

                    }

                });
            } else {
                /// Cannot handshake with the server, alert user.
                console.error('Error in handshaking: ' + JSON.stringify(status));
            }
        });
    }

}