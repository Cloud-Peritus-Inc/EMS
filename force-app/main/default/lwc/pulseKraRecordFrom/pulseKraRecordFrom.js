import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import WORK_ENVIRONMENT from '@salesforce/schema/Goal__c.Work_Environment__c';
import COMMUNICATION from '@salesforce/schema/Goal__c.Communication__c';
import CAREER_DEVELOPMENT from '@salesforce/schema/Goal__c.Career_Development__c';
import WORK_LIFE_BALANCE from '@salesforce/schema/Goal__c.Work_Life_Balance__c';
import FEED_BACK_RECOGNITION from '@salesforce/schema/Goal__c.Feedback_and_Recognition__c';
import LEADERSHIP_MANAGEMENT from '@salesforce/schema/Goal__c.Leadership_and_Management__c';
import FEEDBACK_COMMENTS from '@salesforce/schema/Goal__c.Feedback_and_Comments__c';
import STATUS from '@salesforce/schema/Goal__c.Status__c';
import RESOURCE_NAME from '@salesforce/schema/Goal__c.Resource__c';
import ID_FIELD from '@salesforce/schema/Goal__c.Id';
//import apex methods
import fetchPulseRecord from "@salesforce/apex/pulseKraRecordFromController.fetchPulseRecord"; 
import updatePulseRecord from "@salesforce/apex/pulseKraRecordFromController.updatePulseRecord";


import { ShowToastEvent } from "lightning/platformShowToastEvent";

const FIELDS = [WORK_ENVIRONMENT, COMMUNICATION, CAREER_DEVELOPMENT, WORK_LIFE_BALANCE, FEED_BACK_RECOGNITION, LEADERSHIP_MANAGEMENT, FEEDBACK_COMMENTS, STATUS,RESOURCE_NAME];

export default class PulseKraRecordFrom extends NavigationMixin(LightningElement) {
    @api recordId = '';

    statusSubmited = 'Pulse Submitted';
    statusRequested = 'Pulse Requested';
    WorkEnvironment = '';
    Communication = '';
    CareerDevelopment = '';
    WorkLifeBalance = '';
    FeedbackRecognition = '';
    LeadershipManagement = '';
    FeedbackComments = '';
    JobSatisfaction = '';

    disableSubmitBtn = false;
    showForm = false;
    showFormSubmittedMsg = false;
    resourceName = '';


    @wire(fetchPulseRecord, { recordId: '$recordId' })
    wiredRecords({ error, data }) {
        if (data) {
            if (data.Status__c == this.statusSubmited) {
                this.showFormSubmittedMsg = true;
                this.showForm = false;
            }
            if (data.Status__c == this.statusRequested) {
                this.disableSubmitBtn = false;
                this.showFormSubmittedMsg = false;
                this.resourceName = data.Resource__r.Name;
                this.showForm = true;
            }
            
        } else if (error) {
            console.log("wiredRecords error " + JSON.stringify(error) );
        }
    }

    @api
    get getResourceName() {
        return this.resourceName;
    }

    rating(event) {
        if (event.target.name === "Work Environment") {
            console.log('Rating Value : ' + event.target.value);
            this.WorkEnvironment = event.target.value;
        }
        if (event.target.name === "Communication") {
            console.log('Rating Value : ' + event.target.value);
            this.Communication = event.target.value;
        }
        if (event.target.name === "Career Development") {
            console.log('Rating Value : ' + event.target.value);
            this.CareerDevelopment = event.target.value;
        }
        if (event.target.name === "Work-Life Balance") {
            console.log('Rating Value : ' + event.target.value);
            this.WorkLifeBalance = event.target.value;
        }
        if (event.target.name === "Feedback and Recognition") {
            console.log('Rating Value : ' + event.target.value);
            this.FeedbackRecognition = event.target.value;
        }
        if (event.target.name === "Leadership and Management") {
            console.log('Rating Value : ' + event.target.value);
            this.LeadershipManagement = event.target.value;
        }
        if (event.target.name === "Job Satisfaction") {
            console.log('Rating Value : ' + event.target.value);
            this.JobSatisfaction = event.target.value;
        }
    }

    setFeedbackComments(event) {
        this.FeedbackComments = event.target.value;
    }

    handleSubmit() {
        console.log(" handleSubmit ");
        if ((!this.WorkEnvironment) || (!this.Communication) || (!this.CareerDevelopment) || (!this.WorkLifeBalance) || (!this.FeedbackRecognition) || (!this.LeadershipManagement) || (!this.FeedbackComments) || (!this.JobSatisfaction)) {
            const event = new ShowToastEvent({
                title: '',
                message: 'All field values are required!',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
        } else {
            let pulse = { 'sobjectType': 'Goal__c' };
            pulse.Id = this.recordId;
            pulse.Work_Environment__c = this.WorkEnvironment;
            pulse.Communication__c = this.Communication;
            pulse.Career_Development__c = this.CareerDevelopment;
            pulse.Work_Life_Balance__c = this.WorkLifeBalance;
            pulse.Feedback_and_Recognition__c = this.FeedbackRecognition;
            pulse.Leadership_and_Management__c = this.LeadershipManagement;
            pulse.Feedback_and_Comments__c = this.FeedbackComments;
            pulse.Job_Satisfaction__c = this.JobSatisfaction;
            pulse.Status__c = this.statusSubmited;
            //Invoke apex method to updateRecord
            updatePulseRecord({pulseRecord: pulse})
                .then((record) => {
                    console.log(record);
                    if (record) {
                        if(record.Status__c == this.statusSubmited){
                            this.disableSubmitBtn = true;
                            const event = new ShowToastEvent({
                                title: '',
                                message: 'Feedback Submitted Successfully !!',
                                variant: 'success',
                                mode: 'dismissable'
                            });
                            this.dispatchEvent(event);
    
                            this[NavigationMixin.Navigate]({
                                type: 'comm__namedPage',
                                attributes: {
                                    name: 'Home'
                                }
                            });
                        }
                    }
                }).catch(error => {
                    console.log(JSON.stringify(error));
                    this.disableSubmitBtn = false;
                    const event = new ShowToastEvent({
                        title: '',
                        message: 'Error Submitting Feedback !!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                })

        }
    }

    handleCancle(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}