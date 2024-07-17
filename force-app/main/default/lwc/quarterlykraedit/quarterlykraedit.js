import { LightningElement, api, wire, track } from 'lwc';
//Apex Methods
import fetchKRARecords from '@salesforce/apex/quarterlyKRAViewCtrl.fetchKRARecords';
import saveKraRecord from '@salesforce/apex/quarterlyKRAViewCtrl.saveKraRecord';
import submitKraRecord from '@salesforce/apex/quarterlyKRAViewCtrl.submitKraRecord';
import getCurrentUserConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getCurrentUserConDetails';
import getSelectedResourceConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getSelectedResourceConDetails';
import getGridConfigurationKRAData from '@salesforce/apex/quarterlyKRAViewCtrl.getGridConfigurationKRAData';
//other imports
import exampleHelpText from "@salesforce/label/c.exampleHelpText";

import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
export default class Quarterlykraedit extends NavigationMixin(LightningElement) {
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
    SelectedResourceResourceRoleProfSkillAcc= 0;
    SelectedResourceResourceRoleStrategicAcc= 0;
    SelectedResourceResourceRoleGoalRewAcc= 0;

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

    enterredValues = [];
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
        //console.log('COPY VALUE ' + this.copy);
    }

    //getCurrentUserResourceRole
    @wire(getCurrentUserConDetails)
    wiredUserResourceRole({ error, data }) {
        if (data) {
            this.CurrentUserConDetails = data;
            this.currentContactName = data.Name;
            this.currentContactResourceRole = data.Resource_Role__r.Name;
            //console.log('getCurrentUserConDetails DATA :  ' + JSON.stringify(this.CurrentUserConDetails));
            this.profileName = data.EMS_TM_User__r.Profile.Name;
            this.CurrentUserResourceRoleTechAcc = data.Resource_Role__r.technical_acumen__c;
            this.CurrentUserResourceRoleProfSkillAcc = data.Resource_Role__r.professional_skills__c;
            this.CurrentUserResourceRoleStrategicAcc = data.Resource_Role__r.strategic_impact__c;
            this.CurrentUserResourceRoleGoalRewAcc = data.Resource_Role__r.goals_and_results__c;
        } else if (error) {
            console.log('getCurrentUserConDetails error :  ' + JSON.stringify(error));
            this.CurrentUserConDetails = undefined;
            this.error = error;
        }
    }

    //getSelectedResourceConDetails
    @wire(getSelectedResourceConDetails, { selectedResourceId: "$selectedresource" })
    wiredSelectedUserResourceRole({ error, data }) {
        if (data) {
            this.SelectedResourceConDetails = data;
            //console.log('getSelectedResourceConDetails DATA :  ' + JSON.stringify(this.SelectedResourceConDetails));
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
        this.wiredKraRecordResult = value;
        const { data, error } = value;
        if (data) {
            console.log("wiredKraRecordResult DATA :: " + JSON.stringify(data));
            this.kraRecord = data;
            //Check if status is COMPLETE/INREVIEW : Disable SUBMIT/SAVE btn
            //smaske : updating Btn Mode for [Defect : PM_040]
            // If status is "KRA COMPLETE" then DISABLE SUBMIT btn, else ENABLE SUBMIT Btn
            this.isSubmitBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_COMPLETE ? true : false;
            this.isSaveBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_COMPLETE ? true : false;
            if (this.profileName == 'Employee - HR(Community)') {
                this.isSubmitBtnDisabled = true;
               // this.isSaveBtnDisabled = true;
            }
            //Check if status is COMPLETE : Disable Submit btn
            this.error = undefined;
            //Set Button visibilty based on mode value
            if (this.mode == 'View') {
                //this.showSaveSubmitButtons = false; //moved this to showSaveSubmitButtonsVisibility
                this.isFieldsDisabled = true;
            } else {
                //this.showSaveSubmitButtons = true; //moved this to showSaveSubmitButtonsVisibility
                this.isFieldsDisabled = false;
            }
        } else if (error) {
            console.log("IF ERROR :: " + JSON.stringify(error))
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
                this.calculateAverageRatingForKRAHandler(JSON.stringify(result.pmAnsRecordsIdData));
            })
            .catch(error => {
                //this.showToast('Error Fetching PM Config Answer Records: ' + error.body.message, this.errorVariant, this.toastMode);
                console.log('Error Fetching PM Config Answer Records: ' + error.body.message);
            });
    }


    stepSelectionHanler(event) {

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
            this.calculateAverageRatingForKRAHandler(this.viewwrap2.pmAnsRecordsIdData);
        }else if(step != 'reviewerDetails' && step != 'overAllRating'){
            console.log('Calling from stepSelectionHanler');
            this.getPMConfigKRADataHandler(this.kraRecord);
        }

    }

    handleNextAction() {
        console.log('handleNextAction ' + this.selectedStep);
        var moveToNextStep = this.selectedStep;
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

        /*smaske: [UAT_018] : Commenting Below Next button field validation code as per new requirement we dont need validation.
        Keeping the code commneted for Future Reference.
        Only keeping the navigation code above for switching between tabs on NEXT button.*/

        
        /*let isValid = true;
        let divToValidate;
        let inputFields = null;

        if (this.mode == 'Edit') {
            var moveToNextStep = this.selectedStep;
            if (moveToNextStep == 'reviewerDetails') {
                divToValidate = this.template.querySelector('[data-reviewer-details]');
                inputFields = divToValidate.querySelectorAll('lightning-input');
            } else if (moveToNextStep == 'technicalAcumen') {
                divToValidate = this.template.querySelector('[data-technical-acumen]');
                inputFields = [
                    ...divToValidate.querySelectorAll('lightning-input'),
                    divToValidate.querySelector('lightning-textarea')
                ];
            } else if (moveToNextStep == 'professionalSkills') {
                console.log(' in professionalSkills');
                divToValidate = this.template.querySelector('[data-professional-skills]');
                console.log(' data-professional-skills ' + divToValidate);
                inputFields = [
                    ...divToValidate.querySelectorAll('lightning-input'),
                    divToValidate.querySelector('lightning-textarea')
                ];
            } else if (moveToNextStep == 'strategicImpact') {
                console.log(' in strategicImpact');
                divToValidate = this.template.querySelector('[data-strategic-impact]');
                inputFields = [
                    ...divToValidate.querySelectorAll('lightning-input'),
                    divToValidate.querySelector('lightning-textarea')
                ];
            } else if (moveToNextStep == 'goalsResults') {
                console.log(' in goalsResults');
                divToValidate = this.template.querySelector('[data-goals-results]');
                //inputFields = divToValidate.querySelectorAll('lightning-input');
                inputFields = [
                    ...divToValidate.querySelectorAll('lightning-input'),
                    divToValidate.querySelector('lightning-textarea')
                ];
            }
            console.log("ALL INP FIELDS : " + JSON.stringify(inputFields));
            if (Array.isArray(inputFields) && inputFields.length > 0 && inputFields.every(field => field !== null)) {
                inputFields.forEach(inputField => {
                    const fieldName = inputField.name;
                    const value = this.kraRecord[fieldName];
                    if (!value) {
                        isValid = false;
                    }
                });
            }

        }

        if (isValid) {
            var moveToNextStep = this.selectedStep;
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

        } else {
            var msg = 'Field value cannot be empty.';
            this.showToast(msg, this.errorVariant, this.toastMode);
        } */

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
         if(decimalPart!=''){
         if(decimalPart!=='.5' ){//&& decimalPart!=='.9'
            let text =this.inputValue.toString();
            let splitValue =text.split('.')[0];
            event.target.value= Number(splitValue);
            var msg = 'Please enter Ratings like 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5 ,5';
            this.showToast(msg, this.errorVariant, this.toastMode);

         }
        }
         // Validate the input
         const validValues = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5];
         if(fieldType === 'number'){
        if(!validValues.includes(this.inputValue)){
            
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

    // *** SAVE BUTTON CODE *** 
    handleSaveAction() {
        console.log(" handleSaveAction ");

    // ***DUPLICATE SAVE BUTTON CODE *** 
    @track clickedBtnLabel;
    handleSaveSubmitActionDuplicateOverAll(event) {
        this.clickedBtnLabel = event.target.label;
        console.log('SUBMIT BUTTON IS CLICKED');
        //console.log('RECORD ID AVAILABLE : ' + this.viewwrap2.pmAnsRecordsIdData.length);
        //console.log('RECORD ID AVAILABLE : ' + this.viewwrap2.pmAnsRecordsIdData);
        this.updatePMAnswerRecordsStatusHandler(this.viewwrap2.pmAnsRecordsIdData,this.clickedBtnLabel);
    }

    handleSaveActionDuplicate(event) {
        console.log(" handleSaveActionDuplicate Invoked");
        this.clickedBtnLabel = event.target.label;
        //console.log(" clickedBtnLabel & selectedStep  :" + this.clickedBtnLabel + ' ---- ' + this.selectedStep);
        let isFormValid = true;
        const recordEditForms = this.template.querySelectorAll('lightning-record-edit-form');
        recordEditForms.forEach(form => {
            const inputFields = form.querySelectorAll('lightning-input-field');
            inputFields.forEach(inputField => {
                if (!inputField.value) {
                    isFormValid = false;
                    inputField.reportValidity();
                }
            });*/

            /*
            //Calculate Overall_Tech_Rating_2__c based on Visibile Tech Rating Fields for User Resource Role.
            let techPropertyFieldMap = this.getTechPropertyFieldMap();
            allPositiveTechFieldsList = this.updateAllPositiveFieldsList(techPropertyFieldMap,this.viewwrap,allPositiveTechFieldsList);
            let techSum = this.getTotalSum(this.kraRecord,allPositiveTechFieldsList);
            let averageOfTechSkillsRating = allPositiveTechFieldsList.length > 0 ? techSum / allPositiveTechFieldsList.length : 0;
            if(this.SelectedResourceResourceRoleTechAcc){
                this.kraRecord.Overall_Tech_Rating_2__c = averageOfTechSkillsRating * (this.SelectedResourceResourceRoleTechAcc/100);
            }else{
                this.kraRecord.Overall_Tech_Rating_2__c = averageOfTechSkillsRating * (this.CurrentUserResourceRoleTechAcc/100);
            }


            //Calculate Overall_Professional_Rating_2__c based on Visibile Professional Rating Fields for User Resource Role.
            let profPropertyFieldMap = this.getProfSkillsPropertyFieldMap();
            allPositiveProfessionalFieldsList = this.updateAllPositiveFieldsList(profPropertyFieldMap,this.viewwrap,allPositiveProfessionalFieldsList);
            let profSum = this.getTotalSum(this.kraRecord,allPositiveProfessionalFieldsList);
            let averageOfProfSkillsRating = allPositiveProfessionalFieldsList.length > 0 ? profSum / allPositiveProfessionalFieldsList.length : 0;
            if(this.SelectedResourceResourceRoleProfSkillAcc){
                this.kraRecord.Overall_Professional_Rating_2__c = averageOfProfSkillsRating * (this.SelectedResourceResourceRoleProfSkillAcc/100);
            }else{
                this.kraRecord.Overall_Professional_Rating_2__c = averageOfProfSkillsRating * (this.CurrentUserResourceRoleProfSkillAcc/100);
            }

            //Calculate Overall_Strategic_Rating_2__c based on Visibile Strategic Skills Rating Fields for User Resource Role.
            let strategicPropertyFieldMap = this.getStrategicImpactPropertyFieldMap();
            allPositiveStrategicFieldsList = this.updateAllPositiveFieldsList(strategicPropertyFieldMap, this.viewwrap, allPositiveStrategicFieldsList);
            let strategicSum = this.getTotalSum(this.kraRecord, allPositiveStrategicFieldsList);
            let averageOfStrategicSkillsRating = allPositiveStrategicFieldsList.length > 0 ? strategicSum / allPositiveStrategicFieldsList.length : 0;
            if (this.SelectedResourceResourceRoleStrategicAcc) {
                this.kraRecord.Overall_Strategic_Rating_2__c = averageOfStrategicSkillsRating * (this.SelectedResourceResourceRoleStrategicAcc / 100);
            } else {
                this.kraRecord.Overall_Strategic_Rating_2__c = averageOfStrategicSkillsRating * (this.CurrentUserResourceRoleStrategicAcc / 100);
            }

            //Calculate Overall_Goals_Results_Rating_2__c based on Visibile Goal & Result Rating Fields for User Resource Role.
            let goalResultPropertyFieldMap = this.getGoalResultPropertyFieldMap();
            allPositiveGoalResultFieldsList = this.updateAllPositiveFieldsList(goalResultPropertyFieldMap, this.viewwrap, allPositiveGoalResultFieldsList);
            let goalResultSum = this.getTotalSum(this.kraRecord, allPositiveGoalResultFieldsList);
            let averageOfGoalResultRating = allPositiveGoalResultFieldsList.length > 0 ? goalResultSum / allPositiveGoalResultFieldsList.length : 0;
            if (this.SelectedResourceResourceRoleGoalRewAcc) {
                this.kraRecord.Overall_Goals_Results_Rating_2__c = averageOfGoalResultRating * (this.SelectedResourceResourceRoleGoalRewAcc / 100);
            } else {
                this.kraRecord.Overall_Goals_Results_Rating_2__c = averageOfGoalResultRating * (this.CurrentUserResourceRoleGoalRewAcc / 100);
            }
            */

            // Call the function for each skill category
            this.processSkillCategory(this.getTechPropertyFieldMap(), allPositiveTechFieldsList, this.SelectedResourceResourceRoleTechAcc, this.CurrentUserResourceRoleTechAcc, "Overall_Tech_Rating_2__c", 'Average_Tech_Rating__c');
            this.processSkillCategory(this.getProfSkillsPropertyFieldMap(), allPositiveProfessionalFieldsList, this.SelectedResourceResourceRoleProfSkillAcc, this.CurrentUserResourceRoleProfSkillAcc, 'Overall_Professional_Rating_2__c', 'Average_Professional_Rating__c');
            this.processSkillCategory(this.getStrategicImpactPropertyFieldMap(), allPositiveStrategicFieldsList, this.SelectedResourceResourceRoleStrategicAcc, this.CurrentUserResourceRoleStrategicAcc, 'Overall_Strategic_Rating_2__c', 'Average_Strategic_Rating__c');
            this.processSkillCategory(this.getGoalResultPropertyFieldMap(), allPositiveGoalResultFieldsList, this.SelectedResourceResourceRoleGoalRewAcc, this.CurrentUserResourceRoleGoalRewAcc, 'Overall_Goals_Results_Rating_2__c', 'Average_Goals_Results_Rating__c');
        }

    /* handleRatingChange(event) {
        const ratingValue = parseFloat(event.currentTarget.value);
        console.log('ratingValue ' + ratingValue);
        if (ratingValue < 1 || ratingValue > 5 || ratingValue == '') {
            event.currentTarget.value = NaN;
            this.showToast('Rating must be between 1 and 5.', this.errorVariant, this.toastMode);
            event.target.setCustomValidity('Rating must be between 1 and 5.');
        } else {
            event.target.setCustomValidity(''); // Clear the error message
        }
        event.target.reportValidity();
    } */

    handleRatingChange(event) {
        const ratingValue = parseFloat(event.currentTarget.value);
        console.log('ratingValue ' + ratingValue);

        if (ratingValue < 1 || ratingValue > 5 || isNaN(ratingValue) || (ratingValue * 10) % 5 !== 0) {
            event.currentTarget.value = '';
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
                this.calculateAverageRatingForKRAHandler(this.recordIds);
                if (status == 'Submit') {
                    this.submitKraRecordHandler();
                    this.showToast('KRA details submitted successfully.', this.successVariant, this.toastMode);
                }else {
                    this.showToast('KRA details saved successfully.', this.successVariant, this.toastMode);
                }
                
            })
            .catch(error => {
                console.log('518 updatePMAnswerRecordsStatus error : ' + JSON.stringify(error.body.message));
                //this.showToast('Error submitting records: ' + error.body.message, this.errorVariant, this.toastMode);
            });
    }

    @track wrapData;
    calculateAverageRatingForKRAHandler(recordIds) {
        console.log('calculateAverageRatingForKRAHandler Invoked');
        /* console.log('Received recordIds : ' + recordIds);
        console.log('Received this.kraRecord : ' + JSON.stringify(this.kraRecord));
        console.log('Received this.tab : ' + this.tab); */
        calculateAverageRatingForKRA({ PMAnswerRecordsId: recordIds, kraRecord: this.kraRecord, tab: this.tab })
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

                    //Check if status is COMPLETE/INREVIEW : Disable SUBMIT/SAVE btn
                    //smaske : updating Btn Mode for [Defect : PM_040]
                    // If status is "KRA COMPLETE" then DISABLE SUBMIT btn, else ENABLE SUBMIT Btn
                    this.isSubmitBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_COMPLETE ? true : false;
                    this.isSaveBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_COMPLETE ? true : false;

                    if (this.profileName == 'Employee - HR(Community)') {
                        this.isSubmitBtnDisabled = true;
                        //smaske :[EN_002] : Not Disabling SAVE btn as per Feedback
                        //this.isSaveBtnDisabled = true;
                    }
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
        } else {
            var msg = 'Field value cannot be empty.';
            this.showToast(msg, this.errorVariant, this.toastMode);
        }

    }


    // *** SUBMIT BUTTON CODE *** 
    handleSubmitAction() {
        console.log(" handleSubmitAction ");
        console.log(JSON.stringify(this.kraRecord));

        let isValid = true;
        let allPositiveTechFieldsList = [];
        let allPositiveProfessionalFieldsList = [];
        let allPositiveStrategicFieldsList = [];
        let allPositiveGoalResultFieldsList = [];
        let inputFields = [];

        if (this.viewwrap) {
            // Define relationships between viewwrap properties and associated fields
            const propertyFieldMap = this.getAllPropertyFieldMap();
            /*{
                showDevelopment: ['Development_Rating__c', 'Development_Example__c'],
                showTesting: ['Testing_Rating__c', 'Testing_Example__c'],
                showUnderstandingCode: ['Understanding_Code_Rating__c', 'Understanding_Code_Example__c'],
                showPlatformKnowledge: ['Platform_Knowledge_Rating__c', 'Platform_Knowledge_Example__c'],
                showDesignArchitecture: ['Design_and_Architecture_Rating__c', 'Design_and_Architecture_Example__c'],
                showDocumentation: ['Documentation_Rating__c', 'Documentation_Example__c'],
                showContinuousImprovement: ['Continuous_Improvement_Rating__c', 'Continuous_Improvement_Example__c'],
                showProjectPlanningSchedulingManagement: ['Project_Planning_Scheduling_Rating__c', 'Project_Planning_Scheduling_Example__c'],
                showDocumentationReportingManagement: ['Documentation_Reporting_Mgmt_Rating__c', 'Documentation_Reporting_Mgmt_Example__c'],
                showTaskManagement: ['Task_Management_Rating__c', 'Task_Management_Example__c'],
                showRiskManagement: ['Risk_Management_Rating__c', 'Risk_Management_Example__c'],
                showResourceManagement: ['Resource_Management_Rating__c', 'Resource_Management_Example__c'],
                showStakeholderManagement: ['Stakeholder_Management_Rating__c', 'Stakeholder_Management_Example__c'],
                showCommunicationManagement: ['Communication_Management_Rating__c', 'Communication_Management_Example__c'],
                showLearningAndSkillDevelopment: ['Learning_and_Skill_Development_Rating__c', 'Learning_and_Skill_Development_Example__c'],
                showEstimations: ['Estimations_Rating__c', 'Estimations_Example__c'],
                showTestCaseDesignExecution: ['Test_Case_Design_Execution_Rating__c', 'Test_Case_Design_Execution_Example__c'],
                showDefectManagement: ['Defect_Management_Rating__c', 'Defect_Management_Example__c'],
                showTroubleshootingAndEnvironmentPrep: ['Troubleshooting_Environment_Prep_Rating__c', 'Troubleshooting_Environment_Prep_Example__c'],
                showRequirementGathering: ['Requirement_Gathering_Rating__c', 'Requirement_Gathering_Example__c'],
                showPOVCreationDemos: ['POV_Creation_Client_Demos_Rating__c', 'POV_Creation_Client_Demos_Example__c'],
                showDeliveryAccountability: ['Delivery_Accountability_Rating__c', 'Delivery_Accountability_Example__c'],
                showEffectiveCommunication: ['Effective_Communication_Rating__c', 'Effective_Communication_Example__c'],
                showKnowledgeSharing: ['Knowledge_Sharing_Rating__c', 'Knowledge_Sharing_Example__c'],
                showTeamwork: ['Teamwork_Rating__c', 'Teamwork_Example__c'],
                showAttitudeBehavior: ['Attitude_and_Behavior_Rating__c', 'Attitude_and_Behavior_Example__c'],
                showBusinessDevelopment: ['Business_Development_Rating__c', 'Business_Development_Example__c'],
                showStrategicWork: ['Strategic_Work_Rating__c', 'Strategic_Work_Example__c'],
                showCompanyGrowth: ['Company_Growth_Rating__c', 'Company_Growth_Example__c'],
                showGoalAchievement: ['Goal_Achievement_Rating__c', 'Goal_Achievement_Example__c'],
                showStakeholderSatisfaction: ['Stakeholder_Satisfaction_Rating__c', 'Stakeholder_Satisfaction_Example__c'],
                showProjectSuccess: ['Project_Success_Rating__c', 'Project_Success_Example__c']
            };*/

            // Validate fields based on viewwrap properties
            Object.entries(propertyFieldMap).forEach(([property, fields]) => {
                if (this.viewwrap[property]) {
                    if (fields.some(field => !this.kraRecord[field])) {
                        console.error(`${property} fields are blank in the kraRecord object`);
                        isValid = false;
                    }
                }
            });

            // Call the function for each skill category
            this.processSkillCategory(this.getTechPropertyFieldMap(), allPositiveTechFieldsList, this.SelectedResourceResourceRoleTechAcc, this.CurrentUserResourceRoleTechAcc, 'Overall_Tech_Rating_2__c', 'Average_Tech_Rating__c');
            this.processSkillCategory(this.getProfSkillsPropertyFieldMap(), allPositiveProfessionalFieldsList, this.SelectedResourceResourceRoleProfSkillAcc, this.CurrentUserResourceRoleProfSkillAcc, 'Overall_Professional_Rating_2__c', 'Average_Professional_Rating__c');
            this.processSkillCategory(this.getStrategicImpactPropertyFieldMap(), allPositiveStrategicFieldsList, this.SelectedResourceResourceRoleStrategicAcc, this.CurrentUserResourceRoleStrategicAcc, 'Overall_Strategic_Rating_2__c', 'Average_Strategic_Rating__c');
            this.processSkillCategory(this.getGoalResultPropertyFieldMap(), allPositiveGoalResultFieldsList, this.SelectedResourceResourceRoleGoalRewAcc, this.CurrentUserResourceRoleGoalRewAcc, 'Overall_Goals_Results_Rating_2__c', 'Average_Goals_Results_Rating__c');
        }


        if (isValid) {
            console.log(" kraRecord B4 SAVE " + this.kraRecord);
            submitKraRecord({ kraRecord: this.kraRecord })
                .then(result => {
                    console.log(" result ::" + JSON.stringify(result));
                    this.kraRecord = result;
                    console.log('going to close');
                    this.dispatchEvent(new CustomEvent('close'));
                    console.log('closed$$$$$$$$$');
                    //Check if status is COMPLETE : Disable Submit btn
                    this.isSubmitBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_COMPLETE ? true : false;
                    this.isSaveBtnDisabled = this.kraRecord.Status__c === this.STATUS_KRA_COMPLETE ? true : false;
                    //Check if status is COMPLETE : Disable Submit btn

                    console.log(" After Save ::" + JSON.stringify(this.kraRecord));
                    this.showToast('KRA submitted successfully.', this.successVariant, this.toastMode);

                    return refreshApex(this.wiredKraRecordResult);
                })
                .catch(error => {
                    this.showToast('Error updating record: ' + error.body.message, this.errorVariant, this.toastMode);
                });
        } else {
            var msg = 'Please make sure to circle back and fill all the marked fields.';
            this.showToast(msg, this.errorVariant, this.toastMode);
        }
    }

    showToast(message, variant, mode) {
        const event = new ShowToastEvent({
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
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



}