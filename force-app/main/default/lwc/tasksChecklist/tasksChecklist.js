import { LightningElement, api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
export default class TasksChecklist extends LightningElement {
    @api recordId;

    
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          this.recordId = currentPageReference.attributes.recordId || null;

       }
    }
}