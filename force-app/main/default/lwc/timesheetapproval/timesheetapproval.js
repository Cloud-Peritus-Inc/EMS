import { LightningElement, wire, track } from 'lwc';
import Recordssize from '@salesforce/apex/PedningTimesheet.Recordssize';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
export default class Timesheetapproval extends NavigationMixin(LightningElement) {
  contextText = 'This shows your Timesheet approval'

  @track NumberofApprovals=0;
  @track error;
refreshRecordsize=[];

  @wire(Recordssize)
  wiredRecords(result) {
     const {data,error}= result;
     this.refreshRecordsize=result;
   console.log('noofrecords================================',result);
   if(result.data){
     this.NumberofApprovals = result.data;
    /*
    if(result.lenth()>=1){
     // if(data.length()>=1){
        alert('test');
        this.NumberofApprovals =data.length();
  //  if (result.data) {
      
      //  this.NumberofApprovals = result.data;
      console.log('Records size===============', this.NumberofApprovals);
    } else if (error) {
      // alert('error===================');
      console.log('error diplyed===============================', result.error);
      this.error = result.error;
    }
    */
  }else{
    this.error = result.error;
  }
  }
  connectedCallback(){
  this.a_Record_URL = window.location.origin;
   console.log('Base Url' + this.a_Record_URL)
  }
  handleLMNavigation(event) {
    var url = new URL(this.a_Record_URL + '/Grid/s/timesheetapproval');
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href
      }
    });
  }

  refreshtimesheet(event){
    refreshApex(this.refreshRecordsize);
  }
}