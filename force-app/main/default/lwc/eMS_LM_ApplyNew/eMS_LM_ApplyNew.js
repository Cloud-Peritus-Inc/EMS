import { api, LightningElement, track, wire } from 'lwc';

import u_Id from '@salesforce/user/Id';

export default class EMS_LM_ApplyNew extends LightningElement {
  @track selectedValue;
  check = false;
  check1 = false;
  
  handleOnselect(event) {
    console.log('OUTPUT : ',);
   // this.check = true;
    this.selectedValue = event.detail.value;
    console.log('### selectedValue : ',this.selectedValue);
    if (this.selectedValue == 'Leave') {
      this.check = true;
    }
    else if ((this.selectedValue == 'Work From Home')) {
      this.check1 = true;
    }
  } 
  getlvalue(event){
    this.check = event.detail;
    console.log('this.check-->',this.check);
  }
  gethvalue(event){
    this.check1 = event.detail;
    console.log('this.check1-->',this.check1);
  }
}