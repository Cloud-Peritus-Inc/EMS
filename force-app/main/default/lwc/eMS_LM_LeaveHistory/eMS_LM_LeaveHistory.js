import { LightningElement, track, wire, api } from 'lwc';
import getLeaveRequest from '@salesforce/apex/LeaveManagementApexController.getLeaveRequest';
//import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
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
  
}