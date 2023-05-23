import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyCertificationsAndSkills from '@salesforce/apex/mySkillsAndCertifcations.getMyCertificationsAndSkills';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

import { getListUi } from 'lightning/uiListApi';

export default class MyCertificationsAndSkills extends NavigationMixin(LightningElement) {
    @track skillList;

    openModal = false;
    showtable = false;
    resourceId;
    showskill = false;
    showcertification = false;
    showOther = false;
    createdRecordId;
    certificatenskill;
    connectedCallback() {

    }

    loaded = false
    @wire(getMyCertificationsAndSkills)
    wiredLabels(result) {
        this.certificatenskill = result;
        if (result.data) {
            this.skillList = result.data.skillList;
            this.resourceId = result.data.resourceId;
            if (this.skillList.length > 0) {
                this.showtable = true;
            }
            this.loaded = true;

        }
        if (result.error) {
            console.log('-======---=ERROR==--=-=-' + JSON.stringify(result.error));
        }
    }

    handleClick() {
        this.openModal = true;
    }

    handleCancel(event) {
        this.openModal = false;
        this.showskill = false;
        this.showcertification = false;
    }

    handleTypeChange(event) {
        this.showskill = false;
        this.showcertification = false;
        let changedVal = event.target.value;
        if (changedVal == 'Skill') {
            this.showskill = true;
            this.showcertification = false;
        } else {
            this.showskill = false;
            this.showcertification = true;
        }
    }

    /*handleNavClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/recordlist/Certifications__c/Default'
               //url:'/recordlist/Certifications__c/Default?Certifications__c-filterId=00B52000008AX5DEAW'
            }
        });
    }*/

listViewId;

    @wire(getListUi, { objectApiName: 'Certifications__c', listViewApiName: 'My_Skills_and_Certifications' })
    listViewResult({ error, data }) {
        if (data) {
            const listViews = data.info.listReference.id;
            this.listViewId = listViews;
        }
    }

    handleNavClick() {
        const listId = this.listViewId;
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Certifications__c',
                actionName: 'list'
            },
            state: {       
                //filterName: '00B52000008AX5DEAW' //Custom list view Id
                filterName: listId
            }
        });
    }

    handleexpClick(event) {
        let selectexp = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectexp,
                objectApiName: 'Certifications__c',
                actionName: 'view'
            },
        });
    }

    handleFormSubmit(event) {
       // console.log('In Submit ====');
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Contact__c = this.resourceId;
        this.template
            .querySelector('lightning-record-edit-form').submit(fields);

    }

    handleSuccess(event) {
        this.skillList = [];
       // console.log('=====event.detail.id=====' + event.detail.id);
        getMyCertificationsAndSkills()
            .then(result => {
                //console.log('=====event Data------->=====' + result.skillList);
                const even = new ShowToastEvent({
                    message: 'Successfully added your skill/certification. keep up the learning spirit!',
                    variant: 'success'
                });
                this.dispatchEvent(even);
               // console.log('===data====' + JSON.stringify(result));
                this.skillList = result.skillList;
                this.resourceId = result.resourceId;
                if (this.skillList.length > 0) {
                    this.showtable = true;
                }
                this.openModal = false;
                this.showskill = false;
                this.showcertification = false;
                refreshApex(this.certificatenskill);
            })
            .catch(error => {
                console.log('===ERROR====' + JSON.stringify(error));
                const event = new ShowToastEvent({
                    message: 'Error in creating a record. Please Contact System Admin',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            });
    }

    handleError(event) {
        console.log('====event.detail.detail======' + JSON.stringify(event.detail.detail));
        const evt = new ShowToastEvent({
            message: event.detail.detail,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    handleChange(event) {
        if (event.detail.value == 'Other') {
            this.showOther = true;
        } else {
            this.showOther = false;
        }

    }


}