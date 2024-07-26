import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class Genericmodal extends LightningModal {
    @api btnLable1;
    @api btnLable2;
    @api headerLable;
    @api bodyLable;

    handleSave(){
        this.close('okay');
    }

    handleClose(){
        this.close('close');
    }
}