import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getKRAFullDetails from '@salesforce/apex/quarterlyKRAFullViewCtrl.getPMConfigKRAFullDetails';
import getLoginAnswerdata from '@salesforce/apex/quarterlyKRAFullViewCtrl.getLoginAnswerdata';
import getCurrentUserConDetails from '@salesforce/apex/quarterlyKRAViewCtrl.getCurrentUserConDetails';
import calculateAverageRatingForKRA from '@salesforce/apex/CalculateFullQuarterlyKRA.calculateAverageRatingForKRA';
import completekraMethod from '@salesforce/apex/quarterlyKRAFullViewCtrl.completekraMethod';
import SavePMFeedbackReason from '@salesforce/apex/quarterlyKRAFullViewCtrl.SavePMFeedbackReason';
import Genericmodal from 'c/genericmodal';

export default class Pmkrafullview extends NavigationMixin(LightningElement) {
    @track questions = [];
    @api tab;
    receivedKRAId;
    viewonlymode = false;
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

    CurrentUserConDetails
    currentContactName;
    currentContactResourceRole;
    resourceid;
    orgDomainId;
    showKraEditButton = false;
    submittedKRAbutton = false;
    isLoaded = false;
    disabledCheckbox = false;
    visiablecheckbox = false;
    visiableNote = false;
    showFeedbackReason = false;

    connectedCallback() {
        this.orgDomainId = window.location.origin;
        console.log('this.tab-->' + this.tab);
    }

    @wire(getCurrentUserConDetails)
    wiredUserResourceRole({ error, data }) {
        if (data) {
            this.isLoading = true;
            this.CurrentUserConDetails = data;
            // this.resourceid = data.Id;
            this.currentContactName = data.Name;
            this.currentContactResourceRole = data.Resource_Role__r.Name;

            console.log('getCurrentUserConDetails DATA :  ' + JSON.stringify(this.CurrentUserConDetails));
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
            this.viewonlymode = pageRef.state.viewonlymode;
            console.log('viewonlymode--> ' + this.viewonlymode);
        }
    }

    @wire(getLoginAnswerdata, { kraid: '$receivedKRAId', tab: '$tab', viewonlymode: '$viewonlymode' })
    loginwiredData({ error, data }) {
        if (data) {
            console.log(' getLoginAnswerdata data-->' + JSON.stringify(data));
            this.showKraEditButton = data.submittedRecords;
            this.submittedKRAbutton = data.submittedKRAbutton;
            this.disabledCheckbox = !this.submittedKRAbutton;
            this.visiableNote = data.overallViewScreenNote;
            this.visiablecheckbox = data.visiablecheckbox;
            console.log('this.submittedKRAbutton' + this.submittedKRAbutton);
            console.log('this.disabledCheckbox' + this.disabledCheckbox);
            if (this.tab == 'My Team' && this.submittedKRAbutton) {
                this.showFeedbackReason = true;
            } else {
                this.showFeedbackReason = false;
            }
            this.resourceid = data.kraResourceId;
            console.log('this.resourceid-->' + this.resourceid);
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
            console.log('data' + JSON.stringify(data));
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
                                        contact: {
                                            id: answer.contactId,
                                            name: answer.contactName,
                                            projectname: answer.ProjectName,
                                            resourceRole: answer.resourceRole,
                                            classs: answer.ConsiderFeedbackRating ? 'green' : 'red'
                                        }, // @sangharsh adding projectname and resource role
                                        answers: []
                                    };
                                }
                                contactAnswers[answer.contactId].answers.push({
                                    answerId: answer.answerId,
                                    answerValue: answer.answerValue,
                                    ratingoverview: answer.Ratingoverview,
                                    descriptionoverview: answer.Descriptionoverview,
                                    rating: answer.rating,
                                    classs: answer.ConsiderFeedbackRating ? 'green' : 'red'
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
                console.log('questionWrapper-->' + JSON.stringify(questionWrapper));
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
            // this.calculateAverageRatingForKRAHandler();
            this.isLoading = false;
        } else if (error) {
            this.error = error;
            console.log('this.error -->' + JSON.stringify(this.error));
            this.isLoading = false;
        }
    }

    @track areaWrapperList = [];
    @track contacts = [];
    @track processedData = [];
    overallRatings;

    @wire(calculateAverageRatingForKRA, { kraid: '$receivedKRAId', tab: '$tab' })
    wiredcalculateData({ error, data }) {
        if (data) {
            console.log('receivedKRAId-->' + this.receivedKRAId);
            console.log('tab-->' + this.tab);
            console.log('data-->' + JSON.stringify(data));
            this.areaWrapperList = data;
            this.processData();
        } else if (error) {
            this.error = error;
            console.log('nw this.error -->' + JSON.stringify(this.error));
        }
    }

    processData() {
        let contactMap = new Map();
        let contactOverallRatingMap = new Map();
        // Define the custom order for the areas
        const areaOrder = ['TECHNICAL SKILLS', 'PROFESSIONAL SKILLS', 'STRATEGIC IMPACT', 'GOALS AND RESULTS'];
        console.log('areaOrder-->' + areaOrder);
        // Sort the areaWrapperList based on the custom order
        let sortedAreaWrapperList = areaOrder.map(area =>
            this.areaWrapperList.find(wrapper => wrapper.area === area)
        ).filter(wrapper => wrapper !== undefined);

        this.processedData = sortedAreaWrapperList.map(areaWrapper => {
            let ratingsArray = [];
            let totalRating = 0;
            let totalSkillRating = 0;
            let totalCount = 0;

            for (let contactId in areaWrapper.answerscalculation) {
                let answer = areaWrapper.answerscalculation[contactId][0];
                let averageRating = parseFloat(answer.averageRating).toFixed(2);
                let AvgRatingSkillForResource = parseFloat(answer.AvgRatingSkillForResource).toFixed(2);

                ratingsArray.push({
                    contactId: contactId,
                    averageRating: averageRating,
                    AvgRatingSkillForResource: AvgRatingSkillForResource,
                    ConsiderFeedbackRating: answer.ConsiderFeedbackRating,
                    classs: answer.ConsiderFeedbackRating ? 'green' : 'red',
                });

                totalRating += parseFloat(answer.averageRating);
                totalSkillRating += parseFloat(answer.AvgRatingSkillForResource);
                totalCount++;

                if (!contactMap.has(contactId)) {
                    contactMap.set(contactId, {
                        contactId: answer.contactId,
                        contactname: answer.contactname,
                        projectname: answer.ProjectName,
                        resourceRole: answer.resourceRole,
                        ConsiderFeedbackRating: answer.ConsiderFeedbackRating,
                        classs: answer.ConsiderFeedbackRating ? 'green' : 'red',
                        requiredreason: !answer.ConsiderFeedbackRating,
                        NotConsiderFeedbackReason: answer.NotConsiderFeedbackReason
                        // @sangharsh adding projectname and resource role
                    });
                }
                if (!contactOverallRatingMap.has(contactId)) {
                    contactOverallRatingMap.set(contactId, {
                        rating: 0,
                        ConsiderFeedbackRating: answer.ConsiderFeedbackRating
                    });
                }
                let contactData = contactOverallRatingMap.get(contactId);
                contactOverallRatingMap.set(contactId, {
                    ...contactData,
                    rating: contactData.rating + parseFloat(answer.AvgRatingSkillForResource)
                });
            }

            let overallAverage = (totalCount > 0) ? (totalRating / totalCount).toFixed(2) : 'N/A';
            let overallSkillAverage = (totalCount > 0) ? (totalSkillRating / totalCount).toFixed(2) : 'N/A';

            return {
                area: areaWrapper.area,
                areapercentage: areaWrapper.areapercentage,
                ratings: ratingsArray,
                overallAverage: `${overallAverage} (${overallSkillAverage})`
            };
        });
        // Convert contactOverallRatingMap to an array for template rendering
        this.overallRatings = Array.from(contactOverallRatingMap.entries()).map(([contactId, { rating, ConsiderFeedbackRating }]) => ({
            contactId: contactId,
            overallRating: rating.toFixed(2),
            ConsiderFeedbackRating: ConsiderFeedbackRating,
            classs: ConsiderFeedbackRating ? 'green' : 'red'
        }));
        console.log('this.overallRatings' + JSON.stringify(this.overallRatings));

        this.contacts = Array.from(contactMap.values());
        const allConsidered = this.contacts.every(contact => contact.ConsiderFeedbackRating);
        this.showthisSection = !allConsidered;

        /* this.contacts = Array.from(contactMap.values()).map(contact => {
             return {
                 ...contact,
                 classs: contact.ConsiderFeedbackRating ? 'green' : 'red' // Add class dynamically
             };
         });*/
        console.log('this.contacts' + JSON.stringify(this.contacts));
    }

    stepSelectionHanler(event) {
        this.isLoading = true;
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

        Object.keys(stepToVisibility).forEach(key => {
            console.log('key-->' + key + ' step-->' + step);
            this[stepToVisibility[key]] = key === step;
        });
        this.isLoading = false;
    }

    handleNextAction() {
        console.log('handleNextAction ' + this.selectedStep);

        this.showReviewerDetails = false;
        this.showTechnicalAcumen = false;
        this.showProfessionalSkills = false;
        this.showStrategicImpact = false;
        this.showGoalsResults = false;
        this.showOverAllRating = false;
        this.isLoading = true;
        switch (this.selectedStep) {
            case 'reviewerDetails':
                this.showTechnicalAcumen = true;
                this.selectedStep = 'technicalAcumen';
                this.isLoading = false;
                break;
            case 'technicalAcumen':
                this.showProfessionalSkills = true;
                this.selectedStep = 'professionalSkills';
                this.isLoading = false;
                break;
            case 'professionalSkills':
                this.showStrategicImpact = true;
                this.selectedStep = 'strategicImpact';
                this.isLoading = false;
                break;
            case 'strategicImpact':
                this.showGoalsResults = true;
                this.selectedStep = 'goalsResults';
                this.isLoading = false;
                break;
            case 'goalsResults':
                this.showOverAllRating = true;
                this.selectedStep = 'overAllRating';
                this.isLoading = false;
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
        this.isLoading = true;

        // Set the specific show property to true based on the selected step
        switch (this.selectedStep) {
            case 'technicalAcumen':
                this.showReviewerDetails = true;
                this.selectedStep = 'reviewerDetails';
                this.isLoading = false;
                break;
            case 'professionalSkills':
                this.showTechnicalAcumen = true;
                this.selectedStep = 'technicalAcumen';
                this.isLoading = false;
                break;
            case 'strategicImpact':
                this.showProfessionalSkills = true;
                this.selectedStep = 'professionalSkills';
                this.isLoading = false;
                break;
            case 'goalsResults':
                this.showStrategicImpact = true;
                this.selectedStep = 'strategicImpact';
                this.isLoading = false;
                break;
            case 'overAllRating':
                this.showGoalsResults = true;
                this.selectedStep = 'goalsResults';
                this.isLoading = false;
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

    //Feedback response once submitted, cannot be reverted. Would you like to proceed?
    async handleCompleteKRA() {
        /* const result = await LightningConfirm.open({
             message: '',
             variant: 'header',
             label: 'Are you sure you want to complete the KRA?',
             // setting theme would have no effect
         });*/

        const relevantContacts = this.contacts.filter(contact => contact.contactId.includes('&'));
        console.log('relevantContacts.length' + relevantContacts.length);
        if (relevantContacts.length != 0) {
            const allFalse = relevantContacts.every(contact => !contact.ConsiderFeedbackRating);

            if (allFalse) {
                this.ShowToast(' ', 'Please select at least one additional rating besides your own.', 'error', 'dismissable');
                return;
            }
        }
        const allValid = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {

            const result = await Genericmodal.open({
                style: {
                    '--slds-c-modal-color-border': 'black'
                },
                btnLable1: 'No',
                btnLable2: 'Yes',
                headerLable: 'Confirm KRA Completion',
                bodyLable: 'You are about to complete the KRA feedback process for your Mentee. Would you like to proceed?',
                size: 'small',
            });

            if (result === 'okay') {
                this.isLoading = true;
                const filteredContacts = relevantContacts.map(contact => ({
                    contactId: contact.contactId,
                    ConsiderFeedbackRating: contact.ConsiderFeedbackRating,
                    NotConsiderFeedbackReason: contact.NotConsiderFeedbackReason
                }));

                completekraMethod({ kraid: this.receivedKRAId, contactData: JSON.stringify(filteredContacts) })
                    .then((result) => {
                        this.ShowToast(' ', 'KRA completed successfully', 'success', 'dismissable');
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
                        this.isLoading = false;;
                    });
            }
        } else {
            this.ShowToast(' ', 'Please complete required field', 'error', 'dismissable');
        }
    }

    HandlesavePMFeedbackReason() {
        const allValid = [...this.template.querySelectorAll('lightning-textarea')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        if (allValid) {
            const relevantContacts = this.contacts.filter(contact => contact.contactId.includes('&'));
            console.log('relevantContacts.length' + relevantContacts.length);
            if (relevantContacts.length != 0) {
                const allFalse = relevantContacts.every(contact => !contact.ConsiderFeedbackRating);

                if (allFalse) {
                    this.ShowToast(' ', 'Please select at least one additional rating besides your own.', 'error', 'dismissable');
                    return;
                }
            }
            this.isLoading = true;
            const filteredContacts = relevantContacts.map(contact => ({
                contactId: contact.contactId,
                ConsiderFeedbackRating: contact.ConsiderFeedbackRating,
                NotConsiderFeedbackReason: contact.NotConsiderFeedbackReason
            }));

            console.log('filteredContacts' + JSON.stringify(filteredContacts));
            SavePMFeedbackReason({ kraid: this.receivedKRAId, contactData: JSON.stringify(filteredContacts) })
                .then((result) => {
                    console.log('result' + result);
                    this.ShowToast(' ', 'Changes Saved successfully!', 'success', 'dismissable');
                    this.isLoading = false;
                })
                .catch((error) => {
                    console.log('error-->', error);
                    this.ShowToast(' ', 'Something went wrong!', 'error', 'dismissable');
                    this.isLoading = false;;
                });
        } else {
            this.ShowToast(' ', 'Please complete required field', 'error', 'dismissable');
        }
    }

    projectManagerId;
    showReasonModel = false;
    showthisSection = false;

    handleCheckbox(event) {
        this.isLoaded = true;
        this.projectManagerId = event.target.dataset.id;
        const isChecked = event.target.checked;
        console.log('projectManagerId' + this.projectManagerId);
        console.log('isChecked' + isChecked);
        // Update the ConsiderFeedbackRating for the corresponding contact

        this.contacts = this.contacts.map(contact => {
            if (contact.contactId === this.projectManagerId) {
                return {
                    ...contact,
                    ConsiderFeedbackRating: isChecked,
                    classs: isChecked ? 'green' : 'red',
                    requiredreason: !isChecked,
                    NotConsiderFeedbackReason: isChecked ? '' : contact.NotConsiderFeedbackReason
                };
            }
            return contact;
        });

        const allConsidered = this.contacts.every(contact => contact.ConsiderFeedbackRating);
        this.showthisSection = !allConsidered;

        this.overallRatings = this.overallRatings.map(overallRating => {
            if (overallRating.contactId === this.projectManagerId) {
                return {
                    ...overallRating,
                    ConsiderFeedbackRating: isChecked,
                    classs: isChecked ? 'green' : 'red'
                };
            }
            return overallRating;
        });
        this.processedData.forEach(areaData => {
            areaData.ratings = areaData.ratings.map(rating => {
                if (rating.contactId === this.projectManagerId) {
                    return {
                        ...rating,
                        ConsiderFeedbackRating: isChecked,
                        classs: isChecked ? 'green' : 'red'
                    };
                }
                return rating;
            });
        });

        //-----------------------------------------------------------
        this.questionstechicalskill = this.questionstechicalskill.map(question => {
            return {
                ...question,
                contactAnswers: question.contactAnswers.map(contactAnswer => {
                    console.log('contactAnswer.contact.id-->' + contactAnswer.contact.id);
                    if (contactAnswer.contact.id === this.projectManagerId) {
                        return {
                            ...contactAnswer,
                            contact: {
                                ...contactAnswer.contact,
                                classs: isChecked ? 'green' : 'red'
                            }
                        };
                    }
                    return contactAnswer;
                })
            };
        });

           this.questionsProfessionalskill= this.questionsProfessionalskill.map(question => {
            return {
                ...question,
                contactAnswers: question.contactAnswers.map(contactAnswer => {
                    console.log('contactAnswer.contact.id-->' + contactAnswer.contact.id);
                    if (contactAnswer.contact.id === this.projectManagerId) {
                        return {
                            ...contactAnswer,
                            contact: {
                                ...contactAnswer.contact,
                                classs: isChecked ? 'green' : 'red'
                            }
                        };
                    }
                    return contactAnswer;
                })
            };
        });
             
             this.questionsStrategicskill= this.questionsStrategicskill.map(question => {
            return {
                ...question,
                contactAnswers: question.contactAnswers.map(contactAnswer => {
                    console.log('contactAnswer.contact.id-->' + contactAnswer.contact.id);
                    if (contactAnswer.contact.id === this.projectManagerId) {
                        return {
                            ...contactAnswer,
                            contact: {
                                ...contactAnswer.contact,
                                classs: isChecked ? 'green' : 'red'
                            }
                        };
                    }
                    return contactAnswer;
                })
            };
        });
             
             this.questionsGoalskill= this.questionsGoalskill.map(question => {
            return {
                ...question,
                contactAnswers: question.contactAnswers.map(contactAnswer => {
                    console.log('contactAnswer.contact.id-->' + contactAnswer.contact.id);
                    if (contactAnswer.contact.id === this.projectManagerId) {
                        return {
                            ...contactAnswer,
                            contact: {
                                ...contactAnswer.contact,
                                classs: isChecked ? 'green' : 'red'
                            }
                        };
                    }
                    return contactAnswer;
                })
            };
        });
             
             this.questionsSpecificArea= this.questionsSpecificArea.map(question => {
            return {
                ...question,
                contactAnswers: question.contactAnswers.map(contactAnswer => {
                    console.log('contactAnswer.contact.id-->' + contactAnswer.contact.id);
                    if (contactAnswer.contact.id === this.projectManagerId) {
                        return {
                            ...contactAnswer,
                            contact: {
                                ...contactAnswer.contact,
                                classs: isChecked ? 'green' : 'red'
                            }
                        };
                    }
                    return contactAnswer;
                })
            };
        });


        this.isLoaded = false;
    }

    handleChangeFeedbackReason(event) {
        const value = event.target.value;
        const contactId = event.target.dataset.id;
        this.contacts = this.contacts.map(contact => {
            if (contact.contactId === contactId) {
                return {
                    ...contact,
                    NotConsiderFeedbackReason: value
                };
            }
            return contact;
        });
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