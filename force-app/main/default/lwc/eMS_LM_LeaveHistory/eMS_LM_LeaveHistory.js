import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeaveHistory from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveHistory';
import getLeaveType from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveType';
import recallApproval from '@salesforce/apex/EMS_LM_ApprovalProcessUpdate.recallApproval';//need to change apex class method after approval process
import u_Id from '@salesforce/user/Id';
import LightningConfirm from "lightning/confirm";
import { refreshApex } from '@salesforce/apex';
const columns = [
  { label: 'Leave Type', fieldName: 'EMS_LM_Leave_Type_Name__c' },
  { label: 'Leave Start Date', fieldName: 'EMS_LM_Leave_Start_Date__c', type: 'date' },
  { label: 'Leave End Date', fieldName: 'EMS_LM_Leave_End_Date__c', type: 'date' },
  { label: 'Leave Duration', fieldName: 'EMS_LM_Leave_Duration__c', type: 'number' },
  { label: 'Reason', fieldName: 'EMS_LM_Reason__c' },
  { label: 'Approver', fieldName: 'EMS_LM_Final_Approver__c' },
  { label: 'Leave Status', fieldName: 'EMS_LM_Status__c' },
  { label: 'Approved On', fieldName: 'EMS_LM_Approved_On__c', type: 'date' }];

export default class EMS_LM_LeaveHistory extends LightningElement {
  @track columns = columns;
  fixedWidth = "width:8rem;";
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
  @track lOptions = [];
  value = '';
  sValue = '';
  @track lStatus = [{ label: 'None', value: '' }, { label: 'Pending', value: 'Pending' }, { label: 'Approved', value: 'Approved' }, 
                    { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' },
                    { label: 'Approver 1 Pending' , value: 'Approver 1 Pending' } ,
                    { label: 'Approver 2 Pending' , value: 'Approver 2 Pending' } ];
  @wire(getLeaveType, { userid: '$uId' })
  wiredlvtype({ error, data }) {
    if (data) {
      let opt1 = { label: 'None', value: '' };
      let opt = data.map((record) => ({
        value: record,
        label: record
      }));
      opt.push(opt1);
      this.lOptions = opt;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.lOptions = undefined;
    }
  }
  @wire(getLeaveHistory, { stdate: '$startDate', eddate: '$endDate', status: '$sValue', type: '$value' })
  wiredLeavHistory({ error, data }) {
    if (data) {
      if (data.length>0) {
        this.showdata = true;
        this.nodata = false;
        this.datahistory = data;
        this.error = undefined;
      }
      else {
        this.nodata = true;
        this.showdata = false;
        this.datahistory = data;
        this.error = undefined;
      }
    } else if (error) {
      this.error = error;
      this.datahistory = undefined;
    }
  }
  statusChange(event) {
    this.sValue = event.detail.value;
  }
  startdatechange(event) {
    this.startDate = event.detail.value;
    console.log(this.startDate);
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
    if (this.endDate != null) {
      this.endDate = event.detail.value + ' 00:00:00';
    }
  }
  handleChange(event) {
    this.value = event.detail.value;
  }
  handleCancelButton(event) {
    this.requeststatus = event.target.dataset.value;
    if (this.requeststatus == 'Pending' || this.requeststatus == '' || this.requeststatus == undefined || this.requeststatus == 'Approver 1 Pending' || this.requeststatus == 'Approver 2 Pending') {
      this.showcancelbutton = true;
    }
    else
      this.showcancelbutton = false;
  }
  /*HandelViewRequestModel(event) {
    this.isShowViewRequest = true;
    this.requestType = event.target.dataset.value;
    this.reqRecordId = event.target.dataset.recordId;
  }*/
  hideModalBox() {
    this.isShowViewRequest = false;
  }

  async handleConfirmClick(event) {
    this.requeststatus = event.target.dataset.value;
    this.reqRecordId = event.target.dataset.recordId;
    const result = await LightningConfirm.open({
      message: "Are you sure you want to Cancel this request?",
      variant: "default", // headerless
      theme: 'error', // more would be success, info, warning
      label: "Cancel the request"
    });
    if (result) {
      recallApproval({ recId: this.reqRecordId })
      .then(()=> {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success!!',
            message: 'Leave Cancelled Successfully !!.',
            variant: 'success'
        }));
        window.location.reload();
    })
    .catch(error => {
        window.console.log('Error ====> '+error);
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: error.message,
            variant: 'error'
        }));
        window.location.reload();
    });
    }
    else {
    }
  }
}