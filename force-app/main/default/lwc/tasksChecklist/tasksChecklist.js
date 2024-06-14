import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getRecordTypeName from '@salesforce/apex/tasksChecklistController.getRecordTypeName';

export default class TasksChecklist extends LightningElement {
    @api recordId;
    @track conRecordTypeName;
    @track showChecklist = false;
    data;

    
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          this.recordId = currentPageReference.attributes.recordId || null;
       }
    }
   connectedCallback() {
      getRecordTypeName({recordIdContact: this.recordId})
         .then(result => {
                this.data = result;
                if(this.data == 'Resource'){

                  this.showChecklist = true;
                }
            })
            .catch(error => {
                this.error = error;
            });
   }
}