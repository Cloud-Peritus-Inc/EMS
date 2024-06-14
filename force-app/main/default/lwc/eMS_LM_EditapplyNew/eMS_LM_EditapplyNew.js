import { LightningElement, api, track, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import getLeaveRequestMethod from '@salesforce/apex/EMS_LM_EditLeaveRequest.getLeaveRequestMethod';
import getLeaveType from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveType';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getLeaveDuration';
import getLeaveTypeId from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveTypeid';
import getbilling from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getbilling';
import getLeaveBalance from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveBalance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getwfhWFHweekends from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getwfhWFHweekends';
import LightningConfirm from "lightning/confirm";
import getContentDistributionForFile from '@salesforce/apex/GetDataForLoginUser.getContentDistributionForFile';
import getRelatedFilesByRecordIdForPayForms from '@salesforce/apex/GetDataForLoginUser.getRelatedFilesByRecordIdForPayForms';

import { createMessageContext, publish } from 'lightning/messageService';
import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';
import { subscribe, unsubscribe } from 'lightning/messageService';
import MY_REFRESH_SEC_CHANNEL from '@salesforce/messageChannel/refreshlmscomponent__c';
import { refreshApex } from '@salesforce/apex';
import updateleaveRequest from '@salesforce/apex/EMS_LM_EditLeaveRequest.updateleaveRequest';
import getAllLeavesData from '@salesforce/apex/EMS_LM_MyRequestTabLeaveReq.getAllLeavesData';
export default class EMS_LM_EditapplyNew extends LightningElement {
  @track isLoading = false;
  @track isfloatleave = false;
  @track isfloattype=false;
  @track isReasonRequired=true;
  uId = u_Id;
  @api selecteditrecordid;
  closeleavepopup;
  @track duration;
  dur = this.duration;
  @track lOptions = [];
  dOptions = [{ label: 'Full Day', value: 'Full Day' }];
  fullday;
  location;
  error;
  startDate1;//To apply Leave start date
  endDate1;//To apply Leave end date
  startDate;//To apply Leave start date
  endDate;
  @track value;
  submitcheck;//need to changed based on condition LD < ALD
  @track availabledays;
  @track allavailabledays;
  @track reason;
  daycheck;
  cId;
  todaydate;
  isbillable;
  fileuploadRequired = false;
  annualduration;
  annualcompduration;
  filecheck = true;
  fileData;
  wfhtodaydate;
  leavetypeId;
  dayhalfChange;
  firstseconday;
  hideInotherleave = false;
  hideInWorkfromHome = false;
  weekendwfh = false;
  currentAnnualleaves = 0;
  editleaveData;
  refbalanceleave;
  editedRecordData;
  fullday='FULL DAY';
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

    const messageContext = createMessageContext();
    this.subscription = subscribe(messageContext, MY_REFRESH_SEC_CHANNEL, (message) => {
      this.handleRefreshMessage(message);
    });

    //leave balance
    refreshApex(this.calculateDuration());
    this.calculateDuration();
  }

  calculateDuration() {
    getLeaveBalance({ userid: this.uId }).then((result) => {
      // console.log('### result : ', result);

      if (result) {
        // console.log('### result : ', result);
        this.allavailabledays = result;
        this.annualcompduration = result.EMS_LM_No_Of_Availble_Leaves__c + result.EMS_LM_No_Of_Available_Compensatory_Off__c + 5;
        //console.log(' caldur availabledays' + result.EMS_LM_No_Of_Availble_Leaves__c);
        this.availabledays = result.EMS_LM_No_Of_Availble_Leaves__c;

        //  console.log('this.annualduration 1122' + this.annualduration);
        this.cId = result.Id;
        this.email = result.Email;

        //smaske : updating availabledays to 0 if its "Unpaid time off"
        if ( this.value && this.value == 'UnPaid time off') {
          //console.log('###UnPaid time off 105');
          this.availabledays = 0;
        }

      } else if (result.error) {
        console.log(result.error);
        this.error = result.error;
      }
    }).catch((err) => {

    });
  }

  @wire(getLeaveType, { userid: '$uId' })
  wiredltype({ error, data }) {
    if (data) {
      console.log('leave type data-=============================->', data);
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

  @wire(getLeaveTypeId, { leavetype: '$value' })
  wireleavetype({ error, data }) {
    if (data) {
      this.leavetypeId = data.Id;
      //  console.log('type data-->', data.Id);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getbilling, { userid: '$uId' })
  wiredbilling({ error, data }) {
    if (data) {
      this.isbillable = data.EMS_TM_In_Billing__c;
      this.location = data.Work_Location__r.Country__c;
      //  console.log('this.isbillable-->', this.isbillable);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getwfhWFHweekends, { stDate: '$startDate1', edDate: '$endDate1' })
  wirewfhWFHweekends({ error, data }) {
    if (data) {
      //  console.log('wfhWFHweekends-->', data);
      this.weekendwfh = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.weekendwfh = undefined;
    }
  }

  @wire(getLeaveBalance, { userid: '$uId' })
  wirelbalance(result) {
    this.refbalanceleave = result;
    if (result.data) {
        console.log('data duration' + result.data);
      this.allavailabledays = result.data;
      //  console.log('this.allavailabledays' + JSON.stringify(this.allavailabledays));
      this.annualcompduration = result.data.EMS_LM_No_Of_Availble_Leaves__c + result.data.EMS_LM_No_Of_Available_Compensatory_Off__c;
      //  console.log(this.annualcompduration);
      this.annualduration = result.data.EMS_LM_No_Of_Availble_Leaves__c;
      //   console.log('annual duration' + this.annualduration);
      this.cId = result.data.Id;
      if (this.value == 'Annual Leave') {
        this.isfloatleave = false;
        this.availabledays = this.annualduration;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Paternity Leave') {
        this.isfloatleave = false;
        this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Paternity_Leave__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Bereavement Leave') {
        this.isfloatleave = false;
        this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Bereavement_Leave__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Maternity Leave') {
        this.isfloatleave = false;
        this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Maternity_Leave__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Compensatory Off') {
        this.isfloatleave = false;
        this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Compensatory_Off__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
        //  console.log('this.allavailabledays' + availabledays);
      }
      if (this.value == 'Marriage Leave') {
        this.isfloatleave = false;
        this.availabledays = this.allavailabledays.EMS_LM_No_of_Available_Marriage_Leave__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Floating Holiday') {
        this.isfloattype = true;
        this.hideInotherleave = false;
        this.hideInWorkfromHome = false;
        //this.availabledays = this.allavailabledays.EMS_LM_No_of_Available_Marriage_Leave__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {
          console.log('this.isfloatleave=============================================', this.isfloatleave);
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
      else {

        this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
      } 
      }

    } else if (result.error) {
      console.log(result.error);
      this.error = result.error;
    }
  }

  @wire(getLeaveRequestMethod, { getrecordId: '$selecteditrecordid' })
  wiredleaveRequest(result) {
    this.editleaveData = result;JSON.stringify(this.editleaveData)
    if (result.data) {
      console.log('resultsan-->', JSON.stringify(result.data));
      // console.log('resultsan-->', result.data.EMS_LM_Leave_Start_Date__c);
      this.startDate1 = result.data.EMS_LM_Leave_Start_Date__c;
      this.endDate1 = result.data.EMS_LM_Leave_End_Date__c;
      this.duration = result.data.EMS_LM_Leave_Duration__c;
      this.reason = result.data.EMS_LM_Reason__c;
      this.value = result.data.Leave_Type_Name__c;
      console.log('resultsan-->', JSON.stringify(this.value));
      
      this.fullday = result.data.EMS_LM_Day__c;
      /*if (this.value == 'Floating Holiday') {
        this.isfloattype = true;
        this.hideInotherleave = false;
        this.hideInWorkfromHome = false;
        //this.availabledays = this.allavailabledays.EMS_LM_No_of_Available_Marriage_Leave__c;
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {
          console.log('this.isfloatleave=============================================', this.isfloatleave);
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
      else {

        this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
      } 
      } */

      if (result.data.Leave_Type_Name__c != 'Work From Home' ) {

        //  console.log('###leave', result.data.Leave_Type_Name__c);
        this.hideInotherleave = true;
        this.hideInWorkfromHome = false;
        if (result.data.Leave_Type_Name__c == 'Floating Holiday' ){
            this.isfloattype = true;
            this.hideInotherleave = false;
            this.isReasonRequired=false;
        this.hideInWorkfromHome = false;
        }
        
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {
           console.log('OUTPUT : ',305);
          this.daycheck = false;

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          console.log('OUTPUT : ',311);
          this.daycheck = true;
          if (result.data.Leave_Type_Name__c == 'Floating Holiday' ){
            console.log('OUTPUT : ',314);
            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
          } else{
             console.log('OUTPUT : ',317);
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
          }
          
        }

        //smaske : updating availabledays to 0 if its "Unpaid time off"
        if (result.data.Leave_Type_Name__c == 'UnPaid time off') {
          //console.log('###UnPaid time off 336');
          this.availabledays = 0;
        }

      } else if (result.data.Leave_Type_Name__c == 'Work From Home') {
        console.log('###WorkFROMHOMEleave');
        this.hideInWorkfromHome = true;
        this.hideInotherleave = false;
      }

      if (result.data.EMS_LM_Day__c != 'Full Day') {
        this.daycheck = true;
        
      } else {
        console.log('OUTPUT : ',325);
        console.log('OUTPUT : 334',JSON.stringify(this.dOptions));
        this.daycheck = false;
        
      }


    } else if (result.error) {
      this.error = result.error;
      // console.log('this.error', this.error);
      this.submitcheck = true;
    }
  }




  @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', location: '$location', dayCheck: '$daycheck', value: '$value',fullday:'$fullday' })
  async wiredduration({ error, data }) {
    console.log('result.data-> Duration', data);
    console.log('this.value',this.value);
    if (data) {
      if (this.value == 'Loss of Pay' || this.value == 'Annual Leave') {
        if (this.value == 'Loss of Pay') {
          if (this.startDate != undefined || this.startDate != null) {
            this.submitcheck = false;
            this.duration = data;
          }
        }
        if (this.value == 'Annual Leave') {
          //  console.log('total -5 leaves###'+this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c+data);
          // if (this.annualduration >= data) {
          this.submitcheck = false;
          this.duration = data;
          console.log('the duration checking 326' + this.duration);
          this.currentAnnualleaves = this.availabledays + this.duration + 5;
          this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
          //  console.log('this.currentAnnualleaves-->', this.currentAnnualleaves, 'this.availabledays', this.availabledays);
          this.error = undefined;
        }
      }
      else {
        if (this.value == 'Paternity Leave') {
          this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Paternity_Leave__c;
          if (this.startDate != undefined || this.startDate != null) {
            //  console.log('this.availabledays##', this.availabledays);
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
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
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);

              this.duration = data;
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }
        }
        if (this.value == 'Bereavement Leave') {
          this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Bereavement_Leave__c;
          if (this.startDate != undefined || this.startDate != null) {
            //  console.log('this.availabledays##', this.availabledays);
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
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
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);

              this.duration = data;
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }
        }
        if (this.value == 'Maternity Leave') {
          this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Maternity_Leave__c;
          if (this.startDate != undefined || this.startDate != null) {
            //  console.log('this.availabledays##', this.availabledays);
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
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
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);

              this.duration = data;
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }
        }
        if (this.value == 'Marriage Leave') {
          this.availabledays = this.allavailabledays.EMS_LM_No_of_Available_Marriage_Leave__c;
          if (this.startDate != undefined || this.startDate != null) {
            //  console.log('this.availabledays##', this.availabledays);
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
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
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);

              this.duration = data;
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }
        }
        if (this.value == 'Compensatory Off') {
          this.isfloatleave = false;
          this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Compensatory_Off__c;
          if (this.startDate != undefined || this.startDate != null) {
            //  console.log('this.availabledays##', this.availabledays);
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
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
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {

              const evt = new ShowToastEvent({
                message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
              });
              this.dispatchEvent(evt);

              this.duration = data;
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }
          // console.log('this.allavailabledays' + this.availabledays);
        }

        //smaske : updating availabledays to 0 if its "Unpaid time off"
        if (this.value == 'UnPaid time off') {
          console.log('###UnPaid time off 588');
          this.availabledays = 0;
          this.duration = data;
        }

        /*   if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior
             if (this.startDate != undefined || this.startDate != null) {
               console.log('this.availabledays##', this.availabledays);
               if (this.availabledays >= data) {
                 this.submitcheck = false;
                 this.duration = data;
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
               if (this.availabledays >= data) {
                 this.submitcheck = false;
                 this.duration = data;
                 this.error = undefined;
               }
               else {
   
                 const evt = new ShowToastEvent({
                   message: 'Sorry! You dont have enough leave balance. Consider applying leave of some other type.',
                   variant: 'error',
                 });
                 this.dispatchEvent(evt);
   
                 this.duration = data;
                 this.duration = undefined;
                 this.error = undefined;
                 this.submitcheck = true;
               }
             }
           }*/
        else {
          // this.hideInWorkfromHome = true;
          this.duration = data;
        }
      }
    } else if (error) {
      this.error = error;
      this.duration = undefined;
      this.submitcheck = true;
    }
  }


  datechange(event) {
    var namecheck = event.target.name;
    let enteredDate = new Date(event.target.value + ' 00:00:00');
    let day = enteredDate.getDay();
    this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
    this.daycheck = false;

    if ((namecheck == 'startDate1') && (event.detail.value == '' || event.detail.value == null)) {
      this.submitcheck = true;
      const evt = new ShowToastEvent({
        message: 'Start date can not be blank',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    }
    else if ((namecheck == 'endDate1') && (event.detail.value == '' || event.detail.value == null)) {
      this.submitcheck = true;
      const evt = new ShowToastEvent({
        message: 'End date can not be blank',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    } else {

      if (namecheck == 'startDate1') {
        this.startDate1 = event.detail.value;
        this.startDate = event.detail.value;
        if (this.startDate1 != null) {
          this.startDate1 = event.detail.value + ' 00:00:00';
        }

        if (day == 6 || day == 0) {
          const evt = new ShowToastEvent({
            message: 'You can apply leave on working days only, please select working days. ',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          this.startDate = this.startDate1 = undefined;
          this.submitcheck = true;
        }

        let date = new Date(this.startDate1);
        let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
        let todaydate1 = formattedDate;
        if ((new Date(todaydate1) < new Date(this.todaydate)) && this.value == 'Work From Home') {
          this.disabledSubmitted = true;
          this.startDate1 = null;
          const evt = new ShowToastEvent({
            message: 'You have selected past date, please select future date.',
            variant: 'error',
          });
          this.dispatchEvent(evt);
        }

        if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
          if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
          }
          else {

            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
          }
        }
        if (this.endDate1 < this.startDate1.split(' ')[0] && this.startDate1 != null && this.endDate1 != null) {
          console.log('696');
          const evt = new ShowToastEvent({
            message: 'Please select a proper start date',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
          this.submitcheck = true;
        }
      }
      if (namecheck == 'endDate1') {
        this.endDate1 = event.detail.value + ' 00:00:00';
        this.endDate = event.detail.value;

        if (day == 6 || day == 0) {
          // alert('please select working days');
          const evt = new ShowToastEvent({
            message: 'You can apply leave on working days only, please select working days.',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          this.endDate = this.endDate1 = undefined;
          this.submitcheck = true;
        }
        if (this.endDate1 < this.startDate1 && this.startDate1 != null && this.endDate1 != null) {
          console.log(this.endDate <= this.startDate);
          const evt = new ShowToastEvent({
            message: 'Please select a valid end date',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
          this.submitcheck = true;
        }

        let date = new Date(this.endDate1);
        let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
        let todaydate1 = formattedDate;
        if ((new Date(todaydate1) < new Date(this.todaydate)) && this.value == 'Work From Home') {
          this.disabledSubmitted = true;
          this.endDate1 = null;
          const evt = new ShowToastEvent({
            message: 'You have selected past date, please select future date.',
            variant: 'error',
          });
          this.dispatchEvent(evt);
        }
        /* if(this.annualduration < this.duration){
           const evt = new ShowToastEvent({
               message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
               variant: 'error',
           });
           this.dispatchEvent(evt);
           this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
           this.submitcheck = true;      
         } */

        if (this.value === 'Annual Leave' || this.value === 'Loss of Pay' || this.value === 'Paid time off' || this.value === 'UnPaid time off') {

          console.log('764 start==',this.startDate1);
          console.log('765 end==',this.endDate1);
          if(this.startDate1 == this.endDate1.split(' ')[0]){
               this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];

          }else{
                    this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];

          }


         /* if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
          }
          else {
            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
          }*/
        }
      }
    }

    if (this.startDate1 != null && this.endDate1 != null) {
      this.submitcheck = false;
    }


    this.editedRecordData=JSON.parse(JSON.stringify(this.editleaveData));
    console.log(this.editedRecordData.data.EMS_LM_Leave_Start_Date__c);
  
    
    getAllLeavesData()
      .then((result) => {
        this._wiredRefreshData = result;
        this.datahistory = JSON.parse(JSON.stringify(result));
        this.datahistory.forEach(req => {
          if(req.EMS_LM_Status__c!='Cancelled' && req.EMS_LM_Status__c!='Rejected'){

            if(namecheck == 'endDate1'){
              console.log('its an end date');
            if(this.endDate1.split(' ')[0] >= this.editedRecordData.data.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] <= this.editedRecordData.data.EMS_LM_Leave_End_Date__c){
              console.log('797');             
            }else if(this.endDate1.split(' ')[0] >= this.editedRecordData.data.EMS_LM_Leave_Start_Date__c){
              console.log('799');
              if((this.editedRecordData.data.Id!=req.Id) && (this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_End_Date__c) ||
              ((this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] <= req.EMS_LM_Leave_End_Date__c)) 
               ){          
                console.log('803');    
                const evt = new ShowToastEvent({
                  message: 'Given dates are already selected please choose other days.',
                  variant: 'error',
                });
                this.dispatchEvent(evt);
                this.endDate1='';
                this.startDate1='';
                this.submitcheck = true;
              }else{
                console.log('810');
              }
            }
            else if(this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] <= req.EMS_LM_Leave_End_Date__c){
              console.log('813');
              const evt = new ShowToastEvent({
                message: 'Given dates are already selected please choose other days.',
                variant: 'error',
              });
              this.dispatchEvent(evt);
              this.submitcheck = true;
              this.startDate1='';
              this.endDate1='';
            }else if(this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_End_Date__c){
              console.log('821');
              const evt = new ShowToastEvent({
                message: 'Given dates are already selected please choose other days.',
                variant: 'error',
              });
              this.dispatchEvent(evt);
              this.submitcheck = true;
              this.startDate1='';
              this.endDate1='';
            }
          } 
             
          else if(namecheck == 'startDate1'){
            console.log('its an start date');
             if((this.startDate1.split(' ')[0] >= this.editedRecordData.data.EMS_LM_Leave_Start_Date__c && this.startDate1.split(' ')[0] <= this.editedRecordData.data.EMS_LM_Leave_End_Date__c)){
                console.log('836');
            }else if(this.startDate1.split(' ')[0] <= this.editedRecordData.data.EMS_LM_Leave_Start_Date__c){
              console.log('838');
              if((this.editedRecordData.data.Id!=req.Id) && (this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_End_Date__c) || 
              (this.startDate1.split(' ')[0] >= req.EMS_LM_Leave_Start_Date__c && this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_End_Date__c) 
              ){          
                console.log('848');    
                const evt = new ShowToastEvent({
                  message: 'Given dates are already selected please choose other days.',
                  variant: 'error',
                });
                this.dispatchEvent(evt);
                this.submitcheck = true;
                this.endDate1='';
                this.startDate1='';
              }else{
                console.log('848');
              }
            }
            else if (this.startDate1.split(' ')[0] >= req.EMS_LM_Leave_Start_Date__c && this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_End_Date__c) {
              const evt = new ShowToastEvent({
                message: 'Given dates are already selected please choose other days.',
                variant: 'error',
              });
              this.dispatchEvent(evt);
              this.submitcheck = true;
              this.startDate1='';
              this.endDate1='';
            }else if(this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_End_Date__c){
              const evt = new ShowToastEvent({
                message: 'Given dates are already selected please choose other days.',
                variant: 'error',
              });
              this.dispatchEvent(evt);
              this.submitcheck = true;
              this.startDate1='';
              this.endDate1='';
            }
          }else{this.submitcheck = false;}                          
        }
        });
      })
      .catch((error) => {
        this.error = error;
      });
    
    
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

  dayhalfChange(event) {
    this.dayhalfChange = event.detail.value;
    if (this.dayhalfChange != 'Full Day') {
      this.daycheck = true;
    }
    else {
      this.daycheck = false;
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
    this.closeleavepopup = false;
    const myEvent = new CustomEvent('closeleave', {
      detail: this.closeleavepopup
    });
    this.dispatchEvent(myEvent);
  }

  submitme() {

    if (this.weekendwfh > 1 && this.value == 'Work From Home') {
      const evt = new ShowToastEvent({
        message: 'Please apply Work from Home for same week',
        variant: 'error',
      });
      this.dispatchEvent(evt);

    } else {

      if ((this.reason == null || this.reason == '') && this.duration > 3 && this.value == 'Work From Home') {
        const evt = new ShowToastEvent({
          message: 'Please mention the reason for your leave request',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      } else {

        if ((this.reason == null || this.reason == '') && this.value != 'Work From Home' && this.value != 'Floating Holiday') {
          const evt = new ShowToastEvent({
            message: 'Please mention the reason for your leave request',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          // alert('Please Upload Proof');// need to chane the alert message
        } else   if (this.value == 'Floating Holiday') {
          /*if ((this.reason == null || this.reason == '')) {
            const evt = new ShowToastEvent({
              message: 'Please mention the reason for your leave request',
              variant: 'error',
            });
            this.dispatchEvent(evt);
          } */
          if (this.duration > 1) {
            const evt = new ShowToastEvent({
              message: 'Floating leave duration cannot be more than one day.',
              variant: 'error',
            });
            this.dispatchEvent(evt);
          }
          if (this.duration == 1) {
            this.updateleaveRequestHandler();
          }
          
        } else {
          this.updateleaveRequestHandler();
        }
      }
    }
  }

  handleDownloadFile(e) {
    getContentDistributionForFile({
      contentDocumentId: e.target.dataset.id
    })
      .then(response => {
        //console.log('Disturbution----' + JSON.stringify(response));
        window.open(response.ContentDownloadUrl);
      })
      .catch(error => {
        console.log(JSON.stringify(error));
      })
  }

  @track documents;
  @wire(getRelatedFilesByRecordIdForPayForms, { recordId: '$selecteditrecordid' })
  wiredResult({ data, error }) {
    if (data) {
      this.documents = data;
    }
    if (error) {
      console.log(error)
    }
  }

  // // for refresh using LMS
  subscription = null;

  disconnectedCallback() {
    unsubscribe(this.subscription);
    this.subscription = null;
    refreshApex(this.refbalanceleave);
  }

  handleRefreshMessage(message) {
    if (message.refresh) {
      refreshApex(this.refbalanceleave);
    }
  }

  updateleaveRequestHandler() {
    
    this.isLoading = true;
    let guestObj = { 'sobjectType': 'EMS_LM_Leave_History__c' };

    guestObj.EMS_LM_Leave_Start_Date__c = this.startDate;
    guestObj.EMS_LM_Leave_End_Date__c = this.endDate;
    guestObj.EMS_LM_Reason__c = this.reason;
    console.log("Checking the Value  :: " + this.value);
    guestObj.EMS_LM_Leave_Type_Name__c = this.value;
    guestObj.EMS_LM_Day__c = this.fullday;
    guestObj.EMS_LM_Leave_Duration__c = this.dur;
    console.log(' guestObj.EMS_LM_Leave_Type_Name__c ------------------------------------------------', guestObj.EMS_LM_Leave_Type_Name__c);
    console.log('EMS_LM_Leave_Duration__c$$$$$$$$', guestObj.EMS_LM_Leave_Duration__c);
    console.log('guestObj', guestObj);

    updateleaveRequest({ newRecord: guestObj, recordId: this.selecteditrecordid })
      .then(result => {
        //  console.log('sdf-->', result);
        this.isLoading = false;
        const event = new ShowToastEvent({
          message: 'Your request has been updated successfully!',
          variant: 'success'

        });
        this.dispatchEvent(event);
        refreshApex(this.editleaveData, this.refbalanceleave);
        const myEvent = new CustomEvent('closeleave', {
          detail: this.closeleavepopup
        });
        this.dispatchEvent(myEvent);
        // window.location.reload();
        const messageContext = createMessageContext();
        const payload = {
          refresh: true
        };
        publish(messageContext, MY_REFRESH_CHANNEL, payload);
      })
      .catch(error => {
        this.isLoading = false;
        this.error = error;
        console.log('error-->', error);
        console.log('this.error-->' + JSON.stringify(this.error));
        console.log('error-->', error.body.pageErrors[0].message);
        this.dispatchEvent(
          new ShowToastEvent({
            message: error.body.pageErrors[0].message,
            variant: 'error',
          }),
        );
      });

  }

}