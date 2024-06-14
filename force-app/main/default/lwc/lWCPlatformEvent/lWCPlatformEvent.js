import { LightningElement,wire,api,track } from 'lwc';
import { loadScript } from "lightning/platformResourceLoader";
import cometdlwc from "@salesforce/resourceUrl/cometd";
import getSessionId from '@salesforce/apex/SessionUtil.getSessionId';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
//import PROJECT_ASSIGNEE_CREATED_CHANNEL from '@salesforce/schema/projectAssigneeCreated__e';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LWCPlatformEvent extends LightningElement {

    libInitialized = false;
    @track sessionId;
    @track error;

    @api recordId;
    @api channelName = '/event/projectAssigneeCreated__e';
    @api message = 'An assignment record is created for the Project Manager, please review the details, and edit them if necessarily';
    subscription = {};

    /*connectedCallback() {
        // Register error listener
        console.log('Connected callback called');     
        this.registerErrorListener();
        this.handleSubscribe();
    }

    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const self = this;
        const messageCallback = function (response) {
            console.log('New message received 1: ', JSON.stringify(response));
            var obj = JSON.parse(JSON.stringify(response));
            console.log( JSON.stringify(obj.data.payload));
            console.log(self.channelName);
            let objData = obj.data.payload;
            console.log(objData);
            self.ShowToast('Success', self.message, 'success', 'dismissable');
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    //handle Error
    registerErrorListener() {
        onError(error => {
            console.log('Received error from server: ', JSON.stringify(error));
        });
    }
 
    ShowToast(title, message, variant, mode) {        
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    } */

    
    
    // CODE FOR COMMETD

    @wire(getSessionId)
    wiredSessionId({ error, data }) {
        if (data) {
            console.log('sessionId data ' + data);
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
          url: window.location.protocol + '//' + window.location.hostname + '/cometd/47.0/',
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
                cometdlib.subscribe('/event/projectAssigneeCreated__e', function (message) {
                    console.log('subscribed to message!' + message);
                    console.log('subscribed to message!'+ JSON.stringify(message));
                    var obj = JSON.parse(JSON.stringify(message));
                    let objData = obj.data.payload;
                    let projectAssigneeId = objData.projectAssigneeId__c;
                    if(projectAssigneeId){
                        const msg = 'An assignment record is created for the Project Manager, please review the details, and edit them if necessarily';

                        const evt = new ShowToastEvent({
                            title: 'Success',
                            message: msg,
                            variant: 'success',
                            mode: 'dismissable'
                        });
                        self.dispatchEvent(evt);
                    }

                });
            } else {
                /// Cannot handshake with the server, alert user.
                console.error('Error in handshaking: ' + JSON.stringify(status));
            }
        });
    }


}