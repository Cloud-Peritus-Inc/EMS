import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Contact.Name',
    'Contact.EMS_RM_Current_Job_Role__c',
    'Contact.EMS_Phone_Number__c',
    'Contact.Email',
	'Contact.Department',
    'Contact.EMS_RM_Employee_Id__c',
    'Contact.EMS_RM_ApplicantStatus_Update__c',
    'Contact.Age__c',
];
export default class ApplicantDetails extends LightningElement {

    @api recordId;
    @track contact;
    @track name;
    @track designation;
    @track phone;
    @track email;
	@track Department;
    @track empId;
    @track empStatus;
    @track age;


    @wire(getRecord,  { recordId: '$recordId', fields: FIELDS}) 
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading contact',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.contact = data;
            this.name = this.contact.fields.Name.value;
            this.designation = this.contact.fields.EMS_RM_Current_Job_Role__c.value;
            this.phone = this.contact.fields.EMS_Phone_Number__c.value;
            this.email = this.contact.fields.Email.value;
			this.department = this.contact.fields.Department.value;
            this.empId = this.contact.fields.EMS_RM_Employee_Id__c.value;
            this.empStatus = this.contact.fields.EMS_RM_ApplicantStatus_Update__c.value;
            this.age = this.contact.fields.Age__c.value;
        }
    }    
}