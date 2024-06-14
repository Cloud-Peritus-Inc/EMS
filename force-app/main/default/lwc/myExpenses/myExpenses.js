import { LightningElement,track,wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyExpenseReport from '@salesforce/apex/myExpenseController.getMyExpenseReport';
import updateAndGetData from '@salesforce/apex/myExpenseController.updateAndGetData';
import uploadFile from '@salesforce/apex/myExpenseController.uploadFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProjectsAssignedToLoggedInContact from '@salesforce/apex/myExpenseController.getProjectsAssignedToLoggedInContact';
let i=0;

export default class MyExpenses extends NavigationMixin(LightningElement) {
@track expList ;
@track wrapdate;
reimbursment;
reimbCurrency ;
openModal = false;
showtable = false;
resourceId;
showFileUpload = false;
approvalManager;

fileData;

createdRecordId ;
connectedCallback(){
}

loaded = false
    @wire(getMyExpenseReport) 
    wiredLabels({error, data}){
        if(data){
        this.expList = data.expList;
        this.resourceId = data.resourceId;
        console.log('Current logged in contact Id 33 ==> '+ this.resourceId);
       // this.approvalManager = data.approvalManager;
        if(this.expList.length > 0){
           this.showtable = true;
        }
        this.reimbursment = data.pendingreim;
        this.reimbCurrency = data.expCurrency;
        this.loaded = true;
       
    }
        if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
        }
    }

    handleClick(){
       this.openModal = true;
       console.log('Current logged in contact Id 49 ==> '+ this.resourceId);
    }

    //----------------

    @track comboboxValues = [];
    @track value = '';
    @track projectValue = '';
    

    @wire(getProjectsAssignedToLoggedInContact, { contactId: "$resourceId" })
    retrieveComboBoxValues({ error, data }) {
        if (data) {
            for(i=0; i<data.length; i++) {
                console.log('id=' + data[i].Id);
                this.comboboxValues = [...this.comboboxValues ,{value: data[i].Id , label: data[i].Name}];  
                console.log('Picklist => '+this.comboboxValues);                                 
            }                
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    handleProjectChange(event) {
        this.projectValue = event.detail.value;
        console.log('Project value ==> 77 =>  '+this.projectValue);
    } 

    handleSubmit(event) {
        // stop the form from submitting
        event.preventDefault();
        //Get the fields       
        const fields = event.detail.fields;
        //Set the field for the hidden lightning-input-field
        fields.Project__c = this.projectValue;
        //Submit the form
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    //----------------

    handleCancel(event) {
      this.openModal = false;
     // this.showFileUpload =false;
     
    }

handleNavClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/recordlist/Expense__c/Default'
            }
        });
}

handleexpClick(event){
let selectexp = event.currentTarget.dataset.id;
this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectexp,
                objectApiName: 'expense__c',
                actionName: 'view'
            },
         });
}

handleFormSubmit(event) {
    event.stopPropagation();

    // This must also suppress default submit processing
    event.preventDefault();

    // Set default values of the new instance.
    let fields = event.detail.fields;
    fields.Status__c = 'Draft';
    fields.Resource__c = this.resourceId;
   // fields.Approval_Manager__c	= this.approvalManager;

    // Push the updated fields though for the actual submission itself
    this.template.querySelector('lightning-record-edit-form').submit(fields);
}

 handleSuccess(event) {
    //console.log('=====event.detail.id====='+event.detail.id);
    this.createdRecordId = event.detail.id;
    console.log('Project update 122 => '+ this.value);
     this.showFileUpload = true;
 }

    handleError(event){
        const evt = new ShowToastEvent({
            message: event.detail.detail,
            variant: 'error',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

        get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg','.txt','.docx','.attachment','.js','.cls','.apxt','.html','.zip'];
        }

        /*handleUploadFinished(event) {
            let strFileNames = '';
            const uploadedFiles = event.detail.files;
            for(let i = 0; i < uploadedFiles.length; i++) {
            strFileNames += uploadedFiles[i].name + ', ';
            }
            this.showToast('Success!!','success',strFileNames + ' Files uploaded Successfully!!!');
        }*/

    handleUploadFinished(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        console.log('Record id 123 => '+ this.createdRecordId);
        reader.onload =()=> {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.createdRecordId
            }
            console.log('Filedata => '+this.fileData)
        }
        reader.readAsDataURL(file)
    }

    /*@track filesUploaded = [];
    fileName2;

    handleUploadFinished(event) {
        if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && (event.target.files[0].type == "image/png" || event.target.files[0].type == "image/jpeg" || event.target.files[0].type == "image/jpg")) {
            let files = [];
            let file = event.target.files[0];
            this.fileName2 = event.target.files[0].name;
            let reader = new FileReader();
            reader.onloadend = e => {
                let base64 = 'base64,';
                let content = reader.result.indexOf(base64) + base64.length;
                let fileContents = reader.result.substring(content);
                this.filesUploaded.push({ PathOnClient: file.name, Title: 'Picture_' + file.name, VersionData: fileContents });
            };
            reader.readAsDataURL(file);
        } else {
            const even = new ShowToastEvent({
                message: 'The maximum file size is 2MB and the supported file type is image/jpeg/png/jpeg only',
                variant: 'error'
            });
            this.dispatchEvent(even);
        }
    }*/


       /* handleSubmittedFinish(){
            this.openModal = false;
            updateAndGetData({ 
             expId : this.createdRecordId,
             status : 'Submitted' 
             
         })
         .then(result => {
            const even = new ShowToastEvent({
            message: 'Successfully submitted the Expense for an Approval!',
            variant: 'success'
        });
        this.dispatchEvent(even);
            this.expList = result.expList;
            this.resourceId = result.resourceId;
            if(this.expList.length > 0){
            this.showtable = true;
            }
            this.reimbursment = result.pendingreim;
            this.reimbCurrency = result.expCurrency;
            this.loaded = true;
            
            this.openModal = false;
            this.showFileUpload =false;
         })
         .catch(error => {
             console.log('===ERROR===='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 message : 'Error in submitting the Expense. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         });
        }*/

handleSubmittedFinish(){

    this.openModal = false;
    updateAndGetData({
        expId: this.createdRecordId,
        status: 'Submitted'

    })
       
    const {base64, filename, recordId} = this.fileData
        uploadFile({ base64, filename, recordId }).then(result=>{
            this.fileData = null
            let title = 'Successfully submitted the Expense for an Approval!'
            this.toast(title)
        })
    this.openModal = false;
    

}

toast(title){
        const toastEvent = new ShowToastEvent({
            title, 
            variant:"success"
        })
        this.dispatchEvent(toastEvent)
        window.location.reload();
    }

         handleFinish(){
            this.openModal = false;
            updateAndGetData({ 
             expId : this.createdRecordId,
             status : 'Draft' 
         })
         .then(result => {
              const even = new ShowToastEvent({
            message: 'Successfully submitted the Expense for an Approval',
            variant: 'success'
        });
        this.dispatchEvent(even);
            this.expList = result.expList;
            this.resourceId = result.resourceId;
            
            if(this.expList.length > 0){
            this.showtable = true;
            }
            this.reimbursment = result.pendingreim;
            this.reimbCurrency = result.expCurrency;
            this.loaded = true;
            this.openModal = false;
            this.showFileUpload =false;
         })
         .catch(error => {
               console.log('===ERROR===='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 message : 'Error in updating the Expense. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         });
        }


}