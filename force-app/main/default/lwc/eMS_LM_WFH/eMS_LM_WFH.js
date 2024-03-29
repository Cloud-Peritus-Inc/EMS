import { LightningElement, track, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import getbilling from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getbilling';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getwfhDuration';
import getwfhWFHweekends from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getwfhWFHweekends';
import createwfhRecord from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.createwfhRecord';
import uploadFile from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { createMessageContext, publish } from 'lightning/messageService';
import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';

export default class EMS_LM_WFH extends LightningElement {
  @track isLoading = false;
  check1;
  check2 = false;
  uId = u_Id;
  Location;
  fileData;
  conId;
  reason;
  wfhrecordId;
  @track duration;
  weekendwfh = false;
  error;
  startDate1;//To apply Leave start date
  endDate1;//To apply Leave end date
  todaydate;
  disabledSubmitted = true;

  connectedCallback() {
    let today = new Date();
    let dd = today.getDate();
    let mm = today.getMonth() + 1;
    let y = today.getFullYear();
    let date = Date.parse(y + '-' + mm + '-' + dd);
    let date1 = new Date(date);
   // console.log('date-->', date);
    let formattedDate = date1.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
    this.todaydate = formattedDate;
  }



  datechange(event) {
    var namecheck = event.target.name;
    let enteredDate = new Date(event.target.value);
    let day = enteredDate.getDay();
    if (namecheck == 'startDate1') {

      this.startDate1 = event.detail.value + ' 00:00:00';
      let date = new Date(this.startDate1);
      let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
      let todaydate1 = formattedDate;
      if (new Date(todaydate1) < new Date(this.todaydate)) {
        this.disabledSubmitted = true;
        this.startDate1 = null;
        const evt = new ShowToastEvent({
          message: 'You have selected past date, please select future date.',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      }

      if (this.endDate1 < this.startDate1 && this.startDate1 != null && this.endDate1 != null) {
        const evt = new ShowToastEvent({
          message: 'Please select a proper start date',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.startDate1 = null;
        this.endDate1 = null;
      }
    }

    if (namecheck == 'endDate1') {

      this.endDate1 = event.detail.value + ' 00:00:00';
      let datessend = new Date(this.endDate1);
      let formattedendDate = datessend.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
      let todaydate2 = formattedendDate;
      if (new Date(todaydate2) < new Date(this.todaydate)) {
        this.disabledSubmitted = true;
        this.endDate1 = null;
        const evts = new ShowToastEvent({
          message: 'You have selected past date, please select future date.',
          variant: 'error',
        });
        this.dispatchEvent(evts);
      }

      if (this.endDate1 < this.startDate1 && this.startDate1 != null && this.endDate1 != null) {
        const evt = new ShowToastEvent({
          message: 'Please select a Valid End date',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        //alert('Please select a Valid End date');
        this.startDate1 = null;
        this.endDate1 = null;
      }
      if (this.startDate1 != null && this.endDate1 != null) {
        this.disabledSubmitted = false;
      }
    }

    if (day == 6 || day == 0) {
      //alert('please select working days');
      const evt = new ShowToastEvent({
        message: 'You can apply leave on working days only, please select working days.',
        variant: 'error',
      });
      this.dispatchEvent(evt);
      this.endDate1 = null;
      this.startDate1 = null;
    }

    if (this.startDate1 != null && this.endDate1 != null) {
      this.disabledSubmitted = false;
    }

  }


  @wire(getbilling, { userid: '$uId' })
  wiredbilling({ error, data }) {
    if (data) {
      this.conId = data.Id;
      this.Location = data.Work_Location__r.Country__c;
     // console.log('this.conId', this.conId, 'this.Location', this.Location);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', Location: '$Location' })
  wiredduration({ error, data }) {
    if (data) {
      this.check2 = true;
      this.duration = data;
    //  console.log('this.duration-->', this.duration);
      this.error = undefined;
    } else if (error) {
      this.error = error;
      console.log('this.error ', this.error);
      this.duration = undefined;
    }
  }

  @wire(getwfhWFHweekends, { stDate: '$startDate1', edDate: '$endDate1' })
  wirewfhWFHweekends({ error, data }) {
    if (data) {
     // console.log('wfhWFHweekends-->', data);
      this.weekendwfh = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.weekendwfh = undefined;
    }
  }

  closeme() {
    this.check1 = false;
    this.check2 = false;
    console.log(this.check1);
    const gethvalue = new CustomEvent('gethvalue', {
      detail: this.check1
    });
    this.dispatchEvent(gethvalue);
  }

  reasonchange(event) {
    this.reason = event.target.value;
  }

  submit(event) {

    if (this.weekendwfh > 1) {
      const evt = new ShowToastEvent({
        message: 'Please apply Work from Home for same week',
        variant: 'error',
      });
      this.dispatchEvent(evt);

    } else {

      if ((this.reason == null || this.reason == '') && this.duration > 3) {
        const evt = new ShowToastEvent({
          message: 'Please mention the reason for your request',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      } else {
        this.isLoading = true;
        createwfhRecord({ cId: this.conId, duration: this.duration, stDate: this.startDate1, edDate: this.endDate1, reason: this.reason })
          .then(result => {
            this.wfhrecordId = result;

            if (this.fileData != null) {
              uploadFile({ base64: this.fileData.base64, filename: this.fileData.filename, recordId: this.wfhrecordId }).then(res => {
                //console.log(res);
              }).catch(error => { console.error(error.body.message); });
            }
            this.isLoading = false;
            this.check1 = false;
            const gethvalue = new CustomEvent('gethvalue', {
              detail: this.check1
            });
            this.dispatchEvent(gethvalue);

            this.dispatchEvent(new ShowToastEvent({
              message: 'Your Work From Home request has been successfully applied!',
              variant: 'success'
            }));

            const messageContext = createMessageContext();
            const payload = {
              refresh: true
            };
            publish(messageContext, MY_REFRESH_CHANNEL, payload);
          }).catch(error => {
            this.check1 = false;
            this.isLoading = false;
            console.error('Error creating record: ', error);
            //  console.error('Error creating record: ', error.body.message);
            this.dispatchEvent(new ShowToastEvent({
              message: error.body.pageErrors[0].message,
              variant: 'error'
            }));

          })
      }
    }

  }

  handleIsLoading(isLoading) {
    this.isLoading = isLoading;
  }

  get acceptedFormats() {
    return ['.pdf', '.png', '.jpg', '.jpeg', '.docx'];
  }

  openfileUpload(event) {
    const file = event.target.files[0]
    var reader = new FileReader()
    reader.onload = () => {
      var base64 = reader.result.split(',')[1]
      this.fileData = {
        'filename': file.name,
        'base64': base64
      }
    }
    reader.readAsDataURL(file)
  }

}