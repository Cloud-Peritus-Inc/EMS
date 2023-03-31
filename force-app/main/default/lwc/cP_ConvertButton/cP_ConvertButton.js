import { LightningElement, api } from 'lwc';
import createContact from '@salesforce/apex/CP_OnboardingToResourceConvert.createContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class cP_ConvertButton extends NavigationMixin(LightningElement) {
    @api recordId;
    conid;

    handleConvert() {
        // console.log('recordId-->', this.recordId);

        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        // Mapping the data onboarding to Resource // Change the status Approved to Converted to Resource
        createContact({ onBoardRecordsIdsSet: this.recordId })
            .then(res => {
                this.conid = res[0].Id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: 'Record has been Converted!',
                        variant: 'success',
                    }),
                );
                this.dispatchEvent(new CustomEvent('closeQuickAction'));
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.conid,
                        actionName: 'view'
                    }
                },true /*refresh*/);
                //  console.log('this.conid1-->', this.conid);
                //  console.log('this.conid3-->', res);
            })
            .catch(error => {
                this.error = error;
                console.log('this.errorsss-->' + JSON.stringify(this.error));
            });

    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('closeQuickAction'));
    }

}