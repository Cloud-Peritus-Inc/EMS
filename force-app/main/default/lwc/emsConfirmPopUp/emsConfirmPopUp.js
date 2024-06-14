import { LightningElement, api } from 'lwc';

export default class EmsConfirmPopUp extends LightningElement {
    @api title;
    @api message;
    @api cancelLabel;
    @api confirmLabel;

    handleClick(event) {
        let finalEvent = {
            status: event.target.name
        };

        this.dispatchEvent(new CustomEvent('responce', {detail: finalEvent}));
    }
}