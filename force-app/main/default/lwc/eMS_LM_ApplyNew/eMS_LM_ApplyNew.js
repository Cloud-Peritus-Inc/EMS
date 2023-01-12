import { api, LightningElement, track, wire } from 'lwc';

import u_Id from '@salesforce/user/Id';

export default class EMS_LM_ApplyNew extends LightningElement {
  @track selectedValue;
  check = false;
  check1 = false;
  
  handleOnselect(event) {
    this.selectedValue = event.detail.value;
    if (this.selectedValue == 'Leave') {
      this.check = true;
    }
    else if ((this.selectedValue == 'Work From Home')) {
      this.check1 = true;
    }
  } 
  getlvalue(event){
    this.check = event.detail;
  }
  gethvalue(event){
    this.check1 = event.detail;
  }
}