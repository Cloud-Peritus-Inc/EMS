import { api, LightningElement, track, wire } from 'lwc';

import u_Id from '@salesforce/user/Id';

export default class EMS_LM_ApplyNew extends LightningElement {

  @api istile = false;
  
  @track selectedValue;
  check = false;
  check1 = false;
  openleave = false;
  openWfh = false;
  isModalOpen=false;
  selectedOption;

  firsthandle(event){
    this.isModalOpen=true;
  }
  closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
}


  
  handleOnselect(event) {
    console.log('OUTPUT : ',);
    this.check = true;
    this.selectedValue = event.detail.value;
    console.log('### selectedValue : ',this.selectedValue);
   /* if (this.selectedValue == 'Leave') {
      this.check = true;
    }
    else if ((this.selectedValue == 'Work From Home')) {
      this.check1 = true;
    }*/
  }

  getlvalue(event){
    this.check = event.detail;
    console.log('this.check-->',this.check);
  }
  gethvalue(event){
    this.check1 = event.detail;
    console.log('this.check1-->',this.check1);
  }

  getclosevalue(event){
    this.isModalOpen = false;
  }
leavetemplate;
wfhtemplate;
  getleavechecktrue(event){
    this.leavetemplate=event.detail;
    console.log('this.leavetemplate-->',this.leavetemplate);
    if(this.leavetemplate==true){
      this.check = true;
    }
  }

  getwfhchcktrue(event){
    this.wfhtemplate=event.detail;
    console.log('this.wfhtemplate-->',this.wfhtemplate);
    if(this.wfhtemplate==true){
      this.check1 = true;
    }
  }
}