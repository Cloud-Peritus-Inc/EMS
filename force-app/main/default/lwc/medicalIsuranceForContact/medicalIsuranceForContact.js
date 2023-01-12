import { LightningElement, api, track, wire } from 'lwc';
import getMedicalInsuranceMethod from '@salesforce/apex/EMS_EM_MedicalInsuranceController.MedicalInsuranceMethod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { deleteRecord } from 'lightning/uiRecordApi';
import userId from '@salesforce/user/Id';
import LOGGEDINUSERPROFILENAME from '@salesforce/schema/User.Profile.Name';
import { getRecord } from 'lightning/uiRecordApi';

export default class MedicalIsuranceForContact extends LightningElement {

    @api recordId;
    showMedicalInsurace = false;
    medicalInsuranceId;
    contactID;
    @track isfullmyinfoModal = false;
    @track dependenciesRecordsArray = [];
    @track isdependentpageModal = false;
    @track totalMedicalRecords;
    @track isButtonDisabled = false;
    profileName;
    isValid = false;
    isDateValid = false;
    buttonDisable = false;
    isDepDateValid = false;
    isNameValid = false;
    onchangeDate = null;
    onchangeName = null;

    @wire(getRecord, { recordId: userId, fields: [LOGGEDINUSERPROFILENAME] })
    loggedInUserRecordInfor({ data, error }) {
        if (data) {
            this.profileName = data.fields.Profile.displayValue;
            console.log("RECEIVED DATA", this.profileName);
        }
        if (error) {
            console.log("ERROR", error);
        }
    }
    get hideCreateOrEditButton() {
        return this.profileName === "Manager" ? false : true;
    }

    @wire(getMedicalInsuranceMethod, { contactId: "$recordId" })
    getMedicalInsuranceMethodRec(totalRecords) {
        this.totalMedicalRecords = totalRecords;
        if (totalRecords.data) {
            this.showMedicalInsurace = true;

            console.log("medicalInsuranceId", totalRecords.data.emsBenefitsId);
            this.medicalInsuranceId = totalRecords.data.emsBenefitsId;
            if (totalRecords.data.listEmsEmDependents && (totalRecords.data.listEmsEmDependents.length > 0)) {
                this.dependenciesRecordsArray = totalRecords.data.listEmsEmDependents;
            }

        }


        if (totalRecords.error) {
            console.log("Error OCcured With", totalRecords.error);
        }
    }
    handleValidation(event){
        console.log(event.target.dataset.id);
        console.log(event.target.value);
        var regxval = /^[A-Za-z ]+$/;
       // isValid
        if(regxval.test(event.target.value)){
            console.log("I am in If");

            this.isValid = true;
        }
        else{
            console.log("I am in else");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Valid Name',
                    variant: 'error',
                }),
            );
            this.isValid = false;
        }

    }
    handleValidationDateDependents(event){
        this.onchangeDate = event.target.value;
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy +'-'+ mm +'-'+dd;
        console.log("onchangeDate", this.onchangeDate);
        console.log("today", today);
        if(this.onchangeDate >= today){
            console.log("I am in if");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Past Date',
                    variant: 'error',
                }),
            );
            this.isDepDateValid = false;
        }
        else{
            this.isDepDateValid = true;
            console.log("isDepDateValid",this.isDepDateValid);
        }
        if(this.onchangeDate && this.onchangeName){
            if(this.isNameValid && this.isDepDateValid){
              this.buttonDisable = false;
          } else{
            this.buttonDisable = true;
          } 
        }else if(this.onchageDate && this.isDepDateValid){
                this.buttonDisable = false;
           }else{
             this.buttonDisable = true;
          }
    }
    handleValidationforUpdateDependents(event){

        console.log(event.target.dataset.id);
        console.log(event.target.value);
        this.onchangeName = event.target.value;
        var regxval = /^[A-Za-z ]+$/;
       // isValid
        if(regxval.test(this.onchangeName)){
         
            console.log("I am in If");
            this.isNameValid = true;
            
        }
        else{
            console.log("I am in else");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Valid Name',
                    variant: 'error',
                }),
            );
            this.isNameValid = false;
        }
        if(this.onchangeDate && this.onchangeName){
            if(this.isNameValid && this.isDepDateValid){
              this.buttonDisable = false;
          } else{
            this.buttonDisable = true;
          } 
        }else if(this.onchangeName && this.isNameValid){
                this.buttonDisable = false;
           }else{
             this.buttonDisable = true;
          }
    
    }
    handleValidationDateforBenefits(event){
        let onchangeDate = event.target.value;
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy +'-'+ mm +'-'+dd;
        console.log("onchangeDate", onchangeDate);
        console.log("today", today);
        if(onchangeDate >= today){
            console.log("I am in if");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Past Date',
                    variant: 'error',
                }),
            );
            this.buttonDisable = true;
        }
        else{
            this.buttonDisable = false;
        }
    }

    handleValidationDate(event){
        let onchangeDate = event.target.value;
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy +'-'+ mm +'-'+dd;
        console.log("onchangeDate", onchangeDate);
        console.log("today", today);
        if(onchangeDate >= today){
            console.log("I am in if");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter Past Date',
                    variant: 'error',
                }),
            );
            this.isDateValid = false;
        }
        else{
            this.isDateValid = true;
        }
    }

    get hideCreateNewDependentsRecords() {
        if (this.dependenciesRecordsArray.length >= 5) {
            return false;
        } else if (this.dependenciesRecordsArray.length <= 5) {
            return true;
        }
    }
    get getdependenciesRecordsArrayLength() {
        return this.dependenciesRecordsArray.length === 5;
    }
    get showLabel() {
        return this.dependenciesRecordsArray.length === 0 ? "Create" : "Edit";
    }
    get hideExsistingDependencies() {
        return this.dependenciesRecordsArray.length === 0 ? false : true;
    }
    get checkForDependents() {
        return this.dependenciesRecordsArray.length === 0 ? true : false;
    }
    get showMedicalDetails() {
        return this.medicalInsuranceId ? true : false;
    }
    get showMedicalDetailsLabel() {
        return this.medicalInsuranceId ? "Edit" : "Create";
    }

    fullmyInfopage() {
        this.isfullmyinfoModal = true;
    }
    dependentpage() {
        this.isdependentpageModal = true;
    }
    hideModalBox() {
        this.isfullmyinfoModal = false;
        this.isdependentpageModal = false;
    }
    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
        window.location.reload();
    }
    handleSubmit(event) {
        console.log('onsubmit event recordEditForm' + event.detail.fields);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Benefits record successfully created',
                variant: 'success',
            }),
        );
    }
    showSuccessToast() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Benefits Record Created successful',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
    keyIndex = 0;
    @track itemList = [
        {
            id: 0
        }
    ];

    addRow() {
        console.log("Length", this.itemList.length);
        console.log("Length", this.dependenciesRecordsArray);
        if (this.dependenciesRecordsArray.length >= 5 || (this.dependenciesRecordsArray.length + this.itemList.length >= 5)) {
            console.log("I WILL NOT EXECUETE")
        } else if (this.dependenciesRecordsArray.length <= 5 || (this.dependenciesRecordsArray.length + this.itemList.length <= 5)) {
            console.log("Executed")
            ++this.keyIndex;
            var newItem = [{ id: this.keyIndex }];
            this.itemList = this.itemList.concat(newItem);
        }
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    handleSubmit1(event) {
        var isVal = true;
        this.template.querySelectorAll('.inputValField').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if (isVal && this.isValid && this.isDateValid) {
            this.template.querySelectorAll('.createDependenciesRecord').forEach(element => {
                console.log("element", JSON.stringify(element));
                element.submit();
                refreshApex(this.totalMedicalRecords);
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Dependents Record Successfully Created',
                    variant: 'success',
                }),
            );
            window.location.reload();
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please Enter All The Required Fields Correctly',
                    variant: 'error',
                }),
            );
        }
    }

    updateRecordsOfExsistingHandler(event) {
        var isVal = true;
        if (isVal ) {
            this.template.querySelectorAll('.updateExsisiingRecords').forEach(element => {
                console.log("element", element);
                element.submit();
                refreshApex(this.totalMedicalRecords);
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Dependents Record Successfully Created',
                    variant: 'success',
                }),
            ); window.location.reload();

        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please Enter All The Required Fields Correctly',
                    variant: 'error',
                }),
            );
        }

    }

    deleteDependencyRecord(event) {
        const recordId = event.target.dataset.recordid;
        deleteRecord(recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record  Deleted Suscessfully',
                        variant: 'success'
                    })
                );
                refreshApex(this.totalMedicalRecords);
                if (this.totalMedicalRecords.data.listEmsEmDependents.length === 1) {
                    this.dependenciesRecordsArray = [];
                }
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Deleting Record',
                        variant: 'error'
                    })
                );
            });
    }
}