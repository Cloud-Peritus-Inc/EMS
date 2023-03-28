import { LightningElement,track,wire,api } from 'lwc';
import recordTypeChangeByLWC from '@salesforce/apex/CP_aplicantConvertResource.recordTypeChangeByLWC';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class CP_ApplicantConvertButton extends NavigationMixin(LightningElement) {
   @api recordId;
   conid;

   
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
            console.log('this.res-->',res);
            this.conid = res[0].Id;
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Applicant converted to Resource successfully!',
                    variant: 'success',
                })
            );
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
            this.error = error;
            console.log('this.errorsss-->'+JSON.stringify(this.error));
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