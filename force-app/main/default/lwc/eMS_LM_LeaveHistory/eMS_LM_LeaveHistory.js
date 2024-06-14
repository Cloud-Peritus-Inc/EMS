import { LightningElement, track, wire, api } from 'lwc';
import getLeaveRequest from '@salesforce/apex/LeaveManagementApexController.getLeaveRequest';
//import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { refreshApex } from '@salesforce/apex';
import { createMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';
export default class EMS_LM_LeaveHistory extends NavigationMixin(LightningElement) {
  leavebalanceResult;
  PendingLeaveReq;
  nodata = false;
  @api recordId;
  isActions = false;
  @track currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
  }

  @wire(getLeaveRequest) LeaveRequestwiredDataresult(result) {
    this.leavebalanceResult = result;
    if (result.data) {
       console.log('the pending results are:'+result.data);
      if (result.data.length > 0) {
        this.PendingLeaveReq = JSON.parse(JSON.stringify(result.data));
        console.log('the pending requests are:'+this.PendingLeaveReq);
        this.PendingLeaveReq.forEach(req => {
          req.disableButton = req.EMS_LM_Status__c !== 'Pending';
        });
      } else {
        this.nodata = true;
      }
    } else if (result.error) {
      console.error('Error:', result.error);
    }
  }

  handleRefresh() {
    const refreshEvent = new CustomEvent('refresh', {
      bubbles: true
    });
    this.dispatchEvent(refreshEvent);
  }

  // for refresh using LMS
  subscription = null;

  connectedCallback() {
    const messageContext = createMessageContext();
    this.subscription = subscribe(messageContext, MY_REFRESH_CHANNEL, (message) => {
      this.handleRefreshMessage(message);
    });
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleRefreshMessage(message) {
    if (message.refresh) {
      refreshApex(this.leavebalanceResult);
    }
  }

}