import { LightningElement, api } from 'lwc';
import convertButton from '@salesforce/apex/CP_ConvertButtonOnOnboarding.ConvertButton';
import createContact from '@salesforce/apex/CP_OnboardingToResourceConvert.createContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

export default class cP_ConvertButton extends NavigationMixin(LightningElement) {
    @api recordId;
    conid;

    handleConvert() {
        console.log('recordId-->', this.recordId);

        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        // Mapping the data onboarding to Resource
        createContact({ onBoardRecordsIdsSet: this.recordId })
            .then(res => {
                this.conid = res[0].Id;
                //console.log('this.conid1-->', this.conid);
                //console.log('this.conid3-->',res);
                // Change the status Approved to Converted to Resource
                convertButton({ recordId: this.recordId })
                    .then(result => {
                        this.recordId = result;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Record has been Converted!',
                                variant: 'success',
                            }),
                        );
                        this.dispatchEvent(new CustomEvent('closeQuickAction'));
                        this[NavigationMixin.Navigate]({
                            type: 'standard__webPage',
                            attributes: {
                                url: `/detail/${this.conid}`
                            }
                        },
                            true
                        ).then(() => {
                            // Refresh the data on the page
                            return refreshApex(this.record);
                        }).catch(error => {
                            console.log(error);
                        });

                    })
                    .catch(error => {
                        this.error = error;
                        console.log('this.errors-->' + JSON.stringify(this.error));
                    });


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