import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import fetchOnboardingRecords from '@salesforce/apex/ProgressBarApplicantController.fetchOnboardingRecords';
import fetchAdditionalDetailRecords from '@salesforce/apex/ProgressBarApplicantController.fetchAdditionalDetailRecords';
import { getRecord} from 'lightning/uiRecordApi';
import PersonalDetails from '@salesforce/schema/EMS_EM_Onboarding_Request__c.Personal_Details_Value_Filled__c'
import IdentifyDetails from '@salesforce/schema/EMS_EM_Onboarding_Request__c.Identify_Details_Value_Filled__c'
import AddressDetails from '@salesforce/schema/EMS_EM_Onboarding_Request__c.Address_Details_Value_Filled__c'
import OtherCertifications from '@salesforce/schema/EMS_EM_Onboarding_Request__c.Other_Certifications_Value_Filled__c'
import WorkDetails from '@salesforce/schema/ems_EM_Additional_Detail__c.Work_Details_Filled__c'
import EducationDetails from '@salesforce/schema/ems_EM_Additional_Detail__c.Education_Details_Filled__c'

export default class ProgressBarApplicant extends LightningElement {
  
  @api recordId;
  personalDetailsFilled;
  identifyDetailsFilled;
  addressDetailsFilled;
  certificationDetailsFilled;
  workDetailsFilled;
  educationDetailsFilled;
  error;
  progressValue;

  /*@wire(getRecord, { recordId: '$recordId', fields: [PersonalDetails, IdentifyDetails, AddressDetails, OtherCertifications]}) 
    userDetails({error, data}) {
        if (data) {
            this.personalDetailsFilled = data.fields.Personal_Details_Value_Filled__c.value;
            this.identifyDetailsFilled = data.fields.Identify_Details_Value_Filled__c.value;
            this.addressDetailsFilled = data.fields.Address_Details_Value_Filled__c.value;
            this.certificationDetailsFilled = data.fields.Other_Certifications_Value_Filled__c.value;
        } else if (error) {
            console.error('error => '+ error);
            this.error = error ;
        }
    }*/

   /* @wire(fetchAdditionalDetailRecords, { additionalDetailId: '$recordId', fields: [WorkDetails, EducationDetails]}) 
    additionalDetails({error, data}) {
        if (data) {
            this.workDetailsFilled = data[0].Work_Details_Filled__c;
            this.educationDetailsFilled = data[0].Education_Details_Filled__c;
        } else if (error) {
            console.error('error mg=> '+ JSON.stringify(error));
            this.error = JSON.stringify(error);
        }
    }*/
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference);
          this.recordId = currentPageReference.attributes.recordId || null;

       }
    }
    userDetails(){
        fetchOnboardingRecords({onboardingId: this.recordId})
            .then((result) => {
                this.personalDetailsFilled = result[0].Personal_Details_Value_Filled__c;
                this.identifyDetailsFilled = result[0].Identify_Details_Value_Filled__c;
                this.addressDetailsFilled = result[0].Address_Details_Value_Filled__c;
                this.certificationDetailsFilled = result[0].Other_Certifications_Value_Filled__c;
                console.log('personalDetailsFilled ==> '+this.personalDetailsFilled);
                this.additionalDetails();
            })
            .catch((error) => {
                this.error = error;
            });
    }

    additionalDetails(){
        fetchAdditionalDetailRecords({ additionalDetailId: this.recordId })
            .then((result) => {
                console.log('Result ==> '+result);
                this.workDetailsFilled = result[0].Work_Details_Filled__c;
                console.log('workDetailsFilled ==> '+this.workDetailsFilled);
                this.educationDetailsFilled = result[0].Education_Details_Filled__c;
                console.log('educationDetailsFilled ==> '+this.educationDetailsFilled);
                this.progressbarStatus();
            })
            .catch((error) => {
                this.error = error;
            });
    }


    connectedCallback() {
        this.userDetails();
    }

    progressbarStatus(){
        if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.educationDetailsFilled === true){
                this.progressValue = 100;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.educationDetailsFilled === false){
                this.progressValue = 83.334;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === true && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                this.progressValue = 66.668;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === false && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                this.progressValue = 50.002;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === false && 
            this.certificationDetailsFilled === false && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                console.log('Inside condition ==');
                this.progressValue = 33.336;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === false && this.addressDetailsFilled === false && 
            this.certificationDetailsFilled === false && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                this.progressValue = 16.666;
        }
    }

}