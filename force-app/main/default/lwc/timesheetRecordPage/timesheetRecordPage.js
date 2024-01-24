import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchTimesheetRecordsData from '@salesforce/apex/timesheetRecordPageController.fetchTimesheetRecordsData';
export default class TimesheetRecordPage extends NavigationMixin(LightningElement) {
    @api recordId;
    resultRecords;
    error;
    totalHoursVal;

    monVal;
    tueVal;
    wedVal;
    thursdayVal;
    fridayVal;
    saturdayVal1 = false;
    sundayVal1 = false;
    saturdayVal;
    sundayVal
    mondaytime;
    tuestime;
    wedtime;
    thurstime;
    fritime;
    sattime;
    sundtime;
   rowTotals = [];
   @track columnTotals = {
    Monday: 0,
    Tuesday: 0,
    Wednesday: 0,
    Thursday: 0,
    Friday: 0,
    Saturday: 0,
    Sunday: 0
};

    @wire(fetchTimesheetRecordsData, { timesheetId: '$recordId' })
    timesheetRecordsData({ data, error }) {
        if (data) {
            this.resultRecords = data;
            console.log('the time sheet Totl hour'+this.resultRecords.TotalHours);
             console.log('Data ==> ' + JSON.stringify(data));
            console.log('Result ==> ' + this.resultRecords[0].TotalHours); 
            this.totalHoursVal = this.resultRecords[0].TotalHours;
            /*this.mondaytime=this.resultRecords[0].Monday;
            this.tuestime=this.resultRecords[0].Tuesday;
            this.wedtime=this.resultRecords[0].Wednesday;
            this.thurstime=this.resultRecords[0].Thursday;
            this.fritime=this.resultRecords[0].Friday;
            this.sattime=this.resultRecords[0].Saturday;
            this.sundtime=this.resultRecords[0].Sunday;
         this.rowTotal=this.mondaytime+this.tuestime+this.wedtime+this.thurstime+this.fritime+this.sattime+this.sundtime; */
         /*if (this.resultRecords[0].Saturday >0) {
                this.saturdayVal1 = true;
            } else {
                this.saturdayVal1 = false;
            }

            if (this.resultRecords[0].Sunday >0) {
                this.sundayVal1 = true;
            } else {
                this.sundayVal1 = false;
            } */
            this.resultRecords.forEach(record => {
                   if(record.Saturday > 0 && record.Sunday > 0){
                    this.saturdayVal1=true;
                    this.sundayVal1=true;
                   }
                      
                     });
          this.resultRecords=data.map(row => {
                return {
                ...row,
                rowTotal: row.Monday + row.Tuesday + row.Wednesday + row.Thursday + row.Friday + row.Saturday + row.Sunday
            };
        });
        this.resultRecords.forEach(item => {
            Object.keys(this.columnTotals).forEach(key => {
                this.columnTotals[key] += item[key];
            });
        });
           /*  console.log('this.resultRecords[0].Id' ,this.resultRecords[0].Id); */
            let week = new Date(this.resultRecords[0].Week);
            let dates = [];
            dates[0] = week.valueOf();
            for (let i = 1; i < 7; i++) {
                dates[i] = week.setDate(week.getDate() + 1);
            }
            dates = [...dates];
            //console.log('***dates'+dates);
            this.monVal = dates[0];
            this.tueVal = dates[1];
            this.wedVal = dates[2];
            this.thursdayVal = dates[3];
            this.fridayVal = dates[4];
            this.saturdayVal = dates[5];
            this.sundayVal = dates[6];

        } else {
            this.error = error;
            console.log('this.error ==> ' + JSON.stringify(this.error));
            console.log('Error ==> ' + this.error);
        }

    }

    handleTimesheetClick(event) {
        let selectexp = event.target.dataset.id;
        //console.log('selectexp', selectexp);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectexp,
                objectApiName: 'EMS_TM_Timesheet_Record__c',
                actionName: 'view'
            },
        });
    }

    handleProjectClick(event) {
        let selectexp = event.target.dataset.id;
        //console.log('selectexp', selectexp);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectexp,
                objectApiName: 'EMS_TM_Project__c',
                actionName: 'view'
            },
        });
    }

}