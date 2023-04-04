import { LightningElement,api } from 'lwc';
import updateComments from '@salesforce/apex/ems_EM_AddComments.sendOnboardingFormReopenEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AddCommentButton extends LightningElement {
@api recordId;
inputValue;
handleCancel(event){
        this.dispatchEvent( new CustomEvent('closeQuickAction'));
    }

    handleChangeRichText(event) {
        this.inputValue = event.target.value;
    }

    handleAddComments(event){
        if(this.inputValue){
        updateComments({recordId:this.recordId,comments : this.inputValue})
        .then((result) =>{
            console.log("result" + result)
            this.updateRecordView();
            this.dispatchEvent(
                 new ShowToastEvent({
              message: 'Reopening comments sent to applicant successfully',
              variant: 'success',
          }),
            )
              this.dispatchEvent(new CustomEvent('successaction'));
        })
        .catch((error) => {
            console.error("ERROR" + error);
        })

        }
    }
    updateRecordView() {
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 500); 
    }
}