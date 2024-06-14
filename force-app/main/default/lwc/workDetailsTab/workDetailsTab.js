import { LightningElement,api,track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class profileTabComponent extends LightningElement {
@api recordId;
@track objectapiName;
//@api loading = false;
activeSections = ['workDetail'];

/*handleSuccess(){
   const toastmsg = new ShowToastEvent({
       title : 'Success',
       message : 'Data Saved Successfully',
       variant : 'info',
       mode : 'dismissable'
   })
   this.dispatchEvent(toastmsg);
}*/

handleSuccess() {
   //this.loading = true;
        const event = new ShowToastEvent({
            variant: 'success',
            title: 'Success!',
            message: 'Record has been updated',
        });
        this.dispatchEvent(event);
        //Promise.resolve();
        //this.loading = false;
    }

handleCancel(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }

}