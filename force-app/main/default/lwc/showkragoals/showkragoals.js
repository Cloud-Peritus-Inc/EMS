import { LightningElement, api, track, wire } from 'lwc';
import getAlltheGoals from '@salesforce/apex/myGoalsController.getAlltheGoals';
import getTheGoals from '@salesforce/apex/myGoalsController.getTheGoals';
import saveTheGoal from '@salesforce/apex/myGoalsController.saveTheGoal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Goal__c.Status__c';
import ID_FIELD from '@salesforce/schema/Goal__c.Id';
import { refreshApex } from '@salesforce/apex';
export default class Showkragoals extends LightningElement {
    @api receivedkraid;
    @track goaltable;
    @track error;

    @track showinprogress = false;
    showGoalRecords;
    connectedCallback() {
        console.log('===receivedkraid====' + this.receivedkraid);
       // this.getallGoalsfromserver();
    }
    showEditGoal = false;
    showViewGoal = false;
    selectedGoaldId;

@track goalRecord ;
     @wire(getAlltheGoals,{ kraId: '$receivedkraid'}) 
    goalsData(result) {

            console.log('RecordId is============');
            this.goalRecord = result;
            console.log('Data===='+JSON.stringify(this.goalRecord));
        if (result.data) {
            this.goaltable = [];
            this.goaltable = result.data; 
            if(this.goaltable.length>0){
            this.showGoalRecords=true;
            }else{
                this.showGoalRecords=false;
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
            // Create the recordInput object Status__c Goal__c
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.selectedGoaldId;
            fields[STATUS_FIELD.fieldApiName] = 'In Progress';

            const recordInput = { fields };
            console.log(recordInput);

            updateRecord(recordInput)
                .then(() => {
                    this.showToast('Success!!', 'Goal updated Inprogress successfully!!', 'success', 'dismissable');
                    // Display fresh data in the form
                    this.  hideGoalEditModalBox();
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