import { LightningElement,track,wire } from 'lwc';
import getMyUpcomingHoliday from '@salesforce/apex/holidayTitleController.getMyUpcomingHoliday';
import getSelectLocList from '@salesforce/apex/holidayTitleController.getSelectLocList';
export default class UpcomingHolidayTile extends LightningElement {
@track holidaydata ;
@track value ;
loclist = [];
 mapdata =  [];

connectedCallback() {
  
}

loaded = false
    @wire(getMyUpcomingHoliday) 
    wiredLabels({error, data}){
        if(data){
            console.log('data '+JSON.stringify(data));
             this.holidaydata = data.datalist;
             this.value = data.resourceLocation;
            var consts = data.locationList;
            for(var key in consts){
            this.mapdata.push({label:key, value:consts[key]});
        }
        this.loaded = true;
    }
    if(error){
        this.error=error;
    }
    }


handleChange(event) {
        this.value = event.detail.value;
       
        getSelectLocList({ locationId: this.value })
            .then((result) => {
             
                this.holidaydata = result;  
            })
            .catch((error) => {
            console.log('====='+error);
        });
       
    }

  }