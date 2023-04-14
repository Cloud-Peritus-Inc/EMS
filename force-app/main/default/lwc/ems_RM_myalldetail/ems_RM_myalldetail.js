import { LightningElement,track } from 'lwc';
import getUserContactInfo from '@salesforce/apex/EMS_TM_GetmyInfo.getUserContactInfo'; 
import getContactAdditionalInfo from '@salesforce/apex/EMS_TM_GetmyInfo.getContactAdditionalInfo'; 
import Id from '@salesforce/user/Id';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Ems_RM_myalldetail extends LightningElement {
  activeSections = ['personDetail'];  
  
  @track buttonvisiable;
    @track isfullmyinfoModal=false;
   userId = Id;
   contactID;
   additionaldetailId;
   additionalEducation1=false;
   additionalEducation2=false;
   additionalEducation3=false;
   additionalEducation4=false;
   additionalEducation5=false;

   workExperience1=false;
   workExperience2=false;
   workExperience3=false;
   workExperience4=false;
   workExperience5=false;

   levelOfEducation;
   levelOfEducation1;
   levelOfEducation2;
   levelOfEducation3;
   levelOfEducation4;
   levelOfEducation5;
   degree;
   degree1;
   degree2;
   degree3;
   degree4;
   degree5;
   fieldOfStudy;
   fieldOfStudy1;
   fieldOfStudy2;
   fieldOfStudy3;
   fieldOfStudy4;
   fieldOfStudy5;
   institutionName;
   institutionName1;
   institutionName2;
   institutionName3;
   institutionName4;
   institutionName5;
   graduationDate;
   graduationDate1;
   graduationDate2;
   graduationDate3;
   graduationDate4;
   graduationDate5;

   jobTitle;
    jobTitle1;
    jobTitle2;
    jobTitle3;
    jobTitle4;
    jobTitle5;
    fromDate;
    fromDate1;
    fromDate2;
    fromDate3;
    fromDate4;
    fromDate5;
    toDate;
    toDate1;
    toDate2;
    toDate3;
    toDate4;
    toDate5;
    PreviousCompanyName;
    PreviousCompanyName1;
    PreviousCompanyName2;
    PreviousCompanyName3;
    PreviousCompanyName4;
    PreviousCompanyName5;
    PreviousCompanyHrMailId;

    CurrentAddressLine1;
    CurrentAddressLine2;
    currentState;
    currentZip;
    currentCity;

    permanentAddressLine1;
    permanentAddressLine2;
    permanentState;
    permanentZip;
    PermanentCity;

   connectedCallback(){
       getUserContactInfo({userId :this.userId}).then( result => {
        console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);

        this.buttonvisiable =result.visiable_to_edit__c;

        this.CurrentAddressLine1=result.Current_Address_Line_1__c;
        this.CurrentAddressLine2=result.Current_Address_Line_2__c;
        this.currentState=result.EMS_EM_CA_State__c;
        this.currentZip=result.EMS_EM_CA_Zip__c;
        this.permanentAddressLine1=result.Permanent_Address_Line_1__c;
        this.permanentAddressLine2=result.Permanent_Address_Line_2__c;
        this.permanentState=result.EMS_EM_PA_State__c;
        this.permanentZip=result.EMS_EM_PA_Zip__c;
        this.currentCity=result.EMS_EM_CA_City__c;
        this.PermanentCity=result.EMS_EM_PA_City__c;
        
        this.contactID=result.Id;
        console.log('this.contactID==>'+this.contactID);
           console.log('result'+result);
           console.log('result'+JSON.stringify(result));
           
          const employye = result;
          console.log('employye.LastName'+employye.LastName);

          getContactAdditionalInfo({getContactid :this.contactID}).then( results => {
            console.log('additional result.Id==>'+results);
            console.log('additional result.Id==>'+results.Id);
               
            this.additionaldetailId=results.Id

            this.levelOfEducation=results.EMS_EM_Education__c;
            this.levelOfEducation1=results.EMS_EM_Education1__c;
            this.levelOfEducation2=results.EMS_EM_Education2__c;
            this.levelOfEducation3=results.EMS_EM_Education3__c;
            this.levelOfEducation4=results.EMS_EM_Education4__c;
            this.levelOfEducation5=results.EMS_EM_Education5__c;
            this.degree=results.EMS_EM_Degree__c;
            this.degree1=results.EMS_EM_Degree1__c;
            this.degree2=results.EMS_EM_Degree2__c;
            this.degree3=results.EMS_EM_Degree3__c;
            this.degree4=results.EMS_EM_Degree4__c;
            this.degree5=results.EMS_EM_Degree5__c;
            this.fieldOfStudy=results.EMS_EM_Field_of_Study__c;
            this.fieldOfStudy1=results.EMS_EM_Field_of_Study1__c;
            this.fieldOfStudy2=results.EMS_EM_Field_of_Study2__c;
            this.fieldOfStudy3=results.EMS_EM_Field_of_Study3__c;
            this.fieldOfStudy4=results.EMS_EM_Field_of_Study4__c;
            this.fieldOfStudy5=results.EMS_EM_Field_of_Study5__c;
             this.institutionName=results.EMS_EM_IName__c;
             this.institutionName1=results.EMS_EM_IName1__c;
             this.institutionName2=results.EMS_EM_IName2__c;
             this.institutionName3=results.EMS_EM_IName3__c;
             this.institutionName4=results.EMS_EM_IName4__c;
             this.institutionName5=results.EMS_EM_IName5__c;
             this.graduationDate=results.EMS_EM_GDate__c;
             this.graduationDate1=results.EMS_EM_GDate1__c;
             this.graduationDate2=results.EMS_EM_GDate2__c;
             this.graduationDate3=results.EMS_EM_GDate3__c;
             this.graduationDate4=results.EMS_EM_GDate4__c;
             this.graduationDate5=results.EMS_EM_GDate5__c;

             this.jobTitle=results.EMS_EM_Job_Title__c;
            this.jobTitle1=results.EMS_EM_Job_Title1__c;
            this.jobTitle2=results.EMS_EM_Job_Title2__c;
            this.jobTitle3=results.EMS_EM_Job_Title3__c;
            this.jobTitle4=results.EMS_EM_Job_Title4__c;
            this.jobTitle5=results.EMS_EM_Job_Title5__c;
            this.fromDate=results.EMS_EM_From_Date__c;
            this.fromDate1=results.EMS_EM_From_Date1__c;
            this.fromDate2=results.EMS_EM_From_Date2__c;
            this.fromDate3=results.EMS_EM_From_Date3__c;
            this.fromDate4=results.EMS_EM_From_Date4__c;
            this.fromDate5=results.EMS_EM_From_Date5__c;
            this.toDate=results.EMS_EM_To_Date__c;
            this.toDate1=results.EMS_EM_To_Date1__c;
            this.toDate2=results.EMS_EM_To_Date2__c;
            this.toDate3=results.EMS_EM_To_Date3__c;
            this.toDate4=results.EMS_EM_To_Date4__c;
            this.toDate5=results.EMS_EM_To_Date5__c;
            this.PreviousCompanyName=results.EMS_EM_Previous_Company_Name__c;
            this.PreviousCompanyName1=results.EMS_EM_Previous_Company_Name1__c;
            this.PreviousCompanyName2=results.EMS_EM_Previous_Company_Name2__c;
            this.PreviousCompanyName3=results.EMS_EM_Previous_Company_Name3__c;
            this.PreviousCompanyName5=results.EMS_EM_Previous_Company_Name4__c;
            this.PreviousCompanyName5=results.EMS_EM_Previous_Company_Name5__c;
             this.PreviousCompanyHrMailId=results.EMS_EM_Previous_Company_HR_EmailId__c;

             this.additionalEducation1 = this.levelOfEducation1!=null || this.degree1!=null || this.fieldOfStudy1!=null || this.institutionName1!=null || this.graduationDate1!=null ? true:false;
             this.additionalEducation2 = this.levelOfEducation2!=null || this.degree2!=null || this.fieldOfStudy2!=null || this.institutionName2!=null || this.graduationDate2!=null ? true:false;
             this.additionalEducation3 = this.levelOfEducation3!=null || this.degree3!=null || this.fieldOfStudy3!=null || this.institutionName3!=null || this.graduationDate3!=null ? true:false;
             this.additionalEducation4=  this.levelOfEducation4!=null || this.degree4!=null || this.fieldOfStudy4!=null || this.institutionName4!=null || this.graduationDate4!=null ? true:false;
             this.additionalEducation5 = this.levelOfEducation5!=null || this.degree5!=null || this.fieldOfStudy5!=null || this.institutionName5!=null || this.graduationDate5!=null ? true:false;

             this.workExperience1= this.jobTitle1!=null || this.fromDate1!=null || this.toDate1!=null || this.PreviousCompanyName1!=null ? true:false;
             this.workExperience2= this.jobTitle2!=null || this.fromDate2!=null || this.toDate2!=null || this.PreviousCompanyName2!=null ? true:false;
             this.workExperience3= this.jobTitle3!=null || this.fromDate3!=null || this.toDate3!=null || this.PreviousCompanyName3!=null ? true:false;
             this.workExperience4= this.jobTitle4!=null || this.fromDate4!=null || this.toDate4!=null || this.PreviousCompanyName4!=null ? true:false;
             this.workExperience5=this.jobTitle5!=null || this.fromDate5!=null || this.toDate5!=null || this.PreviousCompanyName5!=null ? true:false;
           }).catch(err => {
               console.log(err);
           });

       }).catch(err => {
           console.log(err);
       
       });

      
     }


     renderedCallback(){
      if(this.mstatus=='Married'){
        this.marialinfo=true;
      }else{
        this.marialinfo=false;
      }
     }

     mstatus;
     marialinfo;

     changemstatues(event){
        this.mstatus = event.target.value;

      if(this.mstatus=='Married'){
        this.marialinfo=true;
      }else{
        this.marialinfo=false;
      }
     }


     Handlersuccess(){
        
        }

        Handlererror(){
            console.log('Error==>'+Error)
            const event = new ShowToastEvent({
                    title: 'error',
                    variant:'error',
                    message: 'something error...',
                });
                this.dispatchEvent(event);
        }

        
       

    
    fullmyInfopage(){
        this.isfullmyinfoModal=true;
    }

    hideModalBox() {  
        this.isfullmyinfoModal=false;
    }

   

    AddressCheckboxChange(event){
    
      this.inputcheckboxValue = event.target.checked ? 'Checked' : 'Unchecked';
      console.log('this.inputcheckboxValue-->',this.inputcheckboxValue);
  
      if(this.inputcheckboxValue=='Checked'){
        console.log('address checked')
        this.permanentAddressLine1=this.CurrentAddressLine1;
        this.padrressline2=this.cadrressline2;
        this.pastate=this.castate;
        this.pacity=this.cacity;
        this.pazip=this.cazip;
    }else{
      console.log('address unchecked')
        this.permanentAddressLine1='';
        this.padrressline2='';
        this.pastate='';
        this.pacity='';
        this.pazip='';
    }   
  }

  accountId;
  handleAccountSuccess(event) {
    this.accountId = event.detail.id;
    console.info("Account is saved, new id is: " + this.accountId);
   
    this.template
      .querySelectorAll('lightning-record-edit-form[data-id="contactForm"]')
      .forEach((form) => {
        form.submit();
      });
  }

  HandlerSubmit(event){
  /*  this.template.querySelectorAll('lightning-input-field[data-id="visiabletoedit"]').forEach((field) => {
      field.value = true;
    });*/
    //event.preventDefault();
  /*  const fields = event.detail.fields;
    fields.visiable_to_edit__c = true;  
    this.template.querySelector('lightning-record-edit-form[data-id="accountForm"]').submit(fields);*/
}

handleContactSaveSuccess() {
  const event = new ShowToastEvent({
    title: 'Success!',
    variant: 'success',
    message: 'updated successfully...',
});
this.dispatchEvent(event);
this.isfullmyinfoModal=false;
this.buttonvisiable=true;
}

handleSave(event) {
  console.info("save");
  this.template.querySelectorAll('lightning-input-field[data-id="visiabletoedit"]').forEach((field) => {
    field.value = true;
  });
  let accountForm = this.template.querySelector('lightning-record-edit-form[data-id="accountForm"]');
  accountForm.submit();
}
}