import { LightningElement, api } from 'lwc';
import updateRejecteStatusAndComments from '@salesforce/apex/LeaveRequestRejectHandler.updateRejecteStatusAndComments';
import updateApproveStatusAndComments from '@salesforce/apex/LeaveRequestApproveHandler.updateApproveStatusAndComments';
import { NavigationMixin } from 'lightning/navigation';
export default class EMS_LeaveRequest_Table extends NavigationMixin(LightningElement) {

    approveComments;
    rejectComments;
    multipleApprovals = []
    isShowModalApprove = false;
    isShowModalReject = false;
    isViewAll = false;
    nodata = false;
    _leaveReqData;
    _wiredRefreshData
    
    @api get leaveReq() {
        return this._leaveReqData;
    }

    set leaveReq(value) {
        this._leaveReqData = this.leaveData(value);
    }

    leaveData(value) {
        value = JSON.parse(JSON.stringify(value));
        value.forEach((item, index) => {
            console.log('### item size: ' + JSON.stringify(item))
        });
        return value;
    }
    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        console.log('Base Url' + this.a_Record_URL);
        this.leaveReq = JSON.parse(JSON.stringify(this.leaveReq));
        if (this.leaveReq > 0) {
            this.leaveReq.forEach((item, index) => {
                console.log('### item size: ' + JSON.stringify(item))
            });
        } else {
            this.nodata = true;
        }
    }

    //Approve Modal
    handleApproveComments(event) {
        this.approveComments = event.target.value;
    }

    showModalApprovalBox() {
        console.log('BUTTON CLICKED : ');
        this.isShowModalApprove = true;
    }

    handleApproveSave(event) {
        const selectedRecordApproveId = event.currentTarget.dataset.id;
        console.log('### selectedRecordApproveId : ', selectedRecordApproveId);
        updateApproveStatusAndComments({ leaveRequestId: selectedRecordApproveId, comments: this.approveComments })
            .then((result) => {
                console.log('Leave Request: ', result);
                //window.location.reload();
            }).catch((err) => {
                console.log('ERROR : ', err);
            });
    }

    //Reject Modal
    handleRejectComments(event) {
        this.rejectComments = event.target.value;
    }

    showModalRejectBox() {
        console.log('BUTTON CLICKED : ');
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
            const selectedRecordRejectId = event.currentTarget.dataset.id;
            console.log('### selectedRecordRejectId : ', selectedRecordRejectId);
            updateRejecteStatusAndComments({ leaveRequestId: selectedRecordRejectId, comments: this.rejectComments })
                .then((result) => {
                    console.log('Leave Request: ', result);
                    this.isShowModalReject = false;
                    //window.location.reload();
                }).catch((err) => {
                    console.log('ERROR : ', err);
                });
        }
    }

    handleClose() {
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
}