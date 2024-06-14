import { LightningElement, track, wire,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import ASSIGNMENT_OBJECT from '@salesforce/schema/EMS_TM_Assignment__c';
import { getPicklistValues, getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getOpportunities from '@salesforce/apex/GetContactWhoReportToManger.getContacts';
import insertAssignemnts from '@salesforce/apex/GetContactWhoReportToManger.insertMultipleAssignments';
//

export default class MultipleResourceParent extends NavigationMixin(LightningElement){
 @api recordId;
    @track error;
    @track opps = [];
    @track showOppLookup = false;
    @track selectedOppsIds;
    @track conIds =[];
     enddate;
     startDate;
     assignedAs;
     @track assignedvalues =[];
     @track assignmentObjectInfo;

     currentPageReference = null; 
    urlStateParameters = null;

    //TO GET OBJECT INFO
  @wire(getObjectInfo, { objectApiName: ASSIGNMENT_OBJECT })
  assignmentObjectInfo

  @wire(getPicklistValuesByRecordType, { objectApiName: ASSIGNMENT_OBJECT, recordTypeId: '$assignmentObjectInfo.data.defaultRecordTypeId' })
  picklistHandler({ error, data }) {
    if (data) {
      //console.log('getPicklistValuesByRecordTypeData Pending Tab', data);
      this.assignedvalues = data.picklistFieldValues.EMS_TM_AssignedAs__c.values;
      console.log('### assignedvalues Pending Tab: ', this.assignedvalues);
    } else if (error) {
      console.error('Error:', error);
    }
  }
  
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          this.recordId = currentPageReference.attributes.recordId || null;

       }
    }

    @wire(getOpportunities)
    wOpps({error,data}){
        if(data){
            console.log('Data'+data);
            console.log('Error'+JSON.stringify(data));
            for(let i=0; i<data.length; i++){
                let obj = {id: data[i].Id, value: data[i].Name, icon:'standard:contact'};
                this.opps.push(obj);
            }
            this.showOppLookup = true;

        }else{
            console.log('Error'+JSON.stringify(error));
            this.error = error;
        }       
    }
   
   assignStartDate(event){
this.enddate = event.target.value;
console.log('this.enddate '+this.enddate);
}
handleChange(event){
this.assignedAs = event.target.value;
console.log('this.enddate '+this.assignedAs);
}
assignendDate(event){
this.startDate = event.target.value;
console.log('this.startDate '+this.startDate);
}
   handleOppsChange(event){
       console.log('event'+event.detail);
        let opps = event.detail;
        console.log('opps'+JSON.stringify(opps));
     /*  this.conIds = opps;
       console.log('conIds'+this.conIds);*/
        this.selectedOppsIds = '';
        opps.forEach(opp => {

            this.selectedOppsIds += opp.id+'; ';
             this.conIds.push(opp.id);
        });

        console.log('this.selectedOppsIds---->>>'+this.selectedOppsIds);
        console.log('this.conIds---->>>'+this.conIds);
    }
//Date startDate,Date endDate, List<Id> contactIds,Id projectId)
    handleValidation(){
      /*  console.log('ProjectID'+this.recordId);
        console.log('this.selectedOppsIds---->>>'+this.selectedOppsIds);
        console.log('this.startDate '+this.startDate );
        console.log('this.enddate '+this.enddate );*/
     insertAssignemnts({startDate:this.startDate,endDate:this.enddate,contactIds:this.conIds
     ,projectId:this.recordId,assignedAs:this.assignedAs})
        .then(result => {
            console.log('Result'+result);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success!!',
                message: 'Multiple Resource are Created Successfully!!',
                variant: 'success'
            }),);
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/ems-tm-project/'+this.recordId,
            }
        });
        })
        .catch(error => {
            console.log('error'+JSON.stringify(error));
            this.error = error.message;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error!!',
                message: error.body.message,
                variant: 'error'
            }),)
            
        });
    }

    }