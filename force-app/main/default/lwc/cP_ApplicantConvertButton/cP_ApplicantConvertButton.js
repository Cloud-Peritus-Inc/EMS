import { LightningElement,track,wire,api } from 'lwc';
import recordTypeChangeByLWC from '@salesforce/apex/CP_aplicantConvertResource.recordTypeChangeByLWC';
import convertButton from '@salesforce/apex/CP_aplicantConvertResource.ConvertButton';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord, getFieldValue } from "lightning/uiRecordApi";
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
            this.conid =res[0].Id;
            console.log('this.conid1-->',this.conid);
            //console.log('this.conid3-->',res);

        convertButton({contactId:this.recordId})
        .then(result => {
            this.recordId = result;  
            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Applicant converted to Resource successfully!',
                  variant: 'success',
              }),
          );window.location.reload();
        //   this.dispatchEvent( new CustomEvent('closeQuickAction'));
        //   this[NavigationMixin.Navigate]({
        //     type: 'standard__webPage',
        //     attributes: {
        //         url: `/detail/${this.recordId}`
        //     }
        // },
        // true
        // );
          
        })
        .catch(error => {
            this.error = error;
            console.log('this.errors-->'+JSON.stringify(this.error));
        });
           
          
        })
        .catch(error => {
            this.error = error;
            console.log('this.errorsss-->'+JSON.stringify(this.error));
        });
}

handleCancel(){
    this.dispatchEvent( new CustomEvent('closeQuickAction'));
}
}