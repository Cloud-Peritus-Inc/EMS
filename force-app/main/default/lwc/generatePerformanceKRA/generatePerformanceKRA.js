import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import getResourceDetails from '@salesforce/apex/generatePerformanceKRAController.getResourceDetails';
import getCurrentUserConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getCurrentUserConDetails';
import getResourceKraRecords from '@salesforce/apex/generatePerformanceKRAController.getResourceKraRecords';
import getCompensationDetails from '@salesforce/apex/generatePerformanceKRAController.getCompensationDetails';
import updateCompensationDetails from '@salesforce/apex/generatePerformanceKRAController.updateCompensationDetails';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
export default class GeneratePerformanceKRA extends NavigationMixin(LightningElement) {
    @api resourceId;
    @api tab;
    @track CurrentUserConDetails;
    profileName; 

    userId = Id;
    @api member = '';
    @api fy;
    objectName = 'Contact';
    compensationObj = 'Compensation__c';
    @track selectedStep = 'General';
    @track Contact;
    @track ContactId;
    @track kraRecords;
    totalkraRecords = 0;
    @track averageOverallRating = 0;
    @track Compensation = {sobjectType:'Compensation__c'};
    @track CompensationDates = [];
    @track dataLoaded = false;
    //smaske : PM_079/PM_078
    @track submitButtonDisabled = false;

    errorVariant = 'error';
    successVariant = 'success';
    warningVariant = 'warning';

    steps = [
        { label: 'GENERAL', value: 'General' },
        { label: 'CONTENT', value: 'Content' },
        { label: 'REVIEW', value: 'Review' }
    ];
    showGeneral = true; showContent = false; showReview = false;
    activeSection = '';

    connectedCallback() {
        console.log("CC " + this.member + ' ' + this.resourceId);
        console.log("FY " + this.fy);
    }

    //getCurrentUserResourceRole
    @wire(getCurrentUserConDetails)
    wiredUserResourceRole({ error, data }) {
        if (data) {
            console.log('getCurrentUserConDetails DATA :  ' + JSON.stringify(data));
            this.CurrentUserConDetails = data;
            this.profileName = data.EMS_TM_User__r.Profile.Name;
            console.log('PROFILE :: ' + this.profileName);
        } else if (error) {
            console.log('getCurrentUserConDetails error :  ' + JSON.stringify(error));
            this.CurrentUserConDetails = undefined;
        }
    }

    @wire(getResourceDetails, { selectedresource: '$member' })
    wiredResule({ data, error }) {
        if (data) {
            console.log('Wired Data :' + JSON.stringify(data));
            this.Contact = data;
            this.ContactId = data.Id;
        } else if (error) {
            console.log('Wired Error :' + JSON.stringify(error));
            msg = 'Unable to fetch details for selected resource';
            this.showNotification(msg, this.errorVariant);
            this.dataLoaded = true;
        }
    }

    @wire(getResourceKraRecords, { member: '$Contact' , fy : '$fy' })
    wiredKraRecords({ data, error }) {
        if(data == null){
            this.dataLoaded = true;
        }
        if (data) {
            console.log('Data kra ' + JSON.stringify(data));
            if (data.length > 0) {
                this.kraRecords = data;
                this.totalkraRecords = data.length;
                let sumOverallRating = 0;
                this.kraRecords.forEach(record => {
                    sumOverallRating += record.Overall_Average_Section_Rating__c || 0; // Ensure numeric values
                });
                this.averageOverallRating = this.totalkraRecords > 0 ? (sumOverallRating / this.totalkraRecords).toFixed(1) : 0;
            }
            this.dataLoaded = true;
            console.log('member :' + this.member);
            console.log('resourceId :' + this.resourceId);
            
        } else if (error) {
            console.log('Wired kraRecords Error :' + JSON.stringify(error));
            msg = 'Unable to fetch Goal records for selected resource';
            this.showNotification(msg, this.errorVariant);
            this.dataLoaded = true;
        }
    }

    @wire(getCompensationDetails, { selectedresource: '$member'})
    wiredComp({ data, error }) {
        if(data == null){
            this.Compensation.Reviewed_By__c =this.userId;
            this.Compensation.Resource__c =this.member;
            if (this.Contact && this.Contact.Next_Appraisal_Date__c) {
                //smaske : PM_079/PM_078 : for populating date value
                let RR = { ...this.Compensation };
                RR.Next_Appraisal_Date__c = this.Contact.Next_Appraisal_Date__c;
                this.Compensation = RR;
            }
            else if(this.Contact && this.Contact.Last_Appraisal_Date__c) {
                var lastAppraisalDate = new Date(this.Contact.Last_Appraisal_Date__c);
                var nextYearDate = new Date(lastAppraisalDate);
                nextYearDate.setFullYear(lastAppraisalDate.getFullYear() + 1);
                var formattedNextYearDate = nextYearDate.toISOString().split('T')[0];
                //smaske : PM_079/PM_078 : for populating date value
                let RR = { ...this.Compensation };
                RR.Next_Appraisal_Date__c = formattedNextYearDate;
                this.Compensation = RR;
            }
        }
        if (data) {
            console.log('Compensation Data :' + JSON.stringify(data));
            this.Compensation = data;
            this.CompensationDates.push(data.Appraisal_Date__c);
            this.CompensationDates.push(data.Next_Appraisal_Date__c);
            this.dataLoaded = true;
            //smaske : PM_079/PM_078 : Disable Submit btn
            this.submitButtonDisabled = data.Compensation_Submitted__c == true ? true : false;
        }else if (error) {
            console.log('Compensation Error :' + JSON.stringify(error));
            this.dataLoaded = true;
        }
    }

    stepSelectionHanler(event) {
        this.selectedStep = event.target.value;
        console.log("selectedStep : " + this.selectedStep);
        this.showGeneral = this.selectedStep === 'General';
        this.showContent = this.selectedStep === 'Content';
        this.showReview = this.selectedStep === 'Review';
    }

    handleValueSelectedOnAccount(event){
        const selectedLookupValue = event.detail;
        console.log(" selectedLookupValue " + JSON.stringify(selectedLookupValue) );
        const value = selectedLookupValue.id;
        const label = selectedLookupValue.label;
        this.Compensation.Reviewed_By__c = value;
        console.log(" this.Compensation.Reviewed_By__c " + JSON.stringify(this.Compensation.Reviewed_By__c) );
    }

    dataHandler(event){
        console.log(JSON.stringify(event.target.value));
        console.log(JSON.stringify(event.target.name));
        const dataValue = event.target.value;
        const name = event.target.name;
        var todaysDate = new Date();

        let RR = { ...this.Compensation };

        if (name === 'Next_Appraisal_Date__c') {8
            if (dataValue <= todaysDate.toISOString().split('T')[0]) {
                const evt = new ShowToastEvent({
                    message: 'Next Appraisal Date must be a future date.',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.template.querySelector('lightning-input').value = '';
            } else {
                RR[name] = dataValue;
            }
        }else if(name == 'Appraisal_Date__c'){
            RR[name] = dataValue;
        }else if(name == 'Comments__c'){
            RR[name] = dataValue;
        }else if(name == 'Finalized_Hike__c'){
            RR[name] = dataValue;
        }
        this.Compensation = RR;

    }

    handleNextButtonAction(event) {
        console.log('Inside next btn');
        const currentStep = this.selectedStep;
        this.hideAllSections();

        if (currentStep == 'General') {
            this.showContent = true;
        }
        if (currentStep == 'Content') {
            this.showReview = true;
        }
        this.selectedStep = this.getNextStep();

        console.log("Present Step : " + this.selectedStep);
    }

    getNextStep() {
        const currentStepIndex = this.steps.findIndex(step => step.value === this.selectedStep);
        if (currentStepIndex < this.steps.length - 1) {
            return this.steps[currentStepIndex + 1].value;
        } else {
            return this.selectedStep;
        }
    }

    //BACK BUTTON CODE
    handlePreviousButtonAction() {
        console.log('handlePreviousAction ' + this.selectedStep);
        var moveToPreviousStep = this.selectedStep;
        this.hideAllSections();
        switch (moveToPreviousStep) {
            case 'Content':
                this.showGeneral = true;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Review':
                this.showContent = true;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
        }
    }

    handleSubmitButtonAction(){
        //smaske : PM_079/PM_078 : Updating Submit functionality to avoid duplicate record creation and Field Validation.
        let isValid = true;
        //smaske :[EN_05] : Removed "Finalized_Hike__c" from API Array as field is commented
        const apiFieldNames = ['Next_Appraisal_Date__c', 'Reviewed_By__c', 'Comments__c']; // Replace with your actual field names
        // Iterate through the list of API field names
        for (const fieldName of apiFieldNames) {
            if (!this.Compensation[fieldName]) {
                console.log(`${fieldName} is blank.`);
                isValid = false;
            } else {
                console.log(`${fieldName} is not blank. Value: ${this.Compensation[fieldName]}`);
            }
        }

        if (isValid) {
            // Update/Create Record when all required fields value is populated.
            updateCompensationDetails({ record: this.Compensation, fy: this.fy })
                .then(result => {
                    console.log(" updateCompensationDetails " + JSON.stringify(result));
                    this.Compensation = result;
                    let msg = 'Record Submitted Successfully !';
                    this.showNotification(msg, this.successVariant);
                    this.dispatchEvent(new CustomEvent('close'))
                    /* this[NavigationMixin.Navigate]({
                        type: 'comm__namedPage',
                        attributes: {
                            name: 'Home'
                        }
                    }); */

                    return refreshApex(this.Compensation);
                })
                .catch(error => {
                    let msg = 'Error Submitting Records!';
                    this.showNotification(msg, this.successVariant);
                    console.log(" updateCompensationDetails error " + JSON.stringify(error));
                })
        }else{
            let msg = 'All field values are required!';
            this.showNotification(msg, this.errorVariant);
        }
    }

    getPreviousStep() {
        const currentStepIndex = this.steps.findIndex(step => step.value === this.selectedStep);
        if (currentStepIndex === 0) {
            return this.steps[this.steps.length - 1].value;
        } else {
            return this.steps[currentStepIndex - 1].value;
        }
    }

    handleToggleSection(event) {
        console.log("Open Section Name :" + event.detail.openSections);
        this.activeSection = event.detail.openSections;

    }

    //CANCEL BUTTON CODE
    handleCancelButtonAction() {
        this.dispatchEvent(new CustomEvent('close'))
    }


    @api
    get setSaveBtnVisibility() {
        if (this.selectedStep === 'Review') {
            return 'slds-show slds-p-around_small';
        }
        return 'slds-hide slds-p-around_small';
    }

    @api
    get setSubmitBtnVisibility() {
        if (this.selectedStep === 'Review') {
            return 'slds-show slds-p-around_small';
        }
        return 'slds-hide slds-p-around_small';
    }

    @api
    get setBackBtnVisibility() {
        if (this.selectedStep === 'General') {
            return 'slds-hide slds-p-around_small';
        }
        return 'slds-show slds-p-around_small';
    }

    @api
    get setNextBtnVisibility() {
        if (this.selectedStep === 'Review') {
            return 'slds-hide slds-p-around_small';
        }
        return 'slds-show slds-p-around_small';
    }

    hideAllSections() {
        this.showGeneral = false;
        this.showContent = false;
        this.showReview = false;
    }

    showNotification(msg, variant) {
        const evt = new ShowToastEvent({
            title: '',
            message: msg,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // CODE FOR EDIT AND VIEW KRA RECORDS

    @track selectedKraQuaterly;
    showKRAEditModal = false;
    showKRAViewModal = false;
    mode;

    handleViewKRAClick(event){
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        this.mode = 'View';
        this.showKRAViewModalBox();
    }

    handleEditKRAClick(event){
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        this.mode = 'Edit';
        this.showKRAEditModalBox();
    }

    showKRAEditModalBox() { 
        this.showKRAEditModal = true; 
   }
    hideKRAEditModalBox() {  
        this.showKRAEditModal = false;
    }

    showKRAViewModalBox() {
        this.showKRAViewModal = true;
    }
    hideKRAViewModalBox() {
        this.showKRAViewModal = false;
    }

    @api
    get isEditButtonVisible(){
        if(this.profileName && this.profileName == 'Employee - HR(Community)'){
            //smaske : PM_072 : Setting as False ,as we dont need edit button
            return false;
        }
        return false;
    }

    // CODE FOR GoalModal
    showGoalModal = false;
    handleViewGoalClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        console.log('==node====' + node);
        this.showGoalModalBox();
    }

    showGoalModalBox() {
        this.showGoalModal = true;
    }

    hideGoalModalBox() {
        this.showGoalModal = false;
    }
}