import { LightningElement, track, wire, api } from 'lwc';
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
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
//import defaultAdminViewData from '@salesforce/apex/EMS_LM_LeaveReq_AdminView.defaultAdminViewData';
import { refreshApex } from '@salesforce/apex';
export default class EMS_LM_LeaveHistory_AdminView extends NavigationMixin(LightningElement) {
  @track empName = '';
  @api recordId;
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
  fixedWidth = "width:10rem;";
  durationfixedWidth = "width:5rem;"
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
  disableCancelButton;
  @track isLoading = false;
  errorMessage;
  _wiredRefreshData;
  checkBox;
  role;
  approvalLevel;
  autoApproval;


  @track currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
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
      //console.log('### picklistValues Pending Tab: ', this.picklistValues);
      //console.log('### leaveTypeValues Pending Tab: ', this.leaveTypeValues);
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
        this.disableButton = false;
        //this.datahistory = data;
        this.datahistory = JSON.parse(JSON.stringify(data));
        //console.log('### datahistory JSON : ', this.datahistory);
        this.datahistory.forEach(req => {
          req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 Pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Status__c !== 'Approver 2 Pending';

          if ((req.EMS_LM_Status__c === 'Approved' || req.EMS_LM_Status__c === 'Rejected')) {
            req.disableButton = true; // disable Approve and Reject buttons
          } else if (req.EMS_LM_Status__c === 'Cancelled') {
            req.disableCancelButton = true; // disable cancel button only
          } else {
            req.disableButton = false; // enable all buttons
          } if (req.EMS_LM_Contact__r.Resource_Role__r.Level_of_Approval__c === 0) {
            //req.EMS_LM_Contact__r !== null && req.EMS_LM_Contact__r.Resource_Role__r !== null && req.EMS_LM_Contact__r.Resource_Role__r.Name === 'HR Director' && req.EMS_LM_Contact__r.Resource_Role__r.Name === 'TA Director'
            req.disableButton = true;
            req.disableCancelButton = true;
          }
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
      this.disableButton = this.nodata === true;
      this.showdata = false;
      this.error = undefined;
    }
  }
  namechange(event) {
    this.empName = event.detail.value;
  }
  statusChange(event) {
    //console.log(JSON.stringify(event.detail));
    this.sValue = event.detail;
    //console.log(this.sValue);
  }
  startdatechange(event) {
    this.startDate = event.detail.value
    //window.console.log('startDate ##' + this.startDate);
    if (this.startDate != null) {
      this.startDate = event.detail.value;
    }
    if (this.startDate > this.endDate) {
      if (this.endDate != null) {
        this.endDate = '';
      }
    }
  }
  enddatechange(event) {
    this.endDate = event.detail.value;
    //window.console.log('endDate ##' + this.endDate);
    if (this.endDate != null) {
      this.endDate = event.detail.value;
    }
  }

  handleTypeValueChange(event) {
    //console.log(JSON.stringify(event.detail));
    this.tValue = event.detail;
    //console.log('## this.sValue Pending Tab', this.tValue);
  }
  handleChange(event) {
    this.value = event.detail.value;
    //console.log(this.value);
  }

  //CheckBox
  handleSelect(event) {
    const selectedRecordCheckboxId = event.currentTarget.dataset.id;
    //console.log('### selectedRecordCheckboxId : ', selectedRecordCheckboxId);
    this.checkBox = event.target.checked
    if (!this.checkBox) {
      const index = this.multipleApprovals.indexOf(selectedRecordCheckboxId);
      this.multipleApprovals.splice(index, 1);
    } else {
      this.multipleApprovals = [... this.multipleApprovals, selectedRecordCheckboxId];
    }
    //console.log('###  multipleApprovals Child: ', this.multipleApprovals);
  }

  //TO SELECT ALL THE CHECKBOXES
  handleSelectAll(event) {
    this.checkBox = event.target.checked;
    const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]:not([disabled])');
    if (this.checkBox) {
      checkboxElements.forEach(element => {
        element.checked = true;
        this.multipleApprovals.push(element.dataset.id);
        //console.log('### multipleApprovals', this.multipleApprovals);
      });
    } else {
      checkboxElements.forEach(element => {
        element.checked = false;
        this.multipleApprovals = [];
        //console.log('### multipleApprovals', this.multipleApprovals);

      });
    }
  }

  //Approve All
  handleApproveAllComments(event) {
    this.approveAllComments = event.target.value
  }

  handleApproveAll() {
    if (this.multipleApprovals.length === 0) {
      const evt = new ShowToastEvent({
        message: 'Please select at least one record',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    } else {
      this.isShowModalApproveAll = true;
    }
  }

  handleApproveAllSave() {
    //console.log('OUTPUT multipleApprovals: ', JSON.stringify(this.multipleApprovals));
    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      bulkLeaveReqApproval({ bulkleaveReqId: this.multipleApprovals, comments: this.approveAllComments })
        .then((result) => {
          //console.log('Leave Request: ', result);
          this.isShowModalApproveAll = false;
          this.approveAllComments = '';
          const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
          checkboxElements.forEach(element => {
            element.checked = false;
          });
          //console.log('### checkBox : ', this.checkBox);
          const evt = new ShowToastEvent({
            message: 'Leave Request was updated successfully',
            variant: 'success',
          });
          this.dispatchEvent(evt);
          return refreshApex(this._wiredRefreshData)
        }).catch((err) => {
          //console.log('ERROR : ', err);
        });
    }
  }

  //Reject All
  handleRejectAllComments(event) {
    this.rejectAllComments = event.target.value
  }

  handleRejectAll() {
    if (this.multipleApprovals.length === 0) {
      const evt = new ShowToastEvent({
        message: 'Please select at least one record',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    } else {
      this.isShowModalRejectAll = true;
    }
  }

  handleRejectAllSave() {
    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      bulkLeaveReqReject({ bulkleaveReqId: this.multipleApprovals, comments: this.rejectAllComments })
        .then((result) => {
          //console.log('Leave Request: ', result);
          this.isShowModalRejectAll = false;
          const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
          checkboxElements.forEach(element => {
            element.checked = false;
          });
          const evt = new ShowToastEvent({
            message: 'Leave Request was rejected successfully',
            variant: 'success',
          });
          this.dispatchEvent(evt);
          this.rejectAllComments = '';
          return refreshApex(this._wiredRefreshData)
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  //Modal Pop-up Close
  handleCloseAll() {
    this.approveComments = '';
    this.approveAllComments = '';
    this.rejectComments = '';
    this.rejectAllComments = '';
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
    //console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    this.selectedRecordApproveId = event.currentTarget.dataset.id;
    //console.log('### selectedRecordApproveId : ', this.selectedRecordApproveId);
    this.isShowModalApprove = true;
  }

  handleApproveSave(event) {
    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      updateLeaveStatus({ leaveRequestId: this.selectedRecordApproveId, comments: this.approveComments })
        .then((result) => {
          //console.log('Leave Request: ', result);
          this.isShowModalApprove = false;
          this.approveComments = ''
          const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
          checkboxElements.forEach(element => {
            element.checked = false;
          });
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
  }

  //Reject Modal
  handleRejectComments(event) {
    this.rejectComments = event.target.value
  }

  showModalRejectBox(event) {
    this.isShowModalReject = true;
    //console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    this.selectedRecordRejectId = event.currentTarget.dataset.id;
    //console.log('### selectedRecordRejectId : ', selectedRecordRejectId);

  }

  handleRejectSave(event) {
    const selectedRecordRejectId = event.currentTarget.dataset.id;
    //console.log('### selectedRecordRejectId : ', selectedRecordRejectId);
    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      updateRejectStatus({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
        .then((result) => {
          //console.log('Leave Request: ', result);
          this.isShowModalReject = false;
          const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
          checkboxElements.forEach(element => {
            element.checked = false;
          });
          const evt = new ShowToastEvent({
            message: 'Leave Request was rejected successfully',
            variant: 'success',
          });
          this.dispatchEvent(evt);
          this.rejectComments = ' ';
          return refreshApex(this._wiredRefreshData)
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  //TO VIEW THE LEAVE RECORD
  connectedCallback() {
    this.a_Record_URL = window.location.origin;
    //console.log('Base Url' + this.a_Record_URL);
  }
  handleView(event) {
    const selectedRecordId = event.currentTarget.dataset.id;
    //console.log('### handleView : ', selectedRecordId);
    var url = new URL(this.a_Record_URL + '/Grid/s/ems-lm-leave-history/' + selectedRecordId);
    var params = new URLSearchParams();
    params.append("adminTab", "value");
    url.search += "&" + params.toString();

    //console.log('### url : ', JSON.stringify(url));
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href

      },
    });
  }

  // TO cancel the leave record
  handleCancel(event) {
    const selectedRecordId = event.currentTarget.dataset.id;
    //console.log('### handleCancel : ', selectedRecordId);
    cancleLeaveRequest({ leaveReqCancelId: selectedRecordId })
      .then((result) => {
        //console.log('### result : ', result);
        const evt = new ShowToastEvent({
          message: 'Leave Request was Cancelled Successfully',
          variant: 'success',
        });
        this.dispatchEvent(evt);
        /*const messageContext = createMessageContext();
        const payload = {
          refresh: true
        };
        publish(messageContext, MY_REFRESH_CHANNEL, payload);*/
        return refreshApex(this._wiredRefreshData)
      }).catch((err) => {
        console.log('### err : ', JSON.stringify(err));
      });
  }

  //TO VIEW THE CONTACT RECORD
  handlConClick(event) {
    let selectCon = event.currentTarget.dataset.id;
    //console.log('### selectCon : ', selectCon);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectCon,
        objectApiName: 'Contact',
        actionName: 'view',
      },
    });
  }
}