import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancleLeaveRequest from '@salesforce/apex/LeaveManagementApexController.cancleLeaveRequest';
import u_Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getLMHistory from '@salesforce/apex/EMS_LM_MyRequestTabLeaveReq.getLMHistory';
import getLeaveTypesForUser from '@salesforce/apex/LeaveHistoryApexController.getLeaveTypesForUser';
import userLevelOfApproval from '@salesforce/apex/LeaveHistoryApexController.userLevelOfApproval';
//import defaultMyRequestData from '@salesforce/apex/EMS_LM_MyRequestTabLeaveReq.defaultMyRequestData';

import { refreshApex } from '@salesforce/apex';
import LightningModal from 'lightning/modal';

import { createMessageContext, publish, subscribe, unsubscribe } from 'lightning/messageService';
import MY_REFRESH_CHANNEL from '@salesforce/messageChannel/refreshothercomponent__c';
import MY_REFRESH_SEC_CHANNEL from '@salesforce/messageChannel/refreshlmscomponent__c';

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
    overriden;
    overridenLevel;
    isShowCancel = false;
    selectedRecordId;

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
        ],

    };

    connectedCallback() {
        this.a_Record_URL = window.location.origin;
        //console.log('Base Url' + this.a_Record_URL);
        this.LevelOfApproval();
        //console.log('the picklist values are ++'+this.picklistValues)
        const messageContext = createMessageContext();
        this.subscription = subscribe(messageContext, MY_REFRESH_CHANNEL, (message) => {
            this.handleRefreshMessage(message);
        });
    }


    //Based on Level of Approval showing Leave status values
    LevelOfApproval() {
        userLevelOfApproval().then((result) => {
            //console.log('RESULT  : ', JSON.stringify(result));
            this.approvalLevel = result.levelOfApproval;
            this.autoApproval = result.autoApproval;
            this.overriden = result.overRideCheck;
            this.overridenLevel = result.overridelevelOfApproval;
            this.approvalCheckMethod();
        }).catch((err) => {
            console.log('### err : ', err);
        });
    }

    approvalCheckMethod() {
        // EMP CHECK
        console.log('the checking approval level' + this.approvalLevel)
        if (this.approvalLevel === 2) {
            this.picklistValues = this.listStatus.empStatus;
            console.log('the picklist values are ++==2===' + this.picklistValues)
            console.log('the picklist values are ++==2=== json' + JSON.stringify(this.picklistValues))
        }

        // LEAD CHECK
        if (this.overriden === true && this.overridenLevel === 2) {
            this.picklistValues = this.listStatus.empStatus;
        } else if (this.approvalLevel === 1) {
            this.picklistValues = this.listStatus.leadStatus;
        }

        //AUTO APPROVAL
        if (this.approvalLevel === 0) {
            this.picklistValues = this.listStatus.directorStatus;
        }
    }

    // GETTING THE LEAVE TYPES BASED ON THE LOGGED IN USER HAD.
    @wire(getLeaveTypesForUser, { userId: '$uId' })
    wiredlvtype({ error, data }) {
        if (data) {
            console.log('### data : 132 ========leavetypesforuser========= ', data);
            let leaveTypeOptions = data.map((record) => ({
                value: record,
                label: record
            }));
            const workFromHomeOption = { value: 'Work From Home', label: 'Work From Home' };
            leaveTypeOptions.push(workFromHomeOption);
            this.leaveTypeValues = leaveTypeOptions;
            //console.log('### leaveTypeValues : ', this.leaveTypeValues);
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
            //console.log('OUTPUT : ', this.isLoading);
            if (data.length > 0) {
                console.log('### DATA AFTER: ', data);
                this.showdata = true;
                this.nodata = false;

                this.datahistory = JSON.parse(JSON.stringify(data));
                console.log('### datahistory: ', this.datahistory);
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
        if ((this.endDate != null && this.startDate != null) && (this.endDate < this.startDate)) {
            const event = new ShowToastEvent({ title: '', variant: 'error', mode: 'dismissible', message: 'End date should be greater than Start date',});
            this.dispatchEvent(event);
        }
    }

    //MULTI SELECT LEAVE STATUS
    handleValueChange(event) {
        this.sValue = event.detail;
    }

    //MULTI SELECT LEAVE TYPE
    handleTypeValueChange(event) {
        this.value = event.detail;
    }


    handleView(event) {
        const selectedRecordId = event.currentTarget.dataset.id;
        var url = new URL(this.a_Record_URL + '/Grid/s/ems-lm-leave-history/' + selectedRecordId);
        var params = new URLSearchParams();
        params.append("myRequest", "value");
        url.search += "&" + params.toString();

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url.href

            },
        });
    }

    //To edit the leave record
    handleEdit(event) {
        this.selectEditRecordId = event.currentTarget.dataset.id;
        const selectedRecordId = event.currentTarget.dataset.id;
        //console.log('### handleEdit : ', selectedRecordId);
        this.showApplyLeaveEdit = true;
        const messageContext = createMessageContext();
        const payload = {
            refresh: true
        };
        publish(messageContext, MY_REFRESH_SEC_CHANNEL, payload);
    }

    cancelHandler(event) {
        this.showApplyLeaveEdit = false;
    }

    //TO cancel the leave record
    handleCancel(event) {
        this.isShowCancel = true;
        this.selectedRecordId = event.currentTarget.dataset.id;
        console.log('correct');
    }

    handleCancelSave(event) {
        cancleLeaveRequest({ leaveReqCancelId: this.selectedRecordId ,userId: this.uId })
            .then((result) => {
                this.isShowCancel = false;
                refreshApex(this._wiredRefreshData);
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Leave Request was Cancelled Successfully',
                        variant: 'success',
                    })
                );
                const messageContext = createMessageContext();
                const payload = {
                    refresh: true
                };
                publish(messageContext, MY_REFRESH_CHANNEL, payload);
                const payload1 = {
                    refresh: true
                };
                publish(messageContext, MY_REFRESH_SEC_CHANNEL, payload1);

            }).catch((err) => {
                console.log('### err : ', JSON.stringify(err));
            });
    }

    // for refresh using LMS
    subscription = null;

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleRefreshMessage(message) {
        if (message.refresh) {
            refreshApex(this._wiredRefreshData)
        }
    }

    //TO CLOSE THE CANCEL POP-UP
    handleNo() {
        this.isShowCancel = false;
    }

}