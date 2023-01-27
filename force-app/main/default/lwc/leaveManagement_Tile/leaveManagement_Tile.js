import { LightningElement, wire } from 'lwc';
import leaveBanlance from '@salesforce/apex/LeaveManagementApexController.leaveBanlance';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
export default class LeaveManagement_Tile extends NavigationMixin(LightningElement) {
  contextText = 'This shows your total leave balance in hours.This includes your annual leaves, comp off, etc. for which you are eligible and have balance.'
  leaveBalanceData;
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
    console.log('Button Clicked : ');
    //Conditions to make isActions to TRUE
    var url = new URL("https://cpprd--dev.sandbox.my.site.com/CpLink/s/leave-management");
    var params = new URLSearchParams();
    params.append("bulkupdate", "value");
    url.search += "&" + params.toString();
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href
      }
    });
  }
}