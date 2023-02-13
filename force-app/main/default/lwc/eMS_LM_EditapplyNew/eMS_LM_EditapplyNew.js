import { LightningElement,api,track,wire } from 'lwc';
import u_Id from '@salesforce/user/Id';
import getLeaveRequestMethod from '@salesforce/apex/EMS_LM_EditLeaveRequest.getLeaveRequestMethod';
import getLeaveType from '@salesforce/apex/EMS_LM_EditLeaveRequest.getLeaveType';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getLeaveDuration';
import getLeaveTypeId from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveTypeid';
import getLocation from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLocation';
import getLeaveBalance from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getLeaveBalance';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import updateleaveRequest from '@salesforce/apex/EMS_LM_EditLeaveRequest.updateleaveRequest';
export default class EMS_LM_EditapplyNew extends LightningElement {

uId = u_Id;
@api selecteditrecordid;
closeleavepopup;
duration;
@track lOptions = [];
dOptions = [{ label: 'Full Day', value: 'Full Day' }];
halfOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
fullday;
Location;
error; 
startDate1;//To apply Leave start date
endDate1;//To apply Leave end date
startDate;//To apply Leave start date
endDate;
value;
submitcheck = true;//need to changed based on condition LD < ALD
@track availabledays;
@track allavailabledays;
@track reason;
daycheck = false;
cId;
Email;
todaydate;
isbillable;
fileuploadRequired=false;
annualduration;
annualcompduration;
filecheck = true;
fileData;
wfhtodaydate;
leavetypeId;
firstsecondDay;
dayhalfChange;
firstseconday;

@wire(getLeaveType, { userid: '$uId' })
  wiredltype({ error, data }) {
    if (data) {
      console.log('leave type data-->',data);
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

   @wire(getLeaveTypeId, {leavetype: '$value'})
  wireleavetype({ error, data }) {
    if (data) {
      this.leavetypeId=data.Id;
     console.log('type data-->',data.Id);
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getLocation, { userid: '$uId' })
  wiredlocation({ error, data }) {
    if (data) {
      this.Location = data.Location__c;
      this.isbillable=data.EMS_TM_Billable__c;
      console.log('this.isbillable-->',this.isbillable,'this.Location-->',this.Location);
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
                   
             /* const evt = new ShowToastEvent({
              message: 'Leave to be applied before 48Hrs',
              variant: 'error',
              });
              this.dispatchEvent(evt);*/
              //this.submitcheck = true;
              //alert('Leave to be applied before 48Hrs');
            }
            else{
             this.submitcheck =false;
             this.duration = data;
            }
          }
        }
        if (this.value == 'Annual Leave') {
          if (this.annualduration >= data) {
            this.submitcheck = false;
            this.duration = data;
            this.error = undefined;
          }
          else {
            const result = await LightningConfirm.open({
              message: "To apply this leave, you have to avail additional leaves from next quarter. You can take a leave loan upto 5 days.",
              variant: "default", // headerless
              theme: 'error', // more would be success, info, warning
              label: "Avail Advance Annual Leaves"
            });
            if (result) {
              this.availabledays = this.allavailabledays.EMS_LM_No_Of_Availble_Leaves__c + 5;
              if (this.availabledays >= data) {
                this.submitcheck = false;
                this.duration = data;
                this.error = undefined;
              }
              else {
                this.startDate = this.startDate1 = this.endDate = this.endDate1 = undefined;
                const evt = new ShowToastEvent({
                message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
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
              const evt = new ShowToastEvent({
                message: 'Sorry !! You dont have enough leave balance. Consider applying leave of some other type.',
                variant: 'error',
                });
                  this.dispatchEvent(evt);
              //alert('You dont have enough balance to apply leave');
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
            let date = new Date(this.startDate);
            let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate1 = formattedDate;
            if (new Date(todaydate1) < new Date(this.todaydate)) {
              
            /*  const evt = new ShowToastEvent({
              message: 'Leave to be applied before 48Hrs',
              variant: 'error',
              });
              this.dispatchEvent(evt);*/
             // this.submitcheck = true;
              //alert('Leave to be applied before 48Hrs');
            }
            else{
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
               // alert('You dont have enough balance to apply leave');
              }             
             }
          }
          else{
            if (this.availabledays >= data) {
              this.submitcheck = false;
              this.duration = data;
              this.error = undefined;
            }
            else {
              this.duration = data;
              alert('Sorry !! You dont have enough leave balance. Consider applying leave of some other type.');
              this.duration = undefined;
              this.error = undefined;
              this.submitcheck = true;
            }
          }  
        }
        else{
          if(this.value == 'Work from Home'){
            this.submitcheck = false;
            this.duration = data;
          }else{
            if (this.availabledays >= data) {
            this.submitcheck = false;
            this.duration = data;
            this.error = undefined;
          }
          else {
            this.duration = data;
            alert('Sorry !! You dont have enough leave balance. Consider applying leave of some other type.');
            this.duration = undefined;
            this.error = undefined;
            this.submitcheck = true;
          }
        }
          } 
      }
    } else if (error) {
      this.error = error;
      this.duration = undefined;
      this.submitcheck = true;
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

connectedCallback(){
          
          getLeaveRequestMethod({getrecordId: this.selecteditrecordid})
          .then(result => {
            console.log('result-->',result);
            console.log('result'+JSON.stringify(result));
            const employye = result;
            console.log('employye'+employye);
           this.startDate1 = employye.EMS_LM_Leave_Start_Date__c;
           this.endDate1=employye.EMS_LM_Leave_End_Date__c;
           this.duration=employye.EMS_LM_Leave_Duration__c;
           this.reason=employye.EMS_LM_Reason__c;
           this.value=employye.EMS_LM_Leave_Type_Name__c;
            this.fullday=employye.EMS_LM_Day__c;      
          
           
           

          if (this.fullday != 'Full Day') {
                this.daycheck = true;
                this.firstsecondDay=false;
          }
          else {
                this.daycheck = false;
                this.firstsecondDay=true;
            }           
           
        })
        .catch(error => {
            this.error = error;
            console.log('this.error-->'+JSON.stringify(this.error));
        });


         
    }




  handleChange(event) {
   
    this.daycheck = false;
    this.startDate = this.startDate1 = this.endDate = this.endDate1 = this.duration = undefined;

    this.submitcheck = true;
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
    
    if (this.value == 'Loss of Pay') {
      if (this.annualcompduration > 0) {
        console.log(this.annualcompduration);
        this.submitcheck = true;
        const evt = new ShowToastEvent({
            message: 'Loss of Pay will effect your monthly pay check, consider applying leave of annual or comp off type. ',
            variant: 'warning',
        });
        this.dispatchEvent(evt);
        //alert('Please Utilise Your Leaves(Annual / Comp Off) before applying for Loss Of Pay');
      }
       
    }
  }

   datechange(event) {
    var namecheck = event.target.name;
    let enteredDate = new Date(event.target.value);
    let day =enteredDate.getDay();
    this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
    this.daycheck = false;
    if (namecheck == 'startDate1') {
      this.startDate1 = event.detail.value;
      this.startDate = event.detail.value;
      if (this.startDate1 != null) {
        this.startDate1 = event.detail.value + ' 00:00:00';
      }
      if(day==6 || day==0){
        //alert('please select working days');
        const evt = new ShowToastEvent({
            message: 'You can apply leave on working days only, please select working days. ',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.startDate1 = null;
      }
      if (this.endDate < this.startDate && this.startDate != null && this.endDate != null) {
        const evt = new ShowToastEvent({
            message: 'Please select a proper start date',
            variant: 'error',
        });
        this.dispatchEvent(evt);
      //  alert('Please select a proper Start Date');
        this.startDate1 = null;
      }
      if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
        if (this.startDate != this.endDate || this.startDate == undefined || this.endDate == undefined) {
          let date = new Date(this.startDate);
          let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
          let todaydate1 = formattedDate;
          if (new Date(todaydate1) < new Date(this.todaydate)) {      
          /*  const evt = new ShowToastEvent({
            message: 'Leave to be applied before 48Hrs',
            variant: 'error',
        });
        this.dispatchEvent(evt);*/
       // this.submitcheck = true;
            //alert('Leave to be applied before 48Hrs');
          }
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          let date = new Date(this.startDate);
          let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
          let todaydate1 = formattedDate;
          if (new Date(todaydate1) < new Date(this.todaydate)) {
            
         /*   const evt = new ShowToastEvent({
            message: 'Leave to be applied before 48Hrs',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.submitcheck = true;*/
            //alert('Leave to be applied before 48Hrs');
          }
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      }
      if (this.value == 'Compensatory Off' || this.value == 'Paternity Leave') {// to check PL and Comp Off 2days prior
        if (this.startDate != undefined || this.startDate != null) {
          let date = new Date(this.startDate);
          let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
          let todaydate1 = formattedDate;
          if (new Date(todaydate1) < new Date(this.todaydate)) {       
         /*   const evt = new ShowToastEvent({
            message: 'Leave to be applied before 48Hrs',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.submitcheck = true;*/
            //alert('Leave to be applied before 48Hrs');
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
      if (this.value === 'Annual Leave' || this.value === 'Loss of Pay') {
        if (this.startDate1 != this.endDate1 || this.startDate1 == undefined || this.endDate1 == undefined) {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }];
        }
        else {
          this.dOptions = [{ label: 'Full Day', value: 'Full Day' }, { label: 'First Half', value: 'First Half' }, { label: 'Second Half', value: 'Second Half' }];
        }
      } 
      if(day==6 || day==0){
       // alert('please select working days');
        const evt = new ShowToastEvent({
            message: 'You can apply leave on working days only, please select working days.',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.endDate1 = null;
      }
      if (this.endDate < this.startDate && this.startDate != null && this.endDate != null) {
        console.log(this.endDate <= this.startDate);
        //alert('Please select a Valid End date');
        const evt = new ShowToastEvent({
            message: 'Please select a valid end date',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.endDate1 = null;
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
      if(this.availabledays >= this.duration){
        this.submitcheck = false;
      }      
    }
  }

  closeme() {
    this.closeleavepopup = false;
    const myEvent = new CustomEvent('closeleave',{
        detail:this.closeleavepopup
    });
    this.dispatchEvent(myEvent);
  }

  submitme(){

    let guestObj = { 'sobjectType': 'EMS_LM_Leave_History__c' };
        
        guestObj.EMS_LM_Leave_Start_Date__c = this.startDate;
        guestObj.EMS_LM_Leave_End_Date__c = this.endDate;
        guestObj.EMS_LM_Reason__c = this.reason;
        guestObj.EMS_LM_Leave_Type_Name__c=this.value;
        guestObj.EMS_LM_Day__c=this.fullday;
        

        console.log('guestObj',guestObj);
    
    updateleaveRequest({newRecord: guestObj , recordId:this.selecteditrecordid})
            .then(result => {
                console.log('sdf-->',result);
                const event = new ShowToastEvent({
                  title: 'Save',
                  message: 'Your leave request has been updated successfully!',
                  variant: 'success'
                 
              });
              this.dispatchEvent(event); 
              const myEvent = new CustomEvent('closeleave',{
              detail:this.closeleavepopup
              });
              this.dispatchEvent(myEvent); 
              window.location.reload();
            })
            .catch(error => {
                this.error = error;
                console.log('error-->',error);
                console.log('this.error-->'+JSON.stringify(this.error));
            });
  }

  
}