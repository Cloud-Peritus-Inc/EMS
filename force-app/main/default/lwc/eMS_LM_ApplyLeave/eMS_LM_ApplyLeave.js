import { api, LightningElement, track, wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLeaveType from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveType';
import getExperienceOfUser from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getExperienceOfUser';
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
import getAllLeavesData from '@salesforce/apex/EMS_LM_MyRequestTabLeaveReq.getAllLeavesData';


export default class EMS_LM_ApplyLeave extends LightningElement {
  @track isLoading = false;
  @track isfloattype = false;
  check;
  uId = u_Id;
  Location;
  @track duration;
  @track lOptions = [];
  @track floatleaves;
  error;
  dOptions = [{ label: 'Full Day', value: 'Full Day' }];//{label: 'a', value: 1}, {label: 'b', value: 2}
  fullday = 'Full Day';
  startDate1;//To apply Leave start date
  endDate1;//To apply Leave end date
  startDate;//To apply Leave start date
  endDate;
  value = '';
  fullday='FULL DAY';
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
  @track isUsContractEmployee = false;
  userexperienceinmonths;
  @track ismandatory = false;
  _wiredRefreshData;


  @wire(getbilling, { userid: '$uId' })
  wiredbilling({ error, data }) {
    if (data) {
      this.isbillable = data.EMS_TM_In_Billing__c;
      this.Location = data.Work_Location__r.Country__c;
      if (this.Location == 'United States of America' && data.EMS_Employee_Type__c == 'Contract') {
        this.isUsContractEmployee = true;
      }
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }
  @wire(getExperienceOfUser, { userId: '$uId' })
  wiredbilling1({ error, data }) {
    if (data) {
      this.userexperienceinmonths = data;
      console.log('the user experience in months based on starting date' + this.userexperienceinmonths);

    } else if (error) {
      this.error = error;
    }
  }



  @wire(getLeaveType, { userid: '$uId', annualavailable: '$annualduration' }) wiredltype(result) {
    this.refleaveType = result;
    if (result.data) {
      console.log('leave type data-->', JSON.stringify(result.data));
      if (this.isUsContractEmployee == false) {
        this.lOptions = result.data.map((record) => ({
          value: record,
          label: record
        }));
      } else {
        this.lOptions = [{ label: 'UnPaid time off', value: 'UnPaid time off' }]
      }
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
      console.log('type data-->', data.Id);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', location: '$Location', dayCheck: '$daycheck', value: '$value',fullday:'$fullday'})
  async wiredduration(result) {
    this.refleaveduration = result;
    console.log('result.data-> Duration', result.data);
    if (result.data != null) { //result.data
      console.log("INSIDE RESULT DATA");
      if (this.value == 'Loss of Pay' || this.value == 'Annual Leave' || this.value == 'Paid time off' || this.value == 'Floating Holiday' || this.value == 'UnPaid time off') {
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
        if (this.value == 'UnPaid time off') {
          console.log("INSIDE UnPaid time off");
          console.log("INSIDE result.data " + result.data);
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
              //this.submitcheck = false;
              this.duration = result.data;
            }

          }
          /* if(this.reason==null || this.reason =='' || this.reason == undefined){
                 this.submitcheck = true;
           }*/


        }
        if (this.value == 'Paid time off') {
          this.duration = result.data;
          //SHUBHAM
          this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c - this.duration;
          //SHUBHAM
          if (this.duration > 30) {
            this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
            this.duration = null;
            console.log('agter 144 ***' + this.submitcheck);
            const evt = new ShowToastEvent({
              message: 'Sorry !! You cannot take more than 30 days leave ',
              variant: 'warning',
              mode: 'sticky',
            });
            this.dispatchEvent(evt);
            this.submitcheck = true;
            console.log('agter 152 ***' + this.submitcheck);
            // return; 
          } else {
            this.submitcheck = false;
            console.log('agter 156 ***' + this.submitcheck);
          }
        }
        if (this.value == 'Floating Holiday') {
          this.isfloattype = true;
          this.ismandatory = true;
          this.duration = result.data;
          this.submitcheck = false;
        }
        if (this.value == 'Annual Leave') {
          console.log("INSIDE Annual Leave");
          console.log("USER EXPERIENCE : " + this.userexperienceinmonths);
          console.log(" annualduration " + this.annualduration);
          if (this.annualduration >= result.data) {
            this.submitcheck = false;
            this.duration = result.data;
            //SHUBHAM :
            this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c - this.duration;
            //SHUBHAM:

            this.error = undefined;
          }
          else {
            console.log("ELSE 207");
            const results = await LightningConfirm.open({
              message: "To apply this leave, you have to avail additional leaves from next quarter. You can take a leave loan upto 5 days.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });
            console.log("results " + results);
            if (results) {
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 5;
              if (this.availabledays >= result.data || (this.availabledays >= 0.5 && result.data == 1)) {
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

        if (this.value == 'Paid time off' && this.userexperienceinmonths < 24) {
          if (this.annualduration >= result.data) {
            console.log('the value is diretion 219 ***');
            this.duration = result.data;
            if (this.duration > 30) {
              this.submitcheck = true;
              console.log('the value is diretion 216 ***' + this.submitcheck);
            } else {
              this.submitcheck = false;
              console.log('the value is diretion 216 ***' + this.submitcheck);
            }
            this.duration = result.data;

            this.error = undefined;
          }
          else {
            const results = await LightningConfirm.open({
              //smaske : updated 3.5 days ---> 3 days
              message: "To apply this leave, you have to avail additional leaves from next quarter. You can take a leave loan upto 3 days.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });
            if (results) {
              //smaske : updated 3.5 ---> 3
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 3;
              console.log('this.availabledays', this.availabledays);
              if (this.availabledays >= result.data || (this.availabledays >= 0.5 && result.data == 1)) {
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
        else if (this.value == 'Paid time off' && this.userexperienceinmonths >= 24) {
          if (this.annualduration >= result.data) {
            console.log('the value is duretion **n270 ')
            this.duration = result.data;
            if (this.duration > 30) {
              this.submitcheck = true;
            } else {
              this.submitcheck = false;
            }
            this.duration = result.data;
            this.error = undefined;
          }
          else {
            const results = await LightningConfirm.open({
              message: "To apply this leave, you have to avail additional leaves from next quarter. You can take a leave loan upto 3.75 days.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });
            if (results) {
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 3.75;
              console.log('this.availabledays', this.availabledays);
              if (this.availabledays >= result.data || (this.availabledays >= 0.5 && result.data == 1)) {
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
      this.floatleaves = result.data.UtlizedFloatLeaves__c;
      console.log('this. this.floatleaves=======================================================================', this.floatleaves);
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
    console.log('Selected Leave type ==>>> ' + this.value);
    if (this.value === 'Annual Leave' || this.value === 'Loss of Pay' || this.value === 'Paid time off' || this.value === 'UnPaid time off' || this.value === 'Floating Holiday') {
      //this.calculateDuration();
      // if(this.value == 'Floating Holiday'){
      //   this.ismandatory=True;
      // }
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
      this.fileuploadRequired = true;
    }
    if (this.value == 'Paid time off') {
      // refreshApex(this.allavailabledays);
      this.visiableotherdetail = true;
      this.isfloattype = false;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
      this.fileuploadRequired = true;
      //  console.log('anna  this.availabledays' + this.availabledays);
      /*if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      } */
    }
    if (this.value == 'Floating Holiday') {
      this.isfloattype = true;
      this.fileuploadRequired = false;
      /*  if(this.floatleaves >1){
          const evt = new ShowToastEvent({
          message: 'you dont have float type leave ****************** ',
          variant: 'warning',
        });
        this.dispatchEvent(evt);
       } 
       if(this.floatleaves >1){
         const results = await LightningConfirm.open({
              message: " You don't have any float leaves.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "float leaves"
            });
            if (results){
              this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
              this.visiableotherdetail = false;
            }
       }
       */
      // refreshApex(this.allavailabledays);
      // this.visiableotherdetail = true;
      //this.ismandatory=true;
      // this.submitcheck = true;
    }
    if (this.value == 'Paternity Leave') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Paternity_Leave__c;
      this.fileuploadRequired = true;
      /* if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      } */

    }
    if (this.value == 'Bereavement Leave') {
      this.visiableotherdetail = true;

      this.availabledays = this.allavailabledays.EMS_LM_No_Of_Available_Bereavement_Leave__c;
      this.fileuploadRequired = true;
      /* if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      } */

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
      this.fileuploadRequired = true;
      /* if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      } */

    }
    if (this.value == 'Loss of Pay') {
      this.visiableotherdetail = true;
      this.fileuploadRequired = true;
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
      /*if (this.isbillable == true) {
        this.fileuploadRequired = true;
      } else {
        this.fileuploadRequired = false;
      } */

    }

    //UnPaid time off
    if (this.value == 'UnPaid time off') {
      this.visiableotherdetail = true;
      this.isfloattype = false;
      this.fileuploadRequired = true;
      if (this.annualcompduration > 0) {
        //  console.log(this.annualcompduration);
        this.submitcheck = true;
        const evt = new ShowToastEvent({
          message: 'UnPaid time off will effect your monthly pay check, consider applying leave of annual or comp off type. ',
          variant: 'warning',
        });
        this.dispatchEvent(evt);
        //alert('Please Utilise Your Leaves(Annual / Comp Off) before applying for Loss Of Pay');
      }
      this.availabledays = 0;
      /* if (this.isbillable == true) {
         this.fileuploadRequired = true;
       } else {
         this.fileuploadRequired = false;
       } */

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
    }
    else {

      if (namecheck == 'startDate1') {
        console.log(" ### Start Date :: " + event.detail.value);
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
        /*const selectedDate = new Date(this.startDate);
        console.log('the selecteddate is ' + selectedDate);
        const today = new Date();
        console.log('the today is ' + today);
        const lastMonthStartDate = new Date(today.getFullYear(), today.getMonth() - 1, 1);
        console.log('the lastMonthStartDate is ' + lastMonthStartDate); */
        if (this.endDate < this.startDate && this.endDate != null &&  this.startDate != null /* && selectedDate < lastMonthStartDate */) {
          const evt = new ShowToastEvent({
            message: 'Please select a proper start date',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = '';
        }
        if (this.value === 'Annual Leave' || this.value === 'Loss of Pay' || this.value === 'Paid time off' || this.value === 'UnPaid time off') {
          if (this.startDate != this.endDate || this.startDate == undefined || this.endDate == undefined) {

            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
          }
          else {
            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
          }
        }
        if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior

        }
        if (this.value === 'Floating Holiday') {
          console.log('if floating value is  strting date ***======:-' + this.startDate1)
          console.log('if floating value is   end date &&&&&&====:-' + this.endDate1)
          const today = new Date();
          const selectedStartDate = new Date(this.startDate1);
          console.log('selectedStartDate================', selectedStartDate);
          //const selectedEndDate = new Date(this.endDate);
          if (selectedStartDate.getFullYear() > today.getFullYear()) {
            const evt2 = new ShowToastEvent({
              message: 'You can not take this leave for next year ,should utulize this year only ',
              variant: 'error',
            });
            this.dispatchEvent(evt2);
            this.startDate = this.startDate1 = '';

          }
          if (this.startDate == undefined || this.startDate1 == undefined || this.startDate1 == null || this.startDate == null || this.startDate1 == '') {
            this.endDate = undefined;
            this.endDate1 = undefined;
            this.endDate1 = ' ';
            /*
               const today = new Date();
              const selectedStartDate = new Date(this.startDate1);
              console.log('selectedStartDate================',selectedStartDate);
              //const selectedEndDate = new Date(this.endDate);
              if(selectedStartDate.getFullYear() !== today.getFullYear()){
                 const evt2 = new ShowToastEvent({
                message: 'You can not take this leave for next year ,should utulize this year only ',
                variant: 'error',
              });
              this.dispatchEvent(evt2);
              this.startDate = this.startDate1 = this.duration = undefined;
      
              } */
          }

        }
      }
      if (namecheck == 'endDate1') {
        console.log(" ### End Date :: " + event.detail.value);
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
        if (this.value === 'Floating Holiday') {
          if (this.endDate != this.startDate) {
            //this.endDate1=undefined;
            this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
            this.endDate1 = '';
            const evt = new ShowToastEvent({
              message: 'Floating Holidays are restricted to one day only, to avail leave for more than a day, consider other leave types.',
              variant: 'error',
            });
            this.dispatchEvent(evt);

          }
          /* else {
            const today = new Date();
          const selectedStartDate = new Date(this.startDate1);
          const selectedendDate = new Date(this.endDate1);
          //const selectedEndDate = new Date(this.endDate);
          console.log('the end date year'+selectedStartDate.getFullYear());
          if((selectedStartDate.getFullYear() !== today.getFullYear() || selectedendDate.getFullYear() !== today.getFullYear()) && selectedendDate != '' ){
             const evt2 = new ShowToastEvent({
            message: 'You can not take this leave for next year ,should utulize this year only ',
            variant: 'error',
          });
          this.dispatchEvent(evt2);
          this.startDate = this.startDate1 = this.duration = this.endDate = this.endDate1 ='';
  
          }
          }   */
        }
        /*if(this.value== 'UnPaid time off'){
        if(this.reason == null || this.reason == ' ' || this.reason == undefined){
            const evt = new ShowToastEvent({
          message: 'Please mention the reason for your leave request',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.submitcheck =true;
        //this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;
        console.log('the submit check ======775=====',this.submitcheck)
        //this.duration='';
        }else{
          this.submitcheck =false;
          console.log('the submit check ======779=====',this.submitcheck)
        }
    }*/
        if (this.value === 'Annual Leave' || this.value === 'Loss of Pay' || this.value === 'Paid time off' || this.value === 'UnPaid time off') {
          if (this.startDate != this.endDate || this.startDate == undefined || this.endDate == undefined) {
            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
          }

          else {

            this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
          }
          /* if(this.value==='Floating Holiday'){
            if(this.endDate != this.startDate ){
              //this.duration=result.data;
             console.log('TESTING===================================================================================================');
                      }
          } */
        }
      }

    }
     console.log('851');
     console.log(this.startDate1);
     console.log(this.endDate1);
    getAllLeavesData()
      .then((result) => {
        this._wiredRefreshData = result;
        this.datahistory = JSON.parse(JSON.stringify(result));
        this.datahistory.forEach(req => {
          if(req.EMS_LM_Status__c!='Cancelled' && req.EMS_LM_Status__c!='Rejected'){
          if ( (this.startDate1.split(' ')[0] >= req.EMS_LM_Leave_Start_Date__c && this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_End_Date__c) ||
               (this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] <= req.EMS_LM_Leave_End_Date__c) ||
               (this.startDate1.split(' ')[0] <= req.EMS_LM_Leave_Start_Date__c && this.endDate1.split(' ')[0] >= req.EMS_LM_Leave_End_Date__c)) {
            const evt = new ShowToastEvent({
              message: 'Given dates are already selected please choose other days.',
              variant: 'error',
            });
            this.dispatchEvent(evt);
            this.startDate1='';
            this.endDate1='';
          }
        }
        });
      })
      .catch((error) => {
        this.error = error;
      });
  }

    
  //TO SHOW DEFAULT DATA
 /* @wire(getAllLeavesData)
  getAllLeavesDataWiredData(wireResult) {
       const { data, error } = wireResult;
       this._wiredRefreshData = wireResult;
       if (data) {
           if (data.length > 0) {
             console.log('127');
             console.log(this.startDate1);
               console.log('### getAllLeavesData', data);
               //this.showdata = true;
               //this.nodata = false;
               //this.datahistory = data;
               this.datahistory = JSON.parse(JSON.stringify(data));
               console.log('### datahistory', this.datahistory);
               this.datahistory.forEach(req => {
                 console.log('135');
                 console.log(req.EMS_LM_Leave_End_Date__c);
                 console.log(req.EMS_LM_Leave_Start_Date__c);
                  // req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 Pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Auto_Approve__c != true && req.EMS_LM_Status__c !== 'Auto Approved';
               });
               console.log('### getAllLeavesDatadatahistory: ', this.datahistory);
           } else {
               //this.nodata = true
           }
       } else if (error) {
           console.error('Error:', error);
       }
   } */


  reasonChange(event) {
    this.reason = event.detail.value;
    console.log('the value od the  reason is:-' + this.reason);
    if (this.reason != null) {
      if (this.availabledays >= this.duration) {
        this.submitcheck = false;
      }
      if (this.value == 'Loss of Pay' && this.annualcompduration < 0) {
        this.submitcheck = false;
      }
    }
    if (this.value == 'UnPaid time off') {
      if (this.reason == null || this.reason == undefined || this.reason == '') {
        this.submitcheck = true;
      } else {
        this.submitcheck = false;
      }
    }

  }

  /* handelSubmitDisable() {
    if(this.endDate1 != null && this.startDate1 !=null && this.reason != null && this.duration != null) {
      this.submitcheck = false;
    }
  } */

  closeme() {
    this.check = false;
    this.check2 = false;
    const getlvalue = new CustomEvent('getlvalue', {
      detail: this.check
    });
    this.dispatchEvent(getlvalue);
  }


  submitme(event) {
    console.log('my leaves types=================================', this.value);
    /*if (this.value == 'Floating Holiday') {
      //this.ismandatory = true;
      this.isfloattype = true;
      this.fileuploadRequired = false;
      console.log('=======1=========' + this.isfloattype)
    } else {
      this.ismandatory = false;
      console.log('=========2=======' + this.isfloattype)
    } */

    //if(this.ismandatory=false){
    console.log('*********==========' + this.isfloattype);
   // if (this.value != 'Floating Holiday') {
      console.log(917);
      console.log('OUTPUT :904 ',this.reason);
      if (this.value !=='Floating Holiday' && (this.reason == null || this.reason == '')) {
        console.log('OUTPUT :904 ',this.reason);
        console.log('OUTPUT : 905');
        const evt = new ShowToastEvent({
          message: 'Please mention the reason for your leave request',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      }
     
     else {
      console.log(927);
      if ( this.value !=='Floating Holiday' &&  (this.isbillable == true && this.fileData == null )) {
        const evt = new ShowToastEvent({
          message: 'Please submit the supporting documents',
          variant: 'error',
        });
        this.dispatchEvent(evt); 
      } else { 
      if (this.availabledays < 0 && this.fullday == 'Full Day' && this.value != 'Loss of Pay' && this.value != 'UnPaid time off') {
        const evt = new ShowToastEvent({
          message: "Sorry! You don't have enough leave balance. Consider applying for Half a Day or Loss of Pay leave.",
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
        console.log(951);
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

          setTimeout(function(){
            window.location.reload(1);
               }, 3000);

          const messageContext = createMessageContext();
          const payload = {
            refresh: true
          };
          publish(messageContext, MY_REFRESH_CHANNEL, payload);
          // location.reload();
        }).catch(error => {
          this.isLoading = false;
          if (this.value == 'Floating Holiday') {
            this.isfloattype = true;
            this.startDate = this.startDate1 = this.endDate = this.endDate1 = '';
          }
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
  
  }


  dayChange(event) {
    console.log('$$ dayChange ' + event.detail.value);
    this.fullday = event.detail.value;
    if (this.fullday != 'Full Day') {
      this.daycheck = true;
    }
    else {
      this.daycheck = false;
    }
  }
  openfileUpload(event) {
    if (event.target.files.length > 0 && event.target.files[0].size < 2000000) {
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
      if (this.startDate1 && this.endDate1 && this.reason) {
        this.submitcheck = false;
      } else {
        this.submitcheck = true;
      }
    }
    else {
      const even = new ShowToastEvent({
        message: 'The maximum file size is 2MB.',
        variant: 'error'
      });
      this.dispatchEvent(even);
    }

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
      console.log('message==================================================', message);
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