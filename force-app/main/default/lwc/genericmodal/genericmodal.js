import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Genericmodal extends LightningModal {
    @api btnLable1;
    @api btnLable2;
    @api headerLable;
    @api bodyLable;
    @api bodyLable2;

    handleSave(){
        this.close('okay');
    }

    handleClose(){
        this.close('close');
    }

    renderedCallback() {
        const element = this.template.querySelector('.secondaryLable');
        //smaske : PM_Def_165 : Showing the mentor an updated text messag with a Note
        if (this.bodyLable2) {
            element.innerHTML = this.bodyLable2;
        }
    }

}