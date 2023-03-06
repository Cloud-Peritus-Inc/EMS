import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import u_Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getLMHistory from '@salesforce/apex/EMS_LM_MyRequestTabLeaveReq.getLMHistory';
import getLeaveTypesForUser from '@salesforce/apex/LeaveHistoryApexController.getLeaveTypesForUser';
import userLevelOfApproval from '@salesforce/apex/LeaveHistoryApexController.userLevelOfApproval';
import defaultMyRequestData from '@salesforce/apex/EMS_LM_MyRequestTabLeaveReq.defaultMyRequestData';
import { refreshApex } from '@salesforce/apex';

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
    @track isLoading = false;
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
    approvalLevel;
    autoApproval;
    selectEditRecordId;
    isCheck = false;
    testdata
    _wiredRefreshData;

    //CREATED THIS TO SHOW THE LEAVE STATUSES BASED ON THE LEVEL OF APPROVAL A LOGGED IN USER HAD.
    @track listStatus = {

        empStatus: [
            { label: 'Approver 1 Pending', value: 'Approver 1 Pending' }, { label: 'Approver 2 Pending', value: 'Approver 2 Pending' },
            { label: 'Pending', value: 'Pending' },
            { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' },
            { label: 'Approved', value: 'Approved' }
        ],

        leadStatus: [
            { label: 'Pending', value: 'Pending' }, { label: 'Approved', value: 'Approved' },
            { label: 'Rejected', value: 'Rejected' }, { label: 'Cancelled', value: 'Cancelled' }
        ],

        directorStatus: [
            { label: 'Auto Approved', value: 'Auto Approved' },
            { label: 'Cancelled', value: 'Cancelled' }
        ]
    };

    connectedCallback() {
        this.LevelOfApproval();
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
                /* this.sValue = this.picklistValues[0].value;
                 console.log('this.sValue : ', this.sValue);*/
                break;
            case 1:
                this.picklistValues = this.listStatus.leadStatus;
                /*this.sValue = this.picklistValues[0].value;
                console.log('this.sValue : ', this.sValue);*/
                break;
            case 0:
                this.picklistValues = this.listStatus.directorStatus;
                /* this.sValue = this.picklistValues[0].value;
                 console.log('this.sValue : ', this.sValue);*/
                break;
            default:
                this.picklistValues = [];
                break;
        }
    }

    // GETTING THE LEAVE TYPES BASED ON THE LOGGED IN USER HAD.
    @wire(getLeaveTypesForUser, { userId: '$uId' })
    wiredlvtype({ error, data }) {
        if (data) {
            console.log('### data : ', data);
            let leaveTypeOptions = data.map((record) => ({
                value: record,
                label: record
            }));
            const workFromHomeOption = { value: 'Work From Home', label: 'Work From Home' };
            leaveTypeOptions.push(workFromHomeOption);
            this.leaveTypeValues = leaveTypeOptions;
            console.log('### leaveTypeValues : ', this.leaveTypeValues);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.lOptions = undefined;
        }
    }

    //TO SHOW DEFAULT DATA
  /*  @wire(defaultMyRequestData)
    defaultMyRequestDataWiredData(wireResult) {
        const { data, error } = wireResult;
        this._wiredRefreshData = wireResult;
        if (data) {
            if (data.length > 0) {
              
                console.log('### defaultMyRequestData', data);
                this.showdata = true;
                this.nodata = false;
                //this.datahistory = data;
                this.datahistory = JSON.parse(JSON.stringify(data));
                console.log('### datahistory', this.datahistory);
                this.datahistory.forEach(req => {
                    req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 Pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Auto_Approve__c != true && req.EMS_LM_Status__c !== 'Auto Approved';
                });
                console.log('### defaultMyRequestData datahistory: ', this.datahistory);
            } else {
                this.nodata = true
            }
        } else if (error) {
            console.error('Error:', error);
        }
    }*/

    //TO SHOW FILTER DATA
    @wire(getLMHistory, { startDateStr: '$startDate', endDateStr: '$endDate', statusValues: '$sValue', typeValues: '$value' })
    wiredLeavHistory(wireResult) {
        const { data, error } = wireResult; // TO REFRESH THE DATA USED THIS BY STORING DATA AND ERROR IN A VARIABLE
        this._wiredRefreshData = wireResult;
        if (data) {
            this.isLoading = false;
            console.log('OUTPUT : ', this.isLoading);
            if (data.length > 0) {
                console.log('### DATA AFTER: ', data);
                this.showdata = true;
                this.nodata = false;
                this.datahistory = JSON.parse(JSON.stringify(data));
                console.log('### datahistory', this.datahistory);
                this.datahistory.forEach(req => {
                    req.disableButton = req.EMS_LM_Status__c !== 'Approver 1 Pending' && req.EMS_LM_Status__c !== 'Pending' && req.EMS_LM_Auto_Approve__c != true && req.EMS_LM_Status__c !== 'Auto Approved';
                });
                this.error = undefined;
            }
            else {
                this.nodata = true;
                this.showdata = false;
                this.error = undefined;
            }
        } else if (error) {
            this.error = error;
            this.nodata = true;
            this.datahistory = undefined;
            this.isLoading = false;
        } else {
            this.isLoading = true;
            this.nodata = true;
            this.showdata = false;
            this.error = undefined;
        }
    }

    startdatechange(event) {
        this.startDate = event.detail.value;
        console.log(this.startDate);
        if (this.startDate != null) {
            this.startDate = event.detail.value;
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
            this.endDate = event.detail.value;
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
    }

    cancelHandler(event) {
        this.showApplyLeaveEdit = false;
    }

    //TO cancel the leave record
    handleCancel(event) {
        //this.isLoading = true;
        const selectedRecordId = event.currentTarget.dataset.id;
        console.log('### handleCancel : ', selectedRecordId);
        cancleLeaveRequest({ leaveReqCancelId: selectedRecordId })
            .then((result) => {
                console.log('### result : ', result);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Toast Success',
                        message: 'Leave Request was Cancelled Successfully',
                        variant: 'success',
                    })
                );
                return refreshApex(this._wiredRefreshData)
            }).catch((err) => {
                console.log('### err : ', JSON.stringify(err));
            });
    }

}