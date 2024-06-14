import { LightningElement,api } from 'lwc';
import rejectButton from '@salesforce/apex/EMS_EM_aplicantConvertResource.rejectButton';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class EMS_EM_rejectButton extends LightningElement {
    @api recordId;
    handleReject(){
       
        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        rejectButton({recordId:this.recordId})
        .then(result => {
            console.log('this.recordId-->'+this.recordId);
            this.recordId = result;
    
            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Request has been Rejected!',
                  variant: 'success',
              }),
          );
          this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            this.error = error;
            console.log('this.error-->'+JSON.stringify(this.error));
        });
    }

    handleCancel(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

}