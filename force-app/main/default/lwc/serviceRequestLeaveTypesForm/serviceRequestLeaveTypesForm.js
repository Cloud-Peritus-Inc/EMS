import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType, getObjectInfos } from 'lightning/uiObjectInfoApi';
import LEAVEHISTORY_OBJECT from '@salesforce/schema/EMS_LM_Leave_History__c';
import CASE_OBJECT from '@salesforce/schema/Case';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import u_Id from '@salesforce/user/Id';
import getbilling from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.getbilling';
import getLeaveDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getLeaveDuration';
import getwfhDuration from '@salesforce/apex/EMS_LM_Leave_Duration_Handler.getwfhDuration';
import uploadFile from '@salesforce/apex/EMS_LM_ContactLeaveUpdate.uploadFile';
import { createRecord } from 'lightning/uiRecordApi';

export default class ServiceRequestLeaveTypesForm extends NavigationMixin(LightningElement) {
    uId = u_Id;
    Location;
    duration;
    error;
    @track startDate;
    @track endDate;
    todaydate;
    fileData;
    rId;
    objectApiNames = [CASE_OBJECT, LEAVEHISTORY_OBJECT];
    leaveTypeValues = [];
    priorityValues;
    selectedLeaveTypes;
    selectedPriority;
    recordTypeId;
    caseObjectInfo;
    inputDisabled = true;
    leaveHistoryObjectInfo;
    @api recordId;
    openModal = false;
    @api requestType;
    @api leaveTypeValues;
    @api contactRecord;
    usercontactId;
    showFileUpload = false;
    dayValues;
    selectedDay;
    errorMessage = '';
    reason;
    dayCheck1;

    // MATERINITY-CASE
    @api objectName = CASE_OBJECT;
    maternityFieldList = ['Leave_Start_Date__c', 'Leave_End_Date__c', 'Leave_Duration__c']; // files to be added

    //REASON-CASE
    reasonField = ['Reason__c'];

    //COMPOFF-CASE
    compoffFieldList = ['Leave_Start_Date__c', 'Leave_End_Date__c', 'Day__c', 'Leave_Duration__c', 'Reason__c'];

    connectedCallback() {
        this.usercontactId = this.contactRecord.Id;
        this.useraccountId = this.contactRecord.AccountId;

        let today = new Date();
        let dd = today.getDate();
        let mm = today.getMonth() + 1;
        let y = today.getFullYear();
        let date = Date.parse(y + '-' + mm + '-' + dd);
        let date1 = new Date(date);
        console.log('date-->', date);
        let formattedDate = date1.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
        this.todaydate = formattedDate;

    }

    get renderMaternity() {
        return this.selectedLeaveTypes === 'Maternity' ? true : false
    }
    get renderReason() {
        return (this.selectedLeaveTypes === 'Paternity' || this.selectedLeaveTypes === 'Bereavement' || this.selectedLeaveTypes === 'Marriage') ? true : false
    }
    get renderCompOff() {
        return this.selectedLeaveTypes === 'Compensatory Off' ? true : false
    }

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    //TO GET OBJECT INFORMATION
    @wire(getObjectInfos, { objectApiNames: '$objectApiNames' })
    wiredData({ error, data }) {
        if (data) {
            console.log('###objectApiNames: ', JSON.stringify(data));
            console.log('###objectApiNames: ', data.results)
            const [caseObjInfo, leaveObjInfo] = data.results;

            console.log('###caseObjInfo: ', caseObjInfo);
            console.log('###familyObjInfo: ', leaveObjInfo);
            this.caseObjectInfo = caseObjInfo.result
            this.leaveHistoryObjectInfo = leaveObjInfo.result
        } else if (error) {
            console.error('Error:', error);
        }
    }

    // CODE FOR MATERNITY LEAVE TO CALCULATE DURATION
    @wire(getbilling, { userid: '$uId' })
    wiredbilling({ error, data }) {
        if (data) {
            this.Location = data.Work_Location__r.Country__c;
            console.log('this.Location', this.Location);
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }


    //TO GET PRIORITY PICKLIST VALUES
    @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '$caseObjectInfo.defaultRecordTypeId' })
    picklistPriorityHandler({ error, data }) {
        if (data) {
            console.log('### caseObjectInfo', data);
            this.priorityValues = this.picklistGenerator(data.picklistFieldValues.Priority);
            this.dayValues = this.picklistGenerator(data.picklistFieldValues.Day__c);
            this.leaveTypeValues = this.picklistGenerator(data.picklistFieldValues.Request_Sub_Type__c)
            const leaveTypessRemoved = ["Educational Details", "Bank Details", "Family/Dependent Information", "Offboarding", "Other", "Problem",]
            const filteredLeaveTypeList = this.leaveTypeValues.filter(status => !leaveTypessRemoved.includes(status.label));
            this.leaveTypeValues = filteredLeaveTypeList;
            console.log('### leaveTypeValues filter: ', this.leaveTypeValues);
            console.log('### priorityValues : ', this.priorityValues);
            console.log('### day : ', this.dayValues);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    //COMBOBOX
    picklistGenerator(data) {
        return data.values.map(item => ({ "label": item.label, "value": item.value }))
    }

    handleChange(event) {
        const { name, value } = event.target;
        console.log('### event.target : ', JSON.stringify(event.target.name));
        if (name === 'Priority') {
            this.selectedPriority = value;
        }
        if (name === 'leaveReqTypes') {
            this.selectedLeaveTypes = value;
            this.selectedPriority = '';
            this.startDate = null;
            this.endDate = null;
            console.log('#### selectedLeaveTypes : ', this.selectedLeaveTypes);
        }

        if (name === 'compOffDay') {
            this.selectedDay = value;
            console.log('### selectedDay : ', this.selectedDay);
            if (this.selectedDay === 'Full Day') {
                this.dayCheck1 = false;
                console.log('### Full : ', this.dayCheck);
            } else if (this.selectedDay === 'Half Day') {
                this.dayCheck1 = true;
                console.log('### half : ', this.dayCheck);
            }
        }
    }

    // TO SAVE THE RECORD EDIT FORM
    handleSuccess(event) {
        const even = new ShowToastEvent({
            title: 'Success!',
            message: 'Successfully created the service request!',
            variant: 'success'
        });
        this.dispatchEvent(even);
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: "Account",
                actionName: "view",
                recordId: event.detail.id
            }
        });
        this.openModal = false;
    }

    handleError(event) {
        console.log('====event.detail.detail======' + JSON.stringify(event.detail.detail));
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    onSubmitHandler(event) {
        console.log(' In form ssubmit');
        event.stopPropagation();

        // This must also suppress default submit processing
        event.preventDefault();

        // Set default values of the new instance.
        const fields = event.detail.fields;
        fields.Priority = this.selectedPriority;
        fields.Type = this.requestType;
        fields.Request_Sub_Type__c = this.selectedLeaveTypes;
        fields.ContactId = this.contactRecord.Id;
        fields.AccountId = this.contactRecord.AccountId;
        fields.Subject = this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedLeaveTypes;
        console.log('### fields : ', fields);
        // Push the updated fields though for the actual submission itself
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/Grid/s'
            }
        });
    }

    //TO GET DURATION FOR COMP-OFF
    @wire(getLeaveDuration, { stDate: '$startDate', edDate: '$endDate', location: '$Location', dayCheck: '$dayCheck1' })
    wiredduration({ error, data }) {
        if (data) {
            this.duration = data;
            console.log('this.duration-->', this.duration);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log('this.error ', this.error);
            this.duration = undefined;
        }
    }

    //TO GET DURATION FOR MATERNITY
    @wire(getwfhDuration, { stDate: '$startDate', edDate: '$endDate', Location: '$Location' })
    wiredMaternityduration({ error, data }) {
        if (data) {
            this.duration = data;
            console.log('this.duration-->', this.duration);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log('this.error ', this.error);
            this.duration = undefined;
        }
    }

    //FOR LEAVE STRAT DATE CHECK
    datechange(event) {
        console.log('leave type date : ', this.selectedLeaveTypes);
        var namecheck = event.target.name;
        if (namecheck == 'startDateCheck' && this.selectedLeaveTypes == 'Maternity') {
            this.startDate = event.detail.value;
            let date = new Date(this.startDate);
            let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate1 = formattedDate;
            if (new Date(todaydate1) < new Date(this.todaydate)) {

                this.startDate = '';
                console.log('### Past startDate : ',this.startDate);
                const evt = new ShowToastEvent({
                    message: 'You have selected past date, please select future date.',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.startDate = ''
                console.log('# startDate : ',this.startDate);
            }

            if (this.endDate < this.startDate && this.startDate != '' && this.endDate != '') {
                const evt = new ShowToastEvent({
                    message: 'Please select a proper start date',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.startDate = '';
                this.endDate = '';
            }
        } else if (namecheck == 'startDateCheck' && this.selectedLeaveTypes == 'Compensatory Off') {
            this.startDate = event.detail.value;
            let date = new Date(this.startDate);
            let formattedDate = date.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate1 = formattedDate;
            if (new Date(todaydate1) > new Date(this.todaydate)) {

                this.startDate = '';
                const evt = new ShowToastEvent({
                    message: 'You have selected future date, please select past date.',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }

            if (this.endDate > this.startDate && this.startDate != '' && this.endDate != '') {
                const evt = new ShowToastEvent({
                    message: 'Please select a proper start date',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.startDate = '';
                this.endDate = '';
            }
            if (this.startDate > this.endDate) {
                const evts = new ShowToastEvent({
                    message: 'please select a proper start date',
                    variant: 'error',
                });
                this.dispatchEvent(evts);
                this.startDate = '';
            }
        }

        /*===================================================================================== */
        //FOR LEAVE END DATE CHECK
        if (namecheck == 'endDate' && this.selectedLeaveTypes == 'Maternity') {
            this.endDate = event.detail.value;
            let datessend = new Date(this.endDate);
            let formattedendDate = datessend.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate2 = formattedendDate;
            if (new Date(todaydate2) < new Date(this.todaydate)) {
                this.endDate = '';
                const evts = new ShowToastEvent({
                    message: 'You have selected past date, please select future date.',
                    variant: 'error',
                });
                this.dispatchEvent(evts);
            }

            if (this.endDate < this.startDate && this.startDate != '' && this.endDate != '') {
                const evt = new ShowToastEvent({
                    message: 'Please select a Valid End date',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.startDate = '';
                this.endDate = '';
            }
        } else if (namecheck == 'endDate' && this.selectedLeaveTypes == 'Compensatory Off') {
            this.endDate = event.detail.value;
            let datessend = new Date(this.endDate);
            let formattedendDate = datessend.toLocaleDateString('en-US', { year: 'numeric', month: 'numeric', day: 'numeric' });
            let todaydate2 = formattedendDate;
            if (new Date(todaydate2) > new Date(this.todaydate)) {
                this.endDate = '';
                const evts = new ShowToastEvent({
                    message: 'You have selected future date, please select past date.',
                    variant: 'error',
                });
                this.dispatchEvent(evts);
            }

            if (this.endDate < this.startDate && this.startDate != '' && this.endDate != '') {
                const evt = new ShowToastEvent({
                    message: 'Please select a Valid End date',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                this.startDate = '';
                this.endDate = '';
            }
        }
    }

    //SUBMIT HANDLER FOR MATERNITY LEAVE
    submitcase(event) {
        console.log('### test : ');
        if (this.fileData != null) {
            alert('please upload file');
        } else {
            if (!this.startDate || !this.endDate) {
                const evt = new ShowToastEvent({
                    message: 'Please enter the proper details.',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
                return;
            }
            const fields = {
                'Leave_Start_Date__c': this.startDate, 'Leave_End_Date__c': this.endDate, 'Leave_Duration__c': this.duration,
                'Priority': this.selectedPriority, 'Type': this.requestType, 'Request_Sub_Type__c': this.selectedLeaveTypes,
                'ContactId': this.contactRecord.Id,
                'AccountId': this.contactRecord.AccountId,
                'Subject': this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedLeaveTypes
            };
            console.log('##fields : ', fields);
            const recordData = { apiName: 'Case', fields };
            createRecord(recordData).then(result => {
                this.rId = result.id;
                console.log('this.rId------>', JSON.stringify(result));
                if (this.fileData != null) {
                    uploadFile({ base64: this.fileData.base64, filename: this.fileData.filename, recordId: this.rId }).then(res => {
                        console.log(res);
                    }).catch(error => { console.error(error.body.message); });
                }

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!',
                        message: 'Successfully created the service request!',
                        variant: 'success'
                    }),
                );
                this[NavigationMixin.Navigate]({
                    type: "standard__recordPage",
                    attributes: {
                        objectApiName: "Account",
                        actionName: "view",
                        recordId: this.rId
                    }
                });
                this.openModal = false;

            }).catch(error => {
                console.log('error-->', error);
                console.log('error msg-->', error.body.pageErrors);
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }

    }

    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64
            }
        }
        reader.readAsDataURL(file);
        this.submitcheck = false;
    }

    /*===================================================================================== */

    // SUBMIT HANDLER FOR COMP-OFF
    handelCompSave(event) {
        console.log('helooo : ');
        console.log('reason : ', this.reason);
        console.log('selectedDay : ', this.selectedDay);
        if (!this.startDate || !this.endDate || !this.reason || !this.selectedDay) {
            const evt = new ShowToastEvent({
                message: 'Please enter the details.',
                variant: 'error',
            });
            this.dispatchEvent(evt);
            return;
        }
        const fields = {
            'Leave_Start_Date__c': this.startDate, 'Leave_End_Date__c': this.endDate, 'Leave_Duration__c': this.duration,
            'Priority': this.selectedPriority, 'Type': this.requestType, 'Request_Sub_Type__c': this.selectedLeaveTypes,
            'ContactId': this.contactRecord.Id,
            'AccountId': this.contactRecord.AccountId,
            'Day__c': this.selectedDay,
            'Reason__c': this.reason,
            'Subject': this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedLeaveTypes
        };
        console.log('### fields : ', fields);
        const recordData = { apiName: 'Case', fields };
        createRecord(recordData).then(result => {
            this.rId = result.id;
            console.log('this.rId------>', this.rId);
            const even = new ShowToastEvent({
                title: 'Success!',
                message: 'Successfully created the service request!',
                variant: 'success'
            });
            this.dispatchEvent(even);

            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    objectApiName: "Account",
                    actionName: "view",
                    recordId: this.rId
                }
            });
            this.openModal = false;

        }).catch(error => {
            console.log('error-->', error);
            console.log('error msg-->', error.body.pageErrors);
            this.dispatchEvent(
                new ShowToastEvent({
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    handleReason(event) {
        this.reason = event.target.value;
        console.log('### reason : ', reason);
    }
}