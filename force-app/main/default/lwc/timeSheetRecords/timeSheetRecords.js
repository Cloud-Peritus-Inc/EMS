import { LightningElement, wire, track } from 'lwc';
import PendingRecords from '@salesforce/apex/PedningTimesheet.PendingRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Approvetimesheets from '@salesforce/apex/PedningTimesheet.Approvetimesheets';
import Rejectatimesheets from '@salesforce/apex/PedningTimesheet.Rejectatimesheets';
import { refreshApex } from '@salesforce/apex';
import reassignrecord from '@salesforce/apex/PedningTimesheet.reassignrecord';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
export default class TimeSheetRecords extends NavigationMixin(LightningElement) {


  selectingId;
  Timesheetresults;
  @track penningTimesheet;
  @track error;
  nodata = false;
  refreshdata;
  @track Timesheetdata
  @track timesheetrecords
  //@track refreshdata=[];

  @wire(PendingRecords)
  Timesheetrecord(result) {
    const {data,error}= result;
    this.refreshdata = result;
    this.timesheetrecords=result;
    if (data){
      if(data.length>=1){
           console.log('data size=================================================================',data.length);
          this.Timesheetdata =data;  
    //    this.Timesheetdata = result.data;       // alert('mydata=',this.Timesheetdata);
      //    this.projectid=Timesheetdata.ProjcetName;
      //   console.log('  this.projec   ====='+this.projectid)
      console.log('Records --------------------->>>>', JSON.stringify(this.Timesheetdata));
      
      }else{
        this.nodata = true;
      }
    
      
      
    } 
    else if (error) {
      // alert('error===================');
    
      console.log('error diplyed===============================', error);
      this.error = error;
    }
    
  }


  clickapprove(event) {

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
         const searchEvent =new CustomEvent("getsearchvalue",{
          detail:false
        });
        this.dispatchEvent(searchEvent);
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
  clickreject(event) {
    this.selectid = event.currentTarget.dataset.id;
    //  console.log(' this.selectid----', this.selectid);
    console.log('this.recordId    ===========', this.selectid);
    Rejectatimesheets({ recordId: this.selectid })

      .then(result => {
        console.log('result--> ', result);
        const event = new ShowToastEvent({
          title: 'Rejected ',
          message: 'This Timesheet was Record  rejected',
          variant: 'info',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
         const searchEvent =new CustomEvent("getsearchvalue",{
          detail:false
        });
        this.dispatchEvent(searchEvent);
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
  clickReassing(event) {
    this.assingrecords = event.currentTarget.dataset.id;
    console.log('this.recordId    ===========', this.assingrecords);
    reassignrecord({ recordId: this.assingrecords })

      .then(result => {
        console.log('result--> ', result);
        const event = new ShowToastEvent({
          title: 'Reassigned ',
          message: 'This Timesheet was Record  Reassigned',
          variant: 'info',
          mode: 'dismissable'
        });
        this.dispatchEvent(event);
         const searchEvent =new CustomEvent("getsearchvalue",{
          detail:false
        });
        this.dispatchEvent(searchEvent);
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
  handlTimesheetrecordclick(event){
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
  handlcontactrecordclick(event){
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

}