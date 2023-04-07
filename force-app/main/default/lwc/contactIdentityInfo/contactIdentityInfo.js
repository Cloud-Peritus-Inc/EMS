import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PAN_FIELD from '@salesforce/schema/Contact.EMS_EM_PanNo__c';
import AADHAR_FIELD from '@salesforce/schema/Contact.EMS_EM_AadhaarNo__c';
import UAN_FIELD from '@salesforce/schema/Contact.EMS_EM_PFno__c';
import DL_FIELD from '@salesforce/schema/Contact.EMS_Driving_License_No__c';
import PP_FIELD from '@salesforce/schema/Contact.EMS_EM_PassportNo__c';
import DOB_FIELD from '@salesforce/schema/Contact.EMS_EM_DOB__c';
import getContactInfo from '@salesforce/apex/resourceTileController.getContactInfo';
export default class ContactIdentityInfo extends LightningElement {
@api recordId;
showthedata = false;

connectedCallback() {
    console.log('===rec===='+this.recordId);  
}
fields = [PAN_FIELD, AADHAR_FIELD, UAN_FIELD,DL_FIELD,PP_FIELD,DOB_FIELD];
 @wire(getContactInfo,{conid : '$recordId'})
    userInfo({ error, data }) {
    if (data) {
         console.log('===data.loggedinresource===='+data.loggedinresource);  
      this.showthedata = data.loggedinresource;
    } else if (error) {
      console.error(error);
    }
  }
handleSubmit(event){
}

}