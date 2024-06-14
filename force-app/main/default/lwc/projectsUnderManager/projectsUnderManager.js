import { LightningElement, wire, track } from 'lwc';
import loggedInUserId from '@salesforce/user/Id';
import getProjectsList from "@salesforce/apex/GetProjectsController.getProjects";

// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import NAME_FIELD from '@salesforce/schema/EMS_TM_Project__c.Name';
// import RECORD_TYPE_FIELD from '@salesforce/schema/EMS_TM_Project__c.RecordTypeId';
// import START_DATE_FIELD from '@salesforce/schema/EMS_TM_Project__c.EMS_TM_StartDate__c';
// import END_DATE_FIELD from '@salesforce/schema/EMS_TM_Project__c.EMS_TM_EndDate__c';
// import STATUS_FIELD from '@salesforce/schema/EMS_TM_Project__c.EMS_TM_Status__c';

export default class ProjectsUnderManager extends LightningElement {
    @track projectslist = { };

    // const columns = [
    //            { label: 'Project Name', fieldName: NAME_FIELD.fieldApiName, type: 'text' },
    //            { label: 'Start Date', fieldName: START_DATE_FIELD.fieldApiName, type: 'date' },
    //            { label: 'End Date', fieldName: END_DATE_FIELD.fieldApiName, type: 'date' },
    //            { label: 'Status', fieldName: STATUS_FIELD.fieldApiName, type: 'text' },
    //            { label: 'Record Type', fieldName: RECORD_TYPE_FIELD.fieldApiName, type: 'text' }
    // ];




    @wire(getProjectsList) 
    projectsData({ error, data }) {
        if (data) {
             console.log('Data', data);
             this.projectslist = data;
             alert('==ProjectsDAta==='+this.projectslist);
         } else if (error) {
             console.error('Error:', error);
         }
     }
}