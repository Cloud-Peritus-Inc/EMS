import { LightningElement, api, track, wire } from 'lwc';
import viewPmRequestsController from '@salesforce/apex/viewPmRequestsController.viewPMRequestsTable';
import recallPmRequests from '@salesforce/apex/viewPmRequestsController.recallPmRequests';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class ViewPMRequests extends LightningElement {

    @api receivedkraid;
    @api tab;
    viewRequestRecord;
    rejectionReason = '';
    @track showPMRequestRecords = false;
    @track disablerecallbutton = false;
    @track disablecolumn = false;
    isShowPopUp = false;
    @track comment = '';
    error;
    pmRequestTable;

    connectedcallback() {
      
    }

    @wire(viewPmRequestsController,{ KraId: '$receivedkraid'}) 
        pmRequestData(result) {
        this.viewRequestRecord = result;
        if (result.data) {
            this.pmRequestTable = [];
            this.pmRequestTable = result.data;
            if (this.tab == 'My Team') {
                this.disablecolumn = true;
                console.log('this.tab1 '+this.tab );
            }
            if (this.tab == 'My Metric') {
               console.log('this.tab2 '+this.tab );
                this.disablecolumn = false;
            }
                console.log('pm===='+JSON.stringify(this.pmRequestTable));
                console.log('this.pmRequestTable.length ----'+this.pmRequestTable.length );
                 if (this.pmRequestTable.length > 0) {
                    this.showPMRequestRecords = true;
                    console.log('Entered Inside this.showPMRequestRecord-----'+this.showPMRequestRecords);
                    this.disablerecallbutton = false;
                 }
                  else{
                    this.showPMRequestRecords = false;
                  }
        }
        else if (result.error) {
                 console.log('error------'+result.error);
                this.pmRequestTable = undefined;
                this.error = result.error;
            }
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
                this.disablerecallbutton = false;
                this.hideModalBox();
                console.log('this.viewRequestRecord BEFORE' + JSON.stringify(this.viewRequestRecord));
                refreshApex(this.viewRequestRecord);
                console.log('this.viewRequestRecord aFTER' + JSON.stringify(this.viewRequestRecord));
                // return refreshApex(this.viewRequestRecord);
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