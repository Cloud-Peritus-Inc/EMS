import { LightningElement, api, track, wire } from 'lwc';
import getAlltheGoals from '@salesforce/apex/myGoalsController.getAlltheGoals';
import getTheGoals from '@salesforce/apex/myGoalsController.getTheGoals';
import saveTheGoal from '@salesforce/apex/myGoalsController.saveTheGoal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Showkragoals extends LightningElement {
    @api receivedkraid;
    @track goaltable;

    connectedCallback() {
        console.log('===receivedkraid====' + this.receivedkraid);
        this.getallGoalsfromserver();
    }
    showEditGoal = false;
    showViewGoal = false;
    selectedGoaldId;
    getallGoalsfromserver() {
        getAlltheGoals({
            kraId: this.receivedkraid
        })
            .then(result => {
                console.log('====result=======' + JSON.stringify(result));
                if (result && result.length > 0) {
                    this.goaltable = [];
                    this.goaltable = result;
                }

            })
            .catch(error => {
                console.log('====Error=======' + JSON.stringify(error));
            });
    }

    handleNavClick(event) {
        let node = event.currentTarget.dataset.id;
        console.log('==node====' + node);

    }

    handleeditClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedGoaldId = node;
        console.log('==node====' + node);
        this.showGoalEditModalBox();
    }
    handleViewClick(event) {
        let node = event.currentTarget.dataset.id;
        this.selectedGoaldId = node;
        this.showGoalViewModalBox();
    }

    hideGoalViewModalBox() {
        this.showViewGoal = false;

    }

    showGoalViewModalBox() {
        this.getTheGoalDetails();
        this.showViewGoal = true;
    }

    hideGoalEditModalBox() {
        this.showEditGoal = false;

    }

    showGoalEditModalBox() {
        this.getTheGoalDetails();
        this.showEditGoal = true;
    }

    handledescChange(event) {
        this.mycomments = event.target.value;
    }
    goalstartdate;
    goalenddate;
    goalname;
    mycomments;
    myVal = '';

    saveTheGoal() {

        if(this.mycomments){
            saveTheGoal({
                goalId: this.selectedGoaldId,
                finalComments: this.mycomments
            }).then(res => {
                const evt = new ShowToastEvent({
                    title: 'success',
                    message: 'Successfully marked the goal as completed.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.mycomments = '';
                this.getallGoalsfromserver();
                this.hideGoalEditModalBox();
            }).catch(err => {
                const evt = new ShowToastEvent({
                    title: 'Toast Error',
                    message: 'Some thing went wrong...' + JSON.stringify(err),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
    
            });
        }else{
            const evt = new ShowToastEvent({
                title: 'Toast Error',
                message: 'Final Comments field must not be left empty',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }  

    }

    getTheGoalDetails() {
        getTheGoals({
            goalId: this.selectedGoaldId
        }).then(res => {
            console.log('===res=======' + JSON.stringify(res));
            this.myVal = res.Description__c;
            this.goalname = res.Goal_Name__c;
            this.mycomments = res.Feedback_and_Comments__c;
            this.goalstartdate = res.Start_Date__c;
            this.goalenddate = res.End_Date__c;
        }).catch(err => {
            console.log('===err=======' + JSON.stringify(err));
            const evt = new ShowToastEvent({
                title: 'Toast Error',
                message: 'Some thing went wrong...' + JSON.stringify(err),
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        });
    }

}