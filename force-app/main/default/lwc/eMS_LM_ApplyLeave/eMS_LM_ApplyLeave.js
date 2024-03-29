import { api, LightningElement, track, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeaveType from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveType';
import getbilling from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getbilling';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getLeaveDuration';
import getLeaveBalance from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveBalance';
import uploadFile from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.uploadFile';
import getLeaveTypeId from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveTypeid';
import LightningConfirm from "lightning/confirm";
import { createRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import { createMessageContext, publish } from 'lightning/messageService';
import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';
import { subscribe, unsubscribe } from 'lightning/messageService';
export default class EMS_LM_ApplyLeave extends LightningElement {
  @track isLoading = false;
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
  visiableotherdetail = false;
  submitcheck = true;//need to changed based on condition LD < ALD
  @track availabledays;
  @track allavailabledays;
  @track reason;
  daycheck = false;
  cId;
  email;
  isbillable;
  fileuploadRequired = false;
  annualduration;
  annualcompduration;
  filecheck = true;
  fileData;
  wfhtodaydate;
  leavetypeId;
  currentLocation;
  wiredActivities;
  refleaveType;
  refleaveduration;



  @wire(getLeaveType, { userid: '$uId',annualavailable: '$annualduration' }) wiredltype(result) {
    this.refleaveType = result;
    if (result.data) {
     // console.log('leave type data-->', result.data);
      this.lOptions = result.data.map((record) => ({
        value: record,
        label: record
      }));
      this.error = undefined;
    } else if (result.error) {
      this.error = result.error;
      this.lOptions = undefined;
    }
  }

  @wire(getLeaveTypeId, { leavetype: '$value' })
  wireleavetype({ error, data }) {
    if (data) {
      this.leavetypeId = data.Id;
     // console.log('type data-->', data.Id);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getbilling, { userid: '$uId' })
  wiredbilling({ error, data }) {
    if (data) {
      this.isbillable = data.EMS_TM_In_Billing__c;
      this.Location = data.Work_Location__r.Country__c;
    //  console.log('this.isbillable-->', this.isbillable, 'this.Location', this.Location);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', location: '$Location', dayCheck: '$daycheck', value: '$value' })
  async wiredduration(result) {
    this.refleaveduration = result;
    if (result.data) {
      if (this.value == 'Loss of Pay' || this.value == 'Annual Leave') {
        if (this.value == 'Loss of Pay') {
          if (this.startDate != undefined || this.startDate != null) {
            if (result.data > 90) {
              this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
              this.submitcheck = true;
              const evt = new ShowToastEvent({
                message: 'Sorry !! You cannot take this leave more than 90 days',
                variant: 'error',
              });
              this.dispatchEvent(evt);
            } else {
              this.submitcheck = false;
              this.duration = result.data;
            }

          }
        }
        if (this.value == 'Annual Leave') {
          if (this.annualduration >= result.data) {
            this.submitcheck = false;
            this.duration = result.data;
            this.error = undefined;
          }
          else {
            const results = await LightningConfirm.open({
              message: "To apply this leave, you have to avail additional leaves from next quarter. You can take a leave loan upto 5 days.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });
            if (results) {
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 5;
              if (this.availabledays >= result.data) {
                this.submitcheck = false;
                this.duration = result.data;
                this.error = undefined;
              }
              else {
                this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
                const evt = new ShowToastEvent({
                  message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                  variant: 'error',
                });
                this.dispatchEvent(evt);
                // alert('You dont have enough balance to apply leave');
                this.duration = undefined;
                this.error = undefined;
                this.submitcheck = true;
                this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
              }
            }
            else {
              this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
              /* const evt = new ShowToastEvent({
                 message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
                 variant: 'error',
                 });
                   this.dispatchEvent(evt);*/
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
            }
          }
        }
      }
      else {
        if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior
          if (this.startDate != undefined || this.startDate != null) {

            if (this.availabledays >= result.data) {
              this.submitcheck = false;
              this.duration = result.data;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);
              this.submitcheck = true;
            }

          }
          else {
            if (this.availabledays >= result.data) {
              this.submitcheck = false;
              this.duration = result.data;
              this.error = undefined;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);

              this.duration = result.data;
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }
        }
        else {
          if (this.availabledays >= result.data) {
            this.submitcheck = false;
            this.duration = result.data;
            this.error = undefined;
          }
          else {

            const evt = new ShowToastEvent({
              message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
              variant: 'error',
            });
            this.dispatchEvent(evt);

            this.duration = result.data;
            this.duration = undefined;
            this.error = undefined;
            this.submitcheck = true;
          }
        }
      }
    } else if (result.error) {
      this.error = result.error;
      this.duration = undefined;
      this.submitcheck = true;
    }
  }

  @wire(getLeaveBalance, { userid: '$uId' }) wirelbalance(result) {
    this.wiredActivities = result;
    if (result.data) {
      this.allavailabledays = result.data;
      this.annualcompduration = result.data.EMS_LM_No_Of_Availble_Leaves__c + result.data.EMS_LM_No_Of_Available_Compensatory_Off__c + 5;
    //  console.log('this.annualcompduration' + this.annualcompduration);
      this.annualduration = result.data.EMS_LM_No_Of_Availble_Leaves__c;
    //  console.log('this.annualduration' + this.annualduration);
      this.availabledays = this.annualduration;

      this.cId = result.data.Id;
      this.email = result.data.Email;
    } else if (result.error) {
      console.log(result.error);
      this.error = result.error;
    }
  }

  //ABOVE METHOD FOR CONNECTED CALL BACK
  /*calculateDuration() {
    getLeaveBalance({ userid: this.uId }).then((result) => {
      console.log('### result : ', result);

      if (result) {
        console.log('### result : ', result);
        this.allavailabledays = result;
        this.annualcompduration = result.EMS_LM_No_Of_Availble_Leaves__c + result.EMS_LM_No_Of_Available_Compensatory_Off__c + 5;
        console.log('this.annualcompduration' + this.annualcompduration);
        this.availabledays = result.EMS_LM_No_Of_Availble_Leaves__c;

        console.log('this.annualduration 1122' + this.annualduration);
        this.cId = result.Id;
        this.email = result.Email;
      } else if (result.error) {
        console.log(result.error);
        this.error = result.error;
      }
    }).catch((err) => {

    });
  }*/

  handleChange(event) {
    this.daycheck = false;
    this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;

    this.submitcheck = true;
    this.value = event.detail.value;
    if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
      //this.calculateDuration();
      this.visiableotherdetail = true;
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
     // refreshApex(this.allavailabledays);
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
    //  console.log('anna  this.availabledays' + this.availabledays);
      this.fileuploadRequired = true;
    }
    if (this.value == 'Paternity Leave') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Paternity_Leave__c;
      if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      }

    }
    if (this.value == 'Bereavement Leave') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Bereavement_Leave__c;
      if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      }

    }
    if (this.value == 'Maternity Leave') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Maternity_Leave__c;
      this.fileuploadRequired = true;

    }
    if (this.value == 'Marriage Leave') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_of_Available_Marriage_Leave__c;
      this.fileuploadRequired = true;
    }
    if (this.value == 'Compensatory Off') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Compensatory_Off__c;
      if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      }

    }
    if (this.value == 'Loss of Pay') {
      this.visiableotherdetail = true;
      if (this.annualcompduration > 0) {
      //  console.log(this.annualcompduration);
        this.submitcheck = true;
        const evt = new ShowToastEvent({
          message: 'Loss of Pay will effect your monthly pay check, consider applying leave of annual or comp off type. ',
          variant: 'warning',
        });
        this.dispatchEvent(evt);
        //alert('Please Utilise Your Leaves(Annual / Comp Off) before applying for Loss Of Pay');
      }
      this.availabledays = 0;
      if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      }

    }
   
  }


  datechange(event) {
    var namecheck = event.target.name;
    let enteredDate = new Date(event.target.value + ' 00:00:00');

    let day = enteredDate.getDay();
    this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
    this.daycheck = false;
    if (namecheck == 'startDate1') {
      this.startDate1 = event.detail.value;
      this.startDate = event.detail.value;
      if (this.startDate1 != null) {
        this.startDate1 = event.detail.value + ' 00:00:00';
      }
      if (day == 6 || day == 0) {
        //alert('please select working days');
        const evt = new ShowToastEvent({
          message: 'You can apply leave on working days only, please select working days. ',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.startDate = this.startDate1 = undefined;
      }
      if (this.endDate < this.startDate && this.startDate != null && this.endDate != null) {
        const evt = new ShowToastEvent({
          message: 'Please select a proper start date',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        //  alert('Please select a proper Start Date');
        this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
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

      }
    }
    if (namecheck == 'endDate1') {
      this.endDate1 = event.detail.value;
      this.endDate = event.detail.value;
      if (this.endDate1 != null) {
        this.endDate1 = event.detail.value + ' 00:00:00';
      }
      if (day == 6 || day == 0) {
        // alert('please select working days');
        const evt = new ShowToastEvent({
          message: 'You can apply leave on working days only, please select working days.',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.endDate = this.endDate1 = this.duration = undefined;
      }
      if (this.endDate < this.startDate && this.startDate != null && this.endDate != null) {
        console.log(this.endDate <= this.startDate);
        //alert('Please select a Valid End date');
        const evt = new ShowToastEvent({
          message: 'Please select a valid end date',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
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
      if (this.availabledays >= this.duration) {
        this.submitcheck = false;
      }
      if (this.value == 'Loss of Pay' && this.annualcompduration < 0) {
        this.submitcheck = false;
      }
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

    if (this.reason == null || this.reason == '') {
      const evt = new ShowToastEvent({
        message: 'Please mention the reason for your leave request',
        variant: 'error',
      });
      this.dispatchEvent(evt);
      // alert('Please Upload Proof');// need to chane the alert message
    } else {

      if (this.isbillable == true && this.fileData == null) {
        const evt = new ShowToastEvent({
          message: 'Please submit the supporting documents',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      } else {
        this.isLoading = true;
        //step1 create fields list
        const fields = {
          'EMS_LM_Leave_Start_Date__c': this.startDate1, 'EMS_LM_Leave_End_Date__c': this.endDate1, 'EMS_LM_Leave_Duration__c': this.duration,
          'EMS_LM_Leave_Type_Name__c': this.value, 'EMS_LM_Contact__c': this.cId, 'EMS_LM_Reason__c': this.reason, 'EMS_LM_Day__c': this.fullday,
          'EMS_LM_Leave_Type__c': this.leavetypeId
        };
        //step2 create API record with above fields
        const recordData = { apiName: 'EMS_LM_Leave_History__c', fields };
        //step3 call the imperation and handle it
        createRecord(recordData).then(result => {
          this.rId = result.id;
        //  console.log('this.rId------>', JSON.stringify(result));
          if (this.fileData != null) {
            uploadFile({ base64: this.fileData.base64, filename: this.fileData.filename, recordId: this.rId }).then(res => {
            //  console.log(res);
            }).catch(error => { console.error(error.body.message); });
          }

          refreshApex(this.refleaveType, this.wiredActivities, this.refleaveduration);
          this.isLoading = false;
          this.check = false;
          const getlvalue = new CustomEvent('getlvalue', {
            detail: this.check
          });
          this.dispatchEvent(getlvalue);
          console.log('### getlvalue : ', this.check);
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Your leave request has been successfully applied!',
              variant: 'success',
            }),
          );

          const messageContext = createMessageContext();
          const payload = {
            refresh: true
          };
          publish(messageContext, MY_REFRESH_CHANNEL, payload);
          // location.reload();
        }).catch(error => {
          this.isLoading = false;
          console.log('error-->', error);
          console.log('error msg-->', error.body.pageErrors);
          this.dispatchEvent(
            new ShowToastEvent({
              message: error.body.output.errors[0].message,
              variant: 'error',
            }),
          );
        });
      }
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
    reader.readAsDataURL(file);
    this.submitcheck = false;
  }

  handleRefresh() {
    const refreshEvent = new CustomEvent('refresh', {
      bubbles: true
    });
    this.dispatchEvent(refreshEvent);
  }
  // for refresh using LMS
  subscription = null;

  connectedCallback() {
    const messageContext = createMessageContext();
    this.subscription = subscribe(messageContext, MY_REFRESH_CHANNEL, (message) => {
      this.handleRefreshMessage(message);
    });
  }

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  handleRefreshMessage(message) {
    if (message.refresh) {
       refreshApex(this.wiredActivities, this.refleaveduration, this.refleaveType);
    }
  }


}