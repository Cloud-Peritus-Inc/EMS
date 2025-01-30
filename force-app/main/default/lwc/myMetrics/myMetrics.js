import { LightningElement, wire, api, track } from 'lwc';
import getTheCurrentFY from '@salesforce/apex/myMetricsController.getTheCurrentFY';
import getAllKRAs from '@salesforce/apex/myMetricsController.getAllKRAs';
import getTheCheckInInfo from '@salesforce/apex/checkInController.getTheCheckInInfo';
import getThePulseInfo from '@salesforce/apex/checkInController.getThePulseInfo';
import Id from '@salesforce/user/Id';

//smaske: imports for Get Pulse 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createKraPulseRecords from '@salesforce/apex/myMetricsController.createKraPulseRecords';
import getKraPulseRecords from '@salesforce/apex/myMetricsController.getKraPulseRecords';

export default class MyMetrics extends LightningElement {
    tab = 'My Metric';
    selectedfy;
    fymapdata = [];
    showcheckin = false;
    showpulse = false;
    showkras = false;
    dontshowThePulse = true;
    @track kratable = [];
    @track cintable = [];
    @track ptable = [];
    @track menteerecords = [];
    disableButton;
    @track employeeName ;
    @track managerName ;
    @track startDate ;
    @track endDate;
    @track projectName ;
    @track showcombobox = false; //sangharsh



    //current contact resourceId.
    resourceId;
    pulseKraRecord = [];

    @track columns = [{label: 'Project Name',fieldName: 'projectName', type: 'text',sortable: true,typeAttributes :{ label :{fieldName: 'projectName'},target :'_blank'}},
                     {label: 'Contact Name ',fieldName: 'empName', type: 'text',sortable: true},
                     {label: 'Project Start Date',fieldName: 'startDate', type: 'Date',sortable: true},
                     {label: 'Project End Date',fieldName: 'endDate', type: 'Date',sortable: true},
                      {label: 'Project Manager',fieldName: 'managerName', type: 'text',sortable: true}];

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

        /*smaske [UAT_062] : calling Pulse method / Checkin method for toggle issue*/
        this.getCheckInfo();
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
                //console.log('====My Metric JS result=======' + JSON.stringify(result));
                //this.kratable = result;
                // Process the result to modify allowCopy
            this.kratable = result.map(item => {

                //copied from kratablejs
                let tableRecordsData = item.qualList;
                console.log('tableRecordsData Length ' + tableRecordsData.length);
                tableRecordsData.forEach(qualItem => {
                    if (qualItem.mentorSubmitted && this.tab == 'My Team') {
                        qualItem.allowedit = false;
                        qualItem.allowCopy = false;
                    } else if (qualItem.menteeSubmitted && this.tab == 'My Metric') {
                        qualItem.allowedit = false;
                        qualItem.allowCopy = false;
                    }
                });
                
                return item;
            });

            console.log('Modified KRA Table: ', JSON.stringify(this.kratable));
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
                        let msgg = "You have already received feedback from your reportee(s) for this quarter";
                        let vari = "info";
                        this.showNotification(msgg, vari);
                    } else {
                        let msgg = "You have successfully requested the Pulse Request. Please wait for your reportee(s) to submit the feedback";
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

      //@sangharsh Show Project Assignment
    ProjectAssignToggle(event) {
        //this.selectedresource
        if (event.target.checked) {
            this.showcombobox = true;
            console.log('====Is checked=======');
        }else{
                this.showcombobox = false;
        }
    }

    
}