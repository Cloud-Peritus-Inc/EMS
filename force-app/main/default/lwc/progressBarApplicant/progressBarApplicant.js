import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import fetchOnboardingRecords from '@salesforce/apex/ProgressBarApplicantController.fetchOnboardingRecords';


export default class ProgressBarApplicant extends LightningElement {
  
  @api recordId;
  personalDetailsFilled;
  identifyDetailsFilled;
  addressDetailsFilled;
  certificationDetailsFilled;
  workDetailsFilled;
  educationDetailsFilled;
  error;
  @track progressValueFromDB;
  @track progressValue;



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
                this.workDetailsFilled = result[0].Work_Details_Filled__c;
                this.educationDetailsFilled = result[0].Education_Details_Filled__c;
                //this.progressValueFromDB = result[0].Progress_Value__c;
                console.log('personalDetailsFilled ==> '+this.personalDetailsFilled);
                this.progressbarStatus();
            })
            .catch((error) => {
                this.error = error;
                console.log('Error=> '+ this.error);
            });
    }

    connectedCallback() {
        this.userDetails();
    }

    progressbarStatus(){      
        
        if((this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true)){
            this.progressValue = 100;
            console.log('progressValue => '+this.progressValue);
        }
        else if((this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true) ||
           (this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.workDetailsFilled === true) ||
           
           (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true) ||
           (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.personalDetailsFilled === true) ||
           
           (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true) ||
           (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.identifyDetailsFilled === true) ||
           
           (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true) ||
           (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.addressDetailsFilled === true) ||
           
           (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true) ||
           (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.educationDetailsFilled === true) ||
           
           (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true) ||
           (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.certificationDetailsFilled === true)){
            this.progressValue = 83.334;
            console.log('progressValue => '+this.progressValue);
        }

        else if((this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true) ||
           (this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.certificationDetailsFilled === true) ||
           (this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.workDetailsFilled === true) ||
           
           (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true) ||
           (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.workDetailsFilled === true) ||
           (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.personalDetailsFilled === true) ||
           
           (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true) ||
           (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.personalDetailsFilled === true) ||
           (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.identifyDetailsFilled === true) ||
           
           (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true) ||
           (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.workDetailsFilled === true) ||
           (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true) ||
           
           (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true) ||
           (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.addressDetailsFilled === true) ||
           (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true && this.educationDetailsFilled === true) ||
           
           (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true) ||
           (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.educationDetailsFilled === true) ||
           (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.certificationDetailsFilled === true)){
               this.progressValue = 66.668;
               console.log('progressValue => '+this.progressValue);
        }
        else if((this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true) || 
            (this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.educationDetailsFilled === true) || 
            (this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.certificationDetailsFilled === true) || 
            (this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.workDetailsFilled === true) ||
            (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.educationDetailsFilled === true) ||
            (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.certificationDetailsFilled === true) ||
            (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.workDetailsFilled === true) ||
            (this.identifyDetailsFilled === true && this.addressDetailsFilled === true && this.personalDetailsFilled === true) ||
            (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.certificationDetailsFilled === true) ||
            (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.workDetailsFilled === true) ||
            (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.personalDetailsFilled === true) ||
            (this.addressDetailsFilled === true && this.educationDetailsFilled === true && this.identifyDetailsFilled === true) ||
            (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.workDetailsFilled === true) ||
            (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.personalDetailsFilled === true) ||
            (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.identifyDetailsFilled === true) ||
            (this.educationDetailsFilled === true && this.certificationDetailsFilled === true && this.addressDetailsFilled === true) ||
            (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.personalDetailsFilled === true) ||
            (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.identifyDetailsFilled === true) ||
            (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.addressDetailsFilled === true) ||
            (this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.educationDetailsFilled === true) ||
            (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.identifyDetailsFilled === true) ||
            (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.addressDetailsFilled === true) ||
            (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.educationDetailsFilled === true) ||
            (this.workDetailsFilled === true && this.personalDetailsFilled === true && this.certificationDetailsFilled === true)
            ){
                this.progressValue = 50.002;
                console.log('progressValue => '+this.progressValue);
        }
        else if((this.personalDetailsFilled === true && this.identifyDetailsFilled === true) || (this.personalDetailsFilled === true && this.addressDetailsFilled === true)
        || (this.personalDetailsFilled === true && this.educationDetailsFilled === true) || (this.personalDetailsFilled === true && this.certificationDetailsFilled === true)
        || (this.personalDetailsFilled === true && this.workDetailsFilled === true) || (this.identifyDetailsFilled === true && this.addressDetailsFilled === true) 
        || (this.identifyDetailsFilled === true && this.educationDetailsFilled === true) || (this.identifyDetailsFilled === true && this.certificationDetailsFilled === true)
        || (this.identifyDetailsFilled === true && this.workDetailsFilled === true) || (this.addressDetailsFilled === true && this.educationDetailsFilled === true)
        || (this.addressDetailsFilled === true && this.certificationDetailsFilled === true) || (this.addressDetailsFilled === true && this.workDetailsFilled === true)
        || (this.educationDetailsFilled === true && this.certificationDetailsFilled === true) || (this.educationDetailsFilled === true && this.workDetailsFilled === true)
        || (this.certificationDetailsFilled === true && this.workDetailsFilled === true)){
            this.progressValue = 33.336;
            console.log('progressValue => '+progressValue);
        }
        else if(this.personalDetailsFilled === true || this.identifyDetailsFilled === true || this.addressDetailsFilled === true || 
           this.certificationDetailsFilled === true || this.workDetailsFilled === true || this.educationDetailsFilled === true){
               console.log('progressValue => '+this.progressValue);
                 this.progressValue = 16.666;
        }

    }

}