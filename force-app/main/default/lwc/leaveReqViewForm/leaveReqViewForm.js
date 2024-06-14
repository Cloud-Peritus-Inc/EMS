import { LightningElement, api, wire, track } from 'lwc';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
export default class LeaveReqViewForm extends NavigationMixin(LightningElement) {

    @api objectName = LEAVEHISTORY_OBJECT;
    data;
    error;
    @api recordId;
    currentPageReference = null;
    urlStateParameters = null;

    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        //console.log('Base Url' + this.a_Record_URL);
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            //console.log(currentPageReference);
            this.recordId = currentPageReference.attributes.recordId || null;
        }
    }

    handleBack() {

        var params = new URLSearchParams(location.search);
        if (params.has('myRequest')) {
            var url = new URL(this.a_Record_URL + '/Grid/s/leave-management');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url.href
                }
            });
        } else if (params.has('pendingTab')) {
            var url = new URL(this.a_Record_URL + '/Grid/s/leave-management');
            var params = new URLSearchParams();
            params.append("pendingTab", "value");
            url.search += "&" + params.toString();
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url.href
                }
            });
        } else if (params.has('adminTab')) {
            var url = new URL(this.a_Record_URL + '/Grid/s/leave-management');
            var params = new URLSearchParams();
            params.append("adminTab", "value");
            url.search += "&" + params.toString();
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url.href
                }
            });
        }
    }
}