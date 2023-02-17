import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getAdminLeaveHistory from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getAdminLeaveHistory';
import approveApproval from '@salesforce/apex/EMS_LM_ApprovalProcessUpdate.approveApproval';
import rejectApproval from '@salesforce/apex/EMS_LM_ApprovalProcessUpdate.rejectApproval';
import u_Id from '@salesforce/user/Id';
import LightningConfirm from "lightning/confirm";
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import updateLeaveStatus from '@salesforce/apex/LeaveRequestHRApproveHandler.updateLeaveStatus';
import bulkLeaveReqApproval from '@salesforce/apex/LeaveRequestHRApproveHandler.bulkLeaveReqApproval';
import bulkLeaveReqReject from '@salesforce/apex/LeaveRequestHRRejectHandler.bulkLeaveReqReject';
import updateRejectStatus from '@salesforce/apex/LeaveRequestHRRejectHandler.updateRejectStatus';
import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import pendingOnMeLeaveReq from '@salesforce/apex/LeaveHistoryApexController.pendingOnMeLeaveReq';



export default class EMS_LM_LeaveHistory_AdminView extends LightningElement {
  @track empName = '';
  requeststatus;
  outputStatus;
  outputId;
  @track reqRecordId;
  showcancelbutton = false;
  isShowViewRequest = false;
  uId = u_Id;
  showdata = false;
  nodata = false;
  endDate = '';//To filter Leave History end date = '2022-12-20 00:00:00'
  startDate = '';//To filter Leave History start date  = '2022-01-20 00:00:00'
  @track datahistory = [];//to pass data to Leave history table
  // @track lOptions = [];
  @track multipleApprovals = [];
  approveAllComments;
  rejectAllComments;
  value = '';
  fixedWidth = "width:8rem;";
  leaveTypeValues;
  tValue = '';
  sValue = 'Pending';
  picklistValues = '';
  selectedRecordApproveId;
  selectedRecordRejectId;
  approveComments;
  rejectComments;
  approveAllComments;
  rejectAllComments;
  isShowModalApproveAll = false;
  isShowModalRejectAll = false;
  isShowModalApprove = false;
  isShowModalReject = false;

  //TO GET OBJECT INFO
  @wire(getObjectInfo, { objectApiName: LEAVEHISTORY_OBJECT })
  leaveHistoryObjectInfo

  //FOR MULTI SELECT PICKLIST FOR LEAVE STATUS AND LEAVE TYPE
  @wire(getPicklistValuesByRecordType, { objectApiName: LEAVEHISTORY_OBJECT, recordTypeId: '$leaveHistoryObjectInfo.data.defaultRecordTypeId' })
  picklistHandler({ error, data }) {
    if (data) {
      //console.log('getPicklistValuesByRecordTypeData Pending Tab', data);
      this.leaveTypeValues = data.picklistFieldValues.EMS_LM_Leave_Type_Name__c.values;
      this.picklistValues = data.picklistFieldValues.EMS_LM_Status__c.values;
      console.log('### picklistValues Pending Tab: ', this.picklistValues);
      console.log('### leaveTypeValues Pending Tab: ', this.leaveTypeValues);
    } else if (error) {
      console.error('Error:', error);
    }
  }

  @wire(getAdminLeaveHistory, { name: '$empName', stdate: '$startDate', eddate: '$endDate', leaveType: '$tValue', status: '$sValue' })
  wiredLeavHistory({ error, data }) {
    if (data) {
      if (data.length > 0) {
        this.showdata = true;
        this.nodata = false;
        //this.datahistory = data;
        this.datahistory = JSON.parse(JSON.stringify(data));
        console.log('### datahistory JSON : ', this.datahistory);
        this.datahistory.forEach(req => {
          req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Status__c !== 'Approver 2 pending';
        });
        this.error = undefined;
      }
      else {
        this.nodata = true;
        this.showdata = false;
        //this.datahistory = data;
        this.datahistory = JSON.parse(JSON.stringify(data));
        console.log('### datahistory JSON : ', this.datahistory);
        this.datahistory.forEach(req => {
          req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 pending' && req.EMS_LM_Status__c !== 'Pending' , req.EMS_LM_Status__c !== 'Approver 2 pending';
        });
        this.error = undefined;
      }
    } else if (error) {
      this.error = error;
      this.datahistory = undefined;
    }
  }
  namechange(event) {
    this.empName = event.detail.value;
  }
  statusChange(event) {
    console.log(JSON.stringify(event.detail));
    this.sValue = event.detail;
    console.log(this.sValue);
  }
  startdatechange(event) {
    this.startDate = event.detail.value
    window.console.log('startDate ##' + this.startDate);
    if (this.startDate != null) {
      this.startDate = event.detail.value + ' 00:00:00';
    }
    if (this.startDate > this.endDate) {
      if (this.endDate != null) {
        this.endDate = '';
      }
    }
  }
  enddatechange(event) {
    this.endDate = event.detail.value;
    window.console.log('endDate ##' + this.endDate);
    if (this.endDate != null) {
      this.endDate = event.detail.value + ' 00:00:00';
    }
  }

  handleTypeValueChange(event) {
    console.log(JSON.stringify(event.detail));
    this.tValue = event.detail;
    console.log('## this.sValue Pending Tab', this.tValue);
  }
  handleChange(event) {
    this.value = event.detail.value;
    console.log(this.value);
  }
  handleCancelButton(event) {
    this.requeststatus = event.target.dataset.value;
    if (this.requeststatus == 'Pending' || this.requeststatus == '' || this.requeststatus == undefined || this.requeststatus == 'Approver 1 Pending' || this.requeststatus == 'Approver 2 Pending') {
      this.showcancelbutton = true;
    }
    else
      this.showcancelbutton = false;
  }
  /*handelViewRequestModel(event) {
    this.isShowViewRequest = true;
    this.requestType = event.target.dataset.value;
    this.reqRecordId = event.target.dataset.recordId;
  }*/
  hideModalBox() {
    this.isShowViewRequest = false;
  }

  //TO SELECT ALL THE CHECKBOXES
  handleSelectAll(event) {
    console.log('OUTPUT : ');
    if (event.target.checked) {
      const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
      const selectedRecordIds = [];
      checkboxElements.forEach(element => {
        element.checked = true;
        //console.log('### element.checked : ', element.checked);
        //console.log('### element.dataset : ', JSON.stringify(element.dataset));
        selectedRecordIds.push(element.dataset);
        //console.log('### selectedRecordIds : ', selectedRecordIds);
      });
      console.log('Selected Record Ids:', selectedRecordIds);
      this.multipleApprovals = selectedRecordIds.map(item => item.id);
      console.log('### multipleApprovals', this.multipleApprovals);
    } else if (!event.target.checked) {
      const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
      //const selectedRecordIds = [];
      checkboxElements.forEach(element => {
        element.checked = false;
        this.multipleApprovals = [];
        console.log('### else multipleApprovals : ', this.multipleApprovals);
      });
    }
  }

  //Approve All
  handleApproveAllComments(event) {
    this.approveAllComments = event.target.value;
  }

  handleApproveAll() {
    this.isShowModalApproveAll = true;
    console.log(' APPROVE MODAL OPEN : ');
  }

  handleApproveAllSave() {
    console.log('OUTPUT : ');
    console.log('OUTPUT multipleApprovals: ', JSON.stringify(this.multipleApprovals));
    if (this.multipleApprovals.length === 0) {
      alert('Please select at least one record');
    } else {
      bulkLeaveReqApproval({ bulkleaveReqId: this.multipleApprovals, comments: this.approveAllComments })
        .then((result) => {
          console.log('Leave Request: ', result);
          window.location.reload();
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  //Reject All
  handleRejectAllComments(event) {
    this.rejectAllComments = event.target.value
  }

  handleRejectAll() {
    this.isShowModalRejectAll = true;
    console.log(' REJECT MODAL OPEN : ');
  }

  handleRejectAllSave() {
    console.log('REJECT SAVE : ');
    if (this.multipleApprovals.length === 0) {
      alert('Please select at least one record');
    } else {
      bulkLeaveReqReject({ bulkRejectId: this.multipleApprovals, comments: this.rejectAllComments })
        .then((result) => {
          console.log('Leave Request: ', result);
          window.location.reload();
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  //Modal Pop-up Close
  handleCloseAll() {
    this.isShowModalApprove = false;
    this.isShowModalReject = false;
    this.isShowModalApproveAll = false;
    this.isShowModalRejectAll = false;
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
    updateLeaveStatus({ leaveRequestId: this.selectedRecordApproveId, comments: this.approveComments })
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

  showModalRejectBox(event) {
    console.log('BUTTON CLICKED Reject: ');
    this.isShowModalReject = true;
    console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    this.selectedRecordRejectId = event.currentTarget.dataset.id;
    console.log('### selectedRecordRejectId : ', selectedRecordRejectId);

  }

  handleRejectSave(event) {
    const selectedRecordRejectId = event.currentTarget.dataset.id;
    console.log('### selectedRecordRejectId : ', selectedRecordRejectId);
    updateRejectStatus({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
      .then((result) => {
        console.log('Leave Request: ', result);
        this.isShowModalReject = false;
        window.location.reload();
      }).catch((err) => {
        console.log('ERROR : ', err);
      });
  }

  // TO cancel the leave record
  handleCancel(event) {
    const selectedRecordId = event.currentTarget.dataset.id;
    console.log('### handleCancel : ', selectedRecordId);
    cancleLeaveRequest({ leaveReqCancelId: selectedRecordId })
      .then((result) => {
        console.log('### result : ', result);
        const evt = new ShowToastEvent({
          title: 'Toast Success',
          message: 'Leave Request was Cancelled Successfully',
          variant: 'success',
          mode: 'pester'
        });
        this.dispatchEvent(evt);
        window.location.reload();
      }).catch((err) => {
        console.log('### err : ', JSON.stringify(err));
      });
  }



   async handleApproveClick(event) {
   this.requeststatus = event.target.dataset.value;
   this.reqRecordId = event.target.dataset.recordId;
    const result = await LightningConfirm.open({
     message: "Are you sure you want to Approve this request?",
     variant: "default", // headerless
    theme: 'Success', // more would be success, info, warning
    label: "Approve the request"
   });
    if (result) {
      approveApproval({ recId: this.reqRecordId })
        .then(result => {
          console.log(result);

          this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: 'Leave Request Approved Successfully !!.',
            variant: 'success',
            mode: 'pester'
          }));
          window.location.reload();
        })
        .catch(error => {
          window.console.log('Error ====> ' + error);
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: error.message,
            variant: 'error',
            mode: 'pester'
          }));
          window.location.reload();
        });
    }
    else {

    }

  }


  async handleRejectClick(event) {
    this.requeststatus = event.target.dataset.value;
    this.reqRecordId = event.target.dataset.recordId;
    const result = await LightningConfirm.open({
      message: "Are you sure you want to Reject this request?",
      variant: "default", // headerless
      theme: 'error', // more would be success, info, warning
      label: "Reject the request"
    });
    if (result) {
      rejectApproval({ recId: this.reqRecordId })
        .then(result => {
          console.log(result);

          this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: 'Leave Request Rejected Successfully !!.',
            variant: 'success',
            mode: 'pester'
          }));
          window.location.reload();
        })
        .catch(error => {
          window.console.log('Error ====> ' + error);
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: error.message,
            variant: 'error',
            mode: 'pester'
          }));
          window.location.reload();
        });
    }
    else {
    }
  }
}