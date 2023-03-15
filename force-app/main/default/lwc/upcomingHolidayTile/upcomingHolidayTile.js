import { LightningElement,track,wire } from 'lwc';
import getMyUpcomingHoliday from '@salesforce/apex/holidayTitleController.getMyUpcomingHoliday';
import getSelectLocList from '@salesforce/apex/holidayTitleController.getSelectLocList';
export default class UpcomingHolidayTile extends LightningElement {
@track holidaydata ;
@track value ;
loclist = [];
 mapdata =  [];
 showtable = false;

connectedCallback() {
  
}

loaded = false
    @wire(getMyUpcomingHoliday) 
    wiredLabels({error, data}){
        if(data){
             this.holidaydata = data.datalist;
             if(this.holidaydata.length > 0){
               this.showtable = true;
             }
             this.value = data.resourceLocation;
            var consts = data.locationList;
            for(var key in consts){
            this.mapdata.push({label:key, value:consts[key]});
        }
        this.loaded = true;
    }
    if(error){
        console.log('==ERROR===='+error);
        this.error=error;
    }
    }


handleChange(event) {
    this.showtable = false;
        this.value = event.detail.value;
       
        getSelectLocList({ locationId: this.value })
            .then((result) => {
             
                this.holidaydata = result; 
                if(this.holidaydata.length > 0){
               this.showtable = true;
               } 
            })
            .catch((error) => {
            console.log('====='+error);
        });
       
    }

  }