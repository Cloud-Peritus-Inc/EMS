import { LightningElement, track, wire, api } from 'lwc';
import u_Id from '@salesforce/user/Id';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import getPendingLeaveHistory from '@salesforce/apex/EMS_LM_PendingOnMeLeaveReq.getPendingLeaveHistory';
import bulkLeaveReqApproval from '@salesforce/apex/LeaveRequestApproveHandler.bulkLeaveReqApproval';
import bulkLeaveReqReject from '@salesforce/apex/LeaveRequestRejectHandler.bulkLeaveReqReject';
import updateRejecteStatusAndComments from '@salesforce/apex/LeaveRequestRejectHandler.updateRejecteStatusAndComments';
import updateApproveStatusAndComments from '@salesforce/apex/LeaveRequestApproveHandler.updateApproveStatusAndComments';
//import pendingOnMeLeaveReq from '@salesforce/apex/EMS_LM_PendingOnMeLeaveReq.pendingOnMeLeaveReq';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

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
  value = '';
  sValue = '';
  @api recordId;
  @track multipleApprovals = [];
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
  picklistValues;
  leaveTypeValues;
  disableButton;
  @track isLoading = false;
  @track selectedLeaveReqIds = [];
  isCheck = false;
  errorMessage = '';
  _wiredRefreshData;
  checkBox;
  isModalOpen = false;

  @track currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
  }


  //TO SHOW DEFAULT DATA
  /*pendingOnMeLeaveReqWiredData () {
    pendingOnMeLeaveReq().then((result) => {
        console.log('### pendingOnMeLeaveReq', result);
        if(result.length > 0 ) {
      
        this.showdata = true;
        this.nodata = false;
        this.isCheck = true;
        this.datahistory = JSON.parse(JSON.stringify(result));
        console.log('### non filter : ', this.datahistory);
        this.datahistory.forEach(req => {
          // req.disableButton = req.EMS_LM_Status__c !== 'Pending' && (req.EMS_LM_Status__c ===  'Approver 2 Pending' && req.EMS_LM_2nd_Approver__c  !== this.uId || req.EMS_LM_Status__c ===  'Approver 1 Pending' && req.EMS_LM_Approver__c !== this.uId);
          //console.log(' ### status--->', req.EMS_LM_Status__c, "--value-->", req.EMS_LM_Status__c == 'Approver 2 Pending', "--uid--", this.uId, "--2nd approval--", req.EMS_LM_2nd_Approver__c, "--value--", req.EMS_LM_2nd_Approver__c === this.uId);
          req.disableButton = !(req.EMS_LM_Status__c == 'Pending' || (req.EMS_LM_Status__c == 'Approver 2 Pending' && req.EMS_LM_2nd_Approver__c === this.uId) || (req.EMS_LM_Status__c == 'Approver 1 Pending' && req.EMS_LM_Approver__c === this.uId));
          //console.log('### req.EMS_LM_2nd_Approver__c default: ', req.EMS_LM_2nd_Approver__c);
        });
        }else {
        this.nodata = true;
        this.disableButton = this.nodata === true;         
        }

    }).catch((err) => {
      console.error('Error:', error);
      
    });
  }*/
  // WIRE METHOD TO SHOW THE DEFAULT DATA
  /* @wire(pendingOnMeLeaveReq)
   pendingOnMeLeaveReqWiredData({ error, data }) {
     if (data) {
       if (data.length > 0) {
         console.log('### pendingOnMeLeaveReq', data);
         //console.log('user ID 1: ', uId);
         //console.log('user ID : ', this.uId);
         this.showdata = true;
         console.log('pendingOnMeLeaveReq : ',this.showdata);
         this.nodata = false;
         this.datahistory = JSON.parse(JSON.stringify(data));
         console.log('### non filter : ', this.datahistory);
         this.datahistory.forEach(req => {
           // req.disableButton = req.EMS_LM_Status__c !== 'Pending' && (req.EMS_LM_Status__c ===  'Approver 2 Pending' && req.EMS_LM_2nd_Approver__c  !== this.uId || req.EMS_LM_Status__c ===  'Approver 1 Pending' && req.EMS_LM_Approver__c !== this.uId);
           //console.log(' ### status--->', req.EMS_LM_Status__c, "--value-->", req.EMS_LM_Status__c == 'Approver 2 Pending', "--uid--", this.uId, "--2nd approval--", req.EMS_LM_2nd_Approver__c, "--value--", req.EMS_LM_2nd_Approver__c === this.uId);
           req.disableButton = !(req.EMS_LM_Status__c == 'Pending' || (req.EMS_LM_Status__c == 'Approver 2 Pending' && req.EMS_LM_2nd_Approver__c === this.uId) || (req.EMS_LM_Status__c == 'Approver 1 pending' && req.EMS_LM_Approver__c === this.uId));
           //console.log('### req.EMS_LM_2nd_Approver__c default: ', req.EMS_LM_2nd_Approver__c);
         });
       } else {
         this.nodata = true;
         this.disableButton = this.nodata === true;
       }
     } else if (error) {
       console.error('Error:', error);
     }
   }*/

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

      //Values to remove from picklistValues
      const statusRemoved = ['Approved', 'Rejected', 'Cancelled', 'Auto Approved']
      const filteredStatusList = this.picklistValues.filter(status => !statusRemoved.includes(status.label));
      this.picklistValues = filteredStatusList;
      //console.log('### picklistValues Pending Tab: ', this.picklistValues);
      //console.log('### leaveTypeValues Pending Tab: ', this.leaveTypeValues);
    } else if (error) {
      console.error('Error:', error);
    }
  }

  // WIRE METHOD TO FILTERED DATA
  @wire(getPendingLeaveHistory, { employeeName: '$empName', startDateStr: '$startDate', endDateStr: '$endDate', statusValues: '$sValue', typeValues: '$value' })
  wiredLeavHistory(wireResult) {
    const { data, error } = wireResult; // TO REFRESH THE DATA USED THIS BY STORING DATA AND ERROR IN A VARIABLE
    this._wiredRefreshData = wireResult;
    if (data) {
      this.isLoading = false;
      this.showdata = true;
      if (data.length > 0) {
        //console.log('### DATA AFTER: ', data);
        this.showdata = true;
        this.nodata = false;
        this.datahistory = JSON.parse(JSON.stringify(data));
        this.disableButton = false;
        this.datahistory.forEach(req => {
          //console.log('#### req for approval', req);
          //console.log('### req.EMS_LM_2nd_Approver__c filter: ', req.EMS_LM_2nd_Approver__c);
          //console.log(' ### status--->', req.EMS_LM_Status__c, "--value-->", req.EMS_LM_Status__c == 'Approver 2 Pending', "--uid--", this.uId, "--2nd approval--", req.EMS_LM_2nd_Approver__c, "--value--", req.EMS_LM_2nd_Approver__c === this.uId);
          req.disableButton = !(req.EMS_LM_Status__c == 'Pending' || (req.EMS_LM_Status__c == 'Approver 2 Pending' && req.EMS_LM_2nd_Approver__c != null && req.EMS_LM_2nd_Approver__c === this.uId) || (req.EMS_LM_Status__c == 'Approver 1 Pending' && req.EMS_LM_Approver__c === this.uId));
        });
        this.error = undefined;
      } else if (!this.isCheck) {
        this.nodata = true;
        //console.log('### DATA BEFORE esle before: ', data, this.showdata);
        this.showdata = false;
        //console.log('### DATA BEFORE else: ', data, this.showdata);
        this.error = undefined;
      }
    } else if (error) {
      this.error = error;
      this.nodata = true;

      this.isLoading = false;
      this.datahistory = undefined;
    } else {
      this.nodata = true;
      this.isLoading = true;
      this.disableButton = this.nodata === true;
      this.showdata = false;
      this.error = undefined;
    }
  }

  namechange(event) {
    this.isCheck = false;
    this.empName = event.detail.value;
  }

  startdatechange(event) {
    this.startDate = event.detail.value
    this.isCheck = false;
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
    this.isCheck = false;
    if (this.endDate != null) {
      this.endDate = event.detail.value;
    }
  }

  handleValueChange(event) {
    this.sValue = event.detail;
    this.isCheck = false;
  }

  handleTypeValueChange(event) {
    this.value = event.detail;
    this.isCheck = false;
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
  }


  //TO SELECT ALL THE CHECKBOXES
  handleSelectAll(event) {
    this.checkBox = event.target.checked
    if (this.checkBox) {
      const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
      const selectedRecordIds = [];
      checkboxElements.forEach(element => {
        if (!element.disabled) {
          element.checked = true;
          const dataId = element.dataset.id;
          selectedRecordIds.push(dataId);
        }
      });
      //console.log('Selected Record Ids:', selectedRecordIds);
      this.multipleApprovals = selectedRecordIds;
      //console.log('### multipleApprovals', this.multipleApprovals);
    } else if (!this.checkBox) {
      const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
      checkboxElements.forEach(element => {
        element.checked = false;
        this.multipleApprovals = [];
        //console.log('### else multipleApprovals : ', this.multipleApprovals);
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
          this.isShowModalApproveAll = false;
          this.approveAllComments = '';
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
      bulkLeaveReqReject({ bulkRejectId: this.multipleApprovals, comments: this.rejectAllComments })
        .then((result) => {
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
    //console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    this.selectedRecordApproveId = event.currentTarget.dataset.id;
    //console.log('### selectedRecordApproveId : ', this.selectedRecordApproveId);
    this.isShowModalApprove = true;
  }

  handleApproveSave(event) {
    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      updateApproveStatusAndComments({ leaveRequestId: this.selectedRecordApproveId, comments: this.approveComments })
        .then((result) => {
          //console.log('Leave Request: ', result);
          this.isShowModalApprove = false;
          this.approveComments = '';
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
    this.rejectComments = event.target.value;
  }

  showModalRejectBox(event) {
    //console.log('### event : ', JSON.stringify(event.currentTarget.dataset));
    //console.log('### event id: ', JSON.stringify(event.currentTarget.dataset.id));
    this.selectedRecordRejectId = event.currentTarget.dataset.id;
    //console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
    this.isShowModalReject = true;

  }

  handleRejectSave(event) {
    //console.log('### selectedRecordRejectId : ', this.selectedRecordRejectId);
    if (this.template.querySelector('lightning-textarea').reportValidity()) {
      updateRejecteStatusAndComments({ leaveRequestId: this.selectedRecordRejectId, comments: this.rejectComments })
        .then((result) => {
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
          return refreshApex(this._wiredRefreshData)
        }).catch((err) => {
          console.log('ERROR : ', err);
        });
    }
  }

  connectedCallback() {
    this.a_Record_URL = window.location.origin;
    //console.log('Base Url' + this.a_Record_URL);
  }

  //TO VIEW THE LEAVE RECORD
  handleView(event) {
    const selectedRecordId = event.currentTarget.dataset.id;
    //console.log('### handleView : ', selectedRecordId);
    var url = new URL(this.a_Record_URL + '/Grid/s/ems-lm-leave-history/' + selectedRecordId);
    var params = new URLSearchParams();
    params.append("pendingTab", "value");
    url.search += "&" + params.toString();

    //console.log('### url : ', JSON.stringify(url));
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href

      },
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