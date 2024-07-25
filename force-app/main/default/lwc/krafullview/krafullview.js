import { LightningElement, wire, track, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import calculateAverageRatingForKRA from '@salesforce/apex/CalculateFullQuarterlyKRA.calculateAverageRatingForKRA';
export default class Krafullview extends LightningElement {
    receivedKRAId;
    data;
    error;
    @api tab = 'My Team';
    @track isLoading = true;
    steps = [
        { label: 'REVIEWER DETAILS', value: 'reviewerDetails' },
        { label: 'TECHNICAL ACUMEN', value: 'technicalAcumen' },
        { label: 'PROFESSIONAL SKILLS', value: 'professionalSkills' },
        { label: 'STRATEGIC IMPACT', value: 'strategicImpact' },
        { label: 'GOALS AND RESULTS', value: 'goalsResults' },
        { label: 'OVERALL RATING', value: 'overAllRating' }
    ];
    selectedStep = 'reviewerDetails';
    showReviewerDetails = true;
    showTechnicalAcumen = false;
    showProfessionalSkills = false;
    showStrategicImpact = false;
    showGoalsResults = false;
    showOverAllRating = false;

    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (pageRef) {
            this.receivedKRAId = pageRef.state.c__kraid;
            console.log('receivedKRAId ' + this.receivedKRAId);
        }
    }

    questionstechicalskill = [];
    questionsProfessionalskill = [];
    questionsStrategicskill = [];
    questionsGoalskill = [];
    questionsSpecificArea = [];
    allAnswerIdList
    kraRecord;

    @track areaWrapperList = [];
    @track contacts = [];
    @track processedData = [];

    @wire(calculateAverageRatingForKRA, { kraid: '$receivedKRAId', tab: '$tab' })
    wiredData({ error, data }) {
        if (data) {
            console.log('receivedKRAId-->' + this.receivedKRAId);
            console.log('tab-->' + this.tab);
            console.log('data-->' + JSON.stringify(data));
            this.areaWrapperList = data;
            this.processData();
        } else if (error) {
            this.error = error;
            console.log('nw this.error -->' + JSON.stringify(this.error));
            this.isLoading = false;
        }
    }
    totalAverageRating;
    totalAvgSkillRating;
    processData() {
        let contactMap = new Map();
        let totalAvgRatingSum = 0;
        let totalAvgSkillRatingSum = 0;
        let totalAvgRatingCount = 0;

        this.processedData = this.areaWrapperList.map(areaWrapper => {
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
                    AvgRatingSkillForResource: AvgRatingSkillForResource
                });

                totalRating += parseFloat(answer.averageRating);
                totalSkillRating += parseFloat(answer.AvgRatingSkillForResource);
                totalCount++;

                if (!contactMap.has(contactId)) {
                    contactMap.set(contactId, { contactId: answer.contactId, contactname: answer.contactname });
                }
            }

            let overallAverage = (totalCount > 0) ? (totalRating / totalCount).toFixed(2) : 'N/A';
            let overallSkillAverage = (totalCount > 0) ? (totalSkillRating / totalCount).toFixed(2) : 'N/A';

            // Calculate total average for all areas
            if (overallAverage !== 'N/A') {
                totalAvgRatingSum += parseFloat(overallAverage);
                totalAvgSkillRatingSum += parseFloat(overallSkillAverage);
                totalAvgRatingCount++;
            }

            return {
                area: areaWrapper.area,
                ratings: ratingsArray,
                overallAverage: `${overallAverage} (${overallSkillAverage})`
            };
        });

        this.contacts = Array.from(contactMap.values());

        // Calculate total overall average
        this.totalAverageRating = (totalAvgRatingCount > 0) ? (totalAvgRatingSum / totalAvgRatingCount).toFixed(2) : 'N/A';
        this.totalAvgSkillRating = (totalAvgRatingCount > 0) ? (totalAvgSkillRatingSum / totalAvgRatingCount).toFixed(2) : 'N/A';
    }
        /*@wire(getKRAFullDetails, { kraid: '$receivedKRAId', tab: '$tab' })
            wiredData({ error, data }) {
                if (data) {
                   // this.isLoading = true;
        
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
                                     // Aggregate ratings for each area
                                        switch (q.area) {
                                            case 'TECHNICAL SKILLS':
                                                this.averageRatings.technicalSkills += answer.rating;
                                                ratingCounts.technicalSkills += 1;
                                                break;
                                            case 'PROFESSIONAL SKILLS':
                                                this.averageRatings.professionalSkills += answer.rating;
                                                ratingCounts.professionalSkills += 1;
                                                break;
                                            case 'STRATEGIC IMPACT':
                                                this.averageRatings.strategicImpact += answer.rating;
                                                ratingCounts.strategicImpact += 1;
                                                break;
                                            case 'GOALS AND RESULTS':
                                                this.averageRatings.goalsAndResults += answer.rating;
                                                ratingCounts.goalsAndResults += 1;
                                                break;
                                            default:
                                                break;
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
                  //  this.calculateAverageRatingForKRAHandler();
                  // Calculate average ratings
                    if (ratingCounts.technicalSkills > 0) {
                        this.averageRatings.technicalSkills /= ratingCounts.technicalSkills;
                    }
                    if (ratingCounts.professionalSkills > 0) {
                        this.averageRatings.professionalSkills /= ratingCounts.professionalSkills;
                    }
                    if (ratingCounts.strategicImpact > 0) {
                        this.averageRatings.strategicImpact /= ratingCounts.strategicImpact;
                    }
                    if (ratingCounts.goalsAndResults > 0) {
                        this.averageRatings.goalsAndResults /= ratingCounts.goalsAndResults;
                    }
                    console.log('this.averageRatings'+this.averageRatings);
                    this.isLoading = false;
                } else if (error) {
                    this.error = error;
                    console.log('nw this.error -->' + JSON.stringify(this.error));
                    this.isLoading = false;
                }
            }*/

        stepSelectionHanler(event) {

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
                this[stepToVisibility[key]] = key === step;
            });
        }

        handleNextAction() {
            this.isLoading = true;
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
                    this.isLoading = false;
                    break;
                case 'technicalAcumen':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = true;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = false;
                    this.showOverAllRating = false;
                    this.selectedStep = 'professionalSkills';
                    this.isLoading = false;
                    break;
                case 'professionalSkills':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = true;
                    this.showGoalsResults = false;
                    this.showOverAllRating = false;
                    this.selectedStep = 'strategicImpact';
                    this.isLoading = false;
                    break;
                case 'strategicImpact':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = true;
                    this.showOverAllRating = false;
                    this.selectedStep = 'goalsResults';
                    this.isLoading = false;
                    break;
                case 'goalsResults':
                    this.showReviewerDetails = false;
                    this.showTechnicalAcumen = false;
                    this.showProfessionalSkills = false;
                    this.showStrategicImpact = false;
                    this.showGoalsResults = false;
                    this.showOverAllRating = true;
                    this.selectedStep = 'overAllRating';
                    this.isLoading = false;
                    break;
            }
        }

    }