import { LightningElement, track, wire, api } from 'lwc';
import getLeaveRequest from '@salesforce/apex/LeaveManagementApexController.getLeaveRequest';
import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class EMS_LM_LeaveHistory extends NavigationMixin(LightningElement) {

  PendingLeaveReq;
  @api recordId;
  isActions = false;
  @track currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
  }

  @wire(getLeaveRequest)
  LeaveRequestwiredData({ error, data }) {
    if (data) {
      this.PendingLeaveReq = JSON.parse(JSON.stringify(data));
      console.log('### PendingLeaveReq', this.PendingLeaveReq);
      this.PendingLeaveReq.forEach(req => {
        req.disableButton = req.EMS_LM_Status__c !== 'Pending';
      });
    } else if (error) {
      console.error('Error:', error);
    }
  }
  
  //To check whether the url has "bulkupdate" and to display the actions
  connectedCallback() {
    var params = new URLSearchParams(location.search);
    if (params.has('bulkupdate')) {
      console.log("Hello");
      this.isActions = true;
      console.log('Bye : ');
    }
  }

  //To view the leave record
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

  //To edit the leave record
  handleEdit(event) {
    const selectedRecordId = event.currentTarget.dataset.id;
    console.log('### handleEdit : ', selectedRecordId);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectedRecordId,
        objectApiName: 'EMS_LM_Leave_History__c',
        actionName: 'view',
      },
    });
  }

  //TO cancel the leave record
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
        });
        this.dispatchEvent(evt);
        window.location.reload();
      }).catch((err) => {
        console.log('### err : ', JSON.stringify(err));
      });
  }
}