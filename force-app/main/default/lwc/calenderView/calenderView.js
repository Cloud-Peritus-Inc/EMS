import { LightningElement,track,wire } from 'lwc';
import getEvents from '@salesforce/apex/calenderController.getEvents';
import getRecordInfo from '@salesforce/apex/calenderController.getRecordInfo';
export default class CalenderView extends LightningElement {
@track startDate=new Date();
 showThetable = false;
  @track endDate;
  recordvalue ;
  recorddata;
  error;
  openModal = false;
  @track events=[];
  @wire(getEvents)
    eventObj(value){
        const {data, error} = value;
        if(data){
           console.log('======this.events=data=='+JSON.stringify(data));
            //format as fullcalendar event object
            let records = data.map(event => {
                return { Id : event.Id, 
                        title : event.title, 
                        start : event.start,
                        end : event.endTime,
                        allDay : event.allDay};
            });
            this.showThetable = true;
            this.events = JSON.parse(JSON.stringify(records));
            console.log('======this.events==='+this.events);
            this.error = undefined;
        }else if(error){
            console.log('===error==='+JSON.stringify(error));
            this.events = [];
            this.error = 'No events are found';
        }
   }

  getTheEventsDate(){
   
  }


    handleEvent(event) {
      var id=event.detail;
      this.recordvalue = event.detail;
      console.log('======event.detail==='+event.detail);
     /*  getRecordInfo({recid : event.detail}).then(result => {
			 this.recorddata = result;
        })
        .catch(error => {
          console.log('****ERROR**'+JSON.stringify(error));
        })*/
      let task = this.events.find(x=>x.Id=id);
      this.startDate=task.start;
      this.title=task.title;
      this.endDate=task.end;
      this.openModal = true;
      
    }
    handleCancel(event) {
      this.openModal = false;
    }
}