import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType, getObjectInfos } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import FAMILY_OBJECT from '@salesforce/schema/Family_Information__c';
import getPayrollInfo from '@salesforce/apex/ServiceRequestApexHandler.getPayrollInfo';
import getLoggedInUserFamilyData from '@salesforce/apex/ServiceRequestApexHandler.getLoggedInUserFamilyData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

const familyColumns = [
    { label: 'Family Member Name', fieldName: 'Family_Member_Name__c' },
    { label: 'Is It Emergency Contact?', fieldName: 'Is_It_Emergency_Contact__c' },
    { label: 'Is It Dependent Contact?', fieldName: 'Is_It_Dependent_Contact__c' },
    { label: 'RelationShip', fieldName: 'Relationships__c', type: 'Picklist' },
    { label: 'Phone Number', fieldName: 'Contact_Phone_Number__c' },
    { label: 'Date of Birth', fieldName: 'Date_of_Birth__c', type: 'Date' },
];

export default class ServiceRequestChangeDetailsForm extends NavigationMixin(LightningElement) {

    objectApiNames = [CASE_OBJECT, FAMILY_OBJECT];
    @track tableData = [];
    @track tableColumns = familyColumns;
    openModal = false;
    bankName;
    accountNumber;
    ifscCode;
    accHolderName;
    priorityValues;
    @api reqSubTypeValues;
    relationshipValues;
    selectedPriority;
    selectedReqSubType;
    selectedRelationship
    inputDisabled = true;
    caseObjectInfo;
    familyObjectInfo;
    createdRecordId;
    @api recordId;
    @api requestType;
    keyIndex = 0;
    @api contactRecord;
    usercontactId;
    isEmergency = true;
    isEmergencyReq = false;
    isDependent = true;
    isDependentReq = false;
    isEmergencyCon;
    isDependentCon;
    @track subjectInfo;


    // BANK-CASE
    @api objectName = CASE_OBJECT;
    bankFieldList = ['Bank_Name__c', 'Bank_Account_Number__c', 'IFSC_Code__c', 'Bank_Account_Holder_Name__c'];
    //EDUCATION-CASE
    educationFiledList = ['Level_of_Education__c', 'Degree__c', 'Field_of_Study__c', 'Institution_Name__c', 'Graduation_Date__c'];
    //FAMILY-CASE
    familyFieldList = ['Family_Member_Name__c', 'Is_It_Emergency_Contact__c', 'Is_it_Dependant_Contact__c', 'Relationships__c', 'ContactMobile', 'Date_of_Birth__c'];

    get renderBankField() {
        return this.selectedReqSubType === 'Bank Details' ? true : false
    }
    get renderFamilyField() {
        return this.selectedReqSubType === 'Family/Dependent Information' ? true : false
    }
    get renderEducationField() {
        return this.selectedReqSubType === 'Educational Details' ? true : false
    }

    get sub(){
        return  this.subjectInfo = this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedReqSubType;
    }

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    handleEmergencyChange(event) {
        if (event.target.value === true) {
            this.isEmergency = false;
            this.isEmergencyReq = true;
        }

        if (event.target.value === false) {
            this.isEmergency = true;
            this.isEmergencyReq = false;
        }
    }

    handleDependentChange(event) {
        if (event.target.value === true) {
            this.isDependent = false;
            this.isDependentReq = true;
        }

        if (event.target.value === false) {
            this.isDependent = true;
            this.isDependentReq = false;
        }
    }

    connectedCallback() {
        this.usercontactId = this.contactRecord.Id;
        this.useraccountId = this.contactRecord.AccountId;
    }

    //TO GET OBJECT INFORMATION
    @wire(getObjectInfos, { objectApiNames: '$objectApiNames' })
    wiredData({ error, data }) {
        if (data) {
            const [caseObjInfo, familyObjInfo] = data.results;
            this.caseObjectInfo = caseObjInfo.result
            this.familyObjectInfo = familyObjInfo.result
        } else if (error) {
            console.error('Error:', error);
        }
    }

    //TO GET PRIORITY PICKLIST VALUES
    @wire(getPicklistValuesByRecordType, { objectApiName: CASE_OBJECT, recordTypeId: '$caseObjectInfo.defaultRecordTypeId' })
    priorityPicklistHandler({ error, data }) {
        if (data) {
            this.priorityValues = this.picklistGenerator(data.picklistFieldValues.Priority);
            this.reqSubTypeValues = this.picklistGenerator(data.picklistFieldValues.Request_Sub_Type__c)
            const subTypessRemoved = ["Offboarding", "Other", "Problem", "Paternity", "Maternity", "Marriage", "Bereavement", "Compensatory Off"];
            const filteredReqSubTypes = this.reqSubTypeValues.filter(status => !subTypessRemoved.includes(status.label));
            this.reqSubTypeValues = filteredReqSubTypes
        } else if (error) {
            console.error('Error:', error);
        }
    }


    //TO GET RELATIONSHIP PICKLIST VALUES
    @wire(getPicklistValuesByRecordType, { objectApiName: FAMILY_OBJECT, recordTypeId: '$familyObjectInfo.defaultRecordTypeId' })
    familyPicklistHandler({ error, data }) {
        if (data) {
            this.relationshipValues = this.picklistGenerator(data.picklistFieldValues.Relationships__c);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    // TO GET PAYROLL RECORD INFORMATION OF LOGGED IN USER.
    @wire(getPayrollInfo)
    getPayrollInfoWiredData({ error, data }) {
        if (data) {
            this.bankName = data.Bank_Name__c;
            this.accountNumber = data.Beneficiary_Account_Number__c;
            this.ifscCode = data.IFSC_Routing_Number__c;
            this.accHolderName = data.Name;
        } else if (error) {
            console.error('Error:', error);
        }
    }

    //TO GET FAMILY DETAILS OF LOGGED IN USER.
    @wire(getLoggedInUserFamilyData)
    getLoggedInUserFamilyDataWiredData({ error, data }) {
        if (data) {
            this.tableData = data;
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
        if (name === 'Priority') {
            this.selectedPriority = value;
        }
        if (name === 'SubTypeReq') {
            this.selectedReqSubType = value;
            this.selectedPriority = ''
        }
        if (name === 'Relationship') {
            this.selectedRelationship = value;
        }
    }

    handleFamSuccess(event) {
        const fields = event.detail.fields;
        if (fields.Request_Sub_Type__c.value === 'Family/Dependent Information' && this.isDependentCon == false && this.isEmergencyCon == false) {
            const even = new ShowToastEvent({
                message: 'Please select at least one option before submitting the form.',
                variant: 'error'
            });
            this.dispatchEvent(even);
            return;
        }
        const even = new ShowToastEvent({
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

    handleSuccess(event) {
        const even = new ShowToastEvent({
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

    //***************  BANK SUBMIT HANDLER ****************************
    onSubmitHandler(event) {
        event.stopPropagation();

        // This must also suppress default submit processing
        event.preventDefault();

        // Set default values of the new instance.
        const fields = event.detail.fields;
        fields.Priority = this.selectedPriority;
        fields.Type = this.requestType;
        fields.Request_Sub_Type__c = this.selectedReqSubType;
        fields.ContactId = this.contactRecord.Id;
        fields.AccountId = this.contactRecord.AccountId;
        fields.Subject = this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedReqSubType;
        if (typeof fields !== 'undefined') {
            this.isEmergencyCon = fields.Is_It_Emergency_Contact__c;
            this.isDependentCon = fields.Is_it_Dependant_Contact__c
        }
        if (fields.Request_Sub_Type__c === 'Family/Dependent Information' && this.isDependentCon == false && this.isEmergencyCon == false) {
            const even = new ShowToastEvent({
                message: 'Please select at least one option before submitting the form.',
                variant: 'error'
            });
            this.dispatchEvent(even);
            return;
        }
        // Push the updated fields though for the actual submission itself
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }


    // ADDING ROWS AND TO REMOVE THE EDUCATION DETAILS
    @track itemList = [
        {
            id: 0
        }
    ];

    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    handleSubmit(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = {
            Priority: this.selectedPriority,
            Type: this.requestType,
            Request_Sub_Type__c: this.selectedReqSubType,
            ContactId: this.contactRecord.Id,
            AccountId: this.contactRecord.AccountId,
            Subject: this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedReqSubType
        };
        if (fields.Request_Sub_Type__c.value === 'Educational Details' && fields.Degree__c.value === null && fields.Level_of_Education__c.value === null && fields.Field_of_Study__c.value === null && fields.Institution_Name__c.value === null && fields.Graduation_Date__c.value === null) {
            const even = new ShowToastEvent({
                message: 'Please enter the details.',
                variant: 'error'
            });
            this.dispatchEvent(even);
            return;
        }
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(field => {
            fields[field.fieldName] = field.value;
        });
        let isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(field => {
            isValid = isValid && field.reportValidity();
        });
        if (isValid) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
            });
        }
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

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/Grid/s'
            }
        });
    }
}