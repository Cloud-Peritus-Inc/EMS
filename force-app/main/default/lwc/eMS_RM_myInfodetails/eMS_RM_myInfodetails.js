import { LightningElement, api } from 'lwc';
import getUserContactInfo from '@salesforce/apex/EMS_TM_GetmyInfo.getUserContactInfo'; 
import Id from '@salesforce/user/Id';

export default class EMS_RM_myInfodetails extends LightningElement {
   // @api recordId;
    userId = Id;
    employeedata;
    lastname;
    firstname;
    employeeid;
    phonenumber;
    employeedomain;
    employeeindustry;
    employeejobrole;
    employeemail;
    connectedCallback(){
        getUserContactInfo({userId :this.userId}).then( result => {
            console.log('result'+result);
            console.log('result'+JSON.stringify(result));

           const employye = result;
           console.log('employye.LastName'+employye.LastName);

           
           this.lastname = employye.LastName;
           this.firstname = employye.FirstName;
           this.employeeid = employye.EMS_RM_Employee_Id__c;
           this.phonenumber = employye.EMS_Phone_Number__c;
           this.employeedomain = employye.EMS_Domain_Technology__c;
           this.employeejobrole =employye.EMS_RM_Current_Job_Role__c;
           this.employeeindustry = employye.EMS_RM_Industry__c;
           this.employeemail = employye.EMS_RM_Resource_Email_id__c;
        }).catch(err => {
            console.log(err);
        
        });
  
      }
}