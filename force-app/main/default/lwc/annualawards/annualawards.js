import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAnnualAwardNominationRecords from '@salesforce/apex/AnnualAwardNominationsController.getAnnualAwardNominationRecords';
import createAnnualAwardNominationRecords from '@salesforce/apex/AnnualAwardNominationsController.createAnnualAwardNominationRecords';
import submitAnnualAwardNominationRecords from '@salesforce/apex/AnnualAwardNominationsController.submitAnnualAwardNominationRecords';
import Id from "@salesforce/user/Id";
import { NavigationMixin } from 'lightning/navigation';

//Custom Labels for description
import BestEntrepreneurDesc from '@salesforce/label/c.BestEntrepreneurDesc';
import MostProfessionalDesc from '@salesforce/label/c.MostProfessionalDesc';
import RisingStarDesc from '@salesforce/label/c.RisingStarDesc';
import RockStarDesc from '@salesforce/label/c.RockStarDesc';
import ShiningStarDesc from '@salesforce/label/c.ShiningStarDesc';
import GoingAboveBeyondDesc from '@salesforce/label/c.GoingAboveBeyondDesc';
import AwardOfExcellenceDesc from '@salesforce/label/c.AwardOfExcellenceDesc';

export default class Annualawards extends NavigationMixin(LightningElement) {

    @track userId = Id;

    label = {
        BestEntrepreneurDesc,
        MostProfessionalDesc,
        RisingStarDesc,
        RockStarDesc,
        ShiningStarDesc,
        GoingAboveBeyondDesc,
        AwardOfExcellenceDesc
    };

    RAR = 'Reward_And_Recognition__c';
    @api currentfy;
    @track selectedStep = 'Best Entrepreneur';
    @track rewardAndRecognitionRecords = [];
    dataIsLoaded = false;
    disableSubmitBtn = true;
    totalRecordsSubmitted = 0;

    errorVariant = 'error';
    successVariant = 'success';
    warningVariant = 'warning';

    commentsRequiredAlert = 'You must provide comments for the selected nominee';
    resourceDuplicateAlert = 'Please select different individuals for the Primary and Secondary Nominees';
    recordSaved = 'Record Saved Successfully !';
    recordSubmitted = 'Record Submitted Successfully !';
    recordSaveError = 'Error saving records';
    recordSubmitError = 'Error submitting records';
    noRecordsError = 'Please ensure you select at least one nominee and provide comments before submitting';
    submittedMsg = 'Thank you for your award nominations. You have already successfully submitted them.';

    steps = [
        { label: 'BEST ENTREPRENEUR', value: 'Best Entrepreneur' },
        { label: 'MOST PROFESSIONAL', value: 'Most Professional' },
        { label: 'RISING STAR', value: 'Rising Star' },
        { label: 'ROCK STAR', value: 'Rock Star' },
        { label: 'SHINING STAR', value: 'Shining Star' },
        { label: 'GOING ABOVE & BEYOND', value: 'Going Above and Beyond' },
        { label: 'AWARD OF EXCELLENCE', value: 'Award of Excellence' }
    ];

    showBestEntrepreneur = true;//Default
    showMostProfessional = false;
    showRisingStar = false;
    showRockStar = false;
    showShiningStar = false;
    showGoingAboveBeyond = false;
    showAwardOfExcellence = false;
    Result = false;
    //Declared sObject variable for each section for Primary and Secondary nomination
    BE_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Best Entrepreneur',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
        //Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    BE_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Best Entrepreneur',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    MP_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Most Professional',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    MP_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Most Professional',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    RIS_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Rising Star',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    RIS_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Rising Star',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
        //Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    ROS_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Rock Star',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
        //Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    ROS_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Rock Star',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    SS_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Shining Star',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    SS_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Shining Star',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    GAB_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Going Above and Beyond',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    GAB_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Going Above and Beyond',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    AE_PR_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Award of Excellence',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
       // Status__c: 'Nominated',
        Primary_Nomination__c: true,
        Secondary_Nomination__c: false
    };

    AE_SE_RR = {
        sobjectType: this.RAR,
        Type__c: 'Annual Award',
        Award_Type__c: 'Award of Excellence',
        Reason_for_award__c: '',
        Resource__c: null,
        Fiscal_Year__c: this.currentfy,
        Recognization_By__c: this.userId,
        //Status__c: 'Nominated',
        Primary_Nomination__c: false,
        Secondary_Nomination__c: true
    };

    //WIRE TO GET RECORDS
    /* method to fetch the Nomination records created by the loggedIn User*/
    @wire(getAnnualAwardNominationRecords)
    wiredAnnualAwards({ error, data }) {
        if (data) {
            console.log(" wired Annual Awards " + JSON.stringify(data));

            data.forEach(record => {
                this.disableSubmitBtn = false;
                this.steps.forEach(step => {
                    if (step.value === record.Award_Type__c) {
                        /* Call a different function based on the Award_Type__c value and call the "handleNomination" function
                        to assign the values to respective sObject variables*/
                        switch (step.value) {
                            case 'Best Entrepreneur':
                                const resultBE = this.handleNomination(record, this.BE_PR_RR, this.BE_SE_RR);
                                this.BE_PR_RR = resultBE.updatedPrimaryNominee;
                                this.BE_SE_RR = resultBE.updatedSecondaryNominee;
                                break;
                            case 'Most Professional':
                                const resultMP = this.handleNomination(record, this.MP_PR_RR, this.MP_SE_RR);
                                this.MP_PR_RR = resultMP.updatedPrimaryNominee;
                                this.MP_SE_RR = resultMP.updatedSecondaryNominee;
                                break;
                            case 'Rising Star':
                                const resultRS = this.handleNomination(record, this.RIS_PR_RR, this.RIS_SE_RR);
                                this.RIS_PR_RR = resultRS.updatedPrimaryNominee;
                                this.RIS_SE_RR = resultRS.updatedSecondaryNominee;
                                break;
                            case 'Rock Star':
                                const resultROS = this.handleNomination(record, this.ROS_PR_RR, this.ROS_SE_RR);
                                this.ROS_PR_RR = resultROS.updatedPrimaryNominee;
                                this.ROS_SE_RR = resultROS.updatedSecondaryNominee;
                                break;
                            case 'Shining Star':
                                const resultSS = this.handleNomination(record, this.SS_PR_RR, this.SS_SE_RR);
                                this.SS_PR_RR = resultSS.updatedPrimaryNominee;
                                this.SS_SE_RR = resultSS.updatedSecondaryNominee;
                                break;
                            case 'Going Above and Beyond':
                                const resultGAB = this.handleNomination(record, this.GAB_PR_RR, this.GAB_SE_RR);
                                this.GAB_PR_RR = resultGAB.updatedPrimaryNominee;
                                this.GAB_SE_RR = resultGAB.updatedSecondaryNominee;
                                break;
                            case 'Award of Excellence':
                                const resultAE = this.handleNomination(record, this.AE_PR_RR, this.AE_SE_RR);
                                this.AE_PR_RR = resultAE.updatedPrimaryNominee;
                                this.AE_SE_RR = resultAE.updatedSecondaryNominee;
                                break;
                        }
                    }
                })
            })

            console.log('#totalRecordsSubmitted ' + this.totalRecordsSubmitted);
            setTimeout(() => this.dataIsLoaded = true, 2000);

            //Calculating the Number of records submitted
            setTimeout(() =>
                data.forEach(record => {
                    if (record.Nomination_Submitted__c) {
                        this.totalRecordsSubmitted = this.totalRecordsSubmitted + 1;
                    }
                })
                , 1000);

        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    /*This function is called based on the Award Type value of the wire records.
    This Function receives each record receoved from wire method and assign values to sObjects for Primary and Secondary nominee.
    Record : Actual record received from wire method
    primaryNomineeObj : the Primary sObject for respective "Award Type"
    secondaryNomineeObj : the Secondary sObject for respective "Award Type"
    Return : Primary and Secondary objects
    */
    handleNomination(record, primaryNomineeObj, secondaryNomineeObj) {
        console.log("#291");
        console.log("#record :" + JSON.stringify(record));
        console.log("#primaryNomineeObj :" + JSON.stringify(primaryNomineeObj));
        console.log("#secondaryNomineeObj :" + JSON.stringify(secondaryNomineeObj));

        let updatedPrimaryNominee = { ...primaryNomineeObj };
        let updatedSecondaryNominee = { ...secondaryNomineeObj };

        if (record.Primary_Nomination__c) {
            updatedPrimaryNominee = { ...record };
        } else {
            updatedSecondaryNominee = { ...record };
        }
        return { updatedPrimaryNominee, updatedSecondaryNominee };
    }


    //STEP CHANGE CODE
    /* Function to Update the Steps value and make the selected step section visible */
    stepSelectionHanler(event) {
        this.selectedStep = event.target.value;
        console.log("selectedStep : " + this.selectedStep);
        this.showBestEntrepreneur = this.selectedStep === 'Best Entrepreneur';
        this.showMostProfessional = this.selectedStep === 'Most Professional';
        this.showRisingStar = this.selectedStep === 'Rising Star';
        this.showRockStar = this.selectedStep === 'Rock Star';
        this.showShiningStar = this.selectedStep === 'Shining Star';
        this.showGoingAboveBeyond = this.selectedStep === 'Going Above and Beyond';
        this.showAwardOfExcellence = this.selectedStep === 'Award of Excellence';
    }

    /* This function assigns the selected "Resource/Contact" value to the Primary/Secondary sobject variable property.
    "assignObjectValues" function is called based on Primary/Secondary value selection
    */
    handleValueSelectedOnAccount(event) {
        const selectedLookupValue = event.detail;
        console.log(" selectedLookupValue " + JSON.stringify(selectedLookupValue));
        const value = selectedLookupValue.id;
        const label = selectedLookupValue.label;
        let currentStep = this.selectedStep;
        let field2Update = 'Resource__c';
        let field2Update2 = 'Award_Type__c';
        let primaryType = 'Primary';
        let secondaryType = 'Secondary';

        if (label === 'Primary Nominee') {
            this.assignObjectValues(currentStep, value, field2Update, field2Update2, primaryType);
        }
        if (label === 'Secondary Nominee') {
            this.assignObjectValues(currentStep, value, field2Update, field2Update2, secondaryType);
        }
    }

    /* This function assigns the selected "Comment" value to the Primary/Secondary sobject variable property.
    "assignObjectValues" function is called based on Primary/Secondary value selection
    */
    handleCommentsChange(event) {
        const { name, value } = event.target;
        let currentStep = this.selectedStep;
        let field2Update = 'Reason_for_award__c';
        let field2Update2 = 'Award_Type__c';
        let primaryType = 'Primary';
        let secondaryType = 'Secondary';

        if (name === 'PriComments') {
            this.assignObjectValues(currentStep, value, field2Update, field2Update2, primaryType);
        }
        if (name === 'SecComments') {
            this.assignObjectValues(currentStep, value, field2Update, field2Update2, secondaryType);
        }
    }

    /*
    Based on the currentStep and fieldtype value this function is used for updating the Sobjects property values.
    currentStep : Current Screen label(header)
    val : Contact Id (Lookup Contact)
    field2Update : Resource__c property of sObject
    field2Update2 : Award_Type__c property fo sObject
    */
    assignObjectValues(currentStep, val, field2Update, field2Update2, fieldtype) {

        if (currentStep === 'Best Entrepreneur') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.BE_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.BE_PR_RR = RR;
            } else {
                let RR = { ...this.BE_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.BE_SE_RR = RR;
            }
        }

        if (currentStep === 'Most Professional') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.MP_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.MP_PR_RR = RR;
            } else {
                let RR = { ...this.MP_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.MP_SE_RR = RR;
            }
        }

        if (currentStep === 'Rising Star') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.RIS_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.RIS_PR_RR = RR;
            } else {
                let RR = { ...this.RIS_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.RIS_SE_RR = RR;
            }
        }

        if (currentStep === 'Rock Star') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.ROS_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.ROS_PR_RR = RR;
            } else {
                let RR = { ...this.ROS_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.ROS_SE_RR = RR;
            }
        }

        if (currentStep === 'Shining Star') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.SS_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.SS_PR_RR = RR;
            } else {
                let RR = { ...this.SS_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.SS_SE_RR = RR;
            }
        }

        if (currentStep === 'Going Above and Beyond') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.GAB_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.GAB_PR_RR = RR;
            } else {
                let RR = { ...this.GAB_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.GAB_SE_RR = RR;
            }
        }

        if (currentStep === 'Award of Excellence') {
            if (fieldtype === 'Primary') {
                let RR = { ...this.AE_PR_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.AE_PR_RR = RR;
            } else {
                let RR = { ...this.AE_SE_RR };
                RR[field2Update] = val;
                RR[field2Update2] = currentStep;
                this.AE_SE_RR = RR;
            }
        }
    }

    //NEXT BUTTON CODE
    /*
    This function is used for Navigation.
    But first we are validating the values of Current Step Screen.
    By calling "addObjToArrAndValidate" we are checking the input validation.
    Once Validation is succesfull next screen will be visible.
    */
    handleNextButtonAction(event) {
        console.log('Inside next btn');
        const currentStep = this.selectedStep;
        let isValid = true;

        isValid = this.addObjToArrAndValidate(currentStep);
        console.log('isValid 526' +  isValid);
        if (isValid) {

            this.showBestEntrepreneur = false;
            this.showMostProfessional = false;
            this.showRisingStar = false;
            this.showRockStar = false;
            this.showShiningStar = false;
            this.showGoingAboveBeyond = false;
            this.showAwardOfExcellence = false;

            if (currentStep == 'Best Entrepreneur') {
                this.showMostProfessional = true;
            }
            if (currentStep == 'Most Professional') {
                this.showRisingStar = true;
            }
            if (currentStep == 'Rising Star') {
                this.showRockStar = true;
            }
            if (currentStep == 'Rock Star') {
                this.showShiningStar = true;
            }
            if (currentStep == 'Shining Star') {
                this.showGoingAboveBeyond = true;
            }
            if (currentStep == 'Going Above and Beyond') {
                this.showAwardOfExcellence = true;
            }
            this.selectedStep = this.getNextStep();
        }
        console.log("Present Step : " + this.selectedStep);
        console.log(" rewardAndRecognitionRecords  " + JSON.stringify(this.rewardAndRecognitionRecords));
    }

    /*
    Based on current Step Screen we are checking the values of the Sobjects.
    Alert is thrown if duplicate resource is selected for same Award Type.
    */
    addObjToArrAndValidate(currentStep) {
        console.log("# IN addObjToArrAndValidate  ");
        let Result = false;
        let PriN, SecN;

        if (currentStep === 'Best Entrepreneur') {
            PriN = { ...this.BE_PR_RR };
            SecN = { ...this.BE_SE_RR };
        } else if (currentStep === 'Most Professional') {
            PriN = { ...this.MP_PR_RR };
            SecN = { ...this.MP_SE_RR };
        } else if (currentStep === 'Rising Star') {
            PriN = { ...this.RIS_PR_RR };
            SecN = { ...this.RIS_SE_RR };
        } else if (currentStep === 'Rock Star') {
            PriN = { ...this.ROS_PR_RR };
            SecN = { ...this.ROS_SE_RR };
        } else if (currentStep === 'Shining Star') {
            PriN = { ...this.SS_PR_RR };
            SecN = { ...this.SS_SE_RR };
        } else if (currentStep === 'Going Above and Beyond') {
            PriN = { ...this.GAB_PR_RR };
            SecN = { ...this.GAB_SE_RR };
        } else if (currentStep === 'Award of Excellence') {
            PriN = { ...this.AE_PR_RR };
            SecN = { ...this.AE_SE_RR };
        }

        if (PriN.Resource__c || SecN.Resource__c) {
            if (PriN.Resource__c === SecN.Resource__c) {
                this.removeDuplicateRecord(SecN.Resource__c, SecN.Award_Type__c);
                this.showNotification(this.resourceDuplicateAlert, this.warningVariant);
                Result = false;
            } else {
                if (PriN.Resource__c) {
                    console.log("# IN PRIN RES  ");
                    if (PriN.Reason_for_award__c) {
                        this.addToRewardAndRecognitionRecords(PriN);
                        //14/12/2023
                        Result = true;
                    } else {
                        this.showNotification(this.commentsRequiredAlert, this.warningVariant);
                        Result = false;
                    }
                }
                if (SecN.Resource__c) {
                    console.log("# IN SecN RES  ");
                    if (SecN.Reason_for_award__c) {
                        this.addToRewardAndRecognitionRecords(SecN);
                        //14/12/2023
                        Result = true;
                    } else {
                        this.showNotification(this.commentsRequiredAlert, this.warningVariant);
                        Result = false;
                    }
                }
            }
        }else{
            Result = true;
        }

        return Result;
    }

    addToRewardAndRecognitionRecords(record) {
        console.log("# IN addToRewardAndRecognitionRecords  ");
        const existingRecordIndex = this.rewardAndRecognitionRecords.findIndex(
            existingRecord => existingRecord.Resource__c === record.Resource__c && existingRecord.Award_Type__c === record.AwardType
        );

        if (existingRecordIndex > -1) {
            // If the record exists, update it
            this.rewardAndRecognitionRecords[existingRecordIndex] = record;
        } else {
            // If the record doesn't exist, add it
            this.rewardAndRecognitionRecords.push(record);
        }
    }

    removeDuplicateRecord(Resource, AwardType) {
        console.log("removeDuplicateRecord");
        const existingRecordIndex = this.rewardAndRecognitionRecords.findIndex(
            record => record.Resource__c === Resource && record.Award_Type__c === AwardType
        );

        if (existingRecordIndex > -1) {
            this.rewardAndRecognitionRecords.splice(existingRecordIndex, 1);
        }
    }

    validationOnSaveButton(){

        //let Result = false;

        const recordPairs = [
            [this.BE_PR_RR, this.BE_SE_RR],
            [this.MP_PR_RR, this.MP_SE_RR],
            [this.RIS_PR_RR, this.RIS_SE_RR],
            [this.ROS_PR_RR, this.ROS_SE_RR],
            [this.SS_PR_RR, this.SS_SE_RR],
            [this.GAB_PR_RR, this.GAB_SE_RR],
            [this.AE_PR_RR, this.AE_SE_RR]
          ];
          
          for (const [prRecord, seRecord] of recordPairs) {
            if (prRecord.Resource__c !== null && seRecord.Resource__c !== null && prRecord.Resource__c === seRecord.Resource__c) {
              this.removeDuplicateRecord(seRecord.Resource__c, seRecord.Award_Type__c);
              this.showNotification(this.resourceDuplicateAlert, this.warningVariant);
              return false;
            }
          }

        }

    //SAVE BUTTON CODE
    handleSaveButtonAction() {
        console.log("Save Start");
        console.log("## B4 SAVE rewardAndRecognitionRecords data" + JSON.stringify(this.rewardAndRecognitionRecords));
        let sectionObjects = [this.BE_PR_RR, this.BE_SE_RR, this.MP_PR_RR, this.MP_SE_RR, this.RIS_PR_RR, this.RIS_SE_RR, this.ROS_PR_RR, this.ROS_SE_RR, this.SS_PR_RR, this.SS_SE_RR, this.GAB_PR_RR, this.GAB_SE_RR, this.AE_PR_RR, this.AE_SE_RR];
        
        let returnValue = this.validationOnSaveButton();
        if (returnValue==false){
            return false;
        }

        let isPrevSectionValPopulated = this.hasObjectWithPopulatedValues();
        console.log("isPrevSectionValPopulated " + isPrevSectionValPopulated);
        var Result = this.addObjToArrAndValidate(this.selectedStep);
        console.log("Result " + Result);
  

        if (Result) {
            if (isPrevSectionValPopulated) {
                //if (this.rewardAndRecognitionRecords.length > 0) {
                if (sectionObjects.length > 0) {
                    createAnnualAwardNominationRecords({ recordsToCreate: sectionObjects, currentfy: this.currentfy,status :'Draft' })
                        .then(result => {
                            console.log('Records created successfully: ' + JSON.stringify(result));

                            result.forEach(record => {
                                // Find the matching object based on Award_Type__c and Primary_Nomination__c
                                let matchingObject = sectionObjects.find(obj => obj.Award_Type__c === record.Award_Type__c && obj.Primary_Nomination__c === record.Primary_Nomination__c);
                                // If a matching object is found, update its properties with the returned record values
                                if (matchingObject) {
                                    matchingObject.Resource__c = record.Resource__c;
                                    matchingObject.Id = record.Id;
                                }
                            });
                            this.rewardAndRecognitionRecords = sectionObjects;
                            console.log("## AFTER SAVE rewardAndRecognitionRecords data" + JSON.stringify(this.rewardAndRecognitionRecords));
                            this.showNotification(this.recordSaved, this.successVariant);
                            this.disableSubmitBtn = false;
                            //smaske : [PM_075] : Dispatching event for refresehing My Nomination Tab data
                            const event = new CustomEvent('refreshdata');
                            this.dispatchEvent(event);

                        })
                        .catch(error => {
                            console.error('Error creating records: ' + JSON.stringify(error));
                            this.showNotification(this.recordSaveError, this.errorVariant);
                        });
                } else {
                    this.showNotification(this.noRecordsError, this.warningVariant);
                }
            }
        } else {
            //this.showNotification(this.noRecordsError, this.warningVariant);
        }
    }

    hasObjectWithPopulatedValues() {
        console.log('hasObjectWithPopulatedValues');
        let result = true;
        let sectionObjects = [
            this.BE_PR_RR, this.BE_SE_RR, this.MP_PR_RR, this.MP_SE_RR,
            this.RIS_PR_RR, this.RIS_SE_RR, this.ROS_PR_RR, this.ROS_SE_RR,
            this.SS_PR_RR, this.SS_SE_RR, this.GAB_PR_RR, this.GAB_SE_RR
        ];
        // Check if any object has Resource__c populated but Reason_for_award__c not populated
        const hasInvalidObject = sectionObjects.some(obj => {
            console.log(JSON.stringify(obj));
            return obj.Resource__c && !obj.Reason_for_award__c;
        });

        if (hasInvalidObject) {
            console.log("At least one object has Resource__c populated but Reason_for_award__c not populated");
            this.showNotification(this.commentsRequiredAlert, this.warningVariant);
            result = false;
        } else {
            // Check if at least one object has both Resource__c and Reason_for_award__c values populated
            const hasBothValuesPopulated = sectionObjects.some(obj => {
                return obj.Resource__c && obj.Reason_for_award__c;
            });

            if (hasBothValuesPopulated) {
                console.log("At least one object has both Resource__c and Reason_for_award__c values populated");
                result = true;
            }
        }
        console.log(result);
        console.log('hasObjectWithPopulatedValues end');
        return result;
    }

    //SUBMIT BUTTON CODE
    handleSubmitButtonAction() {
        console.log("SUBMIT");
        let sectionObjects = [this.BE_PR_RR, this.BE_SE_RR, this.MP_PR_RR, this.MP_SE_RR, this.RIS_PR_RR, this.RIS_SE_RR, this.ROS_PR_RR, this.ROS_SE_RR, this.SS_PR_RR, this.SS_SE_RR, this.GAB_PR_RR, this.GAB_SE_RR, this.AE_PR_RR, this.AE_SE_RR];
        let isPrevSectionValPopulated = this.hasObjectWithPopulatedValues();
        var Result = this.addObjToArrAndValidate(this.selectedStep);
        console.log("# isPrevSectionValPopulated # " + JSON.stringify(Result));
        console.log("# Result # " + JSON.stringify(Result));
        let returnValue = this.validationOnSaveButton();
        if (returnValue==false){
            return false;
        }
        if (Result) {
            if (isPrevSectionValPopulated) {
                //14/12/2024 : passing sectionObjects instead of rewardAndRecognitionRecords to apex
                if (sectionObjects.length > 0) {
                    console.log("#673");

                    //14/12/2024 : replaced rewardAndRecognitionRecords with sectionObjects
                    const recordsToBeSubmitted = sectionObjects.filter(record =>
                        record.Resource__c && record.Reason_for_award__c
                    );
                    console.log("recordsToBeSubmitted " + JSON.stringify(recordsToBeSubmitted));
                    if (recordsToBeSubmitted.length > 0) {
                        console.log("#679");
                        submitAnnualAwardNominationRecords({ recordsToSubmit: recordsToBeSubmitted, currentfy: this.currentfy, status :'Nominated' })
                            .then(result => {
                                console.log('Submit result : ' + JSON.stringify(result));
                                this.showNotification(this.recordSubmitted, this.successVariant);
                                //smaske : [PM_075] : Dispatching event for refresehing My Nomination Tab data
                                const event = new CustomEvent('refreshdata');
                                this.dispatchEvent(event);

                                setTimeout(function(){
                                    window.location.reload();
                                 }, 5000);
                                /*this[NavigationMixin.Navigate]({
                                    type: 'comm__namedPage',
                                    attributes: {
                                        name: 'Home'
                                    }
                                });*/
                            })
                            .catch(error => {
                                console.error('Error creating records: ' + JSON.stringify(error));
                                this.showNotification(this.recordSubmitError, this.errorVariant);
                            });
                    }
                } else {
                    this.showNotification(this.noRecordsError, this.warningVariant);
                }
            }
        } else {
            this.showNotification(this.noRecordsError, this.warningVariant);
        }
        console.log("Submit Ended");
    }

    handleValueRemovedOnAccount(event){
        console.log('# handleValueRemovedOnAccount');
        const selectedLookupValue = event.detail;
        const value = selectedLookupValue.id;
        const label = selectedLookupValue.label;
        let currentStep = this.selectedStep;
        this.removeAssignObjectValues(currentStep,selectedLookupValue);
    }

    removeAssignObjectValues(currentStep,selectedLookupValue){
        //this.assignObjectValues(currentStep, value, field2Update, field2Update2, primaryType);
        console.log('# IN removeAssignObjectValues');
        console.log('# currentStep' + currentStep);
        console.log('# selectedLookupValue' + JSON.stringify(selectedLookupValue));
        if (currentStep === 'Best Entrepreneur') {
            let RRP = { ...this.BE_PR_RR };
            let RRS = { ...this.BE_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.BE_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.BE_SE_RR = this.removeValuesHelper(RRS);
            }
        }

        if (currentStep === 'Most Professional') {
            let RRP = { ...this.MP_PR_RR };
            let RRS = { ...this.MP_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.MP_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.MP_SE_RR = this.removeValuesHelper(RRS);
            }
        }

        if (currentStep === 'Rising Star') {
            let RRP = { ...this.RIS_PR_RR };
            let RRS = { ...this.RIS_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.RIS_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.RIS_SE_RR = this.removeValuesHelper(RRS);
            }
        }

        if (currentStep === 'Rock Star') {
            let RRP = { ...this.ROS_PR_RR };
            let RRS = { ...this.ROS_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.ROS_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.ROS_SE_RR = this.removeValuesHelper(RRS);
            }
        }

        if (currentStep === 'Shining Star') {
            let RRP = { ...this.SS_PR_RR };
            let RRS = { ...this.SS_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.SS_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.SS_SE_RR = this.removeValuesHelper(RRS);
            }
        }

        if (currentStep === 'Going Above and Beyond') {
            let RRP = { ...this.GAB_PR_RR };
            let RRS = { ...this.GAB_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.GAB_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.GAB_SE_RR = this.removeValuesHelper(RRS);
            }
        }

        if (currentStep === 'Award of Excellence') { 
            let RRP = { ...this.AE_PR_RR };
            let RRS = { ...this.AE_SE_RR };
            if (RRP.Resource__c === selectedLookupValue.id) {
                this.AE_PR_RR = this.removeValuesHelper(RRP);
            }
            else if (RRS.Resource__c === selectedLookupValue.id) {
                this.AE_SE_RR = this.removeValuesHelper(RRS);
            }
        }
    }

    removeValuesHelper(tempObj){
        console.log(' IN removeValuesHelper ');
        console.log(' tempObj ' +  JSON.stringify(tempObj));
        tempObj.Resource__c = null;
        tempObj.Reason_for_award__c = '';
        console.log(' tempObj ' +  JSON.stringify(tempObj));
        return tempObj;
    }




















    //CANCLE BUTTON CODE
    handleCancelButtonAction() {
        this.dispatchEvent(new CustomEvent('close'))
    }

    //BACK BUTTON CODE
    handlePreviousButtonAction() {
        console.log('handlePreviousAction ' + this.selectedStep);
        var moveToPreviousStep = this.selectedStep;
        switch (moveToPreviousStep) {
            case 'Best Entrepreneur':
                this.showBestEntrepreneur = false;
                this.showMostProfessional = false;
                this.showRisingStar = false;
                this.showRockStar = false;
                this.showShiningStar = false;
                this.showGoingAboveBeyond = false;
                this.showAwardOfExcellence = true;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Most Professional':
                this.showBestEntrepreneur = true;
                this.showMostProfessional = false;
                this.showRisingStar = false;
                this.showRockStar = false;
                this.showShiningStar = false;
                this.showGoingAboveBeyond = false;
                this.showAwardOfExcellence = false;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Rising Star':
                this.showBestEntrepreneur = false;
                this.showMostProfessional = true;
                this.showRisingStar = false;
                this.showRockStar = false;
                this.showShiningStar = false;
                this.showGoingAboveBeyond = false;
                this.showAwardOfExcellence = false;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Rock Star':
                this.showBestEntrepreneur = false;
                this.showMostProfessional = false;
                this.showRisingStar = true;
                this.showRockStar = false;
                this.showShiningStar = false;
                this.showGoingAboveBeyond = false;
                this.showAwardOfExcellence = false;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Shining Star':
                this.showBestEntrepreneur = false;
                this.showMostProfessional = false;
                this.showRisingStar = false;
                this.showRockStar = true;
                this.showShiningStar = false;
                this.showGoingAboveBeyond = false;
                this.showAwardOfExcellence = false;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Going Above and Beyond':
                this.showBestEntrepreneur = false;
                this.showMostProfessional = false;
                this.showRisingStar = false;
                this.showRockStar = false;
                this.showShiningStar = true;
                this.showGoingAboveBeyond = false;
                this.showAwardOfExcellence = false;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
            case 'Award of Excellence':
                this.showBestEntrepreneur = false;
                this.showMostProfessional = false;
                this.showRisingStar = false;
                this.showRockStar = false;
                this.showShiningStar = false;
                this.showGoingAboveBeyond = true;
                this.showAwardOfExcellence = false;
                this.selectedStep = this.getPreviousStep();
                console.log('HandlePrevious ' + this.selectedStep);
                break;
        }
    }

    getNextStep() {
        const currentStepIndex = this.steps.findIndex(step => step.value === this.selectedStep);
        if (currentStepIndex < this.steps.length - 1) {
            return this.steps[currentStepIndex + 1].value;
        } else {
            return this.selectedStep;
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

    @api
    get setSaveBtnVisibility() {
        if (this.selectedStep === 'Award of Excellence') {
            return 'slds-show slds-p-around_medium';
        }
        return 'slds-hide slds-p-around_medium';
    }

    @api
    get setSubmitBtnVisibility() {
        if (this.selectedStep === 'Award of Excellence') {
            return 'slds-show slds-p-around_medium';
        }
        return 'slds-hide slds-p-around_medium';
    }

    @api
    get setBackBtnVisibility() {
        if (this.selectedStep === 'Best Entrepreneur') {
            return 'slds-hide slds-p-around_medium';
        }
        return 'slds-show slds-p-around_medium';
    }

    @api
    get setNextBtnVisibility() {
        if (this.selectedStep === 'Award of Excellence') {
            return 'slds-hide slds-p-around_medium';
        }
        return 'slds-show slds-p-around_medium';
    }

    @api
    get recordsSubmitted() {
        return this.totalRecordsSubmitted > 0;
    }

    showNotification(msg, variant) {
        const evt = new ShowToastEvent({
            title: '',
            message: msg,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}