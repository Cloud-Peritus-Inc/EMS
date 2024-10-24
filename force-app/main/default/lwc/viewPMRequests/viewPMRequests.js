import { LightningElement, api, track, wire } from 'lwc';
import viewPMRequestsTable from '@salesforce/apex/viewPmRequestsController.viewPMRequestsTable';
import recallPmRequests from '@salesforce/apex/viewPmRequestsController.recallPmRequests';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class ViewPMRequests extends LightningElement {

    @api receivedkraid;
    @api tab;
    @api viewonlymode = false;
    viewRequestRecord;
    rejectionReason = '';
    @track showPMRequestRecords = false;
    @track disablerecallbutton = false;
    @track disablecolumn = false;
    isShowPopUp = false;
    @track comment = '';
    error;
    pmRequestTable;

    connectedCallback() {
        //smaske : PM_Def_174 : instead of wire calling in connected callback
        console.log('In connected call back PM_Def_174');
        console.log('In connected call back PM_Def_174 '+ this.viewonlymode);
        this.loadPmRequests();
    }

    loadPmRequests() {
        console.log('In loadPmRequests');
        console.log('In connected call back PM_Def_174 '+ this.viewonlymode);
        viewPMRequestsTable({ KraId: this.receivedkraid })
            .then(result => {
                if (result) {
                    console.log('result :' + JSON.stringify(result));
                    
                    this.pmRequestTable = [];
                    this.pmRequestTable = result;
                    if (this.tab === 'My Team') {
                        //smaske: UAT_Smoke_016 : [24-oct-2024] : hiding action column for indirect reportee, showing for direct reportees.Originally it was set to true
                        this.disablecolumn = this.viewonlymode == true ? false : true;
                        console.log('this.tab1 ' + this.tab);
                    }
                    if (this.tab === 'My Metric') {
                        console.log('this.tab2 ' + this.tab);
                        this.disablecolumn = false;
                    }
                    console.log('pm====' + JSON.stringify(this.pmRequestTable));
                    console.log('this.pmRequestTable.length ----' + this.pmRequestTable.length);
                    if (this.pmRequestTable.length > 0) {
                        this.showPMRequestRecords = true;
                        console.log('Entered Inside this.showPMRequestRecord-----' + this.showPMRequestRecords);
                        this.disablerecallbutton = false;
                    } else {
                        this.showPMRequestRecords = false;
                    }
                }
            })
            .catch(error => {
                console.log('error------' + error);
                this.pmRequestTable = undefined;
                this.error = error;
            });
    }



    hideModalBox() {
        this.isShowPopUp = false;
        this.comment = '';
    }

    handleCommentChange(event) {
        this.rejectionReason = event.target.value;
        this.comment = event.target.value;
    }

    kraId;
    managerid;
    projectid;

    handleRejectionSubmission() {
        if (!this.comment) {
            //smaske : PM_Def_098 : showing toast msg if rejection reason is not filled
            //this.showToast2('Please Enter a Rejection Reason.', 'error', 'dismissible');
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Please enter a recall reason',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        } else {

            recallPmRequests({
                KraId: this.kraId,
                projectManager: this.managerid,
                projectName: this.projectid,
                rejectionReason: this.rejectionReason

            }).then(res => {

                const evt = new ShowToastEvent({
                    //title: 'success',
                    message: 'Successfully recalled the request',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                
                console.log('this.viewRequestRecord BEFORE' + JSON.stringify(this.viewRequestRecord));
                this.loadPmRequests(); //smaske : PM_Def_174 : calling the loadPmRequests to relead and update buttons on UI
                this.hideModalBox();
                console.log('this.viewRequestRecord aFTER' + JSON.stringify(this.viewRequestRecord));
            }).catch(err => {
                this.disablerecallbutton = true;
                console.log('err', err);
                const evt = new ShowToastEvent({
                    //title: 'Toast Error',
                    message: 'Some thing went wrong...' + JSON.stringify(err),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);

            });
        }
    }

    HandlerecallRowAction(event) {
        this.kraId = event.currentTarget.dataset.kraid;
        this.managerid = event.currentTarget.dataset.managerid;
        this.projectid = event.currentTarget.dataset.projectid;

        this.isShowPopUp = true;
    }
}