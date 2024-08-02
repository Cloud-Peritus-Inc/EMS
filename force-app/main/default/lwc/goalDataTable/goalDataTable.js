import { LightningElement, track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getKRARecordsOfContact from '@salesforce/apex/myPendingFeedbackRequest.getKRARecordsOfContact';
import updatePMConfigureRecord from '@salesforce/apex/myPendingFeedbackRequest.updatePMConfigureRecord';

export default class GoalDataTable extends LightningElement {
    data;
    hasData = false;
    isShowPopUp = false;
    showKRAEditModal = false;
    rejectionReason = '';
    selectedGoalId = '';
    @track comment = '';
    @track showError = false;
    @track selectedResourceId = '';

    connectedCallback() {
        console.log('check1 ');
        this.fetchKRARecords();
    }

    fetchKRARecords() {
        getKRARecordsOfContact()
            .then(result => {
                console.log('result ' + result);
                this.data = result;
                console.log('data '+JSON.stringify(this.data));
                if(result.length > 0){
                    this.hasData = !!this.data;
                }
            })
            .catch(error => {
                this.hasData = false;
            });
    }

    showModalPopUp(event) {
        this.isShowPopUp = true;
        this.selectedGoalId = event.currentTarget.dataset.id;
        console.log('selectedGoalId '+this.selectedGoalId); 
    }

    hideModalBox(){
        this.isShowPopUp = false;
    }

    hideKRAEditModalBox(){
        console.log('close button click ' + this.showKRAEditModal);
        this.showKRAEditModal = false;
    }

    editKRAModalPopUp(event){
       
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        this.mode = 'Edit';
        const selectedGoal = this.data.find(goal => goal.Id === node);
        if (selectedGoal) {
            this.selectedResourceId = selectedGoal.resource;
        }
        
        this.checkisshowKRAEditModal();
    }

    checkisshowKRAEditModal(){
        this.showKRAEditModal = true;
    }

    acceptOrRejectRequest(goalId, actionType) {
        updatePMConfigureRecord({
            goalId: goalId,
            
            actionType: actionType,
            rejectionReason: actionType === 'reject' ? this.rejectionReason : null
        })
        
        .then(result => {
                this.data = result;
                if (actionType === 'accept') {
                this.showToast('Feedback request accepted successfully', 'success');
                } else if (actionType === 'reject') {
                    this.showToast('Feedback request rejected successfully', 'success');
                    this.hasData = this.data.length > 0;                
                }
                this.hideModalBox();
                console.log('CheckInside');
            })
            .catch(error => {
                console.error('Error updating PM Configure records: ', error);
                this.showToast('Failed to update', 'error');
            });
            console.log('goalId2 '+goalId);
    }   

    handleCommentChange(event){
        this.rejectionReason = event.target.value;
        this.comment = event.target.value;
        this.showError = false;
    }

    handleRejectionSubmission() {
        if (!this.comment) {
            this.showError = true;
        } else {
            this.showError = false;
            this.acceptOrRejectRequest(this.selectedGoalId, 'reject');
        }
    }

    acceptRequestHandler(event) {

        const goalId = event.currentTarget.dataset.id;
        console.log('goalId '+goalId);
        this.acceptOrRejectRequest(goalId, 'accept');
    }
    
    
    handleCustomEvent(event) {
        console.log('event:: ', event.detail);
        const { recordId, status } = event.detail;

        if (status === 'Success') {
            this.data = this.data.filter(record => record.Id !== recordId);
            this.hasData = this.data.length > 0;
        }
    }

    showToast(message, variant = 'success') {
        const event = new ShowToastEvent({
            title: variant === 'success' ? '' : 'Notification',
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}