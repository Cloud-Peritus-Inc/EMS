import { LightningElement, track, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import getLeaveType from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveType';
import getLocation from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLocation';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getLeaveDuration';
export default class EMS_LM_WFH extends LightningElement {
    check1;
    check2 = false;
    uId = u_Id;
    Location;
    @track duration;
  error;
    startDate1;//To apply Leave start date
  endDate1;//To apply Leave end date
  datechange(event) {
    var namecheck = event.target.name;
    if (namecheck == 'startDate1') {
      this.startDate1 = event.detail.value + ' 00:00:00';
      window.console.log('startDate1 ##' + this.startDate1);
    }    
    if (namecheck == 'endDate1') {
      this.endDate1 = event.detail.value + ' 00:00:00';
      window.console.log('endDate1 ##' + this.endDate1);
    }    
  }
  @wire(getLocation, { userid: '$uId' })
  wiredlocation({ error, data }) {
    if (data) {
      this.Location = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.Location = undefined;
    }
  }

  @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', Location: '$Location' })
  wiredduration({ error, data }) {
    if (data) {
      this.check2 = true;
      this.duration = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.duration = undefined;
    }
  }
  closeme() {
    this.check1 = false;
    this.check2 = false;
    console.log(this.check1);
    const gethvalue = new CustomEvent('gethvalue',{
      detail : this.check1
    });
    this.dispatchEvent(gethvalue);
  }
  submit() {

  }
  get acceptedFormats() {
    return ['.pdf', '.png', '.jpg', '.jpeg', '.docx'];
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
  }
}