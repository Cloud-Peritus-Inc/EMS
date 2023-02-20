import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getTimeSheetData from '@salesforce/apex/EMS_TM_TimesheetClass.getTimesheetHours';
export default class TimeSheetTile extends NavigationMixin(LightningElement) {
  @api percentage = 0;
  @api numberofhoursfilledthisweek = 0;
  timesheetRecentRec ;
  filledpastdata = [];
  @track width = 300;
  @track height = 300;
  
  connectedCallback() {
     
        getTimeSheetData().then( result => {
            this.numberofhoursfilledthisweek = result.timeSheetrecord;
            this.filledpastdata =result.timeSheetRecordsList;
            console.log('====timeSheetRecordsList==='+result.timeSheetRecordsList.length);

            this.frameTheCircle();
        }).catch(err => {
            console.log('timesheettableerror'+JSON.stringify(err));
            
        });
           
    }



  frameTheCircle() {
    console.log('======numberofhoursfilledthisweek=========='+this.numberofhoursfilledthisweek);
  if(this.numberofhoursfilledthisweek != 0 && this.numberofhoursfilledthisweek <= 40){
  this.percentage = (this.numberofhoursfilledthisweek/40) * 100;
  }else if(this.numberofhoursfilledthisweek != 0 && this.numberofhoursfilledthisweek > 40){
   this.percentage = 100;   
  }else{
      this.percentage = 1;
  }
  const canvas = this.template.querySelector('.canvas');
    const ctx = canvas.getContext('2d');
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = 70;

    ctx.beginPath();
    ctx.arc(centerX, centerY, radius, Math.PI / 2, Math.PI / 2 + 2 * Math.PI * this.percentage / 100, false);
    ctx.lineWidth = 15;
    ctx.strokeStyle = '#0070D2';
    ctx.stroke();

    ctx.beginPath();
     ctx.arc(centerX, centerY, radius, Math.PI / 2, Math.PI / 2 + 2 * Math.PI * this.percentage / 100, true);
    ctx.lineWidth = 15;
    ctx.strokeStyle = '#FAFAF9';
    ctx.stroke();

    ctx.fillStyle = 'black';
    ctx.font = 'bold 50px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(this.numberofhoursfilledthisweek, centerX, centerY-20);

    ctx.fillStyle = 'black';
    ctx.font = '10px sans-serif';
  //  ctx.textAlign = 'center';
  //  ctx.textBaseline = 'middle';
    ctx.fillText('Hours', centerX, centerY + 20);

  }

   handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/timepage'
            }
        });
}
}