import { LightningElement, api, wire, track } from 'lwc';
import fetchContactRecordsData from '@salesforce/apex/ChangeProjectActionButtonController.fetchContactRecordsData';
import fetchActiveProjectsList from '@salesforce/apex/ChangeProjectActionButtonController.fetchActiveProjectsList';
import getPicklistValues from '@salesforce/apex/GetDataForLoginUser.getPicklistValues';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class ChangeProjectActionButton extends LightningElement {
    @api recordId;
    resultRecords;
    error;
    @track projectsList;
    @track activeProjectsList;
    @track picklistValues = [];
    @track isShowModal = true;
    @api contactId = '';

    connectedCallback() {
        console.log('Conatct id list 18 => '+this.contactId);
    }

    @wire(fetchContactRecordsData, { contactId: '$contactId' })
    contactProjectsData({ data, error }) {
        if (data) {
            this.resultRecords = data;
            console.log('Project details => '+JSON.stringify(this.resultRecords));
        } else {
            this.error = error;
            console.log('Error ==> ' + this.error);
        }
    }

    @wire(fetchActiveProjectsList)
    activeProjectsList({ data, error }) {
        if (data) {
            try {
                this.activeProjectsList = data;
                let options = [];
                for (var key in data) {
                    options.push({ label: data[key].Name, value: data[key].Id  });
                }
                this.projectsList = options;
            }catch (error) {
                console.error('check error here', error);
            } 
        } else {
            this.error = error;
            console.log('Error2 ==> ' + JSON.stringify(this.error));
        }
    }

    @wire(getPicklistValues, { objectName: 'EMS_TM_Assignment__c', fieldName: 'EMS_TM_Status_Asgn__c' })
    retrievePicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data.map((value) => ({
                label: value,
                value: value
            }));
        } else if (error) {
            console.error('Error retrieving picklist values:', error);
        }
    }

    closeAction() { 
        this.dispatchEvent(new CloseActionScreenEvent());
    } 

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}