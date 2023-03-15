import { LightningElement, wire, track } from 'lwc';
import getLeaveReqData from '@salesforce/apex/LeaveRequestApexController.getLeaveReqData';
import updateRejecteStatusAndComments from '@salesforce/apex/LeaveRequestRejectHandler.updateRejecteStatusAndComments';
import updateApproveStatusAndComments from '@salesforce/apex/LeaveRequestApproveHandler.updateApproveStatusAndComments';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class RecentRequestTile extends NavigationMixin(LightningElement) {

    reqLeaveData;
    approveComments = '';
    rejectComments = '';
    selectedRecordApproveId;
    isShowModalApprove = false;
    isShowModalReject = false;
    nodata = false;
    @track reqLeaveArray;
    errorMessage = ''
    _wiredRefreshData;

    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        console.log('Base Url' + this.a_Record_URL);
    }


    // TO GET THE LEAVE REQUEST DATA
    @wire(getLeaveReqData)
    getLeaveReqDataWiredData(wireResult) {
        const { data, error } = wireResult; // TO REFRESH THE DATA USED THIS BY STORING DATA AND ERROR IN A VARIABLE
        this._wiredRefreshData = wireResult;
        if (data) {
            this.reqLeaveData = data;
            console.log('### reqLeaveData : ', this.reqLeaveData);
            this.reqLeaveArray = [].concat.apply([], Object.values(this.reqLeaveData));
            if ((this.reqLeaveArray).length <= 0) {
                this.nodata = true
                //console.log('### reqLeaveArray concat: ', this.reqLeaveArray);
            }/*else {
                this.nodata = true;
            }*/


        } else if (error) {
            console.error('Error:', error);
        }
    }

    //Approve Modal
    handleApproveComments(event) {
        this.approveComments = event.target.value;
    }
    showModalApprovalBox(event) {
        console.log('BUTTON CLICKED : ');
        this.selectedRecordApproveId = event.currentTarget.dataset.id;
        console.log('### selectedRecordApproveId : ', this.selectedRecordApproveId);
        this.isShowModalApprove = true;
    }

    handleApproveSave(event) {
        updateApproveStatusAndComments({ leaveRequestId: this.selectedRecordApproveId, comments: this.approveComments })
            .then((result) => {
                console.log('Leave Request: ', result);
                this.isShowModalApprove = false;
                const evt = new ShowToastEvent({
                    message: 'Leave Request was updated successfully',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                return refreshApex(this._wiredRefreshData)
            }).catch((err) => {
                console.log('ERROR : ', err);
            });
    }

    //Reject Modal
    handleRejectComments(event) {
        if (event.target.value) {
            this.errorMessage = '';
            this.rejectComments = event.target.value;

        } else {
            this.errorMessage = 'This field is required.';
        }
    }

    showModalRejectBox(event) {
        console.log('BUTTON CLICKED Reject: ');
        console.log('### event id: ', JSON.stringify(event.currentTarget.dataset.id));
        this.selectedRecordRejectId = event.currentTarget.dataset.id;
        console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
        this.isShowModalReject = true;

    }

    handleRejectSave() {
        if (this.template.querySelector('lightning-textarea').reportValidity()) {
            console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
            updateRejecteStatusAndComments({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
                .then((result) => {
                    console.log('Leave Request: ', result);
                    this.isShowModalReject = false;
                    this.rejectComments = '';
                    const evt = new ShowToastEvent({
                        message: 'Leave Request was rejected successfully',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    return refreshApex(this._wiredRefreshData)
                }).catch((err) => {
                    console.log('ERROR : ', err);
                });
        }
    }

    /* handleRejectSave(event) {
         let getelement = this.template.querySelectorAll(".isRequired");
         console.log("getelement", JSON.stringify(getelement));
         console.log('### getelement : ',getelement);
         let letReject = true;
         getelement.forEach(currentItem => {
             if (!currentItem.value || !currentItem.checkValidity()) {
                 currentItem.reportValidity();
                 console.log("Validation failed for element:", currentItem);
                 currentItem.setCustomValidity("Please enter the comments");
                 letReject = false;
             } else {
                 console.log("Validation passed for element:", currentItem);
                 currentItem.setCustomValidity(""); // clear the error message
             }
         });
 
         if (!letReject) {
             console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
             updateRejecteStatusAndComments({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
                 .then((result) => {
                     console.log('Leave Request: ', result);
                     this.isShowModalReject = false;
                     this.rejectComments = '';
                     return refreshApex(this._wiredRefreshData)
                 }).catch((err) => {
                     console.log('ERROR : ', err);
                 });
         }
     }*/





    handleCloseAll() {
        this.isShowModalApprove = false;
        this.isShowModalReject = false;
    }

    //Approve All page navigation
    handleLMNavigation(event) {
        var url = new URL(this.a_Record_URL + '/Grid/s/leave-management');
        var params = new URLSearchParams();
        params.append("pendingTab", "value");
        url.search += "&" + params.toString();
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url.href
            }
        });
    }

    errorCallback(error, stack) {
        console.log("errorcallback – child" + error.message);
        console.log("Stack", stack);
    }
}