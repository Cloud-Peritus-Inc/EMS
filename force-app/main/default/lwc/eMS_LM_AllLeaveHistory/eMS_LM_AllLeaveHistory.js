import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import recallApproval from '@salesforce/apex/EMS_LM_ApprovalProcessUpdate.recallApproval';//need to change apex class method after approval process
import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import u_Id from '@salesforce/user/Id';
import LightningConfirm from "lightning/confirm";
import { NavigationMixin } from 'lightning/navigation';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import getLMHistory from '@salesforce/apex/LeaveHistoryApexController.getLMHistory';
import getLeaveTypesForUser from '@salesforce/apex/LeaveHistoryApexController.getLeaveTypesForUser';
import userLevelOfApproval from '@salesforce/apex/LeaveHistoryApexController.userLevelOfApproval';
import defaultMyRequestData from '@salesforce/apex/LeaveHistoryApexController.defaultMyRequestData';

const columns = [
    { label: 'Leave Type', fieldName: 'EMS_LM_Leave_Type_Name__c' },
    { label: 'Leave Start Date', fieldName: 'EMS_LM_Leave_Start_Date__c', type: 'date' },
    { label: 'Leave End Date', fieldName: 'EMS_LM_Leave_End_Date__c', type: 'date' },
    { label: 'Leave Duration', fieldName: 'EMS_LM_Leave_Duration__c', type: 'number' },
    { label: 'Reason', fieldName: 'EMS_LM_Reason__c' },
    { label: 'Approver', fieldName: 'EMS_LM_Current_Approver__c' },
    { label: 'Leave Status', fieldName: 'EMS_LM_Status__c' },
    { label: 'Approved On', fieldName: 'EMS_LM_Approved_On__c', type: 'date' }];

export default class EMS_LM_AllLeaveHistory extends NavigationMixin(LightningElement) {
    @track columns = columns;
    picklistValues; //Leave status
    leaveTypeValues; // Leave Type
    error;
    fixedWidth = "width:8rem;";
    requeststatus;
    outputStatus;
    outputId;
    @track reqRecordId;
    showcancelbutton = false;
    isShowViewRequest = false;
    uId = u_Id;
    showdata = false;
    nodata = false;
    endDate = '';//To filter Leave History end date = '2022-12-20 00:00:00'
    startDate = '';//To filter Leave History start date  = '2022-01-20 00:00:00'
    @track datahistory = [];//to pass data to Leave history table
    @track lOptions = [];
    value = '';
    sValue = '';
    showApplyLeaveEdit = false;
    @track picklistValues = [];
    // @track loa = 2;
    approvalLevel;
    autoApproval;
    selectEditRecordId;


    @track listStatus = {

        empStatus: [
            { label: 'Approved', value: 'Approved' }, { label: 'Pending', value: 'Pending' },
            { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' },
            { label: 'Approver 1 Pending', value: 'Approver 1 Pending' },
            { label: 'Approver 2 Pending', value: 'Approver 2 Pending' }
        ],

        leadStatus: [
            { label: 'Approved', value: 'Approved' }, { label: 'Pending', value: 'Pending' },
            { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' }
        ],

        directorStatus: [
            { label: 'Auto Approved', value: 'Auto Approved' }, { label: 'Pending', value: 'Pending' },
            { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' }
        ]
    };

    connectedCallback() {
        console.log('OUTPUT : inside connect callback');
        this.LevelOfApproval();
        console.log('OUTPUT : called');
    }

    //Based on Level of Approval showing Leave status values
    LevelOfApproval() {
        userLevelOfApproval().then((result) => {
            console.log('RESULT  : ', JSON.stringify(result));
            this.approvalLevel = result.levelOfApproval;
            console.log('### approvalLevel : ', this.approvalLevel);
            this.autoApproval = result.autoApproval;
            console.log('### autoApproval : ', this.autoApproval);
            this.approvalCheckMethod();
        }).catch((err) => {
            console.log('### err : ', err);
        });
    }

    approvalCheckMethod() {
        switch (this.approvalLevel) {
            case 2:
                console.log('OUTPUT : ');
                this.picklistValues = this.listStatus.empStatus;
                console.log('### selectedList : ', this.selectedList);
                break;
            case 1:
                this.picklistValues = this.listStatus.leadStatus;
                break;
            case 3:
                this.picklistValues = this.listStatus.directorStatus;
                break;
            default:
                this.picklistValues = [];
                break;
        }
    }

    @wire(getLeaveTypesForUser, { userId: '$uId' })
    wiredlvtype({ error, data }) {
        if (data) {
            console.log('### data : ', data);
            let opt = data.map((record) => ({
                value: record,
                label: record
            }));
            this.leaveTypeValues = opt;
            console.log('### leaveTypeValues : ', this.leaveTypeValues);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.lOptions = undefined;
        }
    }

    //TO SHOW DEFAULT DATA
    @wire(defaultMyRequestData)
    defaultMyRequestDataWiredData({ error, data }) {
        if (data) {
            console.log('### defaultMyRequestData', data);
            this.showdata = true;
            this.nodata = false;
            //this.datahistory = data;
            this.datahistory = JSON.parse(JSON.stringify(data));
            console.log('### datahistory', this.datahistory);
            this.datahistory.forEach(req => {
                req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 pending' && req.EMS_LM_Status__c !== 'Pending';
            });
            console.log('### defaultMyRequestData datahistory: ', this.datahistory);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    //TO SHOW FILTER DATA
    @wire(getLMHistory, { stdate: '$startDate', eddate: '$endDate', statusValues: '$sValue', typeValues: '$value' })
    wiredLeavHistory({ error, data }) {
        if (data) {
            console.log('### DATA BEFORE: ', data);
            if (data.length > 0) {
                console.log('### DATA AFTER: ', data);
                this.showdata = true;
                this.nodata = false;
                this.datahistory = JSON.parse(JSON.stringify(data));
                console.log('### datahistory', this.datahistory);
                this.datahistory.forEach(req => {
                    req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 pending' && req.EMS_LM_Status__c !== 'Pending';
                });
                this.error = undefined;
            }
           /* else {
                this.nodata = true;
                this.showdata = false;
               // this.datahistory = data;
                console.log('## Else : ', data);
                this.error = undefined;
            }*/
        } else if (error) {
            this.error = error;
            this.datahistory = undefined;
        }
    }

    startdatechange(event) {
        this.startDate = event.detail.value;
        console.log(this.startDate);
        if (this.startDate != null) {
            this.startDate = event.detail.value + ' 00:00:00';
        }
        if (this.startDate > this.endDate) {
            if (this.endDate != null) {
                this.endDate = '';
            }
        }
    }
    enddatechange(event) {
        this.endDate = event.detail.value;
        if (this.endDate != null) {
            this.endDate = event.detail.value + ' 00:00:00';
        }
    }

    //MULTI SELECT LEAVE STATUS
    handleValueChange(event) {
        console.log(JSON.stringify(event.detail));
        this.sValue = event.detail;
        console.log('## this.sValue', this.sValue);
    }

    //MULTI SELECT LEAVE TYPE
    handleTypeValueChange(event) {
        console.log(JSON.stringify(event.detail));
        this.value = event.detail;
        console.log('## this.value', this.value);
    }

    //To view the leave record
    handleView(event) {
        const selectedRecordId = event.currentTarget.dataset.id;
        console.log('### handleView : ', selectedRecordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'EMS_LM_Leave_History__c',
                actionName: 'view',
            },
        });
    }

    //To edit the leave record
    handleEdit(event) {
        this.selectEditRecordId = event.currentTarget.dataset.id;
        const selectedRecordId = event.currentTarget.dataset.id;
        console.log('### handleEdit : ', selectedRecordId);
        this.showApplyLeaveEdit = true;
        /*
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'EMS_LM_Leave_History__c',
                actionName: 'view',
            },
        });*/
    }

    cancelHandler(event){
        this.showApplyLeaveEdit = false;
    }

    //TO cancel the leave record
    handleCancel(event) {
        const selectedRecordId = event.currentTarget.dataset.id;
        console.log('### handleCancel : ', selectedRecordId);
        cancleLeaveRequest({ leaveReqCancelId: selectedRecordId })
            .then((result) => {
                console.log('### result : ', result);
                const evt = new ShowToastEvent({
                    title: 'Toast Success',
                    message: 'Leave Request was Cancelled Successfully',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                window.location.reload();
            }).catch((err) => {
                console.log('### err : ', JSON.stringify(err));
            });
    }

    /*HandelViewRequestModel(event) {
      this.isShowViewRequest = true;
      this.requestType = event.target.dataset.value;
      this.reqRecordId = event.target.dataset.recordId;
    }*/
    hideModalBox() {
        this.isShowViewRequest = false;
    }

    async handleConfirmClick(event) {
        this.requeststatus = event.target.dataset.value;
        this.reqRecordId = event.target.dataset.recordId;
        const result = await LightningConfirm.open({
            message: "Are you sure you want to Cancel this request?",
            variant: "default", // headerless
            theme: 'error', // more would be success, info, warning
            label: "Cancel the request"
        });
        if (result) {
            recallApproval({ recId: this.reqRecordId })
                .then(() => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success!!',
                        message: 'Leave Cancelled Successfully !!.',
                        variant: 'success'
                    }));
                    window.location.reload();
                })
                .catch(error => {
                    window.console.log('Error ====> ' + error);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error!!',
                        message: error.message,
                        variant: 'error'
                    }));
                    window.location.reload();
                });
        }
        else {
        }
    }




}