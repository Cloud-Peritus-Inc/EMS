import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAdminLeaveHistory from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getAdminLeaveHistory';
import approveApproval from '@salesforce/apex/EMS_LM_ApprovalProcessUpdate.approveApproval';
import rejectApproval from '@salesforce/apex/EMS_LM_ApprovalProcessUpdate.rejectApproval';
import u_Id from '@salesforce/user/Id';
import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';

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
  @track datahistory1 = [];//to refresh apex data to Leave history table
 // @track lOptions = [];
  value = '';
  fixedWidth = "width:8rem;";
  sValue = 'Pending';
  @track lStatus = [{ label: 'None', value: '' },
  { label: 'Approved', value: 'Approved' }, { label: 'Pending', value: 'Pending' },
  { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' },
  { label: 'Approver 1 Pending', value: 'Approver 1 Pending' },
  { label: 'Approver 2 Pending', value: 'Approver 2 Pending' }];
 
  @wire(getAdminLeaveHistory, { name: '$empName', stdate: '$startDate', eddate: '$endDate', status: '$sValue' })
  wiredLeavHistory(result) {
    this.datahistory1 = result;
    if (result.data) {
      if (result.data.length>0) {
        this.showdata = true;
        this.nodata = false;
        this.datahistory = result.data;
        this.error = undefined;
      }
      else {
        this.nodata = true;
        this.showdata = false;
        this.datahistory = result.data;
        this.error = undefined;
      }
    } else if (result.error) {
      this.error = result.error;
      this.datahistory = undefined;
    }
  }
  namechange(event){
    this.empName = event.detail.value;
  }
  statusChange(event) {
    this.sValue = event.detail.value;
    console.log(this.lStatus);
  }
  startdatechange(event) {
    this.startDate = event.detail.value
    window.console.log('startDate ##' + this.startDate);
    if (this.startDate != null) {
      this.startDate = event.detail.value + ' 00:00:00';
    }
    if (this.startDate > this.endDate) {
      if(this.endDate != null){
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
         // window.location.reload();
         refreshApex(this.datahistory1);
        })
        .catch(error => {
          window.console.log('Error ====> ' + error);
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: error.message,
            variant: 'error',
            mode: 'pester'
          }));
          //window.location.reload();
          refreshApex(this.datahistory1);
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
          //window.location.reload();
          refreshApex(this.datahistory1);
        })
        .catch(error => {
          window.console.log('Error ====> ' + error);
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: error.message,
            variant: 'error',
            mode: 'pester'
          }));
          //window.location.reload();
          refreshApex(this.datahistory1);
        });
    }
    else {
    }
  }
}