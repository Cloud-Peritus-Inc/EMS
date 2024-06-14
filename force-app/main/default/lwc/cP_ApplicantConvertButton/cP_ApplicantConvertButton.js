import { LightningElement,track,wire,api } from 'lwc';
import recordTypeChangeByLWC from '@salesforce/apex/CP_aplicantConvertResource.recordTypeChangeByLWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CP_ApplicantConvertButton extends NavigationMixin(LightningElement) {
   @api recordId;
   conid;
   errors;

   
     updateRecordType(){
        console.log('recordId-->',this.recordId);
       
        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        
        recordTypeChangeByLWC({contactId:this.recordId})
        .then(res => {
            console.log('INSIDE THEN');
            console.log('this.res-->',res);
            this.conid = res[0].Id;
            console.log('this.conid-->',this.conid);
            
            /*this.dispatchEvent(
                new ShowToastEvent({
                    message: 'Applicant converted to Resource successfully!',
                    variant: 'success',
                })
            );*/          

            this.updateRecordView();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'Contact',
                    actionName: 'view'
                }
            }, true /*refresh*/);
        })
        .catch(error => {
            this.errors = error;
            console.log('this.errorsss-->'+JSON.stringify(this.errors));
            // Show toast msg on for error
            let errorMessage = 'An error occurred';
            if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                errorMessage = error.body.pageErrors[0].message;
            }

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: errorMessage,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
            
        });
    }

    updateRecordView() {
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 1000); 
    }

handleCancel(){
    this.dispatchEvent( new CustomEvent('closeQuickAction'));
}
}