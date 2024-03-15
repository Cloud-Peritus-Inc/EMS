import { LightningElement, wire, api, track } from 'lwc';
import getTheCurrentFY from '@salesforce/apex/myMetricsController.getTheCurrentFY';
import getAllKRAs from '@salesforce/apex/myMetricsController.getAllKRAs';
import getTheCheckInInfo from '@salesforce/apex/checkInController.getTheCheckInInfo';
import getThePulseInfo from '@salesforce/apex/checkInController.getThePulseInfo';

//smaske: imports for Get Pulse 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createKraPulseRecords from '@salesforce/apex/myMetricsController.createKraPulseRecords';
import getKraPulseRecords from '@salesforce/apex/myMetricsController.getKraPulseRecords';

export default class MyMetrics extends LightningElement {
    selectedfy;
    fymapdata = [];
    showcheckin = false;
    showpulse = false;
    showkras = false;
    dontshowThePulse = true;
    @track kratable = [];
    @track cintable = [];
    @track ptable = [];
    disableButton;

    //current contact resourceId
    resourceId;
    pulseKraRecord = [];

    connectedCallback() {
        this.getallKrafromserver();

        getThePulseInfo({
            resourceId: null,
            fyId: this.selectedfy
        })
            .then(result => {
                console.log('====ptable1=======' + JSON.stringify(result));
                this.ptable = result;
                if (this.ptable) {
                    this.disableButton = false;
                } else {
                    this.disableButton = true;
                }
            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });
    }


    @wire(getTheCurrentFY)
    wiredRR({ error, data }) {
        if (data) {
            console.log('-======---=data==--=-=-' + JSON.stringify(data));
            this.selectedfy = data.currentName;
            this.resourceId = data.currentResId;
            var consts = data.fyListMap;
            this.dontshowThePulse = data.dontshowThePulse;
            var optionlist = [];
            for (var key in consts) {
                optionlist.push({ label: key, value: consts[key] });
            }
            this.fymapdata = optionlist;
            console.log('-======---=this.fymapdata==--=-=-' + JSON.stringify(this.fymapdata));

        }
        if (error) {
            console.log('-======---=ERROR==--=-=-' + JSON.stringify(error));
        }
    }

    checkInToggle(event) {
        if (event.target.checked) {
            this.getCheckInfo();
        }
        this.showcheckin = event.target.checked;
    }
    pulseToggle(event) {
        if (event.target.checked) {
            this.getpulseInfo();
        }

        this.showpulse = event.target.checked;
    }
    kraToggle(event) {
        if (event.target.checked) {
            this.getallKrafromserver();
        }
        this.showkras = event.target.checked;
    }

    handleFYChange(event) {
        this.selectedfy = event.detail.value;
        this.getallKrafromserver();
        this.getCheckInfo();
        this.getpulseInfo();
    }

    getallKrafromserver() {
        console.log('Called by child');
        getAllKRAs({
            fyId: this.selectedfy
        })
            .then(result => {
                console.log('====result=======' + JSON.stringify(result));
                this.kratable = result;
            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });
    }

    getCheckInfo() {
        console.log("resourceId In getCheckInfo:: " + this.resourceId);
        getTheCheckInInfo({
            resourceId: null,
            fyId: this.selectedfy
        })
            .then(result => {
                console.log('====cintable=======' + JSON.stringify(result));
                this.cintable = result;
            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });
    }

    getpulseInfo() {

        getThePulseInfo({
            resourceId: null,
            fyId: this.selectedfy
        })
            .then(result => {
                console.log('====ptable=======' + JSON.stringify(result));
                this.ptable = result;
            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });
    }

    getPulseBtnHandler(event) {
        console.log("Current User ContactId " + this.resourceId);
        console.log("selectedfy " + this.selectedfy);
        let loggedInUserConId = this.resourceId;

        getKraPulseRecords({ loggedInUserConId: loggedInUserConId, FyId: this.selectedfy })
            .then((result) => {
                console.log("result result " + JSON.stringify(result));
                if (result && result.length > 0) {
                    console.log("getKraPulseRecords result " + JSON.stringify(result));
                    //smaske: FOR : QA_PR_037 : Updating Condition to show toast msg based on Pulse Records "Status" field value.
                    let allSubmitted = true;
                    result.forEach(record => {
                        if (record.Status__c !== "Pulse Submitted") {
                            allSubmitted = false;
                        }
                    });

                    if (allSubmitted) {
                        let msgg = "You have already received feedback from the Reportee(s)";
                        let vari = "info";
                        this.showNotification(msgg, vari);
                    } else {
                        let msgg = "You have Successfully requested the Pulse Request. Please wait for the request to be processed";
                        let vari = "info";
                        this.showNotification(msgg, vari);
                    }

                } else {
                    let msg = `You have Successfully requested a Pulse. Please wait for the previous request to be processed.`;
                    const event = new ShowToastEvent({
                        message: msg,
                        variant: 'info',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
            })
            .catch((error) => {
                console.log(" Error fetching Pulse record " + JSON.stringify(error));
                let msg = `Oops! Something went wrong while trying to send your feedback request.`;
                const event = new ShowToastEvent({
                    message: msg,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
            });
    }

    showNotification(msg, variant) {
        const evt = new ShowToastEvent({
            title: '',
            message: msg,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }



}