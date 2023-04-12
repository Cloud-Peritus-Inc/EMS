import { LightningElement, api, wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import fetchOnboardingRecords from '@salesforce/apex/ProgressBarApplicantController.fetchOnboardingRecords';
import { updateRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/schema/EMS_EM_Onboarding_Request__c.Id';
import Progress_Value__c from '@salesforce/schema/EMS_EM_Onboarding_Request__c.Progress_Value__c';

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
  @track progressValue = 0;



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
                this.progressValueFromDB = result[0].Progress_Value__c;
                console.log('personalDetailsFilled ==> '+this.personalDetailsFilled);
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
        /*if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.educationDetailsFilled === true){
                 this.progressValue = this.progressValue + 16.666;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === true && this.workDetailsFilled === true && this.educationDetailsFilled === false){
                 this.progressValue = this.progressValue + 16.666;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === true && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                 this.progressValue = this.progressValue + 16.666;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === true && 
            this.certificationDetailsFilled === false && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                 this.progressValue = this.progressValue + 16.666;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === true && this.addressDetailsFilled === false && 
            this.certificationDetailsFilled === false && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                console.log('Inside condition ==');
                 this.progressValue = this.progressValue + 16.666;;
        }else if(this.personalDetailsFilled === true && this.identifyDetailsFilled === false && this.addressDetailsFilled === false && 
            this.certificationDetailsFilled === false && this.workDetailsFilled === false && this.educationDetailsFilled === false){
                 this.progressValue = this.progressValue + 16.666;
        }*/

         if(this.personalDetailsFilled === true || this.identifyDetailsFilled === true || this.addressDetailsFilled === true || 
             this.certificationDetailsFilled === true || this.workDetailsFilled === true || this.educationDetailsFilled === true){
                //  var test1 = this.template.querySelector('lightning-progress-bar');
                  //alert(Number(this.progressValueFromDB) + Number(16.666));
                this.progressValue = Number(this.progressValueFromDB) + Number(16.666);
             }
              const fields = {};
                fields[Id.fieldApiName] = this.recordId;
                fields[Progress_Value__c.fieldApiName] =  this.progressValue ;
                const recordInput = { fields };
                            updateRecord(recordInput)
                .then(() => {
                })
                .catch(error => {
                  console.log(error);
                });


    }

}