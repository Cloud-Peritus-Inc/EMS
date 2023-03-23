import { LightningElement, wire, track } from 'lwc';
import leaveBanlance from '@salesforce/apex/LeaveManagementApexController.leaveBanlance';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import { refreshApex } from '@salesforce/apex';
import { createMessageContext, subscribe, unsubscribe } from 'lightning/messageService';
import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';
export default class LeaveManagement_Tile extends NavigationMixin(LightningElement) {

  contextText = 'This shows your annual leave balance in days'

  @track leaveBalanceData;
  leavebalanceResult;

  connectedCallback() {
    this.a_Record_URL = window.location.origin;
    console.log('Base Url' + this.a_Record_URL);

     const messageContext = createMessageContext();
        this.subscription = subscribe(messageContext, MY_REFRESH_CHANNEL, (message) => {
            this.handleRefreshMessage(message);
        });
  }

  @wire(leaveBanlance)leaveBalanceWiredData(result) {
    this.leavebalanceResult = result;
    if (result.data) {
      this.leaveBalanceData = result.data.EMS_LM_No_Of_Availble_Leaves__c;
      console.log('### leaveBalanceData', this.leaveBalanceData);
    } else if (result.error) {
      console.error('Error:', result.error);
    }
  }


  handleLMNavigation(event) {
    var url = new URL(this.a_Record_URL + '/Grid/s/leave-management');
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href
      }
    });
  }

  errorCallback(error, stack) {
    console.log('errorcallback – child' + error);
    console.log('### stack' + stack);
  }


  handleRefresh() {
         const refreshEvent = new CustomEvent('refresh', {
    bubbles: true
});
this.dispatchEvent(refreshEvent);
    } 

    // for refresh using LMS
    subscription = null;

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

//https://cpprd--dev.sandbox.my.site.com/cpgrid/s/leave-management