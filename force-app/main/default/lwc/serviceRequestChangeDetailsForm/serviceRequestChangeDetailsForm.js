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

    @track currentPageReference;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        this.currentPageReference = currentPageReference;
    }

    handleEmergencyChange(event) {
        console.log('### event : ', event.target.value);
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
        console.log('### event : ', event.target.value);
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
        console.log('usercontactId : ', this.usercontactId);
        this.useraccountId = this.contactRecord.AccountId;
    }

    //TO GET OBJECT INFORMATION
    @wire(getObjectInfos, { objectApiNames: '$objectApiNames' })
    wiredData({ error, data }) {
        if (data) {
            console.log('###objectApiNames: ', data.results)
            const [caseObjInfo, familyObjInfo] = data.results;
            this.caseObjectInfo = caseObjInfo.result
            this.familyObjectInfo = familyObjInfo.result
            console.log('### familyObjectInfo : ', this.familyObjectInfo);
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
            console.log('### reqSubTypeValues : ', this.reqSubTypeValues);
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
            console.log('### getPayrollInfo', data);
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
            console.log('### getLoggedInUserFamilyData', data);
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
        console.log('### event.target : ', JSON.stringify(event.target.name));
        if (name === 'Priority') {
            this.selectedPriority = value;
        }
        if (name === 'SubTypeReq') {
            this.selectedReqSubType = value;
        }
        if (name === 'Relationship') {
            this.selectedRelationship = value;
        }
    }

    handleSuccess(event) {

        const fields = event.detail.fields;
        console.log('fields : ',fields.Request_Sub_Type__c.value);
        console.log('### save fields : ', fields.Is_It_Emergency_Contact__c.value);
        console.log('### save fields : ', JSON.stringify(fields.Is_It_Emergency_Contact__c.value, ));
        console.log('### prop : ',fields.hasOwnProperty('Is_It_Emergency_Contact__c'));
        // Check if both fields are false, and return from the function if they are
        if (fields.Request_Sub_Type__c.value === 'Family/Dependent Information' && fields.Is_It_Emergency_Contact__c.value === false && fields.Is_it_Dependant_Contact__c.value === false) {
            const even = new ShowToastEvent({
                message: 'Please select at least one option before submitting the form.',
                variant: 'error'
            });
            this.dispatchEvent(even);
            return;
        }
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

    // BANK SUBMIT HANDLER
    onSubmitHandler(event) {
        console.log('OUTPUT : clicked');
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
        console.log('### fields : ', fields);
        /*if (fields.Is_It_Emergency_Contact__c === false && fields.Is_it_Dependant_Contact__c === false) {
            const even = new ShowToastEvent({
                message: 'Helloo',
                variant: 'error'
            });
            this.dispatchEvent(even);
        }*/
        // Push the updated fields though for the actual submission itself
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    // FAMILY SUBMIT HANDLER
    onSubmitFamilyHandler(event) {

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
        console.log('OUTPUT : 123');
        event.preventDefault(); // stop the form from submitting
        const fields = {
            Priority: this.selectedPriority,
            Type: this.requestType,
            Request_Sub_Type__c: this.selectedReqSubType,
            ContactId: this.contactRecord.Id,
            AccountId: this.contactRecord.AccountId,
            Subject: this.contactRecord.EMS_RM_Employee_Id__c + '-' + this.contactRecord.Name + '-' + this.selectedReqSubType
        };
        console.log('### fields : ', fields);

        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(field => {
            fields[field.fieldName] = field.value;
            console.log('### inputFields : ', inputFields);
        });
        let isValid = true;
        this.template.querySelectorAll('lightning-input-field').forEach(field => {
            isValid = isValid && field.reportValidity();
        });
        if (isValid) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit(fields);
            });
        }
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

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/Grid/s'
            }
        });
    }
}