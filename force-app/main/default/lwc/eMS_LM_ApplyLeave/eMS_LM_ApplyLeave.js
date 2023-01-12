import { api, LightningElement, track, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeaveType from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveType';
import getLocation from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLocation';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getLeaveDuration';
import getLeaveBalance from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveBalance';
import createLeaveHistoryRecord from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.createLHRecord';
import uploadFile from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.uploadFile';
import LightningConfirm from "lightning/confirm";
uploadFile
export default class EMS_LM_ApplyLeave extends LightningElement {
  check;
  uId = u_Id;
  Location;
  @track duration;
  @track lOptions = [];
  error;
  dOptions = [{ label: 'Full Day', value: 'Full Day' }];//{label: 'a', value: 1}, {label: 'b', value: 2}
  fullday = 'Full Day';
  startDate1;//To apply Leave start date
  endDate1;//To apply Leave end date
  startDate;//To apply Leave start date
  endDate;
  value = '';
  submitcheck = false;//need to changed based on condition LD < ALD
  @track availabledays;
  @track allavailabledays;
  @track reason;
  daycheck = false;
  cId;
  Email;
  todaydate;
  annualduration;
  annualcompduration;
  filecheck = true;
  fileData;
  connectedCallback() {
    let today = new Date();
    console.log(this.today);
    let dd = today.getDate() + 2;
    let mm = today.getMonth() + 1;
    let y = today.getFullYear();
    let date = Date.parse(y + '-' + mm + '-' + dd);
    let date1 = new Date(date);
    console.log(date);
    let formattedDate = date1.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
    this.todaydate = formattedDate;
  }
  @wire(getLeaveType, { userid: '$uId' })
  wiredltype({ error, data }) {
    if (data) {
      this.lOptions = data.map((record) => ({
        value: record,
        label: record
      }));
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.lOptions = undefined;
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
  @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', location: '$Location', dayCheck: '$daycheck' })
  async wiredduration({ error, data }) {
    if (data) {
      if (this.value == 'Loss of Pay' || this.value == 'Annual Leave') {
        if (this.value == 'Loss of Pay') {
          if (this.startDate != undefined || this.startDate != null) {
            let date = new Date(this.startDate);
            let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate1 = formattedDate;
            if (new Date(todaydate1) < new Date(this.todaydate)) {
              this.submitcheck = false;
              alert('Leave to be applied before 48Hrs');
            }
            else{
             this.submitcheck = true;
             this.duration = data;
            }
          }
        }
        if (this.value == 'Annual Leave') {
          if (this.annualduration >= data) {
            this.submitcheck = true;
            this.duration = data;
            this.error = undefined;
          }
          else {
            const result = await LightningConfirm.open({
              message: "You can avail upto 5 additional Annual Leaves",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });
            if (result) {
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 5;
              if (this.availabledays >= data) {
                this.submitcheck = true;
                this.duration = data;
                this.error = undefined;
              }
              else {
                this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
                alert('You dont have enough balance to apply leave');
                this.duration = undefined;
                this.error = undefined;
                this.submitcheck = false;
                this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
              }
            }
            else {
              this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
              alert('You dont have enough balance to apply leave');
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = false;
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
            }
          }
        }
      }
      else {
        if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior
          if (this.startDate != undefined || this.startDate != null) {
            let date = new Date(this.startDate);
            let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate1 = formattedDate;
            if (new Date(todaydate1) < new Date(this.todaydate)) {
              this.submitcheck = false;
              alert('Leave to be applied before 48Hrs');
            }
            else{
              if(this.availabledays >= data){
                this.submitcheck = true;
                this.duration = data;
              } 
              else{
                this.submitcheck = false;
                alert('You dont have enough balance to apply leave');
              }             
             }
          }
          else{
            if (this.availabledays >= data) {
              this.submitcheck = true;
              this.duration = data;
              this.error = undefined;
            }
            else {
              this.duration = data;
              alert('You dont have enough balance to apply leave');
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = false;
            }
          }  
        }
        else{
          if (this.availabledays >= data) {
            this.submitcheck = true;
            this.duration = data;
            this.error = undefined;
          }
          else {
            this.duration = data;
            alert('You dont have enough balance to apply leave');
            this.duration = undefined;
            this.error = undefined;
            this.submitcheck = false;
          }
        }  
        
      }
    } else if (error) {
      this.error = error;
      this.duration = undefined;
      this.submitcheck = false;
    }
  }

  @wire(getLeaveBalance, { userid: '$uId' })
  wirelbalance({ error, data }) {
    if (data) {
      this.allavailabledays = data;
      this.annualcompduration = data.EMS_LM_No_Of_Availble_Leaves__c + data.EMS_LM_No_Of_Available_Compensatory_Off__c + 5;
      console.log(this.annualcompduration);
      this.annualduration = data.EMS_LM_No_Of_Availble_Leaves__c;
      console.log(this.annualduration);
      this.cId = data.Id;
      this.Email = data.Official_Mail__c;
    } else if (error) {
      console.log(error);
      this.error = error;
    }
  }
  handleChange(event) {
    this.daycheck = false;
    this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;

    this.submitcheck = false;
    this.value = event.detail.value;

    if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
      if (this.startDate == this.endDate) {
        if (this.startDate == undefined || this.endDate == undefined) {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
    }
    else {
      this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
    }
    if (this.value == 'Annual Leave') {
      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
    }
    if (this.value == 'Paternity Leave') {
      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Paternity_Leave__c;
    }
    if (this.value == 'Bereavement Leave') {
      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Bereavement_Leave__c;
    }
    if (this.value == 'Maternity Leave') {
      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Maternity_Leave__c;
    }
    if (this.value == 'Compensatory Off') {
      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Compensatory_Off__c;
    }
    if (this.value == 'Loss of Pay') {
      if (this.annualcompduration > 0) {
        console.log(this.annualcompduration);
        this.submitcheck = false;
        alert('Please Utilise Your Leaves(Annual / Comp Off) before applying for Loss Of Pay');
      }
      this.availabledays = 0;
    }
  }
  datechange(event) {
    var namecheck = event.target.name;
    this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
    this.daycheck = false;
    if (namecheck == 'startDate1') {
      this.startDate1 = event.detail.value;
      this.startDate = event.detail.value;
      if (this.startDate1 != null) {
        this.startDate1 = event.detail.value + ' 00:00:00';
      }
      if (this.endDate < this.startDate && this.startDate != null && this.endDate != null) {
        alert('Please select a proper Start Date');
        this.startDate1 = null;
      }
      if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
        if (this.startDate != this.endDate || this.startDate == undefined || this.endDate == undefined) {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior
        if (this.startDate != undefined || this.startDate != null) {
          let date = new Date(this.startDate);
          let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
          let todaydate1 = formattedDate;
          if (new Date(todaydate1) < new Date(this.todaydate)) {
            this.submitcheck = false;
            alert('Leave to be applied before 48Hrs');
          }
        }

      }
    }
    if (namecheck == 'endDate1') {
      this.endDate1 = event.detail.value;
      this.endDate = event.detail.value;
      if (this.endDate1 != null) {
        this.endDate1 = event.detail.value + ' 00:00:00';
      }
      if (this.endDate < this.startDate && this.startDate != null && this.endDate != null) {
        console.log(this.endDate <= this.startDate);
        alert('Please select a Valid End date');
        this.endDate1 = null;
      }
      if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
        if (this.startDate != this.endDate || this.startDate == undefined || this.endDate == undefined) {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }    
    }
  }
  reasonChange(event) {
    this.reason = event.detail.value;
    if (this.reason != null) {
      if(this.availabledays >= this.duration){
        this.submitcheck = true;
      }      
    }
    if (this.reason == null || this.reason == '') {
      this.submitcheck = false;
    }

  }
  closeme() {
    this.check = false;
    this.check2 = false;
    const getlvalue = new CustomEvent('getlvalue', {
      detail: this.check
    });
    this.dispatchEvent(getlvalue);
  }
  submitme(event) {
    if (this.reason != null) {
      event.preventDefault();
      this.submitcheck = false;
      createLeaveHistoryRecord({ cId: this.cId, duration: this.duration, stDate: this.startDate, edDate: this.endDate, type: this.value, reason: this.reason, day: this.fullday })
        .then(result => {
            this.rId = result;
            if(this.fileData != null){
              uploadFile({ base64 : this.fileData.base64 , filename : this.fileData.filename , recordId : this.rId }).then(res=>{
                console.log(res);
              }).catch(error=> {  console.error(error.body.message);});
            }            
            this.check = false;
            const getlvalue = new CustomEvent('getlvalue', {
              detail: this.check
            });
            this.dispatchEvent(getlvalue);
            this.dispatchEvent(new ShowToastEvent({
              title: 'Success!!',
              message: 'Leave Applied Successfully !!.',
              variant: 'success'
            }));
            window.location.reload();
        }).catch(error => {
          console.error('Error creating record: ', error.body.message);
          this.dispatchEvent(new ShowToastEvent({
            title: 'Error!!',
            message: 'Unable to Apply Leave',
            variant: 'error'
          }));
          window.location.reload();
        });
    }
    if (this.reason == null || this.reason == '') {
      alert('Please mention Reason');// need to chane the alert message
      this.submitcheck = false;
    }
  }
  dayChange(event) {
    this.fullday = event.detail.value;
    if (this.fullday != 'Full Day') {
      this.daycheck = true;
    }
    else {
      this.daycheck = false;
    }
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


// handleUploadFinished(event) {
//   this.file = event.detail.files[0];
//   this.fileName = this.file.name;
// }
// get acceptedFormats() {
//   return ['.pdf', '.png', '.jpg', '.jpeg', '.docx'];
// }