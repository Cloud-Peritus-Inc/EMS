import { LightningElement, api, wire, track } from 'lwc';
//Apex Methods
import fetchKRARecords from '@salesforce/apex/quarterlyKRAViewCtrl.fetchKRARecords';
import saveKraRecord from '@salesforce/apex/quarterlyKRAViewCtrl.saveKraRecord';
import submitKraRecord from '@salesforce/apex/quarterlyKRAViewCtrl.submitKraRecord';
import getCurrentUserConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getCurrentUserConDetails';
import getSelectedResourceConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getSelectedResourceConDetails';
import getPMConfigKRAData from '@salesforce/apex/quarterlyKRAViewCtrl.getPMConfigKRAData';
import calculateAverageRatingForKRA from '@salesforce/apex/quarterlyKRAViewCtrl.calculateAverageRatingForKRA';
import updatePMAnswerRecordsStatus from '@salesforce/apex/quarterlyKRAViewCtrl.updatePMAnswerRecordsStatus';
 
//other imports
import exampleHelpText from "@salesforce/label/c.exampleHelpText";
import LightningConfirm from 'lightning/confirm';
import Genericmodal from 'c/genericmodal';


import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class Quarterlykraedit extends NavigationMixin(LightningElement) {
    @api tab;
    @api copy = false;
    @api selectedresource = '';
    @api receivedkraid;
    @api mode;
    @track kraRecord;
    wiredKraRecordResult;
    @track CurrentUserConDetails;
    CurrentUserResourceRoleTechAcc = 0;
    CurrentUserResourceRoleProfSkillAcc = 0;
    CurrentUserResourceRoleStrategicAcc = 0;
    CurrentUserResourceRoleGoalRewAcc = 0;

    @track SelectedResourceConDetails;
    SelectedResourceResourceRoleTechAcc = 0;
    SelectedResourceResourceRoleProfSkillAcc = 0;
    SelectedResourceResourceRoleStrategicAcc = 0;
    SelectedResourceResourceRoleGoalRewAcc = 0;

    profileName;
    error;
    inputValue;
    @track selectedStep = 'reviewerDetails';
    isFieldsDisabled;
    showReviewerDetails = true;
    showTechnicalAcumen = false;
    showProfessionalSkills = false;
    showStrategicImpact = false;
    showGoalsResults = false;
    showOverAllRating = false;

    showSaveSubmitButtons;

    STATUS_KRA_INREVIEW = 'KRA Inreview';
    STATUS_KRA_COMPLETE = 'KRA Completed';
    @track isSubmitBtnDisabled = true;
    @track isSaveBtnDisabled = false;

    errorVariant = 'error';
    successVariant = 'success';
    warningVariant = 'warning';
    toastMode = 'dismissible';

    maxLength = 255;
    maxLengthError = 'Text is too long. Maximum allowed length is 255 characters.';

    label = {
        exampleHelpText
    };

    steps = [
        { label: 'REVIEWER DETAILS', value: 'reviewerDetails' },
        { label: 'TECHNICAL ACUMEN', value: 'technicalAcumen' },
        { label: 'PROFESSIONAL SKILLS', value: 'professionalSkills' },
        { label: 'STRATEGIC IMPACT', value: 'strategicImpact' },
        { label: 'GOALS AND RESULTS', value: 'goalsResults' },
        { label: 'OVERALL RATING', value: 'overAllRating' }
    ];

    connectedCallback() {
        console.log(' **** connectedCallback selectedresource****  ' + this.selectedresource);
        console.log('COPY VALUE ' + this.receivedkraid);
    }

    //getCurrentUserResourceRole
    currentContactName;
    currentContactResourceRole;
    @wire(getCurrentUserConDetails)
    wiredUserResourceRole({ error, data }) {
        if (data) {
            console.log('getCurrentUserConDetailsdata :  ' + JSON.stringify(data));
            this.CurrentUserConDetails = data;
            this.currentContactName = data.Name;
            this.currentContactResourceRole = data.Resource_Role__r.Name;
            //console.log('getCurrentUserConDetails DATA :  ' + JSON.stringify(this.CurrentUserConDetails));
            this.profileName = data.EMS_TM_User__r.Profile.Name;

            this.CurrentUserResourceRoleTechAcc = data.Resource_Role__r.technical_acumen__c ? data.Resource_Role__r.technical_acumen__c : 0;
            this.CurrentUserResourceRoleProfSkillAcc = data.Resource_Role__r.professional_skills__c ? data.Resource_Role__r.professional_skills__c : 0;
            this.CurrentUserResourceRoleStrategicAcc = data.Resource_Role__r.strategic_impact__c ? data.Resource_Role__r.strategic_impact__c : 0;
            this.CurrentUserResourceRoleGoalRewAcc = data.Resource_Role__r.goals_and_results__c ? data.Resource_Role__r.goals_and_results__c : 0;

        } else if (error) {
            console.log('getCurrentUserConDetails error :  ' + JSON.stringify(error));
            this.CurrentUserConDetails = undefined;
            this.error = error;
        }
    }

    //getSelectedResourceConDetails
    @wire(getSelectedResourceConDetails, { selectedResourceId: "$selectedresource" })
    wiredSelectedUserResourceRole({ error, data }) {
        console.log('getSelectedResourceConDetails ');
        if (data) {
            console.log('checkdata '+data);
            this.SelectedResourceConDetails = data;
            console.log('getSelectedResourceConDetails DATA :  ' + JSON.stringify(this.SelectedResourceConDetails));
            //smaske : PM_066 :  Setting value to '0' if not declared 
            // previously was setting as 'undefined'
            this.SelectedResourceResourceRoleTechAcc = this.SelectedResourceConDetails.Id ? data.Resource_Role__r.technical_acumen__c : 0;
            this.SelectedResourceResourceRoleProfSkillAcc = this.SelectedResourceConDetails.Id ? data.Resource_Role__r.professional_skills__c : 0;
            this.SelectedResourceResourceRoleStrategicAcc = this.SelectedResourceConDetails.Id ? data.Resource_Role__r.strategic_impact__c : 0;
            this.SelectedResourceResourceRoleGoalRewAcc = this.SelectedResourceConDetails.Id ? data.Resource_Role__r.goals_and_results__c : 0;
            //console.log('SelectedResourceResourceRoleTechAcc DATA :  ' + JSON.stringify(this.SelectedResourceResourceRoleTechAcc));
        } else if (error) {
            console.log('getSelectedResourceConDetails error :  ' + JSON.stringify(error));
            this.SelectedResourceConDetails = undefined;
        }
    }

    //Fetch KRA Record details and display on the UI
    @wire(fetchKRARecords, { recordId: "$receivedkraid", selectedresource: "$selectedresource" })
    wiredKraRecords(value) {
        console.log( 'wiredKraRecords RAN RAN' );
        this.wiredKraRecordResult = value;
        const { data, error } = value;
        if (data) {
            console.log("wiredKraRecordResult DATA :: " + JSON.stringify(data));
            //smaske : calling this below function to fetch the PM Answer records
            this.getPMConfigKRADataHandler(data);
            
            if (this.tab == 'My Metric') {
                console.log('IN MYMETRIC CONDITION');
                this.isSubmitBtnDisabled = data.Mentee_KRA_submitted__c == true ? true : false;
                this.isSaveBtnDisabled = data.Mentee_KRA_submitted__c === true ? true : false;
                this.isFieldsDisabled = data.Mentee_KRA_submitted__c === true ? true : false;
            }
            if (this.tab == 'My Team') {
                this.isSubmitBtnDisabled = data.Mentor_KRA_submitted__c == true ? true : false;
                this.isSaveBtnDisabled = data.Mentor_KRA_submitted__c === true ? true : false;
                this.isFieldsDisabled = data.Mentor_KRA_submitted__c === true ? true : false;
            }
            if (this.tab == 'Pending Feedback Request') {
                this.isSubmitBtnDisabled = data.Status__c === this.STATUS_KRA_INREVIEW ? true : false;
                this.isSaveBtnDisabled = data.Status__c === this.STATUS_KRA_INREVIEW === true ? true : false;
                this.isFieldsDisabled = data.Status__c === this.STATUS_KRA_INREVIEW === true ? true : false;
            }


            if (this.profileName == 'Employee - HR(Community)') {
                this.isSubmitBtnDisabled = true;
                this.isSaveBtnDisabled = true;
            }
            //Check if status is COMPLETE : Disable Submit btn
            this.error = undefined;
            //Set Button visibilty based on mode value
            if (this.mode == 'View') {
                this.isFieldsDisabled = true;
                this.isSaveBtnDisabled = true;
                this.isSubmitBtnDisabled = true;
            }

            setTimeout(() => {
                this.kraRecord = data; //smaske :[22-July-2024] : PM_Def_039 assigning data to kraRecord once other method are called
              },2500);
              

            
        } else if (error) {
            console.log("IF ERROR :: " + JSON.stringify(error));
            console.log("wiredKraRecords ERROR :: " + error);
            this.error = error;
            this.kraRecord = undefined;
        }
    }


    //smaske :[03-July-2024]: New method to fetch the data for PM CONFIG Questions and Answers
    // Define maps to store area-specific data
    techSkillsMap = {};
    profSkillsMap = {};
    stratImpactSkillsMap = {};
    goalsResultsSkillsMap = {};

    @track viewwrap2;
    getPMConfigKRADataHandler(kraRecord) {
        console.log('Received this.kraRecord : ' + JSON.stringify(kraRecord));   
        getPMConfigKRAData({ krarecordId: kraRecord, tab: this.tab, copy : this.copy })
            .then(result => {
                //console.log('-======---= getPMConfigKRAData DATA==--=-=-' + JSON.stringify(result.areaAndQueAnsMapData));
                //console.log('-======---= pmAnsRecordsIdData DATA==--=-=-' + JSON.stringify(result.pmAnsRecordsIdData));
                //console.log('-======---= pmAnsRecordsIdData COPY ==--=-=-' + JSON.stringify(this.copy));

                this.viewwrap2 = result;

                this.techSkillsMap = Object.entries(result.areaAndQueAnsMapData['TECHNICAL SKILLS']).map(([key, value]) => ({
                    key,
                    ...value
                }));

                this.profSkillsMap = Object.entries(result.areaAndQueAnsMapData['PROFESSIONAL SKILLS']).map(([key, value]) => ({
                    key,
                    ...value
                }));
                this.stratImpactSkillsMap = Object.entries(result.areaAndQueAnsMapData['STRATEGIC IMPACT']).map(([key, value]) => ({
                    key,
                    ...value
                }));
                this.goalsResultsSkillsMap = Object.entries(result.areaAndQueAnsMapData['GOALS AND RESULTS']).map(([key, value]) => ({
                    key,
                    ...value
                }));

                /* console.log('techSkillsMap ' + JSON.stringify(this.techSkillsMap));
                console.log('profSkillsMap ' + JSON.stringify(this.profSkillsMap));
                console.log('stratImpactSkillsMap ' + JSON.stringify(this.stratImpactSkillsMap));
                console.log('goalsResultsSkillsMap ' + JSON.stringify(this.goalsResultsSkillsMap)); */
                console.log('THIS KRA b4 calculateAverageRatingForKRAHandler');
                this.calculateAverageRatingForKRAHandler(JSON.stringify(result.pmAnsRecordsIdData),kraRecord);
            })
            .catch(error => {
                //this.showToast('Error Fetching PM Config Answer Records: ' + error.body.message, this.errorVariant, this.toastMode);
                console.log('Error Fetching PM Config Answer Records: ' + JSON.stringify(error));
            });
    }


    //STEP SELECTION HANDLER METHOD
    stepSelectionHanler(event) {
        console.log('Current Section we are at : ' + this.selectedStep);
        console.log('Next Section we moving to : ' + event.target.value);

        /*smaske : [PM_Def_027] : Adding validaion before moving to next section. 
        handleSaveActionDuplicateWithValidation will do validation and pass result to changeSection
        if changeSection is true we are moving to next section */
        let changeSection = false;
        const currentSection = this.selectedStep;

        if (currentSection == 'reviewerDetails' || currentSection == 'overAllRating') {
            console.log('if');
            changeSection = true;
        } else {
            console.log('else');
            changeSection = this.handleSaveActionDuplicateWithValidation();
        }

        if (changeSection) {
            const step = event.target.value;
            this.selectedStep = step;
            // Map each step to its corresponding visibility property
            const stepToVisibility = {
                'reviewerDetails': 'showReviewerDetails',
                'technicalAcumen': 'showTechnicalAcumen',
                'professionalSkills': 'showProfessionalSkills',
                'strategicImpact': 'showStrategicImpact',
                'goalsResults': 'showGoalsResults',
                'overAllRating': 'showOverAllRating',
            };

            // Set visibility based on the selected step
            Object.keys(stepToVisibility).forEach(key => {
                this[stepToVisibility[key]] = key === step;
            });

            if (step === 'overAllRating') {
                setTimeout(() => {
                    //this.getPMConfigKRADataHandler(this.kraRecord);
                    //smaske : PM_Def_104
                    this.calculateAverageRatingForKRAHandler(this.viewwrap2.pmAnsRecordsIdData, this.kraRecord);
                  },3000);
            } else if (step != 'reviewerDetails' && step != 'overAllRating') {
                console.log('Calling getPMConfigKRADataHandler');
                setTimeout(() => {
                    this.getPMConfigKRADataHandler(this.kraRecord);
                  },100);
            }
        }

    }

    handleNextAction() {
        console.log('handleNextAction ' + this.selectedStep);
        var moveToNextStep = this.selectedStep;
        /*smaske : [PM_Def_027] : Adding validaion before moving to next section. 
        handleSaveActionDuplicateWithValidation will do validation and pass result to changeSection
        if changeSection is true we are moving to next section */
        let changeSection = true;
        if (moveToNextStep != 'reviewerDetails') {
            changeSection = this.handleSaveActionDuplicateWithValidation();
        }
        
        if (changeSection) {
            switch (moveToNextStep) {
                case 'reviewerDetails':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = true;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = false;
                    this.showOverAllRating = false;
                    this.selectedStep = 'technicalAcumen';
                    break;
                case 'technicalAcumen':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = true;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = false;
                    this.showOverAllRating = false;
                    this.selectedStep = 'professionalSkills';
                    break;
                case 'professionalSkills':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = true;
                    this.showGoalsResults = false;
                    this.showOverAllRating = false;
                    this.selectedStep = 'strategicImpact';
                    break;
                case 'strategicImpact':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = true;
                    this.showOverAllRating = false;
                    this.selectedStep = 'goalsResults';
                    break;
                case 'goalsResults':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = false;
                    this.showOverAllRating = true;
                    this.selectedStep = 'overAllRating';
                    break;
            }
        }

    }

    handlePreviousAction() {
        console.log('handlePreviousAction ' + this.selectedStep);
        // Set all show properties to false
        this.showReviewerDetails = false;
        this.showTechnicalAcumen = false;
        this.showProfessionalSkills = false;
        this.showStrategicImpact = false;
        this.showGoalsResults = false;
        this.showOverAllRating = false;

        // Set the specific show property to true based on the selected step
        switch (this.selectedStep) {
            case 'technicalAcumen':
                this.showReviewerDetails = true;
                this.selectedStep = 'reviewerDetails';
                break;
            case 'professionalSkills':
                this.showTechnicalAcumen = true;
                this.selectedStep = 'technicalAcumen';
                break;
            case 'strategicImpact':
                this.showProfessionalSkills = true;
                this.selectedStep = 'professionalSkills';
                break;
            case 'goalsResults':
                this.showStrategicImpact = true;
                this.selectedStep = 'strategicImpact';
                break;
            case 'overAllRating':
                this.showGoalsResults = true;
                this.selectedStep = 'goalsResults';
                break;
        }

        if(this.selectedStep != 'reviewerDetails' && this.selectedStep != 'overAllRating'){
            console.log('Calling from Previous Handler');
            this.getPMConfigKRADataHandler(this.kraRecord);
        }
        console.log('HandlePrevious ' + this.selectedStep);
    }

    //smaske : [UAT_008] : Changed the validation code for restricting user from entering invalid values.
    //Praveen : [UAT_019] : Updating method for saving Example value  

    handleChange(event) {
        const fieldName = event.target.name;
        const fieldType = event.target.type;

        this.inputValue = event.target.value;
        // this.inputValue = this.removeDecimalPoint(this.inputValue);
        const decimalPart = this.getDecimalPart();
        console.log(decimalPart);
        if (decimalPart != '') {
            if (decimalPart !== '.5') {//&& decimalPart!=='.9'
                let text = this.inputValue.toString();
                let splitValue = text.split('.')[0];
                event.target.value = Number(splitValue);
                var msg = 'Please enter Ratings like 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5 ,5';
                this.showToast(msg, this.errorVariant, this.toastMode);

            }
        }
        // Validate the input
        const validValues = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];
        if (fieldType === 'number') {
            if (!validValues.includes(this.inputValue)) {

                if (this.inputValue < 1 || this.inputValue > 5) {
                    event.target.value = '';
                }
            }
        }

        //const updatedValue = event.target.value;
        const updatedValue = fieldType === 'number' ? Number(event.target.value) : event.target.value;

        console.log('fieldType : ' + fieldType);
        console.log('updatedValue : ' + updatedValue);
        let kraRecordMod = { ...this.kraRecord };


        // Check if the value is not between 1 and 5
        //if (updatedValue < 1 || updatedValue > 5) {
        if (fieldType === 'number' && (isNaN(updatedValue) || updatedValue < 1 || updatedValue > 5)) {
            let msg = 'Rating should be between 1 and 5';
            this.showToast(msg, this.errorVariant, this.toastMode);
        } else {
            kraRecordMod[fieldName] = updatedValue;
            this.kraRecord = kraRecordMod;
        }

    }

    isInvalidInput() {
        // If the input is empty, it's valid
        if (!this.inputValue) {
            return false;
        }

        // Implement your validation logic here
        const decimalPart = this.getDecimalPart();
        return decimalPart !== '.5' && decimalPart !== '.9';
    }

    getDecimalPart() {
        // Extract the decimal part of the input value
        const match = this.inputValue.match(/\.\d+/);
        return match ? match[0] : '';
    }

    removeDecimalPoint(input) {
        // Remove decimal point from the input value
        //return input.replace(/\./g, '');
        return Number(input.toFixed(0));
    }


    // ***SAVE/SUBMIT BUTTON CODE *** 
    @track clickedBtnLabel = 'Save';
    async handleSaveSubmitActionDuplicateOverAll(event) {
        this.clickedBtnLabel = event.target.label;
        console.log('SUBMIT BUTTON IS CLICKED');
        const result = await Genericmodal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            style: {
                '--slds-c-modal-color-border': 'black'
            },
            btnLable1: 'No',
            btnLable2: 'Yes',
            headerLable: 'Confirm KRA Submition',
            bodyLable: 'Feedback response once submitted, cannot be reverted. Would you like to proceed?',
            size: 'small',
        });

        if (result === 'okay') {
            this.updatePMAnswerRecordsStatusHandler(this.viewwrap2.pmAnsRecordsIdData, this.clickedBtnLabel);
        }
    }

    // ***SAVE BUTTON CODE WIHOUT VALIDATION *** 
    /*smaske : [PM_Def_033] : As part fo this defect not validating the record-edit-form data and drectly saving record changes.*/
    handleSaveActionDuplicate(event) {
        console.log(" handleSaveActionDuplicate Invoked");
        this.clickedBtnLabel = event.target.label;
        //console.log(" clickedBtnLabel & selectedStep  :" + this.clickedBtnLabel + ' ---- ' + this.selectedStep);
        let isFormValid = true;
        const recordEditForms = this.template.querySelectorAll('lightning-record-edit-form');
        console.log(" recordEditForms size 583 " + recordEditForms.length);
        if (isFormValid) {
            console.log("Form is Valid");
            recordEditForms.forEach(form => {
                form.submit();
            });
        }
    }


    // ***SAVE BUTTON CODE WItH VALIDATION *** 
    /*smaske : [PM_Def_027] : Adding validaion before moving to next section.
        handleSaveActionDuplicateWithValidation will do validation and pass result to changeSection
        if changeSection is true we are moving to next section */
    handleSaveActionDuplicateWithValidation() {
        console.log(" handleSaveActionDuplicateWithValidation Invoked");
        let isFormValid = true;
        const recordEditForms = this.template.querySelectorAll('lightning-record-edit-form');
        recordEditForms.forEach(form => {
            const inputFields = form.querySelectorAll('lightning-input-field');
            inputFields.forEach(inputField => {
                if (!inputField.value) {
                    isFormValid = false;
                    inputField.reportValidity();
                }
            });
        });
        console.log(" recordEditForms size 511 " + recordEditForms.length);
        if (isFormValid) {
            console.log("Form is Valid");
            recordEditForms.forEach(form => {
                form.submit();
            });
        } else {
            var msg = 'Please make sure to fill all the marked fields.';
            this.showToast(msg, this.errorVariant, this.toastMode);
        }
        return isFormValid;
    }


    handleRatingChange(event) {
        const ratingValue = parseFloat(event.currentTarget.value);
        console.log('ratingValue ' + ratingValue);
        if (ratingValue === 0 || ratingValue < 1 || ratingValue > 5 || isNaN(ratingValue) || (ratingValue * 2) % 1 !== 0) {
            event.currentTarget.value = NaN;
            this.showToast('Rating must be between 1 and 5, and in increments of 0.5.', this.errorVariant, this.toastMode);
            event.target.setCustomValidity('Rating must be between 1 and 5, and in increments of 0.5.');
        } else {
            event.target.setCustomValidity(''); // Clear the error message
        }
        event.target.reportValidity();
    }     


    //Smaske : [05-july-2024] : Success method on record-edit-form successfully submitted
    @track recordIds = [];
    handleSuccessForPMAnswers(event) {
        console.log('IN handleSuccessForPMAnswers');
        // Get the record ID from the event
        const recordId = event.detail.id;
        // Add the record ID to the list
        this.recordIds.push(recordId);
        // Log the record ID
        console.log('recordIds ID:', JSON.stringify(this.recordIds));

        if (this.clickedBtnLabel == 'Save') {
            this.updatePMAnswerRecordsStatusHandler(this.recordIds, 'Save');
        }
    }

    updatePMAnswerRecordsStatusHandler(recordIds, status) {
        console.log("CALLED updatePMAnswerRecordsStatusHandler " + recordIds);
        updatePMAnswerRecordsStatus({ PMAnswerRecordsId: recordIds, newStatus: status })
            .then(result => {
                console.log("updatePMAnswerRecordsStatus result ::" + JSON.stringify(result));
                this.calculateAverageRatingForKRAHandler(this.recordIds,this.kraRecord);
                if (status == 'Submit') {
                    this.submitKraRecordHandler();
                    this.handleChangeChildEvent();
                    this.showToast('KRA details submitted successfully.', this.successVariant, this.toastMode);
                }else {
                    this.showToast('KRA details saved successfully.', this.successVariant, this.toastMode);
                }
                
            })
            .catch(error => {
                console.log('518 updatePMAnswerRecordsStatus error : ' + JSON.stringify(error));
                //this.showToast('Error submitting records: ' + error.body.message, this.errorVariant, this.toastMode);
            });
    }

    @track wrapData;
    calculateAverageRatingForKRAHandler(recordIds,kraData) {
        console.log('calculateAverageRatingForKRAHandler Invoked');
        /* console.log('Received recordIds : ' + recordIds);
        console.log('Received this.kraRecord : ' + JSON.stringify(this.kraRecord));
        console.log('Received this.tab : ' + this.tab); */
        calculateAverageRatingForKRA({ PMAnswerRecordsId: recordIds, kraRecord: kraData, tab: this.tab })
            .then(result => {
                console.log("calculateAverageRatingForKRA result ::" + JSON.stringify(result));
                this.wrapData = result;
            })
            .catch(error => {
                //this.showToast('Error updating record calculateAverageRatingForKRAHandler: ' + error.body.message, this.errorVariant, this.toastMode);
                console.log('Error calculating average values for submitted records : ' + error.body.message);
            });
    }

    submitKraRecordHandler(){
        submitKraRecord({ kraRecord: this.kraRecord })
                .then(result => {
                    console.log(" result ::" + JSON.stringify(result));
                    this.kraRecord = result;
                    //Check if status is COMPLETE : Disable Submit btn
                    if (this.tab == 'My Metric') {
                        console.log('IN MYMETRIC CONDITION');
                        this.isSubmitBtnDisabled = this.kraRecord.Mentee_KRA_submitted__c == true ? true : false;
                        this.isSaveBtnDisabled = this.kraRecord.Mentee_KRA_submitted__c === true ? true : false;
                        this.isFieldsDisabled = this.kraRecord.Mentee_KRA_submitted__c === true ? true : false;
                    }
                    if (this.tab == 'My Team') {
                        this.isSubmitBtnDisabled = this.kraRecord.Mentor_KRA_submitted__c == true ? true : false;
                        this.isSaveBtnDisabled = this.kraRecord.Mentor_KRA_submitted__c === true ? true : false;
                        this.isFieldsDisabled = this.kraRecord.Mentor_KRA_submitted__c === true ? true : false;
                    }
                    if (this.tab == 'Pending Feedback Request') {
                        this.isSubmitBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_INREVIEW ? true : false;
                        this.isSaveBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_INREVIEW === true ? true : false;
                        this.isFieldsDisabled = this.kraRecord.Status__c === this.STATUS_KRA_INREVIEW === true ? true : false;
                    }
                    
                    //console.log('going to close');
                    this.dispatchEvent(new CustomEvent('close'));
                    //console.log('closed$$$$$$$$$');
                    
                    //console.log(" After Save ::" + JSON.stringify(this.kraRecord));
                    return refreshApex(this.wiredKraRecordResult);
                })
                .catch(error => {
                    console.log('Error updating KRA record: ' + error.body.message);
                    //this.showToast('Error updating KRA record: ' + error.body.message, this.errorVariant, this.toastMode);
                });
    }

    //smaske :[EN_002] : Updated code for setting Class instead of hiding whole layout-item
    @api
    get showSaveSubmitButtonsVisibility() {
        if (this.mode == 'View') {
            this.isSaveBtnDisabled = true;
            /*if(this.selectedStep != 'overAllRating'){
                return 'slds-var-m-left_small hidden-button2';
            }*/
            return 'slds-var-m-left_small hidden-button2';

        } else {
            // mode == 'Edit'
            console.log('#showSaveSubmitButtonsVisibility');
            if (this.profileName == 'Employee - HR(Community)') {
                console.log('#531');
                this.isSubmitBtnDisabled = false;
                //SHOW SAVE/SUBMIT buttons
                return 'slds-var-m-left_small';
            }
            //HIDE SAVE/SUBMIT buttons
            return 'slds-var-m-left_small';
        }
    }

    handleErrors(event) {
        console.log('No errors'); 
        console.log('FORM ERROR : '+ JSON.stringify(event.detail));
    }

    showToast(message, variant, mode) {
        const event = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    
    handleChangeChildEvent() {
        const selectEvent = new CustomEvent('mycustomevent', {
            detail: {
                recordId: this.receivedkraid,  
                status: 'Success'  
            }
        });
        this.dispatchEvent(selectEvent);
    }
}