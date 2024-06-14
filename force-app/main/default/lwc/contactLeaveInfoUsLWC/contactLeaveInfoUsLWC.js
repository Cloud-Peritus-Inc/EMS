import { LightningElement,wire,api } from 'lwc';
import contctInfoMethod from '@salesforce/apex/ContactInformationController.contctInfoMethod';
import Id from "@salesforce/user/Id";
export default class ContactLeaveInfoUsLWC extends LightningElement {
 UserId=Id;
 contactData={};
 @wire(contctInfoMethod, { userId: '$UserId' })
    wiredContactData({ error, data }) {
        if (data) {
            this.contactData = data;
            console.log('this.contactData ****', this.contactData);
        } else if (error) {
            console.error('Error fetching contact data:', error);
        }
    }
}