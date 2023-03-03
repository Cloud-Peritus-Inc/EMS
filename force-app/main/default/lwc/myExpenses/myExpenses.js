import { LightningElement,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyExpenseReport from '@salesforce/apex/myExpenseController.getMyExpenseReport';
import updateAndGetData from '@salesforce/apex/myExpenseController.updateAndGetData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MyExpenses extends NavigationMixin(LightningElement) {
@track expList ;
@track wrapdate;
reimbursment;
reimbCurrency ;
openModal = false;
showtable = false;
resourceId;
showFileUpload = false;
createdRecordId ;
connectedCallback(){

}

loaded = false
    @wire(getMyExpenseReport) 
    wiredLabels({error, data}){
        if(data){
        this.expList = data.expList;
        this.resourceId = data.resourceId;
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
    }

    handleCancel(event) {
      this.openModal = false;
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

    // Push the updated fields though for the actual submission itself
    this.template.querySelector('lightning-record-form').submit(fields);
}

 handleSuccess(event) {
    console.log('=====event.detail.id====='+event.detail.id);
    this.createdRecordId = event.detail.id;
     this.showFileUpload = true;
    }

    handleError(event){
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }

        get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg','.txt','.docx','.attachment','.js','.cls','.apxt','.html','.zip'];
        }

        handleUploadFinished(event) {
            let strFileNames = '';
            const uploadedFiles = event.detail.files;
            for(let i = 0; i < uploadedFiles.length; i++) {
            strFileNames += uploadedFiles[i].name + ', ';
            }
            this.showToast('Success!!','success',strFileNames + ' Files uploaded Successfully!!!');
        }

        handleSubmittedFinish(){
            this.openModal = false;
            updateAndGetData({ 
             expId : this.createdRecordId,
             status : 'Submitted' 
         })
         .then(result => {
            const even = new ShowToastEvent({
            title: 'Success!',
            message: 'Successfully Submitted the expense for an approval!',
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
            
         })
         .catch(error => {
             console.log('===ERROR===='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error in submitting the expense. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         });
        }

         handleFinish(){
            this.openModal = false;
            updateAndGetData({ 
             expId : this.createdRecordId,
             status : 'Draft' 
         })
         .then(result => {
              const even = new ShowToastEvent({
            title: 'Success!',
            message: 'Successfully Completed the expense create. Please do not forget to submit the expense for claim process.!',
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
            
         })
         .catch(error => {
               console.log('===ERROR===='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error in updating the expense. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         });
        }


}