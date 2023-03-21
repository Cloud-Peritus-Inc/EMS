import { LightningElement, wire, track } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import getTheCurrentAccAndContactId from '@salesforce/apex/newServiceRequestController.getTheCurrentAccAndContactId';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class NewServiceRequest extends NavigationMixin (LightningElement) {
    @track openModal = false;
    value = '';
    showcod = false;
    showrsl = false;
    showresignation = false;
    showothers = false;
    showproblems = false;
    showfeaturerequest = false;
    showoption = true;
    picklistValuesObj;
    dependentValues;
    mycontactid;
    myaccountid;
    conrecord;
    constructor() {
        super();
        this.template.addEventListener('mycustomevent', this.handleCustomEvent.bind(this));

    }

    @wire(getTheCurrentAccAndContactId)
    wiredLabels({ error, data }) {
        if (data) {
            this.myaccountid = data.accountid;
            this.mycontactid = data.contactid;
            this.conrecord = data.conRec;
        }
        if (error) {
            console.log('-======---=ERROR==--=-=-' + JSON.stringify(error));
        }
    }

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseMetadata;

    @wire(getPicklistValuesByRecordType, { objectApiName: 'Case', recordTypeId: '$caseMetadata.data.defaultRecordTypeId' })
    newPicklistValues({ error, data }) {
        if (data) {
            this.picklistValuesObj = data.picklistFieldValues;
            let TypeValueslist = data.picklistFieldValues.Type.values;
            let typeValues = [];
            for (let i = 0; i < TypeValueslist.length; i++) {
                typeValues.push({
                    label: TypeValueslist[i].label,
                    value: TypeValueslist[i].value
                });
            }
            this.options = typeValues;
        }
        else if (error) {
            console.log('=ERROR==' + JSON.stringify(error));
        }
    }

    handleCustomEvent(event) {
        const textVal = event.detail;
        this.openModal = textVal;
        /*this.showoption = !textVal;
        console.log('### showoption : ',this.showoption);*/
    }



    handleNextClick(event) {
        console.log('===value=====' + this.value);
        this.showoption = false;
        this.showcod = false;
        this.showrsl = false;
        this.showresignation = false;
        this.showothers = false;
        this.showproblems = false;
        this.showfeaturerequest = false;
        if (this.value == 'Change of Details') {
            this.showcod = true;
        } else if (this.value == 'Special Leaves') {
            this.showrsl = true;
        } else if (this.value == 'Resignation') {
            this.showresignation = true;
        } else if (this.value == 'Others') {
            this.showothers = true;
        } else if (this.value == 'Feature Request') {
            this.showfeaturerequest = true;
        } else if (this.value == 'Technical Issues') {
            this.showproblems = true;
        }
    }
    handleChange(event) {
        this.value = event.detail.value;
        let data = this.picklistValuesObj;
        let totalrequestTypeValues = data.Request_Sub_Type__c;
        let controllerValueIndex = totalrequestTypeValues.controllerValues[this.value];
        let dependPicklistValues = data.Request_Sub_Type__c.values;
        let depPicklists = [];
        dependPicklistValues.forEach(key => {
            for (let i = 0; i < key.validFor.length; i++) {
                if (controllerValueIndex == key.validFor[i]) {
                    depPicklists.push({
                        label: key.label,
                        value: key.value
                    });
                }
            }
        })
        if (depPicklists && depPicklists.length > 0) {
            this.dependentValues = depPicklists;
        }
    }
    handleClick(event) {
        this.openModal = true;
    }


    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/Grid/s'
            }
        });
    }

    handleSuccess(event) {
        console.log('=====event.detail.id=====' + event.detail.id);
        const even = new ShowToastEvent({
            title: 'Success!',
            message: 'Successfully created the service request!',
            variant: 'success'
        });
        this.dispatchEvent(even);
        this.openModal = false;
    }

    handleError(event) {
        console.log('====event.detail.detail======' + JSON.stringify(event.detail.detail));
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}