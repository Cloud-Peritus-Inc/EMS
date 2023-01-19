import { LightningElement, api } from 'lwc';
import updateRejecteStatusAndComments from '@salesforce/apex/LeaveRequestRejectHandler.updateRejecteStatusAndComments';
import updateApproveStatusAndComments from '@salesforce/apex/LeaveRequestApproveHandler.updateApproveStatusAndComments';
//import bulkLeaveReqApproval from '@salesforce/apex/LeaveRequestApproveHandler.bulkLeaveReqApproval';
export default class EMS_LeaveRequest_Table extends LightningElement {

    approveComments;
    rejectComments;
    multipleApprovals =[]
    isShowModalApprove = false;
    isShowModalReject = false;
    isViewAll = false;
    _leaveReqData;
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
        this.leaveReq = JSON.parse(JSON.stringify(this.leaveReq));
        this.leaveReq.forEach((item, index) => {
            console.log('### item size: ' + JSON.stringify(item))
        });
    }

    //CheckBox
    handleSelect(event) {
        console.log('SELECTED RECORD : ',);
        const selectedRecordCheckboxId = event.currentTarget.dataset.id;
      //  this.multipleApprovals.push(selectedRecordCheckboxId);
        this.multipleApprovals = [... this.multipleApprovals , selectedRecordCheckboxId]; 
        console.log('###  multipleApprovals Child: ', this.multipleApprovals);
        const myApproveAllEvent = new CustomEvent('approveall', {
            detail: this.multipleApprovals
        });
        this.dispatchEvent(myApproveAllEvent);
    }



    //Approve All Modal
/*    handleApproveAll(event) {
        console.log('### Approve All');
        this.isShowModalApproveAll = true;
    }

    handleApproveAllSave(event) {
        console.log('OUTPUT : ');
        bulkLeaveReqApproval({ bulkleaveReqId: this.multipleApprovals, comments: this.approveAllComments })
            .then((result) => {
                console.log('Leave Request: ', result);
                window.location.reload();
            }).catch((err) => {
                console.log('ERROR : ', err);
            });
    }*/

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
                window.location.reload();
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
                    window.location.reload();
                }).catch((err) => {
                    console.log('ERROR : ', err);
                });
        }
    }

    handleClose() {
        this.isShowModalApprove = false;
        this.isShowModalReject = false;
    }
}