import { LightningElement, wire, track, api } from 'lwc';
import PendingRecords from '@salesforce/apex/PedningTimesheet.PendingRecords';
import Approvetimesheets from '@salesforce/apex/PedningTimesheet.Approvetimesheets';
import Rejectatimesheets from '@salesforce/apex/PedningTimesheet.Rejectatimesheets';
import approvetimesheetsall from '@salesforce/apex/PedningTimesheet.approvetimesheetsall';
import rejecttimesheetsall from '@salesforce/apex/PedningTimesheet.rejecttimesheetsall';
import reassignrecord from '@salesforce/apex/PedningTimesheet.reassignrecord';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class ViewTimesheet extends NavigationMixin(LightningElement) {
  
  projectid;
  @api selectedrows
  @api recordId
  refreshdata;
  checkBox;
  @track multipleApprovals = [];
  @track rejectrecords
  @track selectid;
  @track Timesheetdata;
  selectingId;
  selectid;
  assingrecords;
  
  @wire(PendingRecords)
  Timesheetrecord(result) {
    this.refreshdata = result;
    if (result.data) {
      this.Timesheetdata = result.data;       // alert('mydata=',this.Timesheetdata);
      //    this.projectid=Timesheetdata.ProjcetName;
      //   console.log('  this.projec   ====='+this.projectid)
      console.log('Records --------------------->>>>', JSON.stringify(this.Timesheetdata));
    } else if (result.error) {
      // alert('error===================');
      console.log('error diplyed===============================', error);
      this.error = result.error;
    }
  }

  
  approve(event) {
    console.log('OUTPUT : ');
    this.selectingId = event.currentTarget.dataset.id;
    console.log('selectingId========================= : ', this.selectingId);

    Approvetimesheets({ recordId: this.selectingId })
      .then(result => {
        console.log(' Approvetimesheets Result-> ', result);
        const event = new ShowToastEvent({
          message: 'Succesfully  Approved',
          variant: 'success',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return refreshApex(this.refreshdata);

      })
      .catch(error => {
        console.log('error  ====', error);
        const event = new ShowToastEvent({
          title: 'Failed',
          message: 'Your Approve was Failed',
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);

      })


  }



  Reject(event) {
     this.selectid = event.currentTarget.dataset.id;
    //  console.log(' this.selectid----', this.selectid);
    console.log('this.recordId    ===========',this.selectid);
    Rejectatimesheets({ recordId:this.selectid })

      .then(result => {
        console.log('result--> ', result);
        const event = new ShowToastEvent({
          title: 'Rejected ',
          message: 'This Timesheet was Record  rejected',
          variant: 'info',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return refreshApex(this.refreshdata);

      })
      .catch(error => {
        console.log('error----> ', error);
        const event = new ShowToastEvent({
          title: 'Failed ',
          message: 'null',
          variant: 'This TimeSheet was Failed',
          mode: 'dismissable'
        });

        this.dispatchEvent(event);
        console.log('error   00000', error);

      })
  }
  reassiging(event){
       this.assingrecords = event.currentTarget.dataset.id;
       console.log('this.recordId    ===========',this.assingrecords);
    reassignrecord({ recordId:this.assingrecords })

      .then(result => {
        console.log('result--> ================', result);
        const event = new ShowToastEvent({
          title: 'Reassigned ',
          message: 'This Timesheet was Record  Reassigned',
          variant: 'info',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
        return refreshApex(this.refreshdata);

      })
      .catch(error => {
        console.log('error----> ', error);
        const event = new ShowToastEvent({
          title: 'Failed ',
          message: 'null',
          variant: 'This TimeSheet was Failed',
          mode: 'dismissable'
        });

        this.dispatchEvent(event);
        console.log('error   00000', error);

      })

  }
  handleSelect(event) {
    const selectedRecordCheckboxId = event.currentTarget.dataset.id;
    console.log('### selectedRecordCheckboxId : ', selectedRecordCheckboxId);
    this.checkBox = event.target.checked
    if (!this.checkBox) {
      const index = this.multipleApprovals.indexOf(selectedRecordCheckboxId);
      this.multipleApprovals.splice(index, 1);
    } else {
      this.multipleApprovals = [... this.multipleApprovals, selectedRecordCheckboxId];
      console.log('this.multipleApprovals  ===========', this.multipleApprovals);
    }

  }
  handleSelectAll(event){
      this.checkBox = event.target.checked
    if (this.checkBox) {
      const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
      const selectedRecordIds = [];
      checkboxElements.forEach(element => {
        if (!element.disabled) {
          element.checked = true;
          const dataId = element.dataset.id;
          selectedRecordIds.push(dataId);
        }
      });
      //console.log('Selected Record Ids:', selectedRecordIds);
      this.multipleApprovals = selectedRecordIds;
      //console.log('### multipleApprovals', this.multipleApprovals);
    } else if (!this.checkBox) {
      const checkboxElements = this.template.querySelectorAll('input[type="checkbox"]');
      checkboxElements.forEach(element => {
        element.checked = false;
        this.multipleApprovals = [];
        console.log('### else multipleApprovals : ', this.multipleApprovals);
      });
    }
  }
  handleApproveAll(event) {
    console.log('OUTPUT : ' , JSON.stringify(this.multipleApprovals) );
    if (this.multipleApprovals.length === 0) {
      const evt = new ShowToastEvent({
        message: 'Please select at least record',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    }else{

   /*  const checkrow = event.detail.selectedrows;
    for (let i = 0; i < checkrow.length; i++) {
      this.selectedrows.push(checkrow[i].Id);
      console.log('multipleApprovals  ====================', this.selectedrows);
    } */
    console.log('multipleApprovals  ====================', this.multipleApprovals);
    approvetimesheetsall({ recordIds: this.multipleApprovals })
      .then(result => {
        console.log('result' ,result);
        const event = new ShowToastEvent({
          message: 'This Timesheet Record is all updated',
          variant: 'success',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
         return refreshApex(this.refreshdata);


      })
      .catch(error => {
        console.log('error------->' ,error);
        const event = new ShowToastEvent({
          message: 'This TimeSheet was Failed',
          variant: 'error',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);

      })
    }
  }
  handleRejectAll(event) {
    console.log('OUTPUT : ');
console.log('chekcing multipleApprovals',this.multipleApprovals);
console.log('chekcing multipleApprovals length',this.multipleApprovals.length);
    if (this.multipleApprovals.length === 0) {
      const evt = new ShowToastEvent({
        message: 'Please select at least record',
        variant: 'error',
      });
      this.dispatchEvent(evt);
    } else {
      //alert('error occues  ,' + event.getmessage());
    //}

    //rejecttimesheetsall({ multipleApprovals: '$recordId' })
    rejecttimesheetsall({ recordIdsList: this.multipleApprovals })
      .then(result => {
          console.log('result reject' ,result);
        const event = new ShowToastEvent({
          title: 'Rejected ',
          message: 'This Timesheet Record is all rejected',
          variant: 'warning',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
         return refreshApex(this.refreshdata);


      })
      .catch(error => {
        console.log('error------->' ,error);
        const event = new ShowToastEvent({
          title: 'Failed ' + event.getmessage(),
          message: '',
          variant: 'This TimeSheet was Failed',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);

      })
    }
  }
  handlConcontactClick(event) {
    let selectCon = event.currentTarget.dataset.id;
     console.log('### selectCon : ', selectCon);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectCon,
        objectApiName: 'Contact',
        actionName: 'view',
      },
    });
  }

  handleProjectClick(event) {
    let selectexp = event.currentTarget.dataset.id;
    console.log('selectexp', selectexp);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectexp,
        objectApiName: 'EMS_TM_Project__c',
        actionName: 'view'
      },
    });
  }
  handlTimesheetClick(event) {
    let selectexp = event.currentTarget.dataset.id;
    console.log('selectexp', selectexp);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectexp,
        objectApiName: 'EMS_Timesheet__c',
        actionName: 'view'
      },
    });

  }
  handlTimesheetrecordclick(event){
    let selectexp = event.currentTarget.dataset.id;
    console.log('selectexp', selectexp);
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: selectexp,
        objectApiName: 'EMS_TM_Timesheet_Record__c',
        actionName: 'view'
      },
    });

  }
  
}