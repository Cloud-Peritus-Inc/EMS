import { LightningElement, api, wire, track } from 'lwc';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import { CurrentPageReference } from 'lightning/navigation';
export default class LeaveReqViewForm extends LightningElement {

    @api objectName = LEAVEHISTORY_OBJECT;
    data;
    error;
    @api recordId;
    currentPageReference = null;
    urlStateParameters = null;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            console.log(currentPageReference);
            this.recordId = currentPageReference.attributes.recordId || null;
        }
    }
}