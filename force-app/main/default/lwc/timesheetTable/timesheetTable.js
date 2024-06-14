import { LightningElement, api,track } from 'lwc';
import getTimeSheetData from '@salesforce/apex/EMS_TM_TimesheetClass.getTimesheetHours';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import user_Id from '@salesforce/user/Id';
export default class TimesheetTable extends NavigationMixin(LightningElement) {
 @track leaveReq;
 timesheetRecentRec;
  a_Record_URL;
 ringPercentage;
 timehours;
 fillPercent;
    @api variant;
    @api direction = 'fill';
    @api size;

    @track d;
    @track computedOuterClass = 'slds-progress-ring';
    @track computedIconName;
    @track computedAltText; 

    connectedCallback() {
      
      this.a_Record_URL = window.location.origin;
      console.log('Base Url'+this.a_Record_URL);
        getTimeSheetData().then( result => {
            console.log('TimesheetTableData',result);
            this.timesheetRecentRec = result.timeSheetrecord;
            console.log('timesheetRecentRec'+this.timesheetRecentRec);
            this.leaveReq =result.timeSheetRecordsList;
            console.log('leaveReq'+this.leaveReq);
            this.recalc();
        }).catch(err => {
            console.log('timesheettableerror'+err);
            
        });
           
    }
     handleLMNavigation(){
         var url = new URL(this.a_Record_URL+'/CpLink/s/timepage');
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: url.href
      }
    });
    }

    recalc(){
     console.log('RECENTDATA'+this.timesheetRecentRec);
     this.timehours = this.timesheetRecentRec/40;
     if(this.timehours >= 1){
       console.log('if');
       this.timehours = 1;
     }
     console.log('timehours'+this.timehours);
      this.fillPercent = this.timehours*100;
   console.log ('this.ringPercentage'+this.fillPercent);
    this.ringPercentage = this.fillPercent;
     console.log('ringPercentage'+this.ringPercentage);
    // default for fill
    let filldrain = 0;
    let inverter = -1;

    if (this.direction === 'drain') {
        filldrain = 1;
        inverter = 1;
    }

    const arcx = Math.cos(2 * Math.PI * this.fillPercent);
    const arcy = Math.sin(2 * Math.PI * this.fillPercent) * inverter;
    console.log('arcy'+arcy);
    const arcyx =Math.ceil(arcy);
 console.log('arcx'+arcx);
  console.log('arcyx'+arcyx);
    const islong = this.fillPercent > 0.5 ? 1 : 0;

    const dd = `M 1 0 A 1 1 0 ${islong} ${filldrain} ${arcx} ${arcyx} L 0 0`;
 console.log('dd'+dd);
   this.d = dd;
        
      /*  this.getArc(this.timesheetRecentRec, this.direction);*/
        console.log('D'+this.d);
        console.log ('this.ringPercentage'+this.ringPercentage);
    }

  /*  getArc(current, direction){
      console.log('current'+current);
      console.log('direction'+direction);
    const fillPercent = (current /40)*100;
   console.log ('this.ringPercentage'+this.fillPercent);
    this.ringPercentage = fillPercent;

    // default for fill
    let filldrain = 0;
    let inverter = -1;

    if (direction === 'drain') {
        filldrain = 1;
        inverter = 1;
    }

    const arcx = Math.cos(2 * Math.PI * fillPercent);
    const arcy = Math.sin(2 * Math.PI * fillPercent) * inverter;
 console.log('arcx'+thhis.arcx);
  console.log('arcy'+thhis.arcy);
    const islong = fillPercent > 0.5 ? 1 : 0;

    const dd = `M 1 0 A 1 1 0 ${islong} ${filldrain} ${arcx} ${arcy} L 0 0`;
 console.log('dd'+dd);
   this.d = dd;
}*/
   
}