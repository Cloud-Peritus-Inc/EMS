import { LightningElement,wire,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import checkTheExpense from '@salesforce/apex/myExpenseController.checkTheExpense';
import updateforApproval from '@salesforce/apex/myExpenseController.updateforApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { refreshApex } from '@salesforce/apex';
export default class SubmitExpense extends NavigationMixin(LightningElement) {
@api recordId;
disablesubmit = true;
disablerecall = true;
@wire(checkTheExpense, {expId:'$recordId'})
    wiredExp({data, error}){
        if(data){
           this.disablesubmit = data.disableApproval;
           this.disablerecall = data.disablerecall;
        }
        else if (error) {
            console.log('===error====='+JSON.stringify(error));
        }
}

async handleapproval(){
    const result = await LightningConfirm.open({
            message: 'Are you sure you want to submit for approval ?',
            variant: 'header',
            label: 'Please Confirm',
            theme: 'info',
        });
     
        if(result==true){
          updateforApproval({ 
             expId : this.recordId,
             status : 'Submitted'
         })
         .then(data => {
               this.disablesubmit = data.disableApproval;
               this.disablerecall = data.disablerecall;
              refreshApex(this.disablesubmit);
               refreshApex(this.disablerecall);
             const event = new ShowToastEvent({
                 title: 'Completed',
                 message: 'Successfully submitted for an approval.',
                 variant: 'success'
             });
             this.dispatchEvent(event);
             this.handleNaClick();
              window.location.reload();
         })
         .catch(error => {
              console.log('=======error=='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error submitting the expense. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
            
         });

        }

}

handleNaClick(event){
this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Expense__c',
                actionName: 'view'
            },
         });
}

async handlerecall(){
     const result = await LightningConfirm.open({
            message: 'Are you sure you want to submit for approval ?',
            variant: 'header',
            label: 'Please Confirm',
            theme: 'error',
        });
     
        if(result==true){
          updateforApproval({ 
             expId : this.recordId,
             status : 'Draft'
         })
         .then(data => {
             this.disablesubmit = data.disableApproval;
               this.disablerecall = data.disablerecall;
              refreshApex(this.disablesubmit);
               refreshApex(this.disablerecall);
             const event = new ShowToastEvent({
                 title: 'Completed',
                 message: 'Successfully recalled the expense.',
                 variant: 'success'
             });
             this.dispatchEvent(event);
             window.location.reload();
             
         })
         .catch(error => {
              console.log('=======error=='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error submitting the expense. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
            
         });

        }

}





}