import { LightningElement, api } from 'lwc';
export default class ShowPdfById extends LightningElement {
    @api fileId;
    @api heightInRem;

    get pdfHeight() {
        return this.heightInRem + 'rem';
    }
    get url() {
        return '/sfc/servlet.shepherd/document/download/' + this.fileId;
    }
}