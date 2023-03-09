import { LightningElement, wire, track } from 'lwc';
import getLeaveReqData from '@salesforce/apex/LeaveRequestApexController.getLeaveReqData';
import updateRejecteStatusAndComments from '@salesforce/apex/LeaveRequestRejectHandler.updateRejecteStatusAndComments';
import updateApproveStatusAndComments from '@salesforce/apex/LeaveRequestApproveHandler.updateApproveStatusAndComments';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
export default class RecentRequestTile extends NavigationMixin(LightningElement) {

    reqLeaveData;
    approveComments;
    rejectComments;
    selectedRecordApproveId;
    isShowModalApprove = false;
    isShowModalReject = false;
    nodata = false;
    @track reqLeaveArray;
    _wiredRefreshData;

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
        console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
        this.selectedRecordApproveId = event.currentTarget.dataset.id;
        console.log('### selectedRecordApproveId : ', this.selectedRecordApproveId);
        this.isShowModalApprove = true;
    }

    handleApproveSave(event) {
        updateApproveStatusAndComments({ leaveRequestId: this.selectedRecordApproveId, comments: this.approveComments })
            .then((result) => {
                console.log('Leave Request: ', result);
                this.isShowModalApprove = false;
                this.checkBox = false;
                return refreshApex(this._wiredRefreshData)
            }).catch((err) => {
                console.log('ERROR : ', err);
            });
    }
    /*
    showModalApprovalBox(event) {
        console.log('@@@ : ', JSON.stringify(event));
        console.log('BUTTON CLICKED : ');
        console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
        this.selectedRecordApproveId = event.currentTarget.dataset.id;
        console.log('### selectedRecordApproveId : ', this.selectedRecordApproveId);
        this.isShowModalApprove = true;
    }

    handleApproveSave(event) {
        const selectedRecordApproveId = event.currentTarget.dataset.id;
        console.log('### selectedRecordApproveId : ', selectedRecordApproveId);
        updateApproveStatusAndComments({ leaveRequestId: selectedRecordApproveId, comments: this.approveComments })
            .then((result) => {
                console.log('Leave Request: ', result);
                this.isShowModalApprove = false;
                return refreshApex(this._wiredRefreshData)
            }).catch((err) => {
                console.log('ERROR : ', err);
            });
    }*/

    //Reject Modal
    handleRejectComments(event) {
        this.rejectComments = event.target.value;
    }

    showModalRejectBox(event) {
        console.log('BUTTON CLICKED Reject: ');
        console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
        console.log('### event id: ', JSON.stringify(event.currentTarget.dataset.id));
        this.selectedRecordRejectId = event.currentTarget.dataset.id;
        console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
        this.isShowModalReject = true;

    }

    handleRejectSave(event) {
        let getelement = this.template.querySelectorAll(".isRequired");
        console.log("getelement", JSON.stringify(getelement));
        let letReject = true;
        getelement.forEach(currentItem => {
            if (!currentItem.value || !currentItem.checkValidity()) {
                currentItem.reportValidity();
                console.log(" currentItem.reportValidity();", currentItem.reportValidity());
                currentItem.setCustomValidity("Please entre this fields");
                letReject = false;
            }
        });

        if (letReject) {
            /* const selectedRecordRejectId = event.currentTarget.dataset.id;
             console.log('### selectedRecordRejectId : ', selectedRecordRejectId);
             updateRejecteStatusAndComments({ leaveRequestId: selectedRecordRejectId, comments: this.rejectComments })
                 .then((result) => {
                     console.log('Leave Request: ', result);
                     this.isShowModalReject = false;
                     return refreshApex(this._wiredRefreshData)
                 }).catch((err) => {
                     console.log('ERROR : ', err);
                 });*/
            console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
            updateRejecteStatusAndComments({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
                .then((result) => {
                    console.log('Leave Request: ', result);
                    this.isShowModalReject = false;
                    this.checkBox = false;
                    return refreshApex(this._wiredRefreshData)
                }).catch((err) => {
                    console.log('ERROR : ', err);
                });
        }
    }

    handleCloseAll() {
        this.isShowModalApprove = false;
        this.isShowModalReject = false;
    }

    //Approve All page navigation
    handlebulkNavigation(event) {
        var url = new URL(this.a_Record_URL + '/Grid/s/leave-management');
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