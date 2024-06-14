import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchTimesheetRecordsData from '@salesforce/apex/timesheetRecordRecordPageController.fetchTimesheetRecordsData';
export default class TimesheetRecordRecordPage extends NavigationMixin(LightningElement) {
    @api recordId;
    resultRecords;
    error;
    totalHoursVal;
saturdayVal1 = false;
    sundayVal1 = false;
    monVal;
    tueVal;
    wedVal;
    thursdayVal;
    fridayVal;
    saturdayVal;
    sundayVal;
    monTime;
    tueTime;
    wedTime;
    thursTime;
    friTime;
    satTime;
    sunTime;



    @wire(fetchTimesheetRecordsData, { timesheetRecordId: '$recordId' })
    timesheetRecordsData({ data, error }) {
        if (data) {
            this.resultRecords = data;
             console.log('Data ==> ' + JSON.stringify(data));
            console.log('Result ==> ' + this.resultRecords[0].TotalHours); 
            //this.totalHoursVal = this.resultRecords[0].TotalHours;
            this.monTime=this.resultRecords[0].Monday;
            console.log('MondatTime ==> ' + this.resultRecords[0].Monday); 
            this.tueTime=this.resultRecords[0].Tuesday;
            console.log('MondatTime ==> ' + this.resultRecords[0].Tuesday);
            this.wedTime=this.resultRecords[0].Wednesday;
            this.thursTime=this.resultRecords[0].Thursday;
            this.friTime=this.resultRecords[0].Friday;
            this.satTime=this.resultRecords[0].Saturday;
            this.sunTime=this.resultRecords[0].Sunday;
            this.totalHoursVal=this.monTime+this.tueTime+this.wedTime+this.thursTime+this.friTime+this.satTime+this.sunTime;
           /*  console.log('this.resultRecords[0].Id' ,this.resultRecords[0].Id); */
           if(this.satTime >0 || this.sunTime >0){
             this.saturdayVal1=true;
             this.sundayVal1=true;
           }
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