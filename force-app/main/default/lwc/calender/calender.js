import { LightningElement,api,track } from 'lwc';
import FullCalendarJS from '@salesforce/resourceUrl/fullcalendarv3';
import getEvents from '@salesforce/apex/calenderController.getEvents';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Calender extends LightningElement {
    jsInitialised = false;
    @track _events;



    @api
    get events() {
        return this._events;
    }
    set events(value) {
        this._events=[...value];
    }


    @api
    get eventDataString() {
        return this.events;
    }
    set eventDataString(value) {
        try
        {
            this.events=eval(value);
        }
        catch{
           this.events=[];
        }
    }


   


  renderedCallback() {
    console.log('=====EVENTS======'+JSON.stringify(this.events));
   

console.log('=====EVENTS==AFTER===='+JSON.stringify(this.events));
    // Performs this operation only on first render
    if (this.jsInitialised) {
      return;
    }
    this.jsInitialised = true;

    Promise.all([
      loadScript(this, FullCalendarJS + '/FullCalenderV3/jquery.min.js'),
      loadScript(this, FullCalendarJS + '/FullCalenderV3/moment.min.js'),
      loadScript(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.js'),
      loadStyle(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.css')
    ])
    .then(() => {
      this.initialiseCalendarJs();
    })
    .catch(error => {
       console.log(error);
        new ShowToastEvent({
            title: 'Error!',
            message: error,
            variant: 'error'
        })
    })
  }

  initialiseCalendarJs() { 
    console.log('=====EVENTS======'+JSON.stringify(this.events));
    var that=this;
    const ele = this.template.querySelector('div.fullcalendarjs');
    //Use jQuery to instantiate fullcalender JS
    $(ele).fullCalendar({
      header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,basicWeek,basicDay'
      },
      defaultDate: new Date(),
      navLinks: true, 
      editable: true,
      eventLimit: true,
      events: this.events,
      dragScroll:true,
      droppable:true,
      weekNumbers:true,
      selectable:true,
      //eventClick: this.eventClick,
      eventClick: function (info) {
        const selectedEvent = new CustomEvent('eventclicked', { detail: info.Id });
        // Dispatches the event.
       that.dispatchEvent(selectedEvent);
        }
    });
  }
}