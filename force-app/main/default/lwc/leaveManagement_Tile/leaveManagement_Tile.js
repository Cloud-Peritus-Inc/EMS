import { LightningElement, wire, track } from 'lwc';
import leaveBanlance from '@salesforce/apex/LeaveManagementApexController.leaveBanlance';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
export default class LeaveManagement_Tile extends NavigationMixin(LightningElement) {

  contextText = 'This shows your total leave balance in days.This includes your annual leaves, comp off, etc. for which you are eligible and have balance.'

  @track leaveBalanceData;

  connectedCallback() {
    this.a_Record_URL = window.location.origin;
    console.log('Base Url' + this.a_Record_URL);
  }

  @wire(leaveBanlance)
  leaveBalanceWiredData({ error, data }) {
    if (data) {
      this.leaveBalanceData = data.EMS_LM_No_Of_Availble_Leaves__c;
      console.log('### leaveBalanceData', this.leaveBalanceData);
    } else if (error) {
      console.error('Error:', error);
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
}

//https://cpprd--dev.sandbox.my.site.com/cpgrid/s/leave-management