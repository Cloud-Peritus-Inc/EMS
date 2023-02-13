import { LightningElement ,track,api,wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import getprojectAssignment from '@salesforce/apex/getProjectRelatedAssignments.getAssignments';
const columns = [
    { label: 'AssignmentId', fieldName: 'Name', type: 'text'},
    { label: 'Employee Name', fieldName: 'EmpName', type: 'text' },
    { label: 'StartDate', fieldName: 'EMS_TM_StartDate_Asgn__c', type: 'date' },
    { label: 'EndDate', fieldName: 'EMS_TM_EndDate_Asgn__c', type: 'date' }, //EMS_TM_Status_Asgn__c
    { label: 'Status', fieldName: 'EMS_TM_Status_Asgn__c', type: 'text' }
];

export default class ProjectAssignmentData extends LightningElement {
    @api recordId;
    @ track data ;
    columns = columns;

    currentPageReference = null; 
    urlStateParameters = null;
  
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          this.recordId = currentPageReference.attributes.recordId || null;

       }
    }

    connectedCallback() {
        console.log('REcordId'+this.recordId);
       getprojectAssignment({projectId : this.recordId})
        .then(result => {
            console.log('assignmentResult'+result);
            let tempRecords = result ;
           if(tempRecords) {
               tempRecords = tempRecords.map( row => {
                   return { ...row, EmpName: row. EMS_TM_EmployeeName__r.Name};
               })
           }
console.log('temprecords---------->>>>'+tempRecords); 
            this.data = tempRecords;
        })
        .catch(error => {
            console.log('handlecheckCompOffRecError'+JSON.stringify(error));
        })
    }
}