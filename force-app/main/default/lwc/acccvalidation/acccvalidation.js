import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TIME_ZONE from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import saveTimeSheetRecords from '@salesforce/apex/EMS_TM_TimesheetClass.saveTimeSheetRecords';
import updateTimeSheetRecords from '@salesforce/apex/EMS_TM_TimesheetClass.updateTimeSheetRecords';
import duplicatetimesheetLWC from '@salesforce/apex/EMS_TM_TimesheetClass.duplicatetimesheetLWC';
import getAssignmentProject from '@salesforce/apex/EMS_TM_TimesheetClass.getAssignmentProject';
import getAssignmentProjectWire from '@salesforce/apex/EMS_TM_TimesheetClass.getAssignmentProjectWire';
import getTimeSheetData from '@salesforce/apex/EMS_TM_TimesheetClass.getTimeSheetData';
import getPreWeekData from '@salesforce/apex/EMS_TM_TimesheetClass.getPreWeekData';
import reviseTimesheet from '@salesforce/apex/EMS_TM_TimesheetClass.reviseTimesheet';
import savecomppRec from '@salesforce/apex/createCompoffThroughTimesheet.createCompOff';
import checkcomppRec from '@salesforce/apex/createCompoffThroughTimesheet.checkCompOff';
import { getRecord } from 'lightning/uiRecordApi';
import user_Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class Acccvalidation extends  NavigationMixin(LightningElement) {
    @track taskPicklistVisible = false;
    @track displayItemList;
    @track timeSheetRecord ={};
    @track weekDates = {};
    @track totalHours = {value:0,error:false};
    @track pickListRecords = { clientPicklist: [], oooPicklist: [], benchPicklist: [], otherPicklist: [] };

    records;
    recordId = '';
    disableField = {};
    managerView = false;
    enableManagerView = false;
    disableRevise = false;
    userSelected = false;
    keyIndex = 0;
    hasRendered = false;
    showWeekend = false;
    showRemarks = false;
    showOtherTask = false;
    disablePreButtons = false;
    disableNextButtons = false;
    disableSubmited = false;
    falseVariable = false;
    assignmentRecords;
    holidayRecords;
    projectRecords;
    userId = user_Id;
    userName;
    projectLookUpFilter = '';
    managerLookUpFilter = '';
    error;
    isValid = true;
    totalDayHours = {};
    clientPicklist = [];
    thisWeek;
    deletedRecordsList = [];
    confirmModal = {};
    showCompOffPopUp = false;
    weekendEntered = false;
    weekendEnteredValue = 0;
    hideSpinner = false;
    leaveRecords;
    @track compoffCheck = false;

    @track showModalPopUp = false;

    @track compoffAlredyexist = false;

    @wire(getRecord,({ recordId: '$userId', fields: [NAME_FIELD]}))
    getData({data, error}) {
        if (data) {
            this.userName = data.fields.Name.value;
            this.timeSheetRecord.User__c = this.userId;
        } else if (error) {
            console.log('Error ',error);
        }
    }

    @wire(getAssignmentProjectWire, { week: new Date(), wireMethod: true, userId: '$userId' } )
    assignmentProject({ error, data }) {
        if (data) {
            console.log('result ',data);
            // this.timeSheetRecord.User__c = data.User.Id;
            this.enableManagerView = data.enableManagerView;
            if (this.enableManagerView) {
                // let profileIds = [];
                // data.projectIdList.forEach( project => {
                //     profileIds.push(project);
                // });
                let profileIdsString = JSON.stringify(data.projectIdList);
                profileIdsString = profileIdsString.replace("[", "(");
                profileIdsString = profileIdsString.replace("]", ")");
                profileIdsString = profileIdsString.replace(/"/g, "'");
                this.managerLookUpFilter = 'Id in ' + profileIdsString;
            }
            let pickListValues = data.picklist;
            if (pickListValues) {
                pickListValues.forEach( value => {
                    if (value.EMS_TM_Type__c === 'Client') {
                        this.pickListRecords.clientPicklist.push({value: value.EMS_TM_Value__c, label: value.EMS_TM_Label__c});
                    } else if (value.EMS_TM_Type__c === 'OOO') {
                        this.pickListRecords.oooPicklist.push({value: value.EMS_TM_Value__c, label: value.EMS_TM_Label__c});
                    } else if (value.EMS_TM_Type__c === 'Bench') {
                        this.pickListRecords.benchPicklist.push({value: value.EMS_TM_Value__c, label: value.EMS_TM_Label__c});
                    } //else if (value.EMS_TM_Type__c === 'Other') {
                    //     this.pickListRecords.otherPicklist.push({value: value.EMS_TM_Value__c, label: value.EMS_TM_Label__c});
                    // }
                });
            }
            this.renderAssignmentRecords(data);
            this.hideSpinner = true;
            console.log('this.managerLookUpFilter'+this.managerLookUpFilter);
        } else if (error) {
            console.log('error ', error);
            this.hideSpinner = true;
        }
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.weekDates = {EMS_TM_Sun__c: '',EMS_TM_Mon__c: '',EMS_TM_Tue__c: '',EMS_TM_Wed__c: '',EMS_TM_Thu__c: '',EMS_TM_Fri__c: '',EMS_TM_Sat__c: ''};
            let today = new Date();
            console.log('TODAYCallBacak'+today);
            const timeZone = TIME_ZONE;
            console.log('timeZone'+timeZone);
           let dayDiff = today.getDay() === 0 ? 6 : today.getDay() - 1;
             console.log('dayDiff'+dayDiff);
     
            let firstDay = new Date(today.getUTCFullYear(),today.getUTCMonth(),(today.getUTCDate() - dayDiff));
             console.log('firstDayallBacak'+firstDay);
            let lastDay = new Date(today.getUTCFullYear(),today.getUTCMonth(),(today.getUTCDate() - dayDiff + 6));
            const weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Fri","Saturday"];
            let day = weekday[firstDay.getDay()];
            console.log('day'+day);
            if(day != 'Monday'){
                firstDay = new Date(today.getUTCFullYear(),today.getUTCMonth(),(today.getUTCDate() - dayDiff-1));
                 let lastDay = new Date(today.getUTCFullYear(),today.getUTCMonth(),(today.getUTCDate() - dayDiff + 5));
                 console.log('IF-firstDayallBacak'+firstDay);
                  console.log('IF-lastDayallBacak'+lastDay);
            }
            
              console.log('lastDayallBacak'+lastDay);
              console.log('firstDayallBacak'+firstDay);
        
            this.insertSheetRecord(firstDay, lastDay);
            this.thisWeek = this.timeSheetRecord.EMS_TM_Week__c;
            console.log('getingWEEKCallBacak'+this.thisWeek);
            this.initialValues();

            this.displayItemList = JSON.parse(JSON.stringify(this.records));
            this.disableNextButtons = true;
            this.hasRendered = true;
            
        }
    }

    /*
        function    : initialValues
        Description : Sets values of variables totalDayHours and records to their initial values.
        Parameters  : null 
    */
    initialValues() {
        this.showOtherTask = false;
        this.totalDayHours = {EMS_TM_Sun__c: 0,EMS_TM_Mon__c: 0,EMS_TM_Tue__c: 0,EMS_TM_Wed__c: 0,EMS_TM_Thu__c: 0,EMS_TM_Fri__c: 0,EMS_TM_Sat__c: 0};
        this.records = [{key: 0, otherTask: false, EMS_TM_Sun__c: 0, EMS_TM_Mon__c: 0, EMS_TM_Tue__c: 0, EMS_TM_Wed__c: 0, EMS_TM_ProjectTask__c: '', EMS_TM_Thu__c: 0, EMS_TM_Fri__c: 0, EMS_TM_Sat__c: 0, projectTaskOptions: [], projectName: '', remarkRequired: false, projectAssignAvail: false, projectTaskDuplicate: false}];
    }

    /*
        function    : renderAssignmentRecords
        Description : Render Assignment records retrieved when user changes week or onload
        Parameters  : today, fields 
    */
    renderAssignmentRecords(data) {
        this.projectRecords = data.project;
        this.assignmentRecords = data.assignment;
        this.holidayRecords = data.holidays;
        this.leaveRecords = data.leaves;
        if (this.projectRecords) {
            let projectIds = [];
            this.projectRecords.forEach( project => {
                projectIds.push(project.Id);
            });
            let projectIdsString = JSON.stringify(projectIds);
            projectIdsString = projectIdsString.replace("[", "(");
            projectIdsString = projectIdsString.replace("]", ")");
            projectIdsString = projectIdsString.replace(/"/g, "'");
            this.projectLookUpFilter = 'Id in ' + projectIdsString;
        }
        this.renderTimesheetRecords(data.timeSheet, data.timeSheetRecords);
    }

    /*
        function    : renderTimesheetRecords
        Description : Render time sheet records retrieved when user changes week, onload or saved time sheet
        Parameters  : timeSheet, timeSheetRecords 
    */
    renderTimesheetRecords(timeSheet, timeSheetRecords) {
        if (timeSheet) {
            this.disableSubmited = timeSheet.EMS_TM_Status__c === 'Submitted' || timeSheet.EMS_TM_Status__c === 'Locked' ? true : false;
            this.disableRevise = timeSheet.EMS_TM_Status__c === 'Submitted' || timeSheet.EMS_TM_Status__c === 'Locked' ? false : true;
            this.recordId = timeSheet.Id;
            this.timeSheetRecord.Id = timeSheet.Id;
            this.timeSheetRecord.EMS_TM_Status__c = timeSheet.EMS_TM_Status__c;
            this.records = [];
            let countOtherTask = 0;
            if (timeSheetRecords) {
                timeSheetRecords.forEach( record => {
                    let element = {};
                    element.projectTaskOptions = [];
                    element.projectAssignAvail = false;
                    if (this.projectRecords) {
                        let project = this.projectRecords.find( item => item.Id === record.EMS_TM_Project__c);
                        let assignment = this.assignmentRecords.find( item => item.EMS_TM_ProjectName_Asgn__c === record.EMS_TM_Project__c);
                        element.projectAssignAvail = record.EMS_TM_ProjectTask__c ? true : false;
                        if (project) {
                            element.EMS_TM_Project__c = record.EMS_TM_Project__c;
                            if (project.EMS_TM_Project_Type__c === 'OOO') {
                                element.projectTaskOptions = JSON.parse(JSON.stringify(this.pickListRecords.oooPicklist));
                            } else if (project.EMS_TM_Project_Type__c === 'Bench') {
                                element.projectTaskOptions = JSON.parse(JSON.stringify(this.pickListRecords.benchPicklist));
                            // } else if (project.EMS_TM_Project_Type__c === 'Other') {
                            //     element.projectTaskOptions = JSON.parse(JSON.stringify(this.pickListRecords.otherPicklist));
                            }
                            console.log('record.EMS_TM_OtherTask__c ',record.EMS_TM_OtherTask__c);
                            element.projectValueAvailable = true;
                            for(let key in record) {element[key] = record[key];}
                            if (record.EMS_TM_ProjectTask__c === 'Other' && record.EMS_TM_OtherTask__c) {
                                countOtherTask++;
                                element.otherTask = true;
                                // this.showOtherTask = true;
                            }
                            if (record.EMS_TM_Sun__c > 0 || record.EMS_TM_Sat__c > 0) {
                                this.showWeekend = true;
                                this.showRemarks = true;
                                this.template.querySelector('[data-id="remarkToggle"]').checked = true;
                                this.template.querySelector('[data-id="weekendToggle"]').checked = true;
                                // this.showOtherTask = true;
                            }
                            this.records.push(element);
                        }
                    }
                })
                this.showOtherTask = countOtherTask > 0 ? true : false;
                console.log(countOtherTask + '  ' + this.showOtherTask);
            } else {
                this.initialValues();
                this.holidays();
                this.leaves();
            }
        } else {
            this.recordId = '';
            this.initialValues();
            this.holidays();
            this.leaves();
        }
        this.calculateTotalHours();
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : holidays
        Description : Retrieves holidays when week changes
        Parameters  : null 
    */
    holidays() {
        if (this.holidayRecords) {
            if (this.holidayRecords.length > 0) {
                let oooProject = this.projectRecords.find(item => item.Name === 'OOO');
                let addRow = false;
                let record = {key: 0, otherTask: false, EMS_TM_Sun__c: 0, EMS_TM_Mon__c: 0, EMS_TM_Tue__c: 0, EMS_TM_Wed__c: 0, EMS_TM_Thu__c: 0, EMS_TM_Fri__c: 0, EMS_TM_Sat__c: 0, projectTaskOptions: this.pickListRecords.oooPicklist , EMS_TM_Project__c: oooProject.Id, disableEMS_TM_Project__c: true, disableEMS_TM_ProjectTask__c: true, EMS_TM_ProjectTask__c: 'Holiday', projectValueAvailable: true, projectAssignAvail: false, projectTaskDuplicate: false};
                this.holidayRecords.forEach(holiday => {
                    let date = new Date(holiday.EMS_TM_Calendar_Date__c).getDay();
                    console.log('holidays ',date);
                    switch (date) {
                        case 1: record.EMS_TM_Mon__c = 8; addRow = true; break;
                        case 2: record.EMS_TM_Tue__c = 8; addRow = true; break;
                        case 3: record.EMS_TM_Wed__c = 8; addRow = true; break;
                        case 4: record.EMS_TM_Thu__c = 8; addRow = true; break;
                        case 5: record.EMS_TM_Fri__c = 8; addRow = true; break;
                        default: break;
                    }
                });
                console.log('record ',record);
                if (addRow) {
                    this.records[0] = record;
                }
            }
        }
    }
    /*
        function    : leaves
        Description : Retrieves leaves when week changes
        Parameters  : null 
    */
        leaves() {
            if (this.leaveRecords) {
                if (this.leaveRecords.length > 0) {
                    let oooProject = this.projectRecords.find(item => item.Name === 'OOO')
                    let record = {key: 0, otherTask: false, EMS_TM_Sun__c: 0, EMS_TM_Mon__c: 0, EMS_TM_Tue__c: 0, EMS_TM_Wed__c: 0, EMS_TM_Thu__c: 0, EMS_TM_Fri__c: 0, EMS_TM_Sat__c: 0, projectTaskOptions: this.pickListRecords.oooPicklist , EMS_TM_Project__c: oooProject.Id, disableEMS_TM_Project__c: true, disableEMS_TM_ProjectTask__c: true, EMS_TM_ProjectTask__c: 'Paid time-off', projectValueAvailable: true, projectAssignAvail: false, projectTaskDuplicate: false};
                    this.leaveRecords.forEach(leave => {
                        let date = new Date(leave).getDay();
                        console.log('leaves ',date);
                        switch (date) {
                            case 1: record.EMS_TM_Mon__c = 8; break;
                            case 2: record.EMS_TM_Tue__c = 8; break;
                            case 3: record.EMS_TM_Wed__c = 8; break;
                            case 4: record.EMS_TM_Thu__c = 8; break;
                            case 5: record.EMS_TM_Fri__c = 8; break;
                            default: break;
                        }
                    });
                    console.log('record ',record);
                    this.records.push(record);
                    
                }
            }
        }

    /*
        function    : retrieveRecords
        Description : Retrieves timesheet records when timesheet records are saved
        Parameters  : null 
    */
    retrieveRecords() {
        this.hideSpinner = false;
        let week = new Date(this.timeSheetRecord.EMS_TM_Week__c);
        getTimeSheetData({ week: week, userId: this.timeSheetRecord.User__c }).then( result => {
            console.log('result',result);
            this.renderTimesheetRecords(result.timeSheet,result.timeSheetRecords);
            this.hideSpinner = true;
        }).catch(err => {
            console.log(err);
            this.disableSubmited = false;
            this.initialValues();
            this.calculateTotalHours();
            this.displayItemList = JSON.parse(JSON.stringify(this.records));
            this.hideSpinner = true;
        });
    }

    /*
        function    : retrieveAssignmentRecords
        Description : Retrieves Assignment records when week changes
        Parameters  : null 
    */
    retrieveAssignmentRecords() {
        this.hideSpinner = false;
        let week = new Date(this.timeSheetRecord.EMS_TM_Week__c);
        getAssignmentProject({ week: week, wireMethod: false, userId: this.timeSheetRecord.User__c }).then( result => {
            console.log('result',result);
            this.renderAssignmentRecords(result);
            this.renderTimesheetRecords(result.timeSheet,result.timeSheetRecords);
            this.hideSpinner = true;
        }).catch(err => {
            console.log(err);
            this.disableSubmited = false;
            this.initialValues();
            this.calculateTotalHours();
            this.displayItemList = JSON.parse(JSON.stringify(this.records));
            this.hideSpinner = true;
        });
    }

    /*
        function    : handleWeek
        Description : Handle changes when week changed from date picker
        Parameters  : event 
    */
    handleWeek(event) {
        let firstDay;
        let lastDay;
        let selectedWeek;
        if (this.managerView && !this.userSelected) {
            event.target.value = this.thisWeek;
            // this.timeSheetRecord.EMS_TM_Week__c = this.thisWeek;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'User Selection',
                    message: 'Please select a user to view the entries',
                    variant: 'error',
                }),
            );
        } else {
            if (event.target.value) {
                let enteredDate = new Date(event.target.value);
                console.log('ENTERED DATE'+enteredDate);
                if (enteredDate <= new Date()) {
                    let dayDiff = enteredDate.getDay() === 0 ? 6 : enteredDate.getDay() - 1;
                     console.log('dayDiff>>>>>>>'+dayDiff);
                    firstDay = new Date(enteredDate.getUTCFullYear(),enteredDate.getUTCMonth(),(enteredDate.getUTCDate() - dayDiff));
                    console.log('firstDay'+firstDay);
                    lastDay = new Date(enteredDate.getUTCFullYear(),enteredDate.getUTCMonth(),(enteredDate.getUTCDate() - dayDiff + 6));
                     console.log('lastDay'+lastDay);
                     const weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Fri","Saturday"];
            let day = weekday[firstDay.getDay()];
            console.log('day'+day);
            if(day != 'Monday'){
                firstDay = new Date(today.getUTCFullYear(),today.getUTCMonth(),(today.getUTCDate() - dayDiff-1));
                 let lastDay = new Date(today.getUTCFullYear(),today.getUTCMonth(),(today.getUTCDate() - dayDiff + 5));
                 console.log('IF-firstDayallBacak'+firstDay);
                  console.log('IF-lastDayallBacak'+lastDay);
            }
                    selectedWeek = 'selected';
                } else {
                    event.target.value = this.timeSheetRecord.EMS_TM_Week__c;
                    selectedWeek = '';
                }
            } else {
                selectedWeek = 'empty';
            }
            if (selectedWeek === 'empty') {
                this.disableSubmited = false;
                this.disablePreButtons = true;
                this.disableNextButtons = true;
                this.timeSheetRecord.EMS_TM_Week__c = null;
                this.timeSheetRecord.Week__c = '';
            } else if (selectedWeek === 'selected') {
                this.disableSubmited = false;
                this.disablePreButtons = false;
                this.disableNextButtons = false;
                this.insertSheetRecord(firstDay, lastDay);
                this.disableRevise = true;
                this.retrieveAssignmentRecords();
                this.deletedRecordsList = [];
            }
        }
    }

    /*
        function    : handleNextPreWeek
        Description : Handle changes when week changed from next and previous arrows.
        Parameters  : event 
    */
    handleNextPreWeek(event) {
        let value = event.target.dataset.id;
        let presentWeek = new Date(this.timeSheetRecord.EMS_TM_Week__c);
        console.log('presentWeek'+presentWeek);
        let lastDay;
        let week;
        if (this.managerView && !this.userSelected) {
            this.timeSheetRecord.EMS_TM_Week__c = this.thisWeek;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'User Selection',
                    message: 'Please select a user to view the entries',
                    variant: 'error',
                }),
            );
        } else {
            this.disableSubmited = false;
            if (value === 'pre') {
                week = new Date(presentWeek.getUTCFullYear(), presentWeek.getUTCMonth(), (presentWeek.getUTCDate() - 7));
            } else if (value === 'next') {
                week = new Date(presentWeek.getUTCFullYear(), presentWeek.getUTCMonth(), (presentWeek.getUTCDate() + 7));
            }
            lastDay = new Date(week.getUTCFullYear(), week.getUTCMonth(), week.getUTCDate() + 6);
            this.insertSheetRecord(week, lastDay);
            this.disableRevise = true;
            this.retrieveAssignmentRecords();
            this.deletedRecordsList = [];
        }
        console.log('week'+this.week);
    }

    /*
        function    : insertSheetRecord
        Description : Insert timesheet values
        Parameters  : firstDay, lastDay 
    */
    insertSheetRecord(firstDay, lastDay) {
        let firstMonth = firstDay.getMonth()+1 >= 10 ? firstDay.getMonth()+1 : '0'+(firstDay.getMonth()+1);
        let lastMonth = lastDay.getMonth()+1 >= 10 ? lastDay.getMonth()+1 : '0'+(lastDay.getMonth()+1);
        let firstDate = firstDay.getDate() >= 10 ? firstDay.getDate() : '0'+(firstDay.getDate());
        let lastDate = lastDay.getDate() >= 10 ? lastDay.getDate() : '0'+(lastDay.getDate());
        this.timeSheetRecord.EMS_TM_Week__c = firstDay.getFullYear() + '-' + firstMonth +'-'+ firstDate;
        this.timeSheetRecord.Week__c = firstDay.getFullYear() + '-' + firstMonth + '-' + firstDate + ' - ' + lastDay.getFullYear() + '-' + lastMonth + '-' + lastDate;
        this.disableNextButtons = this.thisWeek > this.timeSheetRecord.EMS_TM_Week__c ? false : true;
        this.showDates();
    }

    /*
        function    : showDates
        Description : To display dates when week is changed
        Parameters  : null 
    */
    showDates() {
        let week = new Date(this.timeSheetRecord.EMS_TM_Week__c);
        console.log('**WEEK'+week);
        console.log('WEEKValue'+week.valueOf());
        let dates = [];
        dates[0] = week.valueOf();
        for (let i = 1; i < 7; i++) {
            dates[i] = week.setDate(week.getDate() + 1);
        }
        dates = [...dates];
        console.log('***dates'+dates);
        this.weekDates.EMS_TM_Mon__c = dates[0];
        this.weekDates.EMS_TM_Tue__c = dates[1];
        this.weekDates.EMS_TM_Wed__c = dates[2];
        this.weekDates.EMS_TM_Thu__c = dates[3];
        this.weekDates.EMS_TM_Fri__c = dates[4];
        this.weekDates.EMS_TM_Sat__c = dates[5];
        this.weekDates.EMS_TM_Sun__c = dates[6];
    }

    /*
        function    : handleWeekendToggle
        Description : Handle changes to display weekend values
        Parameters  : event 
    */
    handleWeekendToggle(event) {
        if (event.target.checked) {
            this.showWeekend = true;
  
        } else if (!event.target.checked) {
            this.showWeekend = false;
            this.totalHours.value = this.totalHours.value - this.totalDayHours.EMS_TM_Sun__c - this.totalDayHours.EMS_TM_Sat__c;
            this.calculateTotalHours();
        }
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : handleRemarkToggle
        Description : Hide and show remarks for time sheet records
        Parameters  : event 
    */
    handleRemarkToggle(event) {
        if (event.target.checked) {
            this.showRemarks = true;
        } else {
            this.showRemarks = false;
        }
    }

    /*
        function    : handleManagerViewToggle
        Description : Hide and show remarks for time sheet records
        Parameters  : event 
    */
    handleManagerViewToggle(event) {
        this.hideSpinner = false;
        if (event.target.checked) {
            this.managerView = true;
            this.disableSubmited = true;
            this.timeSheetRecord.EMS_TM_Week__c = this.thisWeek;
            this.initialValues();
            this.calculateTotalHours();
            this.displayItemList = JSON.parse(JSON.stringify(this.records));
            this.disableRevise = true;//false
            this.hideSpinner = true;
        } else {
            this.hideSpinner = false;
            this.managerView = false;
            this.disableSubmited = false;
            this.disableRevise = false;
            this.userSelected = false;
            this.timeSheetRecord.User__c = this.userId;
            this.retrieveAssignmentRecords();
            this.deletedRecordsList = [];
        }
    }

    handleUserselection(event) {
        this.hideSpinner = false;
        console.log('handleUserselection event ', event);
        console.log('handleUserselection  userID', event.detail.value);
        this.timeSheetRecord.User__c = event.detail.value;
        this.timeSheetRecord.EMS_TM_Week__c = this.thisWeek;
        this.disableRevise = true;
        this.retrieveAssignmentRecords();
        this.deletedRecordsList = [];
        this.userSelected = true;
        // this.hideSpinner = true;
    }

    handleUserRemove(event) {
        this.userSelected = false;
        console.log('handleUserRemove event ', event);
        this.disableSubmited = true;
        this.timeSheetRecord.EMS_TM_Week__c = this.thisWeek;
        this.initialValues();
        this.calculateTotalHours();
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
        this.disableRevise = true;//false
    }

    /*
        function    : copyPreviousWeek
        Description : Retrieves time sheet values from previous week
        Parameters  : null 
    */
    copyPreviousWeek() {
        this.hideSpinner = false;
        getPreWeekData({ timesheet: this.timeSheetRecord }).then( result => {
            console.log('result copy pre',result);
            let timeSheetRecords = result.timeSheetRecords;
            if (timeSheetRecords) {
                // this.records = [];
                timeSheetRecords.forEach( record => {
                    let element = {};
                    element.projectTaskOptions = [];
                    element.projectAssignAvail = false;
                    if (this.projectRecords) {
                        element.projectAssignAvail = record.EMS_TM_ProjectTask__c ? true : false;
                        let project = this.projectRecords.find( item => item.Id === record.EMS_TM_Project__c);
                        if (project && project.EMS_TM_Project_Type__c !== 'OOO') {
                            element.EMS_TM_Project__c = record.EMS_TM_Project__c;
                            if (project.EMS_TM_Project_Type__c === 'OOO') {
                                element.projectTaskOptions = JSON.parse(JSON.stringify(this.pickListRecords.oooPicklist));
                            } else if (project.EMS_TM_Project_Type__c === 'Bench') {
                                element.projectTaskOptions = JSON.parse(JSON.stringify(this.pickListRecords.benchPicklist));
                            } else if (project.EMS_TM_Project_Type__c === 'Other') {
                                element.projectTaskOptions = JSON.parse(JSON.stringify(this.pickListRecords.otherPicklist));
                            }
                            element.projectValueAvailable = true;
                            for(let key in record) { element[key] = record[key]; }
                            delete element.Id;
                            delete element.EMS_Timesheet__c;
                            if (this.records[0].EMS_TM_Project__c) {
                                this.records.push(element);
                            } else {
                                this.records[0] = element;
                            }
                        }
                    }
                })
            }
            // this.deletedRecordsList = [];
            this.calculateTotalHours();
            this.displayItemList = JSON.parse(JSON.stringify(this.records));
            this.hideSpinner = true;
        }).catch( error => {console.log('error',error)});
    }

    /*
        function    : addRow
        Description : Adds new row
        Parameters  : null 
    */
    addRow() {
        this.keyIndex++;
        let newItem = { key: this.keyIndex, otherTask: false, EMS_TM_Sun__c: 0, EMS_TM_Mon__c: 0, EMS_TM_Tue__c: 0, EMS_TM_Wed__c: 0, EMS_TM_Thu__c: 0, EMS_TM_Fri__c: 0, EMS_TM_Sat__c: 0, projectTaskOptions: [], projectAssignAvail: false, projectTaskDuplicate: false, EMS_TM_ProjectTask__c: '' };
        this.records.push(newItem);
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : removeRow
        Description : Retrieves User name using Id
        Parameters  : event
    */
    removeRow(event) {
        if (!this.disableSubmited && !event.target.disabled) {
            this.hideSpinner = false;
            let index = event.target.dataset.id;
            let project = event.target.dataset.project ? true : false;
            if (this.timeSheetRecord.EMS_TM_Status__c === 'Saved' && this.records[index].Id) {
                this.deletedRecordsList.push(this.records[index]);
            }
            // this.template.querySelectorAll('lightning-input').forEach(field => {
            //     if (field.dataset.id === index && field.value!= '') {
            //         field = '';
            //     }
            // });
            // if (project) {
            //     this.template.querySelectorAll('lightning-input-field').forEach(field => {
            //         if (field.dataset.id === index && field.value!= '') {
            //             field.reset();
            //         }
            //     });
            // } else {
            //     this.template.querySelectorAll('c-ems-custom-look-up').forEach(field => {
            //         if (field.indexId === parseInt(index)) {
            //             field.handleRemovePill();
            //         }
            //     });
            // }
            this.records[index].projectValueAvailable = false;
            this.records.splice(index, 1);
            for (let i = 0; i < this.records.length; i++) {
                if(this.records[i].otherTask) {
                    this.showOtherTask = true;
                    break;
                } else {
                    this.showOtherTask = false;
                }
            }
            this.calculateTotalHours();
            console.log('records=> ',this.records.length);
            if (this.records.length === 0) {
                this.records = [{key: 0, otherTask: false, EMS_TM_Sun__c: 0, EMS_TM_Mon__c: 0, EMS_TM_Tue__c: 0, EMS_TM_Wed__c: 0, EMS_TM_Thu__c: 0, EMS_TM_Fri__c: 0, EMS_TM_Sat__c: 0, projectTaskOptions: [], projectAssignAvail: false, projectTaskDuplicate: false, EMS_TM_ProjectTask__c: ''}];
            }

            console.log('this.deletedRecordsList => ', this.deletedRecordsList);
            this.displayItemList = JSON.parse(JSON.stringify(this.records));
            console.log('this.displayItemList ',this.displayItemList);
            this.hideSpinner = true;
        }
    }

    /*
        function    : handleUserInput
        Description : Handles values entered by user
        Parameters  : event 
    */
    handleUserInput(event) {
        let value = event.target.value;
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        if (fieldName === 'EMS_TM_ProjectTask__c') {
            this.handleProjecttaskSelection(value, index);
        } else  if (fieldName.length === 13) {
            this.records[index][fieldName] = value;
            if (value === '' || value == null) {
                this.records[index][fieldName] = '00';
            } else {
                this.records[index][fieldName] = parseFloat(value);
            }
            this.calculateTotalHours();
        } else {
            this.records[index][fieldName] = value;
        
        }
        if ((fieldName === 'EMS_TM_Sat__c' || fieldName === 'EMS_TM_Sun__c') && parseFloat(value) > 0) {
            this.showRemarks = true;
            this.template.querySelector('[data-id="remarkToggle"]').checked = true;
            this.records[index].remarkRequired = true;
        } else {
            this.records[index].remarkRequired = false;
        }
        console.log('this.records[index] ',this.records[index]);
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : removeRetrievedProject
        Description : Removes selected project when retrieved from a saved timesheet
        Parameters  : event 
    */
    removeRetrievedProject(event) {
        let ind = event.target.dataset.id;
        this.handleProjectRemove({detail:{name: 'EMS_TM_Project__c', index: ind}});
        this.records[ind].projectValueAvailable = false;
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : handleProjectselection
        Description : Handles project selected from generic custom lookup
        Parameters  : event 
    */
    handleProjectselection(e) {
        let val = JSON.parse(JSON.stringify(e.detail));
        let fieldName = val.name;
        let index = val.index;
        let value = val.value;
        let assignment = this.assignmentRecords.filter( item => item.EMS_TM_ProjectName_Asgn__c === value);
        let type;
        console.log('handleProjectselection this.assignmentRecords ',this.assignmentRecords);
        console.log('handleProjectselection assignment ',assignment);
        this.records[index][fieldName] = value;
        this.records[index].projectValueAvailable = true;
        this.records[index].projectName = val.recordName;
        this.projectRecords.forEach( project => {
            if (project.Id === value) {
                type = project.EMS_TM_Project_Type__c;
            }
        });
        if (assignment.length === 1) {
            this.records[index].projectAssignAvail = true;
            this.records[index].EMS_TM_ProjectTask__c = assignment[0].EMS_TM_AssignedAs__c;
        } else if(assignment.length > 1) {
            let picklist = [];
            assignment.forEach(assign => {
                picklist.push({value: assign.EMS_TM_AssignedAs__c, label: assign.EMS_TM_AssignedAs__c});
            });
            this.records[index].projectTaskOptions = picklist;
        } else {
            this.handlePicklistValues(index, type);
        }
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : handlePicklistValues
        Description : Assign picklist options for task picklist.
        Parameters  : index, type 
    */
    handlePicklistValues(index, type) {
        let picklist = [];
        if (type === 'Client') {
            picklist = JSON.parse(JSON.stringify(this.pickListRecords.clientPicklist));
        } else if (type === 'OOO') {
            picklist = JSON.parse(JSON.stringify(this.pickListRecords.oooPicklist));
        } else if (type === 'Bench') {
            picklist = JSON.parse(JSON.stringify(this.pickListRecords.benchPicklist));
        // } else if (type === 'Other') {
        //     picklist = JSON.parse(JSON.stringify(this.pickListRecords.otherPicklist));
        }
        this.records[index].projectTaskOptions = picklist;
    }

    /*
        function    : handleProjectRemove
        Description : Handles project removal from generic custom lookup
        Parameters  : event 
    */
    handleProjectRemove(e) {
        let val = JSON.parse(JSON.stringify(e.detail));
        let fieldName = val.name;
        let index = val.index;
        this.records[index][fieldName] = '';
        this.records[index].projectName = '';
        this.handlePicklistValues(index, '');
        for (let key in this.records[index]) {
            if (key === 'EMS_TM_ProjectTask__c') {
                this.records[index][key] = '';
                this.handleProjecttaskSelection('', index);
            } else if (key === 'EMS_TM_Remarks__c' || key === 'EMS_TM_OtherTask__c') {
                this.records[index][key] = '';
            } else if (key.length === 13) {
                this.records[index][key] = 0;
            }
        }
        this.calculateTotalHours();
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : handleProjecttaskSelection
        Description : Handles project task picklist selection
        Parameters  : value, index 
    */
    handleProjecttaskSelection(value, index) {
        this.showOtherTask = false;
        if (value === 'Other') {
            this.records[index].otherTask = true;
        } else {
            this.records[index].otherTask = false;
        }
        for (let i = 0; i < this.records.length; i++) {
            if(this.records[i].otherTask) {
                this.showOtherTask = true;
                break;
            }
            // if (i != index) {
            //     if (this.records[i].EMS_TM_Project__c === this.records[index].EMS_TM_Project__c && this.records[i].EMS_TM_ProjectTask__c === this.records[index].EMS_TM_ProjectTask__c) {
            //         this.records[index].projectTaskDuplicate = true;
            //     } else {
            //         this.records[index].projectTaskDuplicate = false;
            //     }
            // } else {
            //     this.records[index].projectTaskDuplicate = false;
            // }
            // if ( i != index && this.records[i].EMS_TM_Project__c === this.records[index].EMS_TM_Project__c && this.records[i].EMS_TM_ProjectTask__c === this.records[index].EMS_TM_ProjectTask__c) {
            //     this.records[index].projectTaskDuplicate = true;
            // } else {
            //     this.records[index].projectTaskDuplicate = false;
            // }
        }
        this.records[index].EMS_TM_ProjectTask__c = value;
    }

    /*
        function    : calculateTotalHours
        Description : Calculates total hours for values entered
        Parameters  : null 
    */
    calculateTotalHours() {
        let letTotalHours = 0;
        let weekendHours = 0;
        this.totalDayHours = {EMS_TM_Sun__c: 0,EMS_TM_Mon__c: 0,EMS_TM_Tue__c: 0,EMS_TM_Wed__c: 0,EMS_TM_Thu__c: 0,EMS_TM_Fri__c: 0,EMS_TM_Sat__c: 0,};

        this.records.forEach( element => {
            let totalWeekEntered = 0;
            for(let key in element) {
                if (key.length === 13 && element[key]) {
                    let x = parseFloat(element[key]);
                    this.totalDayHours[key] = this.totalDayHours[key] + x;
                    totalWeekEntered = totalWeekEntered + x;
                }
            }
            element.Total_Hours__c = totalWeekEntered;
        });

        for( let key in this.totalDayHours) {
            if (this.totalDayHours[key] && key.length === 13 && (key != 'EMS_TM_Sat__c' && key != 'EMS_TM_Sun__c')) {
                let error = 'error'+key;
                if (this.totalDayHours[key] > 24 || this.totalDayHours[key] < 0 ) {
                    this.totalDayHours[error] = true;
                } else {
                    this.totalDayHours[error] = false;
                }
                letTotalHours = letTotalHours + this.totalDayHours[key];
            } else if (this.totalDayHours[key] && key.length === 13 && (key === 'EMS_TM_Sat__c' || key === 'EMS_TM_Sun__c')) {
                let error = 'error'+key;
                if (this.totalDayHours[key] > 24 || this.totalDayHours[key] < 0 ) {
                    this.totalDayHours[error] = true;
                } else {
                    this.totalDayHours[error] = false;
                }
                letTotalHours = letTotalHours + this.totalDayHours[key];
                weekendHours = weekendHours + this.totalDayHours[key];
            }
        }
        this.totalHours.value = letTotalHours;
        this.weekendEnteredValue = weekendHours;
         if (this.totalHours.value > 168) {
            this.totalHours.error = true;
         } else {
             this.totalHours.error = false;
         }
    }

    /*
        function    : confirmPopUp
        Description : Displays confirm popup when clicked on Submit button
        Parameters  : null 
    */
    confirmPopUp() {
         console.log('+++++ IN confirmPopUp++++++');
        if (this.weekendEnteredValue > 0) {
            this.weekendEntered = true;
        } else {
            this.weekendEntered = false;
        }
        if (this.weekendEntered && this.compoffAlredyexist == false) {
            this.showCompOffPopUp = true;
            this.confirmModal.message = 'Are you sure you want to add data in weekend';
            this.confirmModal.confirmLabel = 'Yes';
            this.confirmModal.cancelLabel = 'No';
            this.confirmModal.title = 'Compoff Request';
        } else {
            this.confirmModal.message = 'Please note that the timesheet once submitted cannot be edited';
            this.confirmModal.confirmLabel = 'OK';
            this.confirmModal.cancelLabel = 'Cancel';
            this.confirmModal.title = 'Confirm Submission';
            this.showModalPopUp = true;
        }
    }
submitpopup(){
    console.log('IN submitpopup++++++');
   // this.showModalPopUp = false;
    this.showCompOffPopUp=false;
    this.weekendEntered = false
   //  this.showModalPopUp = false;
    this.confirmModal.message = 'Please note that the timesheet once submitted cannot be edited';
            this.confirmModal.confirmLabel = 'OK';
            this.confirmModal.cancelLabel = 'Cancel';
            this.confirmModal.title = 'Confirm Submission';
            this.showModalPopUp = true;
}
    /*
        function    : handleResponce
        Description : Handles response from confirm popup when clicked on Submit button
        Parameters  : event 
    */
    handleResponce(event) {
        this.showModalPopUp = false;
        if (event.detail.status === 'cancel') {
            this.showModalPopUp = false;
        } else if (event.detail.status === 'confirm') {
            event.target.name = 'Submitted';
            this.handleValidation(event);
            /* if (this.weekendEnteredValue > 0 && this.compoffCheck == true) {
                 this.handlesaveCompOffRecord();
             }*/
        }
    }

    /*
        function    : handleCompoffResponce
        Description : Handles response from confirm popup when clicked on Submit button
        Parameters  : event 
    */
    handleCompoffResponce(event) {
       // this.showModalPopUp = false;
        if (event.detail.status === 'cancel') {
              // this.confirmPopUp();
              this.compoffCheck = false;
               this.submitpopup();
            console.log('handleCompoffResponce No');
        } else if (event.detail.status === 'confirm') {
            this.compoffCheck = true;
            console.log('handleCompoffResponce Yes');
            this.submitpopup();
        }
    
    }
    connectedCallback() {
        var comoff = null;
              checkcomppRec({userId:user_Id,compOffweek :this.comoff})
        .then(result => {
            window.console.log('handlecheckCompOffRec ===> '+JSON.stringify(result));
            if(result == true){
                this.compoffAlredyexist = true;
               /*this.dispatchEvent(new ShowToastEvent({
                                        title:'you have alredy Compoff Record',
                                        message:'you have alredy Compoff Record in this week',
                                        variant: 'success',
                                    }),
                                );*/
            }else{
                 this.compoffAlredyexist = false;
            } 
        })
        .catch(error => {
            console.log('handlecheckCompOffRecError'+JSON.stringify(error));
        });
    }

    handlecheckCompOffRec(){      
         console.log('handlecheckCompOffRecDate'+this.thisWeek +'userId'+user_Id);
            checkcomppRec({userId:user_Id,compOffweek :this.thisWeek})
        .then(result => {
            window.console.log('handlecheckCompOffRec ===> '+JSON.stringify(result));
            if(result == true){
                this.compoffAlredyexist = true;
             /*  this.dispatchEvent(new ShowToastEvent({
                                        title:'you have alredy Compoff Record',
                                        message:'you have alredy Compoff Record in this week',
                                        variant: 'success',
                                    }),
                                );*/
            }else{
                 this.compoffAlredyexist = false;
            }
        })
        .catch(error => {
            console.log('handlecheckCompOffRecError'+JSON.stringify(error));
        });
    }

    handlesaveCompOffRecord(){
           console.log('data'+this.thisWeek);
            savecomppRec({userId:user_Id,compoffhours:this.weekendEnteredValue,compOffweek :this.thisWeek})
        .then(result => {
            window.console.log('compOffRecordresult ===> '+JSON.stringify(result));
           
            // Show success messsage
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Compoff Record Created Successfully!!',
                variant: 'success'
            }),);
        })
        .catch(error => {
            console.log('compOffError'+JSON.stringify(error));
            /*this.dispatchEvent(new ShowToastEvent({
                                        title: error.body.message,
                                        message:error.body.message,
                                        variant: 'error',
                                    }),
                                );*/
            this.error = error.message;
        });
    }

    checkValidation() {
        for( let key in this.totalDayHours ) {
            if (key.length === 13 && (key != 'EMS_TM_Sat__c' && key != 'EMS_TM_Sun__c')) {
                let error = 'error'+key;
                if (this.totalDayHours[key] > 24 || this.totalDayHours[key] < 8 ) {
                    this.isValid = false;
                    this.totalDayHours[error] = true;
                } else {
                    this.totalDayHours[error] = false;
                }
            } else if (key.length === 13 && (key === 'EMS_TM_Sat__c' || key === 'EMS_TM_Sun__c')) {
                let error = 'error'+key;
                if (this.totalDayHours[key] > 24 || this.totalDayHours[key] < 0 ) {
                    this.isValid = false;
                    this.totalDayHours[error] = true;
                } else {
                    this.totalDayHours[error] = false;
                }
            }
        }
    }

    handleRevise(event) {
        console.log('handleRevert event ',event);
        this.hideSpinner = false;
        reviseTimesheet({timesheet: this.timeSheetRecord}).then( result => {
            console.log('result ',result);
            if (result === 'Success') {
                this.handleSuccess('Timesheet successfully Revised');
                this.retrieveRecords();
                this.disableSubmited = timeSheet.EMS_TM_Status__c === 'Submitted' || timeSheet.EMS_TM_Status__c === 'Locked' ? true : false;
            } else {
                this.recordId = '';
                this.hideSpinner = true;
            }
            // this.hideSpinner = true;
        }).catch(error => {
            console.log('1-error',error);
            this.error = error;
            this.hideSpinner = true;
        });
    }

    /*
        function    : handleValidation
        Description : Check validation and saves or submits data when user clicks on Save or Submit button
        Parameters  : event 
    */
    handleValidation(event) {
        this.hideSpinner = false;
        this.isValid = true;
        let type = event.target.name;
        let isInputError = null;
        let isLookupError = null;
        this.template.querySelectorAll('lightning-input').forEach(element => element.reportValidity());
        this.template.querySelectorAll('lightning-combobox').forEach(element => element.reportValidity());
        this.template.querySelectorAll('c-ems-custom-look-up').forEach(element => element.reportValidation());
        if (type === 'Submitted') {
            this.checkValidation();
        }
        isInputError = this.template.querySelector(".slds-has-error");
        this.template.querySelectorAll('c-ems-custom-look-up').forEach(element => {isLookupError = element.hasErrors()});

        if (isInputError === null && isLookupError === null && this.isValid) {
            for (let key in this.totalDayHours) {
                this.timeSheetRecord[key] = this.totalDayHours[key];
            }
    
            this.timeSheetRecord.EMS_TM_Status__c = type;
            this.records.forEach(ele => {
                ele.Status__c = type;
            });
            if (this.recordId === '') {
                duplicatetimesheetLWC({ timesheet : this.timeSheetRecord }).then(result => {
                    console.log('result ',result);
                    if (result) {
                        this.hideSpinner = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error while creating record',
                                message: 'Oops!... Timesheet has already been Saved for the above date',
                                variant: 'error',
                            }),
                        );
                    } else {
                         //this.records.Status__c ='Saved';
                        saveTimeSheetRecords({timeRecords: this.records, timesheet : this.timeSheetRecord})
                        .then(result => {
                            console.log('saveTimeSheetRecordsresult ',result);
                          //  console.log('saveTimeSheetRecordsresult1 ',JSON.stringify(result));
                            if (result.includes('Success')) {
                                this.recordId = result.slice(7);
                                if (this.timeSheetRecord.EMS_TM_Status__c === 'Submitted') {
                                    console.log('SubmittedTimesheet');
                                     if (this.weekendEnteredValue > 0 && this.compoffCheck == true) {
                                        this.handlesaveCompOffRecord();
                                    }
                                    this.handleSuccess('Timesheet successfully created and submitted');
                                } else if (this.timeSheetRecord.EMS_TM_Status__c === 'Saved') {
                                    this.handleSuccess('Timesheet successfully created');
                                }
                                this.retrieveRecords();
                                this.disableSubmited = this.timeSheetRecord.EMS_TM_Status__c === 'Submitted' || this.timeSheetRecord.EMS_TM_Status__c === 'Locked' ? true : false;
                            } else {
                                this.recordId = '';
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error while creating record',
                                        message: 'You didnot have the access or not enterd the proper data',
                                        variant: 'error',
                                    }),
                                );
                                this.hideSpinner = true;
                            }
                            // this.hideSpinner = true;
                        }).catch(error => {
                            console.log('1-error',error);
                            this.error = error;
                            this.hideSpinner = true;
                        });
                    }
                }).catch(error => {
                    console.log('2-error',error);
                    this.error = error;
                    this.hideSpinner = true;
                });
            } else {
                let updateRecords = [];
                let newRecords = [];
                this.records.forEach( record => {
                    if (record.Id) {
                       // record.Status__c ='Submitted';
                        updateRecords.push(record);
                    } else {
                        newRecords.push(record);
                    }
                })
                updateTimeSheetRecords( {updateRecords: updateRecords, newRecords: newRecords, deleteRecords: this.deletedRecordsList, timesheet : this.timeSheetRecord} ).then(result => {
                    console.log('updateTimeSheetRecordsresult ',result);
                    if (result.includes('Success')) {
                        this.recordId = result.slice(7);
                        if (this.timeSheetRecord.EMS_TM_Status__c === 'Submitted') {
                             if (this.weekendEnteredValue > 0 && this.compoffCheck == true) {
                                        this.handlesaveCompOffRecord();
                                    }
                            this.handleSuccess('Timesheet successfully updated and submitted');
                        } else if (this.timeSheetRecord.EMS_TM_Status__c === 'Saved') {
                            this.handleSuccess('Timesheet successfully updated');
                        }
                        this.retrieveRecords();
                        this.disableSubmited = this.timeSheetRecord.EMS_TM_Status__c === 'Submitted' || this.timeSheetRecord.EMS_TM_Status__c === 'Locked' ? true : false;
                        this.deletedRecordsList = [];
                    } else {
                        this.recordId = '';
                        this.hideSpinner = true;
                    }
                    // this.hideSpinner = true;
                }).catch( error => {
                    console.log('error',error);
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error while creating record',
                            message: error.body.pageErrors[0].message,
                            variant: 'error',
                        }),
                    );
                    this.hideSpinner = true;
                });
            }

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while creating record',
                    message: 'Oops!... Please enter all the required fields with appropriate data',
                    variant: 'error',
                }),
            );
            this.hideSpinner = true;
        }
    }

    /*
        function    : handleCancel
        Description : Clear values of on click
        Parameters  : null 
    */
    handleClear() {
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'EMS_Timesheet__c',
                actionName: 'home'
            },
        });*/
        this.initialValues();
        this.calculateTotalHours();
        this.displayItemList = JSON.parse(JSON.stringify(this.records));
    }

    /*
        function    : handleSuccess
        Description : Displays toast message when values saved, submitted or updated successfully 
        Parameters  : msg 
    */
    handleSuccess(msg) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: msg,
                variant: 'success',
            }),
        );
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'EMS_Timesheet__c',
                actionName: 'view'
            },
        });*/
    }
}