import { LightningElement,api } from 'lwc';
export default class Mynominations extends LightningElement {
@api nomstable = [];

get hasData() {
        return this.nomstable.length > 0;
    }
}