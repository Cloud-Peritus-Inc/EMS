import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import u_Id from '@salesforce/user/Id';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import updateLeaveStatus from '@salesforce/apex/LeaveRequestHRApproveHandler.updateLeaveStatus';
import bulkLeaveReqApproval from '@salesforce/apex/LeaveRequestHRApproveHandler.bulkLeaveReqApproval';
import bulkLeaveReqReject from '@salesforce/apex/LeaveRequestHRRejectHandler.bulkLeaveReqReject';
import updateRejectStatus from '@salesforce/apex/LeaveRequestHRRejectHandler.updateRejectStatus';
import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import getAdminLeaveHistory from '@salesforce/apex/EMS_LM_LeaveReq_AdminView.getAdminLeaveHistory';
import defaultAdminViewData from '@salesforce/apex/EMS_LM_LeaveReq_AdminView.defaultAdminViewData';
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
  // @track lOptions = [];
  @track multipleApprovals = [];
  approveAllComments;
  rejectAllComments;
  value = '';
  fixedWidth = "width:8rem;";
  leaveTypeValues;
  tValue = '';
  sValue = ' ';
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
  disableButton;
  @track isLoading = false;
  _wiredRefreshData;
  checkBox;

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

  // TO SHOW DEFAULT ADMIN VIEW DATA
  /* @wire(defaultAdminViewData)
   wiredData(wireResult) {
     const { data, error } = wireResult; // TO REFRESH THE DATA USED THIS BY STORING DATA AND ERROR IN A VARIABLE
     this._wiredRefreshData = wireResult;
     if (data) {
       if (data.length > 0) {
         console.log('### defaultAdminViewData', data);
         this.showdata = true;
         this.nodata = false;
         this.datahistory = JSON.parse(JSON.stringify(data));
         console.log('###  defaultAdminViewData datahistory ', this.datahistory);
         this.datahistory.forEach(req => {
           req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 Pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Status__c !== 'Approver 2 Pending';
         });
       } else {
         this.nodata = true;
         this.disableButton = this.nodata === true;
       }
     } else if (error) {
       console.log('Error:', error);
     }
   }*/

  // TO SHOW FILTERED DATA
  @wire(getAdminLeaveHistory, { employeeName: '$empName', startDate: '$startDate', endDate: '$endDate', typeValues: '$tValue', statusValues: '$sValue' })
  wiredLeavHistory(wireResult) {
    const { data, error } = wireResult;
    this._wiredRefreshData = wireResult;
    if (data) {
      this.isLoading = false;
      if (data.length > 0) {
        this.showdata = true;
        this.nodata = false;
        //this.datahistory = data;
        this.datahistory = JSON.parse(JSON.stringify(data));
        console.log('### datahistory JSON : ', this.datahistory);
        this.datahistory.forEach(req => {
          req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 Pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Status__c !== 'Approver 2 Pending';
        });
        this.error = undefined;
      }
      else {
        this.nodata = true;
        this.showdata = false;
        this.error = undefined;
      }
    } else if (error) {
      this.error = error;
      this.datahistory = undefined;
      this.isLoading = false;
      this.nodata = true;
    } else {
      this.isLoading = true;
      this.nodata = true;
      this.showdata = false;
      this.error = undefined;
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

  //CheckBox
  handleSelect(event) {
    console.log('SELECTED RECORD : ');
    const selectedRecordCheckboxId = event.currentTarget.dataset.id;
    console.log('### selectedRecordCheckboxId : ', selectedRecordCheckboxId);
    this.checkBox = event.target.checked
    if (!this.checkBox) {
      const index = this.multipleApprovals.indexOf(selectedRecordCheckboxId);
      this.multipleApprovals.splice(index, 1);
    } else {
      this.multipleApprovals = [... this.multipleApprovals, selectedRecordCheckboxId];
    }
    console.log('###  multipleApprovals Child: ', this.multipleApprovals);
  }

  //TO SELECT ALL THE CHECKBOXES
  handleSelectAll(event) {
    console.log('OUTPUT : ');
    this.checkBox = event.target.checked
    if (this.checkBox) {
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
    } else if (!this.checkBox) {
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
          this.isShowModalApproveAll = false;
          this.checkBox = false;
          return refreshApex(this._wiredRefreshData)
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
          this.isShowModalRejectAll = false;
          this.checkBox = false;
          return refreshApex(this._wiredRefreshData)
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
        this.isShowModalApprove = false;
        this.checkBox = false;
        return refreshApex(this._wiredRefreshData)
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
        this.checkBox = false;
        return refreshApex(this._wiredRefreshData)
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
        return refreshApex(this._wiredRefreshData)
      }).catch((err) => {
        console.log('### err : ', JSON.stringify(err));
      });
  }
}