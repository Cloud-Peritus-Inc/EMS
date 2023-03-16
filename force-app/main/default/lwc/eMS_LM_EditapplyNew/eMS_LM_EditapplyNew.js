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

import updateleaveRequest from '@salesforce/apex/EMS_LM_EditLeaveRequest.updateleaveRequest';
export default class EMS_LM_EditapplyNew extends LightningElement {
  @track isLoading = false;
  uId = u_Id;
  @api selecteditrecordid;
  closeleavepopup;
  duration;
  @track lOptions = [];
  dOptions = [{ label: 'Full Day', value: 'Full Day' }];
  halfOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
  fullday;
  location;
  error;
  startDate1;//To apply Leave start date
  endDate1;//To apply Leave end date
  startDate;//To apply Leave start date
  endDate;
  value;
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
  firstsecondDay = false;
  dayhalfChange;
  firstseconday;
  hideInotherleave = false;
  hideInWorkfromHome = false;
  weekendwfh = false;
  currentAnnualleaves = 0;

  @wire(getLeaveType, { userid: '$uId' })
  wiredltype({ error, data }) {
    if (data) {
      console.log('leave type data-->', data);
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
      console.log('type data-->', data.Id);
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
      console.log('this.isbillable-->', this.isbillable);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getwfhWFHweekends, { stDate: '$startDate1', edDate: '$endDate1' })
  wirewfhWFHweekends({ error, data }) {
    if (data) {
      console.log('wfhWFHweekends-->', data);
      this.weekendwfh = data;
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.weekendwfh = undefined;
    }
  }

  @wire(getLeaveBalance, { userid: '$uId' })
  wirelbalance({ error, data }) {
    if (data) {
      console.log('data duration' + data);
      this.allavailabledays = data;
      this.annualcompduration = data.EMS_LM_No_Of_Availble_Leaves__c + data.EMS_LM_No_Of_Available_Compensatory_Off__c;
      console.log(this.annualcompduration);
      this.annualduration = data.EMS_LM_No_Of_Availble_Leaves__c;
      console.log('annual duration' + this.annualduration);
      this.cId = data.Id;
      if (this.value == 'Annual Leave') {
        this.availabledays = this.annualduration;
      }
    } else if (error) {
      console.log(error);
      this.error = error;
    }
  }

@wire(getLeaveRequestMethod, { getrecordId: '$selecteditrecordid' })
wiredleaveRequest({ error, data }) {
    if (data) {
      console.log('resultsan-->', data);
       console.log('resultsan-->', data.EMS_LM_Leave_Start_Date__c);
      
       
        this.startDate1 = data.EMS_LM_Leave_Start_Date__c;
        this.endDate1 = data.EMS_LM_Leave_End_Date__c;
        this.duration = data.EMS_LM_Leave_Duration__c;
        this.reason = data.EMS_LM_Reason__c;
        this.value = data.EMS_LM_Leave_Type_Name__c;
        this.fullday = data.EMS_LM_Day__c;

        if(this.value!='Work From Home'){
          this.hideInotherleave=true;
        }else{
          this.hideInWorkfromHome=true;
        }
        
        if (data.EMS_LM_Day__c == 'Full Day') {
          this.daycheck = false;
          this.firstsecondDay = true;
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
          console.log('this.daycheck',this.daycheck,'this.fullday',this.fullday);
        }
        else {
          this.daycheck = true;
          this.firstsecondDay = false; 
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];  
          console.log('this.daycheck',this.daycheck,'this.fullday',this.fullday);
        }
    }else if (error) {
      this.error = error;
      console.log('this.error',this.error);
      this.submitcheck = true;
    }
    }


  

 @wire(getLeaveDuration, { stDate: '$startDate1', edDate: '$endDate1', location: '$location', dayCheck: '$daycheck' })
  async wiredduration({ error, data }) {
    if (data) {
      if (this.value == 'Loss of Pay' || this.value == 'Annual Leave') {
        if (this.value == 'Loss of Pay') {
          if (this.startDate != undefined || this.startDate != null) {
             this.submitcheck =false;
             this.duration = data;      
          }
        }
        if (this.value == 'Annual Leave') {
         // if (this.annualduration >= data) {
            this.submitcheck = false;
            this.duration = data;
            this.currentAnnualleaves=this.duration + this.annualduration;
            this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
            console.log('this.currentAnnualleaves-->',this.currentAnnualleaves,'this.availabledays',this.availabledays);
            this.error = undefined;
      //    }
        //  else {
           /* const result = await LightningConfirm.open({
              message: "To apply this leave, you have to avail additional leaves from next quarter. You can take a leave loan upto 5 days.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });*/
            if (result) {
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 5;
              if (this.availabledays >= data) {
                this.submitcheck = false;
                this.duration = data;
                this.error = undefined;
              }
              else {
              /*  this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
                const evt = new ShowToastEvent({
                message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
                });
                  this.dispatchEvent(evt);
               // alert('You dont have enough balance to apply leave');
                this.duration = undefined;
                this.error = undefined;
                this.submitcheck = true;
                this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;*/
              }
            }
            else {
            //  this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
           //   this.duration = undefined;
           //   this.error = undefined;
           //   this.submitcheck = true;
           //   this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c;
            }
         // }
        }
      }
      else {
        if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior
          if (this.startDate != undefined || this.startDate != null) {
 
              if(this.availabledays >= data){
                this.submitcheck = false;
                this.duration = data;
              } 
              else{
                
                const evt = new ShowToastEvent({
                message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
                });
                this.dispatchEvent(evt);
                this.submitcheck = true;
              }             
             
          }
          else{
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {
              
               const evt = new ShowToastEvent({
                message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
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
        else{
          this.hideInWorkfromHome = true;
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
        this.submitcheck=true;
      }
      if (this.endDate1 < this.startDate1 && this.startDate1 != null && this.endDate1 != null) {
        const evt = new ShowToastEvent({
          message: 'Please select a proper start date',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.startDate = this.startDate1 = this.endDate = this.endDate1 =this.duration= undefined;
        this.submitcheck=true;
      }
      if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {

          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }

    }
    if (namecheck == 'endDate1') {
      this.endDate1 = event.detail.value + ' 00:00:00';
      this.endDate = event.detail.value;

      if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (day == 6 || day == 0) {
        // alert('please select working days');
        const evt = new ShowToastEvent({
          message: 'You can apply leave on working days only, please select working days.',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.endDate = this.endDate1 = undefined;
        this.submitcheck=true;
      }
      if (this.endDate1 < this.startDate1 && this.startDate1 != null && this.endDate1 != null) {
        console.log(this.endDate <= this.startDate);
        const evt = new ShowToastEvent({
          message: 'Please select a valid end date',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.startDate = this.startDate1 = this.endDate = this.endDate1 =this.duration= undefined;
        this.submitcheck=true;
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
    }
    if (this.startDate1 != null && this.endDate1 != null) {
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
          message: 'Please mention the reason for your request',
          variant: 'error',
        });
        this.dispatchEvent(evt);
      } else {

        if ((this.reason == null || this.reason == '') && this.value != 'Work From Home') {
          const evt = new ShowToastEvent({
            message: 'Please mention the reason for your leave request',
            variant: 'error',
          });
          this.dispatchEvent(evt);
          // alert('Please Upload Proof');// need to chane the alert message
        } else {
          this.isLoading = true;
          let guestObj = { 'sobjectType': 'EMS_LM_Leave_History__c' };

          guestObj.EMS_LM_Leave_Start_Date__c = this.startDate;
          guestObj.EMS_LM_Leave_End_Date__c = this.endDate;
          guestObj.EMS_LM_Reason__c = this.reason;
          guestObj.EMS_LM_Leave_Type_Name__c = this.value;
          guestObj.EMS_LM_Day__c = this.fullday;
          guestObj.EMS_LM_Leave_Duration__c = this.duration;


          console.log('guestObj', guestObj);

          updateleaveRequest({ newRecord: guestObj, recordId: this.selecteditrecordid })
            .then(result => {
              console.log('sdf-->', result);
              this.isLoading = false;
              const event = new ShowToastEvent({
                message: 'Your request has been updated successfully!',
                variant: 'success'

              });
              this.dispatchEvent(event);
              const myEvent = new CustomEvent('closeleave', {
                detail: this.closeleavepopup
              });
              this.dispatchEvent(myEvent);
              window.location.reload();
            })
            .catch(error => {
              this.isLoading = false;
              this.error = error;
              console.log('error-->', error);
              console.log('this.error-->' + JSON.stringify(this.error));
              console.log('error-->', error.body.pageErrors[0].message.substring(200, 250));
              
              this.dispatchEvent(
                new ShowToastEvent({
                    message: error.body.pageErrors[0].message.substring(197, 282),  
                    variant: 'error',
                }),
            );
            });
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

}