import { LightningElement, track, wire, api } from 'lwc';
import getLeaveRequest from '@salesforce/apex/LeaveManagementApexController.getLeaveRequest';
//import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class EMS_LM_LeaveHistory extends NavigationMixin(LightningElement) {

  PendingLeaveReq;
  nodata = false;
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
      if (data.length > 0) {
        this.PendingLeaveReq = JSON.parse(JSON.stringify(data));
        this.PendingLeaveReq.forEach(req => {
          req.disableButton = req.EMS_LM_Status__c !== 'Pending';
        });
      } else {
        this.nodata = true;
      }
    } else if (error) {
      console.error('Error:', error);
    }
  }

}