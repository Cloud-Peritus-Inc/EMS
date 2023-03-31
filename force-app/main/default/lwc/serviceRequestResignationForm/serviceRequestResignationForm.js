import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ServiceRequestResignationForm extends NavigationMixin(LightningElement){

    openModal = false;
    inputDisabled = true;
    @api recordId;
    empName;
    empId;
   // objectApiName = CASE_OBJECT;
    department;
    currentExp;
    noticePeriod;
    usercontactId;
    designationId;
    todayDate;

    departmentId;
    resignationREason;
    lastworkingDate;
    reasonRealiving;
    inputLastWorkingDate;

    @api contactRecord;
    @api requestType;
    @api reqSubTypeValues;

    connectedCallback() {
            this.usercontactId = this.contactRecord.Id;
            this.useraccountId = this.contactRecord.AccountId;
            this.noticedays = this.contactRecord.Notice_Period__c;  
         
            var date = new Date(); 
            date.setDate(date.getDate() +this.noticedays); 
            console.log('DATE'+date);
            this.lastworkingDate = date.toISOString();
            var date = new Date();
            this.todayDate = date.toISOString();
            console.log('this.lastworkingDate***********   '+this.lastworkingDate);

    }
  
    handleCancel(){
  this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/Grid/s'
            }
        });

    }

     handleSuccess(event) {
        const even = new ShowToastEvent({
            title: 'Success!',
            message: 'Successfully created the service request!',
            variant: 'success'
        });
        this.dispatchEvent(even);
       this[NavigationMixin.Navigate]({
        type: "standard__recordPage",
        attributes: {
            objectApiName: "Account",
            actionName: "view",
            recordId:  event.detail.id
        }
        });
        this.openModal = false;
    }

    handleError(event) {
        console.log('====event.detail.detail======' + JSON.stringify(event.detail.detail));
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    onSubmitHandler(event) {
        console.log(' In form ssubmit');
    event.stopPropagation();

    // This must also suppress default submit processing
    event.preventDefault();

    // Set default values of the new instance.
    let fields = event.detail.fields;
    
    fields.Type = this.requestType;
   
    fields.Request_Sub_Type__c = 'Offboarding';
    fields.Status = 'New';
    fields.Origin = 'Grid Portal';
    fields.Department__c = this.contactRecord.Department__c;
    fields.Designation__c = this.contactRecord.Resource_Role__c;
    fields.ContactId = this.contactRecord.Id;
    fields.AccountId = this.contactRecord.AccountId;
    fields.Notice_Period__c =this.contactRecord.Notice_Period__c;
    fields.Subject = this.contactRecord.EMS_RM_Employee_Id__c+'-'+this.contactRecord.Name+'- Resignation Request';
    if(this.inputLastWorkingDate =='undefined' || this.inputLastWorkingDate == undefined){
         this.inputLastWorkingDate = fields.Last_Working_Date__c;
         console.log('IFinputLastWorkingDate'+this.inputLastWorkingDate);
    }

    console.log('fields.Notice_Period__c'+fields.Notice_Period__c);
            var date = new Date(); 
            date.setDate(date.getDate() +fields.Notice_Period__c); 
            console.log('DATE'+date);
            var existingDate = date.toISOString();
      console.log('inputlastWorkingDate  '+this.inputLastWorkingDate);
      console.log('existingDate       '+existingDate);

    if(this.inputLastWorkingDate <= existingDate){
       this.template.querySelector('lightning-record-edit-form').submit(fields);
    }else{
         const evt = new ShowToastEvent({
            message:'Select a date before your last working day as per your notice period',
            variant: 'error',
        });
        this.dispatchEvent(evt);

    }
    
}

handleLastWorkdate(event){
    this.inputLastWorkingDate = event.target.value;
    console.log('this.inputLastWorkingDate'+this.inputLastWorkingDate);

}


}