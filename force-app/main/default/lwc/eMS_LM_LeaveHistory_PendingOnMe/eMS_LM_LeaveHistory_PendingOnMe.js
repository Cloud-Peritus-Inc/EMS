import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import u_Id from '@salesforce/user/Id';
import LightningConfirm from "lightning/confirm";
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import getPendingLeaveHistory from '@salesforce/apex/LeaveHistoryApexController.getPendingLeaveHistory';
import bulkLeaveReqApproval from '@salesforce/apex/LeaveRequestApproveHandler.bulkLeaveReqApproval';
import bulkLeaveReqReject from '@salesforce/apex/LeaveRequestRejectHandler.bulkLeaveReqReject';
import updateRejecteStatusAndComments from '@salesforce/apex/LeaveRequestRejectHandler.updateRejecteStatusAndComments';
import updateApproveStatusAndComments from '@salesforce/apex/LeaveRequestApproveHandler.updateApproveStatusAndComments';
import pendingOnMeLeaveReq from '@salesforce/apex/LeaveHistoryApexController.pendingOnMeLeaveReq';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class EMS_LM_LeaveHistory_PendingOnMe extends NavigationMixin(LightningElement) {
  requeststatus;
  outputStatus;
  outputId;
  @track empName = '';
  fixedWidth = "width:8rem;";
  @track reqRecordId;
  showcancelbutton = false;
  isShowViewRequest = false;
  uId = u_Id;
  showdata = false;
  nodata = false;
  endDate = '';//To filter Leave History end date = '2022-12-20 00:00:00'
  startDate = '';//To filter Leave History start date  = '2022-01-20 00:00:00'
  @track datahistory = [];//to pass data to Leave history table
  value = 'Work From Home ';
  sValue = 'Approver 1 Pending';
  @api recordId;
  multipleApprovals = [];
  approveAllComments;
  rejectAllComments;
  isShowModalApproveAll = false;
  isShowModalRejectAll = false;
  isShowModalApprove = false;
  isShowModalReject = false;
  approveComments
  rejectComments
  selectedRecordApproveId;
  selectedRecordRejectId;
  @track selectedLeaveReqIds = [];

  @track currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
  }

  @wire(pendingOnMeLeaveReq)
  pendingOnMeLeaveReqWiredData({ error, data }) {
    if (data) {
      console.log('### pendingOnMeLeaveReq', data);
      this.datahistory = data;
      console.log('### non filter : ', this.datahistory);
      this.showdata = true;
      console.log('### showdata : ', this.showdata);
      this.nodata = false;
    } else if (error) {
      console.error('Error:', error);
    }
  }

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

  @wire(getPendingLeaveHistory, { name: '$empName', stdate: '$startDate', eddate: '$endDate', statusValues: '$sValue', typeValues: '$value' })
  wiredLeavHistory({ error, data }) {
    if (data) {
      console.log('### DATA BEFORE: ', data);
      if (data.length > 0) {
        console.log('### DATA AFTER: ', data);
        this.showdata = true;
        this.nodata = false;
        this.datahistory = data;
        console.log('### datahistory', this.datahistory);
        this.error = undefined;
      }
      /* else {
         this.nodata = true;
         this.showdata = false;
         this.datahistory = data;
         this.error = undefined;
       }*/
    } else if (error) {
      this.error = error;
      this.datahistory = undefined;
    }
  }

  namechange(event) {
    this.empName = event.detail.value;
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

  handleValueChange(event) {
    console.log(JSON.stringify(event.detail));
    this.sValue = event.detail;
    console.log('## this.sValue Pending Tab', this.sValue);
  }

  handleTypeValueChange(event) {
    console.log(JSON.stringify(event.detail));
    this.value = event.detail;
    console.log('## this.value Pending Tab', this.value);
  }

  //CheckBox
  handleSelect(event) {
    console.log('SELECTED RECORD : ');
    const selectedRecordCheckboxId = event.currentTarget.dataset.id;
    console.log('### selectedRecordCheckboxId : ', selectedRecordCheckboxId);

    if (!event.target.checked) {
      const index = this.multipleApprovals.indexOf(selectedRecordCheckboxId);
      this.multipleApprovals.splice(index, 1);
    } else {
      this.multipleApprovals = [... this.multipleApprovals, selectedRecordCheckboxId];
    }
    console.log('###  multipleApprovals Child: ', this.multipleApprovals);
  }

  //Approve All
  handleApproveAllComments(event) {
    this.approveAllComments = event.target.value
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
    this.isShowModalApproveAll = false;
    this.isShowModalRejectAll = false;
    this.isShowModalApprove = false;
    this.isShowModalReject = false;
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
    updateRejecteStatusAndComments({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
      .then((result) => {
        console.log('Leave Request: ', result);
        this.isShowModalReject = false;
        window.location.reload();
      }).catch((err) => {
        console.log('ERROR : ', err);
      });
  }

  //TO VIEW THE RECORD
  handleView(event) {
    const selectedRecordId = event.currentTarget.dataset.id;
    console.log('### handleView : ', selectedRecordId);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectedRecordId,
        objectApiName: 'EMS_LM_Leave_History__c',
        actionName: 'view',
      },
    });
  }

  //TO SELECT ALL THE CHECKBOXES
  handleSelectAll(event) {
    console.log('OUTPUT : ');
    const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
    const selectedRecordIds = [];
    checkboxElements.forEach(element => {
      element.checked = true;
      //console.log('### element.checked : ', element.checked);
      //console.log('### element.dataset : ', JSON.stringify(element.dataset));
      selectedRecordIds.push(element.dataset);
      console.log('### selectedRecordIds : ',selectedRecordIds);
    });

    console.log('Selected Record Ids:', selectedRecordIds);
  }

  handleCancelButton(event) {
    this.requeststatus = event.target.dataset.value;
    if (this.requeststatus == 'Pending' || this.requeststatus == '' || this.requeststatus == undefined || this.requeststatus == 'Approver 1 Pending' || this.requeststatus == 'Approver 2 Pending') {
      this.showcancelbutton = true;
    }
    else
      this.showcancelbutton = false;
  }

}