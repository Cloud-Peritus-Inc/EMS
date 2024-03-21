import { LightningElement, api, track, wire } from 'lwc';
import getAlltheGoals from '@salesforce/apex/myGoalsController.getAlltheGoals';
import getTheGoals from '@salesforce/apex/myGoalsController.getTheGoals';
import saveTheGoal from '@salesforce/apex/myGoalsController.saveTheGoal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { updateRecord } from 'lightning/uiRecordApi';
import updateRecord from '@salesforce/apex/myGoalsController.updateRecord';

import STATUS_FIELD from '@salesforce/schema/Goal__c.Status__c';
import ID_FIELD from '@salesforce/schema/Goal__c.Id';
import { refreshApex } from '@salesforce/apex';
export default class Showkragoals extends LightningElement {
    @api receivedkraid;
    @track goaltable;
    @track error;
    @api tab;
    @api viewonlymode = false;

    @track showinprogress = false;
    showGoalRecords;
    connectedCallback() {
        console.log('===receivedkraid====' + this.receivedkraid);
        console.log('===receivedkraid====' + this.receivedkraid);
       return refreshApex(this.goalRecord);
    }
    showEditGoal = false;
    showViewGoal = false;
    selectedGoaldId;

    renderedCallback() {
        console.log('call renderedCallback=======');
        return refreshApex(this.goalRecord);
    }

@track goalRecord ;

     @wire(getAlltheGoals,{ kraId: '$receivedkraid'}) 
    goalsData(result) {
            console.log('RecordId is============');
            this.goalRecord = result;
            console.log('Data===='+JSON.stringify(this.goalRecord));
        if (result.data) {
            this.goaltable = [];
            this.goaltable = result.data;

            console.log('Tab is ' + this.tab);   
            if (this.goaltable.length > 0) {
                this.showGoalRecords = true;
                //smaske :[PM_133]: Disabling Edit button for HR PROFILE USER
                const HR = 'Employee - HR(Community)';
                this.goaltable = this.goaltable.map(goalRecord => {
                    //console.log('profileName is ' + goalRecord.profileName);
                    //console.log('showedit is ' + goalRecord.showedit);
                    const modifiedGoalRecord = { ...goalRecord };
                    //modifiedGoalRecord.showedit = goalRecord.profileName === HR && this.tab === 'My Team' ? false : goalRecord.showedit;
                    if (goalRecord.profileName === HR && this.tab === 'My Team') {
                        modifiedGoalRecord.showedit = false;
                    }

                    if (this.viewonlymode == true) {
                        modifiedGoalRecord.showedit = false;
                    }

                    return modifiedGoalRecord;
                });
                //console.log('MODIFIED' + JSON.stringify( this.goaltable) );
                 
            } else {
                this.showGoalRecords = false;
            }     
            this.error = undefined;

        } else if (result.error) {
             console.log('ddddddddddd'+result.error);
            this.goaltable = undefined;
            this.error = result.error;

        }

    }

   /* getallGoalsfromserver() {
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
    } */

    /* handleNavClick(event) {
        let node = event.currentTarget.dataset.id;
        console.log('==node====' + node);

    } */
    
    handleeditClick(event) {
        let node = event.currentTarget.dataset.id;
        let goalstatus =  event.currentTarget.dataset.status;
        console.log('goooo+++++++++++++'+goalstatus);
        if(goalstatus =='Active'){
        this.showinprogress = true;
        }
        console.log('showinprogress'+this.showinprogress);
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
         this.showinprogress = false;
    }

    hideGoalEditModalBox() {
        this.showEditGoal = false;
         this.showinprogress = false;

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
    goalCompdate;
    mycomments;
    myVal = '';

    saveTheGoal() {

        if(this.mycomments){
            saveTheGoal({
                goalId: this.selectedGoaldId,
                finalComments: this.mycomments
            }).then(res => {
                const evt = new ShowToastEvent({
                    //title: 'success',
                    message: 'Successfully marked the goal as completed.',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.mycomments = '';
                
                // @Mukesh 
                //i commented because this funtion is commented above
                //this.getallGoalsfromserver();
                this.hideGoalEditModalBox();
                     return refreshApex(this.goalRecord);
            }).catch(err => {
                console.log('err' ,err);
                const evt = new ShowToastEvent({
                    //title: 'Toast Error',
                    message: 'Some thing went wrong...' + JSON.stringify(err),
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
    
            });
        }else{
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
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
            this.goalCompdate = res.Goal_Completed_Date__c;
        }).catch(err => {
            console.log('===err=======' + JSON.stringify(err));
            const evt = new ShowToastEvent({
                //title: 'Toast Error',
                message: 'Some thing went wrong...' + JSON.stringify(err),
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        });
    }

    updatetheGoaltoInprogress(){

            this.isLoading = true;

            updateRecord({goalId: this.selectedGoaldId})
                .then(() => {
                    this.showToast('Success!!', 'Goal updated Inprogress successfully!!', 'success', 'dismissable');
                    // Display fresh data in the form
                    this.hideGoalEditModalBox();
                    this.isLoading = false;
                    return refreshApex(this.goalRecord);
                     
                     // this.goaltable = [];
                      //console.log('kraid======'+this.receivedkraid);
                     //this.getallGoalsfromserver();
                    
                })
                .catch(error => {
                    this.isLoading = false;
                    this.showToast('Error!!', error.body.message, 'error', 'dismissable');
                });        
    

    }

     showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            //title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

}