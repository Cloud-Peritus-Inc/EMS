import { LightningElement,track,wire } from 'lwc';
import getMyUpcomingHoliday from '@salesforce/apex/holidayTitleController.getMyUpcomingHoliday';
export default class UpcomingHolidayTile extends LightningElement {
@track holidaydata ;
@track value ;

@track mapdata =  [];

connectedCallback() {
  
}

    @wire(getMyUpcomingHoliday)
    holidayInfo({ error, data }) {
    if (data) {
    console.log('=======data==='+JSON.stringify(data));
      this.holidaydata = data.datalist;
      var consts = data.locationList;
      for(var key in consts){
        this.mapdata.push({value:key, label:key}); //Here we are creating the array to show on UI.
      }
      this.value = data.resourceLocation;
      console.log('===d=='+JSON.stringify(this.mapdata));
    } else if (error) {
      console.error('ERROR====='+error);
    }
  }


handleChange(event) {
        this.value = event.detail.value;
        console.log('===sds=='+event.target.value);
        console.log('======Changed Value to ====='+this.value);
        const field = event.target.name;
        if (field === 'optionSelect') {
        this.selectedOption = event.target.value;
            alert("you have selected : "+this.selectedOption);
        } 
    }

  }