import {
  LightningElement,
  api,
  wire,
  track
} from 'lwc';
import {
  getRecord,
  getFieldValue
} from "lightning/uiRecordApi";
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import COUNTRY_FIELD from '@salesforce/schema/Contact.Work_Location_Country__c';
import UTILIZED_LEAVES_FIELD from '@salesforce/schema/Contact.EMS_LM_No_Of_Utilized_Leaves__c';
import CREDITED_LEAVES_FIELD from '@salesforce/schema/Contact.EMS_LM_No_Of_Leaves_Credit__c';
import AVAILABLE_LEAVES_FIELD from '@salesforce/schema/Contact.EMS_LM_No_Of_Availble_Leaves__c';
import AVAILABLE_FLOAT_LEAVES_FIELD from '@salesforce/schema/Contact.No_of_Avilable_floatLeave_credits__c';
import UTILIZED_FLOAT_LEAVES_FIELD from '@salesforce/schema/Contact.UtlizedFloatLeaves__c';
import UTILIZED_LOP_LEAVES_FIELD from '@salesforce/schema/Contact.EMS_LM_No_Of_Utilized_Loss_Of_Pay__c';
import UTILIZED_WFH_FIELD from '@salesforce/schema/Contact.No_OF_Utilized_Work_from_Home__c';

import No_of_Paid_Time_Off_leaves_credited__c from '@salesforce/schema/Contact.No_of_Paid_Time_Off_leaves_credited__c';
import No_of_Paid_Time_Off_leaves_utilised__c from '@salesforce/schema/Contact.No_of_Paid_Time_Off_leaves_utilised__c';
import No_of_Paid_Time_Off_leaves_available__c from '@salesforce/schema/Contact.No_of_Paid_Time_Off_leaves_available__c';
import No_of_Floating_Holiday_Leaves_Credited__c from '@salesforce/schema/Contact.No_of_Floating_Holiday_Leaves_Credited__c';
import No_of_Floating_Holiday_leaves_utilised__c from '@salesforce/schema/Contact.No_of_Floating_Holiday_leaves_utilised__c';
import No_of_Unpaid_time_Off_leaves_utilised__c from '@salesforce/schema/Contact.No_of_Unpaid_time_Off_leaves_utilised__c';
import No_OF_Utilized_Work_from_Home__c from '@salesforce/schema/Contact.Number_of_Work_From_Home_s__c';



const fields = [COUNTRY_FIELD];
export default class CpContactDetailForm extends LightningElement {
  @api recordId;
  @api objectApiName;
  
  // List of fields to be shown on the UI
  USfields = [No_of_Paid_Time_Off_leaves_utilised__c, No_of_Paid_Time_Off_leaves_available__c, No_of_Floating_Holiday_Leaves_Credited__c,
    No_of_Floating_Holiday_leaves_utilised__c,No_of_Paid_Time_Off_leaves_credited__c,
    No_of_Unpaid_time_Off_leaves_utilised__c,No_OF_Utilized_Work_from_Home__c
  ];
  nonUSFields = [NAME_FIELD,CREDITED_LEAVES_FIELD, UTILIZED_LEAVES_FIELD, AVAILABLE_LEAVES_FIELD,
    AVAILABLE_FLOAT_LEAVES_FIELD, UTILIZED_FLOAT_LEAVES_FIELD, UTILIZED_LOP_LEAVES_FIELD, UTILIZED_WFH_FIELD];


  // Flexipage provides recordId and objectApiName
  
  
connectedCallback() {
  
  console.log('checking US region',this.recordId);
  console.log('checking api object name',this.objectApiName);
}
  //Wire the output of the out of the box method getRecord to the property contact
  @wire(getRecord, {
    recordId: "$recordId",
    fields
    
})
  contact;
  //console.log('OUTPUT : ***'+this.contact);
  //console.log('OUTPUT : ***'+contact);


  get isUSRegion() {
    console.log('the this.contact is***',this.contact);
    return (getFieldValue(this.contact.data, COUNTRY_FIELD) == 'United States of America');
  }

  
}