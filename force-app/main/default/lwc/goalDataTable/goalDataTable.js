import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getKRARecordsOfContact from '@salesforce/apex/myPendingFeedbackRequest.getKRARecordsOfContact';
import updatePMConfigureRecord from '@salesforce/apex/myPendingFeedbackRequest.updatePMConfigureRecord';

export default class GoalDataTable extends LightningElement {
    @track data;
    hasData = false;
    isShowPopUp = false;
    showKRAEditModal = false;
    rejectionReason = '';
    selectedGoalId = '';
    wiredGoalsResult;
    @track comment = '';
    @track showError = false;
    @track selectedResourceId = '';

    connectedCallback() {
        this.fetchKRARecords();
    }

    fetchKRARecords() {
        getKRARecordsOfContact()
            .then(result => {
                this.data = result;
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
    }

    hideModalBox(){
        this.isShowPopUp = false;
    }

    hideKRAEditModalBox(){
        this.showKRAEditModal = false;
        this.fetchKRARecords();
    }

    editKRAModalPopUp(event){
        console.log('checkresource '+event.target.id);
        let node = event.currentTarget.dataset.id;
        this.selectedKraQuaterly = node;
        this.mode = 'Edit';
        const selectedGoal = this.data.find(goal => goal.Id === node);
        if (selectedGoal) {
            this.selectedResourceId = selectedGoal.resource;
        }
        console.log('resource '+ this.selectedResourceId);
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
            .then(() => {
                if (actionType === 'accept') {
                    this.showToast('Success', 'Accepted Successfully', 'success');
                } else if (actionType === 'reject') {
                    this.showToast('Success', 'Rejected Successfully', 'success');
                }
                
                this.fetchKRARecords();
                this.hideModalBox();
            })
            .catch(error => {
                console.error('Error updating PM Configure records: ', error);
                this.showToast('Error', 'Failed to update', 'error');
            });
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
        this.acceptOrRejectRequest(goalId, 'accept');
        
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}