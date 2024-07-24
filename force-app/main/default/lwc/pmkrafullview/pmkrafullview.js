import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import getKRAFullDetails from '@salesforce/apex/quarterlyKRAFullViewCtrl.getPMConfigKRAFullDetails';
import completekraMethod from '@salesforce/apex/quarterlyKRAFullViewCtrl.completekraMethod';
import getLoginAnswerdata from '@salesforce/apex/quarterlyKRAFullViewCtrl.getLoginAnswerdata';
import getCurrentUserConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getCurrentUserConDetails';
import calculateAverageRatingForKRA from '@salesforce/apex/quarterlyKRAViewCtrl.calculateAverageRatingForKRA';

export default class Pmkrafullview extends NavigationMixin(LightningElement) {
    @track questions = [];
    @api tab;
    receivedKRAId;
    error;
    @track allAnswerIdList = [];
    @track kraRecord;
    @track isLoading = false;
    steps = [
        { label: 'REVIEWER DETAILS', value: 'reviewerDetails' },
        { label: 'TECHNICAL ACUMEN', value: 'technicalAcumen' },
        { label: 'PROFESSIONAL SKILLS', value: 'professionalSkills' },
        { label: 'STRATEGIC IMPACT', value: 'strategicImpact' },
        { label: 'GOALS AND RESULTS', value: 'goalsResults' },
        { label: 'OVERALL RATING', value: 'overAllRating' }
    ];
    @track selectedStep = 'reviewerDetails';
    showReviewerDetails = true;
    showTechnicalAcumen = false;
    showProfessionalSkills = false;
    showStrategicImpact = false;
    showGoalsResults = false;
    showOverAllRating = false;
    @track showKRAEditModal = false;
    @track mode;

    questionstechicalskill = [];
    questionsProfessionalskill = [];
    questionsStrategicskill = [];
    questionsGoalskill = [];
    questionsSpecificArea = [];

    //getCurrentUserResourceRole
    CurrentUserConDetails
    currentContactName;
    currentContactResourceRole;
    CurrentUserResourceRoleTechAcc;
    CurrentUserResourceRoleProfSkillAcc;
    CurrentUserResourceRoleStrategicAcc;
    resourceid;
    orgDomainId;
    showKraEditButton = false;
    submittedKRAbutton=false;

    connectedCallback() {
        this.orgDomainId = window.location.origin;
        console.log('this.tab-->' + this.tab);
    }

    @wire(getCurrentUserConDetails)
    wiredUserResourceRole({ error, data }) {
        if (data) {
            this.isLoading = true;
            this.CurrentUserConDetails = data;
            this.resourceid = data.Id;
            this.currentContactName = data.Name;
            this.currentContactResourceRole = data.Resource_Role__r.Name;

            console.log('getCurrentUserConDetails DATA :  ' + JSON.stringify(this.CurrentUserConDetails));
            //   this.profileName = data.EMS_TM_User__r.Profile.Name;
            this.CurrentUserResourceRoleTechAcc = data.Resource_Role__r.technical_acumen__c;
            this.CurrentUserResourceRoleProfSkillAcc = data.Resource_Role__r.professional_skills__c;
            this.CurrentUserResourceRoleStrategicAcc = data.Resource_Role__r.strategic_impact__c;
            this.CurrentUserResourceRoleGoalRewAcc = data.Resource_Role__r.goals_and_results__c;
            this.isLoading = false;
        } else if (error) {
            this.isLoading = false;
            console.log('getCurrentUserConDetails error :  ' + JSON.stringify(error));
            this.CurrentUserConDetails = undefined;
            this.error = error;
        }
    }

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef) {
            this.receivedKRAId = pageRef.state.c__kraid;
            console.log('receivedKRAId ' + this.receivedKRAId);
            this.tab = pageRef.state.tab;
            console.log('tab--> ' + this.tab);
        }
    }

    @wire(getLoginAnswerdata, { kraid: '$receivedKRAId', tab: '$tab' })
    loginwiredData({ error, data }) {
        if (data) {
            console.log(' getLoginAnswerdata data-->' + JSON.stringify(data));
            this.showKraEditButton = data.submittedRecords;
            this.submittedKRAbutton =data.submittedKRAbutton;
            this.isLoading = false;
        }
        else if (error) {
            this.error = error;
            console.log('this.error -->' + JSON.stringify(this.error));
            this.isLoading = false;
        }
    }

    @wire(getKRAFullDetails, { kraid: '$receivedKRAId', tab: '$tab' })
    wiredData({ error, data }) {
        if (data) {
            this.isLoading = true;

            this.questionstechicalskill = [];
            this.questionsProfessionalskill = [];
            this.questionsStrategicskill = [];
            this.questionsGoalskill = [];
            this.questionsSpecificArea = [];

            data.forEach(q => {
                let contactAnswers = {}; // To map contact Ids to their answers
                let answerIdList = []; // To store answer Ids for this question

                for (let role in q.answers) {
                    if (q.answers[role].length > 0) {
                        q.answers[role].forEach(answer => {
                            if (answer.contactId) {
                                if (!contactAnswers[answer.contactId]) {
                                    contactAnswers[answer.contactId] = {
                                        contact: { id: answer.contactId, name: answer.contactName },
                                        answers: []
                                    };
                                }
                                contactAnswers[answer.contactId].answers.push({
                                    answerId: answer.answerId,
                                    answerValue: answer.answerValue,
                                    ratingoverview: answer.Ratingoverview,
                                    descriptionoverview: answer.Descriptionoverview,
                                    rating: answer.rating
                                });
                                answerIdList.push(answer.answerId);
                            }
                        });
                    }
                }

                let questionWrapper = {
                    questionId: q.questionId,
                    questionName: q.questionName,
                    contactAnswers: Object.values(contactAnswers), // Convert dictionary to array for easier template handling
                    answerIdList: q.answerIdList,
                    goalRecord: q.goalRecord
                };
                console.log('questionWrapper-->'+JSON.stringify(questionWrapper));
                this.allAnswerIdList = data.flatMap(q => q.answersId);
                this.kraRecord = data[0].goalRecord;
               // console.log('this.kraRecord-->' + this.kraRecord);
               // console.log('this.allAnswerIdList-->' + this.allAnswerIdList);

                // Store based on area
                if (q.area === 'TECHNICAL SKILLS') {
                    this.questionstechicalskill.push(questionWrapper);
                }
                else if (q.area === 'PROFESSIONAL SKILLS') {
                    this.questionsProfessionalskill.push(questionWrapper);
                }
                else if (q.area === 'STRATEGIC IMPACT') {
                    this.questionsStrategicskill.push(questionWrapper);
                }
                else if (q.area === 'GOALS AND RESULTS') {
                    this.questionsGoalskill.push(questionWrapper);
                }
                else {
                    this.questionsSpecificArea.push(questionWrapper);
                    console.log('ENTERTED');
                    if (this.questionsSpecificArea.length > 0) {
                        console.log('ENTERTED LOOP');
                    }
                }
            });
            this.calculateAverageRatingForKRAHandler();
            this.isLoading = false;
        } else if (error) {
            this.error = error;
            console.log('this.error -->' + JSON.stringify(this.error));
            this.isLoading = false;
        }
    }

    @track wrapData;
    calculateAverageRatingForKRAHandler() {
        console.log('Received this.kraRecord : ' + JSON.stringify(this.kraRecord));
        console.log('Received this.tab : ' + this.tab);
        console.log('Received this.allAnswerIdList : ' + this.allAnswerIdList);
        if (!this.kraRecord || !this.kraRecord.Id) {
            console.error('kraRecord is not properly populated.');
            return;
        }

        calculateAverageRatingForKRA({ PMAnswerRecordsId: this.allAnswerIdList, kraRecord: this.kraRecord, tab: this.tab })
            .then(result => {
                console.log("calculateAverageRatingForKRA result ::" + JSON.stringify(result));
                this.wrapData = result;
            })
            .catch(error => {
                console.log("error ::" + JSON.stringify(error));
            });
    }

    stepSelectionHanler(event) {
        this.isLoading=true;
        const step = event.target.value;
        this.selectedStep = step;
        const stepToVisibility = {
            'reviewerDetails': 'showReviewerDetails',
            'technicalAcumen': 'showTechnicalAcumen',
            'professionalSkills': 'showProfessionalSkills',
            'strategicImpact': 'showStrategicImpact',
            'goalsResults': 'showGoalsResults',
            'overAllRating': 'showOverAllRating',
        };

        console.log('selectedStep' + this.selectedStep);
        if (this.selectedStep == 'showOverAllRating') {
            this.calculateAverageRatingForKRAHandler();
        }

        Object.keys(stepToVisibility).forEach(key => {
            console.log('key-->' + key + ' step-->' + step);
            this[stepToVisibility[key]] = key === step;
        });
        this.isLoading=false;
    }

    handleNextAction() {
        console.log('handleNextAction ' + this.selectedStep);

        this.showReviewerDetails = false;
        this.showTechnicalAcumen = false;
        this.showProfessionalSkills = false;
        this.showStrategicImpact = false;
        this.showGoalsResults = false;
        this.showOverAllRating = false;
        this.isLoading=true;
        switch (this.selectedStep) {
            case 'reviewerDetails':
                this.showTechnicalAcumen = true;
                this.selectedStep = 'technicalAcumen';
                this.isLoading=false;
                break;
            case 'technicalAcumen':
                this.showProfessionalSkills = true;
                this.selectedStep = 'professionalSkills';
                this.isLoading=false;
                break;
            case 'professionalSkills':
                this.showStrategicImpact = true;
                this.selectedStep = 'strategicImpact';
                this.isLoading=false;
                break;
            case 'strategicImpact':
                this.showGoalsResults = true;
                this.selectedStep = 'goalsResults';
                this.isLoading=false;
                break;
            case 'goalsResults':
                this.showOverAllRating = true;
                this.selectedStep = 'overAllRating';
                this.calculateAverageRatingForKRAHandler();
                this.isLoading=false;
                break;
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
        this.isLoading=true;

        // Set the specific show property to true based on the selected step
        switch (this.selectedStep) {
            case 'technicalAcumen':
                this.showReviewerDetails = true;
                this.selectedStep = 'reviewerDetails';
                this.isLoading=false;
                break;
            case 'professionalSkills':
                this.showTechnicalAcumen = true;
                this.selectedStep = 'technicalAcumen';
                this.isLoading=false;
                break;
            case 'strategicImpact':
                this.showProfessionalSkills = true;
                this.selectedStep = 'professionalSkills';
                this.isLoading=false;
                break;
            case 'goalsResults':
                this.showStrategicImpact = true;
                this.selectedStep = 'strategicImpact';
                this.isLoading=false;
                break;
            case 'overAllRating':
                this.showGoalsResults = true;
                this.selectedStep = 'goalsResults';
                this.isLoading=false;
                break;
        }
        console.log('HandlePrevious ' + this.selectedStep);
    }

    handleEditKra() {
        this.mode = 'Edit';
        this.showKRAEditModal = true;
    }

    hideKRAEditModalBox() {
        this.showKRAEditModal = false;
        this.dispatchEvent(new CustomEvent('kradata'));

    }

    handleCloseFullView() {
        var url = new URL(this.orgDomainId + '/Grid/s/performance-management');
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url.href
            }
        });
    }

    async handleCompleteKRA() {
        const result = await LightningConfirm.open({
            message: '',
            variant: 'header',
            label: 'Are you sure you want to complete the KRA?',
            // setting theme would have no effect
        });
        if (result === true) {
            this.isLoading = true;
            completekraMethod({ kraid: this.receivedKRAId })
                .then((result) => {
                    this.ShowToast(' ', 'Record(s) updated Successfully!', 'success', 'dismissable');
                    var url = new URL(this.orgDomainId + '/Grid/s/performance-management');
                    this[NavigationMixin.Navigate]({
                        type: 'standard__webPage',
                        attributes: {
                            url: url.href
                        }
                    });
                    this.isLoading = false;
                })
                .catch((error) => {
                    console.log('error-->', error);
                    this.ShowToast(' ', 'Something went wrong!', 'error', 'dismissable');
                    this.isLoading = false;
                });
        }
    }

    ShowToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}