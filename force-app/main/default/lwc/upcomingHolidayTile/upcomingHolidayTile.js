import { LightningElement,track,wire } from 'lwc';
import getMyUpcomingHoliday from '@salesforce/apex/holidayTitleController.getMyUpcomingHoliday';
export default class UpcomingHolidayTile extends LightningElement {
@track holidaydata ;

    @wire(getMyUpcomingHoliday)
    holidayInfo({ error, data }) {
    if (data) {
    console.log('=======data==='+JSON.stringify(data));
      this.holidaydata = data;
    } else if (error) {
      console.error(error);
    }
  }
  }