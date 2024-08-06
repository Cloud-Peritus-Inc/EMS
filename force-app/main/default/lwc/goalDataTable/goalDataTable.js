import { LightningElement, track,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getKRARecordsOfContact from '@salesforce/apex/myPendingFeedbackRequest.getKRARecordsOfContact';
import updatePMConfigureRecord from '@salesforce/apex/myPendingFeedbackRequest.updatePMConfigureRecord';

export default class GoalDataTable extends LightningElement {
    data;
    tab="Pending Feedback Requests";
    hasData = false;
    isShowPopUp = false;
    showKRAEditModal = false;
    rejectionReason = '';
    selectedProjectId = '';//selectedProjectId
    selectedGoalId = '';
    resourceId = '';
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

    acceptRequestHandler(event) {
        const itemIndex = event.currentTarget.dataset.index;
        const rowData = this.data[itemIndex]; 
        this.selectedProjectId = rowData.projectId;
        this.selectedGoalId = rowData.goalId;
        this.selectedResourceId = rowData.resource;
        this.acceptOrRejectRequest('accept');
    }

    rejectRequestHandler(event) {
        const itemIndex = event.currentTarget.dataset.index;
        const rowData = this.data[itemIndex];
        this.isShowPopUp = true;
        this.selectedProjectId = rowData.projectId;
        this.selectedGoalId = rowData.goalId;
        this.selectedResourceId = rowData.resource;
        console.log('selectedProjectId '+this.selectedProjectId); 
    }

    editKRAModalPopUp(event){
        const itemIndex = event.currentTarget.dataset.index;
        const rowData = this.data[itemIndex];
        let node = rowData.goalId;
        this.selectedProjectId = rowData.projectId;
        this.selectedKraQuaterly = node;
        this.selectedResourceId = rowData.resource;
        this.mode = 'Edit';
        this.checkisshowKRAEditModal();
    }

    hideModalBox(){
        this.isShowPopUp = false;
    }

    hideKRAEditModalBox(){
        console.log('close button click ' + this.showKRAEditModal);
        this.showKRAEditModal = false;
    }

    checkisshowKRAEditModal(){
        this.showKRAEditModal = true;
    }

    acceptOrRejectRequest(actionType) {
        updatePMConfigureRecord({
            projectId: this.selectedProjectId,
            goalId: this.selectedGoalId,
            resourceId: this.selectedResourceId,
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
            this.acceptOrRejectRequest('reject');
        }
    }
    
    handleCustomEvent(event) {
    console.log('event:: ', event.detail);
    const { recordId, status, selectedResource } = event.detail;

    if (status === 'Success') {
        this.data = this.data.filter(record => 
            !(record.projectId === recordId && record.resource === selectedResource)
        );
        console.log('datalenght ', this.data.length);
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