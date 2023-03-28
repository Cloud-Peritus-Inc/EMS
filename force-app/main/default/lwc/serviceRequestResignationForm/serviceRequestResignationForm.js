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

    departmentId;
    resignationREason;
    lastworkingDate;
    reasonRealiving;

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
          

var someDate = new Date(new Date().getTime()+(30*24*60*60*1000)); 

console.log('******************date*********'+someDate);
//return someDate.toISOString();


            this.lastworkingDate = date.toISOString();
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
    fields.Notice_Period__c =this.contactRecord.EMS_RM_Notice_Period__c;
    fields.Subject = this.contactRecord.EMS_RM_Employee_Id__c+'-'+this.contactRecord.Name+'- Resignation Request';
   
   /*    fields.Subject = this.EMS_RM_Employee_Id__c+'-'+this.contactRecord.FirstName+' '+this.contactRecord.LastName+'- Resignation Request';
 */

    // Push the updated fields though for the actual submission itself
    this.template.querySelector('lightning-record-edit-form').submit(fields);
}


}