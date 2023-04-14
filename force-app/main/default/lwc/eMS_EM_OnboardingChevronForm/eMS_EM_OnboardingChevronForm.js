import { LightningElement,track,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createGuest from '@salesforce/apex/EMS_EM_CreationOnboard.createGuest';
//import updateGuest from '@salesforce/apex/EMS_EM_CreationOnboard.updateGuest';

import sendEmail from '@salesforce/apex/EMS_EM_CreationOnboard.sendEmail';

import getonOnboardformInfo from '@salesforce/apex/EMS_EM_CreationOnboard.getonOnboardformInfo';
   
    const isAllowedKeyCode = keyCode => {
    if(keyCode === 8 // backspace
        || keyCode === 9 // tab
        || keyCode === 16 // shift
        || keyCode === 35 // end
        || keyCode === 36 // home
        || keyCode === 37 // left arrow
        || keyCode === 39 // right arrow
        || keyCode === 46 // delete
        ) {
        return true;
    }
    return false;
}

const maskAccountNumber = value => {

    if(value === undefined || value === null || value === "") {
        return value;
    }

    let v = value.replace(/\D/g,'');
    let str = v.replace(/\d(?=\d{4})/g, "*");
console.log('sdfghn'+str)
    return str;
}

const maskPanNumber = value => {

    if(value === undefined || value === null || value === "") {
        return value;
    }

    //let v = value.replace(/\W/g,'');
    let str = value.replace(/\d(?=\d{0})/g,"*");
console.log('sdfghn'+str)
    return str;
}

const maskPassportNumber = value => {

    if(value === undefined || value === null || value === "") {
        return value;
    }

    //let v = value.replace(/\W/g,'');
    let str = value.replace(/\w(?=\w{4})/g,"*");
console.log('sdfghn'+str)
    return str;
}


export default class EMS_EM_OnboardingChevronForm extends LightningElement {
    @track selectedStep = 'Step1';
    showPersonaldetail = true;
    showaddressdetail=false;
    showeducationdetails=false;
    showWorkExperiance=false;
    showSubmitted=false;
    getonboardId


//Aadhar Number
    @api aadhaarNo;
    @api actualAadharNumber;

handleAadharNumberFocusIn(event) {
        this.aadhaarNo = this.actualAadharNumber;
    }

    handleAadharNumberChange(event) {
        let value = event.detail.value;
        this.actualAadharNumber = value.replace(/\D/g,'');
        this.aadhaarNo = value;
        event.target.value = value;
    }

    handleAadharNumberFocusOut(event) {

        let newValue = maskAccountNumber(this.aadhaarNo);
        this.aadhaarNo = newValue;

        const evt = new CustomEvent("card_account_number_change", {
            detail: {actualAadharNumber: this.actualAadharNumber, aadhaarNo: this.aadhaarNo}
            , bubbles: true
            , composed: true
        });
        this.dispatchEvent(evt);

    }
    handleAadharNumberKeyDown(event) {
        if(isAllowedKeyCode(event.keyCode)) {
            return;
        }

        if(!event.key.match(/[0-9]/)) {
            event.preventDefault();
        }
    }

    handleFirstLastNameKeyDown(event) {
        if(isAllowedKeyCode(event.keyCode)) {
            return;
        }

        if(!event.key.match(/[A-Z a-z._-]/)) {
            event.preventDefault();
        }
    }
  // PAN Number
    @api panNo;
    @api actualPanNumber;

    handlePanNumberFocusIn(event){
        this.panNo = this.actualPanNumber;
        console.log('actualPanNumber',+this.actualPanNumber);
    }

    PANNumber(event){
        let value = event.detail.value;
        this.actualPanNumber = value.replace(/\W/g,'');
        this.panNo = value;
        event.target.value = value;
    }

    handlePanNumberFocusOut(event){
      let newValue = maskPanNumber(this.panNo);
        this.panNo = newValue;

        const evt = new CustomEvent("card_account_number_change", {
            detail: {actualPanNumber: this.actualPanNumber, panNo: this.panNo}
            , bubbles: true
            , composed: true
        });
        this.dispatchEvent(evt);
    }

    //Passport Number
    @api pNum;
    @api actualPassportNumber;

    handlePassportNumberFocusIn(event){
        this.pNum = this.actualPassportNumber;
        console.log('actualPassportNumber',+this.actualPassportNumber);
    }


    PassportNumber(event){
        let value = event.detail.value;
        this.actualPassportNumber = value.replace(/\W/g,'');
        console.log('actualPassportNumber',+this.actualPassportNumber);
        this.pNum = value;
        event.target.value = value;
    }

    handlePassportNumberFocusOut(event){
      let newValue = maskPassportNumber(this.pNum);
        this.pNum = newValue;

        const evt = new CustomEvent("card_account_number_change", {
            detail: {actualPassportNumber: this.actualPassportNumber, pNum: this.pNum}
            , bubbles: true
            , composed: true
        });
        this.dispatchEvent(evt);
    }
    //------------End
    
    connectedCallback(){
        this.selectedStep = 'Step1';
          const queryString = window.location.search;
          const urlParams = new URLSearchParams(queryString);
          this.personalemail = urlParams.get('emailid');
          console.log('emailid==>',this.personalemail);

          getonOnboardformInfo({onboardEmailid: this.personalemail})
          .then(result => {
            console.log('result-->',result);
            console.log('result'+JSON.stringify(result));
            const employye = result;
            this.getonboardId =employye.Id;
            console.log('employye'+employye);
            if(employye !=null){
              this.readonlyfield=true;

              this.firstName = employye.EMS_EM_First_Name__c;
              this.lastName=employye.EMS_EM_Last_Name__c;
              this.fName=employye.EMS_EM_Father__c;
              this.mName=employye.EMS_EM_Mother__c;   
              this.gen=employye.EMS_EM_Gender__c;
              this.ph=employye.Phone_Number__c;
              this.dob=employye.EMS_EM_DOB__c;
              this.mstatus=employye.EMS_EM_Mstatus__c;
              this.spouse=employye.EMS_EM_Spouse__c;
              this.dow=employye.EMS_EM_DOW__c;
              this.bg=employye.EMS_EM_BG__c;
              this.aadhaarNo=employye.EMS_EM_AadhaarNo__c;
              this.pfn=employye.EMS_EM_UAN_Number__c;
              this.panNo=employye.EMS_EM_PanNo__c;
              this.pNum=employye.EMS_EM_PassportNo__c;
              this.nation=employye.EMS_EM_Nationality__c;
              this.cd=employye.EMS_EM_Current_Address__c;
              this.altphone=employye.EMS_EM_Phone_Number__c;
              this.previouscompanyname=employye.EMS_EM_Previous_Company_Name__c;
              this.castate=employye.EMS_EM_CA_State__c;
              this.pastate=employye.EMS_EM_PA_State__c;
              this.cacity=employye.EMS_EM_CA_City__c;
              this.pacity=employye.EMS_EM_PA_City__c;
              this.cazip=employye.EMS_EM_CA_Zip__c;
              this.pazip=employye.EMS_EM_PA_Zip__c;
              this.cadrressline1=employye.Current_Address_Line_1__c;
              this.cadrressline2=employye.Current_Address_Line_2__c;
              this.padrressline1=employye.Permanent_Address_Line_1__c;
              this.padrressline2=employye.Permanent_Address_Line_2__c;
              this.Certificationname1=employye.EMS_EM_Certification_Name__c;
              this.Certificationname2=employye.EMS_EM_Certification_Name1__c;
              this.Certificationname3=employye.EMS_EM_Certification_Name2__c;
              this.Certificationname4=employye.EMS_EM_Certification_Name3__c;
              this.Certificationname5=employye.EMS_EM_Certification_Name4__c;
              this.Certificationname6=employye.EMS_EM_Certification_Name5__c;
              this.Certificationname7=employye.EMS_EM_Certification_Name6__c;
              this.Certificationname8=employye.EMS_EM_Certification_Name7__c;
              this.Certificationname9=employye.EMS_EM_Certification_Name8__c;
              this.Certificationname10=employye.EMS_EM_Certification_Name9__c;
              this.Certificationname11=employye.EMS_EM_Certification_Name10__c;
              this.Certificationname12=employye.EMS_EM_Certification_Name11__c;
              this.Certificationname13=employye.EMS_EM_Certification_Name12__c;
              this.Certificationname14=employye.EMS_EM_Certification_Name13__c;
              this.Certificationname15=employye.EMS_EM_Certification_Name14__c;
              this.Certificationname16=employye.EMS_EM_Certification_Name15__c;
              this.Certificationname17=employye.EMS_EM_Certification_Name16__c;
              this.Certificationname18=employye.EMS_EM_Certification_Name17__c;
              this.Certificationname19=employye.EMS_EM_Certification_Name18__c;
              this.Certificationname20=employye.EMS_EM_Certification_Name19__c;
         

              this.levleofedu=employye.EMS_EM_Education__c;
              this.fieldOfStudy=employye.EMS_EM_Field_of_Study__c;
              this.instutionname=employye.EMS_EM_IName__c;
              this.graduationDate=employye.EMS_EM_GDate__c;
              this.degree=employye.EMS_EM_Degree__c;
              
              this.levleofedu1=employye.EMS_EM_Education1__c;
              this.fieldOfStudy1=employye.EMS_EM_Field_of_Study1__c;
              this.instutionname1=employye.EMS_EM_IName1__c;
              this.graduationDate1=employye.EMS_EM_GDate1__c;
              this.degree1=employye.EMS_EM_Degree1__c;
              
              this.levleofedu2=employye.EMS_EM_Education2__c;
              this.fieldOfStudy2=employye.EMS_EM_Field_of_Study2__c;
              this.instutionname2=employye.EMS_EM_IName2__c;
              this.graduationDate2=employye.EMS_EM_GDate2__c;
              this.degree2=employye.EMS_EM_Degree2__c;
              
              this.levleofedu3=employye.EMS_EM_Education3__c;
              this.fieldOfStudy3=employye.EMS_EM_Field_of_Study3__c;
              this.instutionname3=employye.EMS_EM_IName3__c;
              this.graduationDate3=employye.EMS_EM_GDate3__c;
              this.degree3=employye.EMS_EM_Degree3__c;
              
              this.levleofedu4=employye.EMS_EM_Education4__c;
              this.fieldOfStudy4=employye.EMS_EM_Field_of_Study4__c;
              this.instutionname4=employye.EMS_EM_IName4__c;
              this.graduationDate4=employye.EMS_EM_GDate4__c;
              this.degree4=employye.EMS_EM_Degree4__c;

              this.levleofedu5=employye.EMS_EM_Education5__c;
              this.fieldOfStudy5=employye.EMS_EM_Field_of_Study5__c;
              this.instutionname5=employye.EMS_EM_IName5__c;
              this.graduationDate5=employye.EMS_EM_GDate5__c;
              this.degree5=employye.EMS_EM_Degree5__c;

              this.jobtitle0=employye.EMS_EM_Job_Title__c;
              this.fromdate0=employye.EMS_EM_From_Date__c;
              this.todate0=employye.EMS_EM_To_Date__c;
              this.previouscompanyname0=employye.EMS_EM_Previous_Company_Name__c;
              this.previouscomemailid=employye.EMS_EM_Previous_Company_HR_EmailId__c;

              if(this.jobtitle0 !=null || this.fromdate0 != null || this.todate0 !=null ||
                this.previouscompanyname0 !=null || this.previouscomemailid !=null){
                       this.showExperienceyouhave=true;
             }

              this.jobtitle1=employye.EMS_EM_Job_Title1__c;
              this.fromdate1=employye.EMS_EM_From_Date1__c;
              this.todate1=employye.EMS_EM_To_Date1__c;
              this.previouscompanyname1=employye.EMS_EM_Previous_Company_Name1__c;

              this.jobtitle2=employye.EMS_EM_Job_Title2__c;
              this.fromdate2=employye.EMS_EM_From_Date2__c;
              this.todate2=employye.EMS_EM_To_Date2__c;
              this.previouscompanyname2=employye.EMS_EM_Previous_Company_Name2__c;

              this.jobtitle3=employye.EMS_EM_Job_Title3__c;
              this.fromdate3=employye.EMS_EM_From_Date3__c;
              this.todate3=employye.EMS_EM_To_Date3__c;
              this.previouscompanyname3=employye.EMS_EM_Previous_Company_Name3__c;

              this.jobtitle4=employye.EMS_EM_Job_Title4__c;
              this.fromdate4=employye.EMS_EM_From_Date4__c;
              this.todate4=employye.EMS_EM_To_Date4__c;
              this.previouscompanyname4=employye.EMS_EM_Previous_Company_Name4__c;

              this.jobtitle5=employye.EMS_EM_Job_Title5__c;
              this.fromdate5=employye.EMS_EM_From_Date5__c;
              this.todate5=employye.EMS_EM_To_Date5__c;
              this.previouscompanyname5=employye.EMS_EM_Previous_Company_Name5__c;       
            }
        })
        .catch(error => {
            this.error = error;
            console.log('this.error-->'+JSON.stringify(this.error));
        });
    }

    selectStep1() {
        this.selectedStep = 'Step1';
        this.showPersonaldetail = true;
        this.showaddressdetail=false;
        this.showeducationdetails=false;
        this.showWorkExperiance=false;
        this.showSubmitted=false;
    }

    selectStep2() { 
if(  this.readonlyfield!=true){
  if(  this.firstName !=null && this.firstName !='' && this.lastName !=null && this.lastName !=''
     && this.fName !=null && this.fName !='' && this.mName !=null &&  this.mName !='' && this.ph.length==10  && 
     this.nation !=null && this.nation !='' && this.dob !=null &&
    this.mstatus !=null && this.personalemail != null && this.aadhaarNo.length==12 && this.panNo !=null && this.gen !=null &&
    this.fileName!=null && this.fileName1!=null && this.fileName2!=null){ 
        
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy +'-'+ mm +'-'+dd;
       console.log("this.dob", this.dob);
       console.log("this.dow", this.dow);
       console.log("this.graduationDate", this.graduationDate);

        console.log("today", today);
        if(this.dob >= today ){
            console.log("I am in if");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please Enter correct date of birth',
                    variant: 'error',
                }),
            );
        }else if(this.dow >= today){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please enter correct Date of Wedding',
                    variant: 'error',
                }),
            );
        }
       
       
        else{
            this.selectedStep = 'Step2';
            this.showaddressdetail=true;
            this.showPersonaldetail = false;
            this.showeducationdetails=false;
            this.showWorkExperiance=false;
            this.showSubmitted=false;
        }
      
   
   }else{
    const even = new ShowToastEvent({
      message: 'Please complete required field & avoid invalid data!',
      variant: 'error'
  });
  this.dispatchEvent(even);
  }

}
else{
  this.selectedStep = 'Step2';
    this.showaddressdetail=true;
    this.showPersonaldetail = false;
    this.showeducationdetails=false;
    this.showWorkExperiance=false;
    this.showSubmitted=false;
}
       }



    selectStep3(){

        if(  this.readonlyfield!=true){
          const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
          .reduce((validSoFar, inputField) => {
              inputField.reportValidity();
              return validSoFar && inputField.checkValidity();
          }, true);
      if (isInputsCorrect) {
       if( this.pazip.length==6 && this.cazip.length==6){
        this.selectedStep = 'Step3'; 
        this.showeducationdetails=true;
        this.showaddressdetail=false;
        this.showPersonaldetail = false;
        this.showWorkExperiance=false;
        this.showSubmitted=false;
       }else{
        const even = new ShowToastEvent({
          message: 'Invalid zip!',
          variant: 'error'
      });
      this.dispatchEvent(even);
       }
      

      }else{
        const even = new ShowToastEvent({
          message: 'Please complete required field & avoid invalid data!!',
          variant: 'error'
      });
      this.dispatchEvent(even);
      }
       
        }else{
          this.selectedStep = 'Step3'; 
          this.showeducationdetails=true;
          this.showaddressdetail=false;
          this.showPersonaldetail = false;
          this.showWorkExperiance=false;
          this.showSubmitted=false;
          }  
        
      }
  
  selectStep4(){
    if(  this.readonlyfield!=true){
      const isInputsCorrect = [...this.template.querySelectorAll('lightning-input,lightning-combobox')]
      .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
      }, true);
  if (isInputsCorrect) {
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy +'-'+ mm +'-'+dd;
   console.log("this.graduationDate", this.graduationDate);
   if(this.graduationDate >=today){
     this.dispatchEvent(
       new ShowToastEvent({
           title: 'Error',
           message: 'Please enter correct Graduation Date',
           variant: 'error',
       }),
   );
   }
   else if(this.graduationDate1 >=today){
    this.dispatchEvent(
      new ShowToastEvent({
          title: 'Error',
          message: 'Please enter correct Graduation Date',
          variant: 'error',
      }),
  );
  }
  else if(this.graduationDate2 >=today){
    this.dispatchEvent(
      new ShowToastEvent({
          title: 'Error',
          message: 'Please enter correct Graduation Date',
          variant: 'error',
      }),
  );
  }
  else if(this.graduationDate3 >=today){
    this.dispatchEvent(
      new ShowToastEvent({
          title: 'Error',
          message: 'Please enter correct Graduation Date',
          variant: 'error',
      }),
  );
  }
  else if(this.graduationDate4 >=today){
    this.dispatchEvent(
      new ShowToastEvent({
          title: 'Error',
          message: 'Please enter correct Graduation Date',
          variant: 'error',
      }),
  );
  }
  else if(this.graduationDate5 >=today){
    this.dispatchEvent(
      new ShowToastEvent({
          title: 'Error',
          message: 'Please enter correct Graduation Date',
          variant: 'error',
      }),
  );
  }
   else if(this.fileName3==null){
      const even = new ShowToastEvent({
        message: 'Please upload certificate!!',
        variant: 'error'
    });
    this.dispatchEvent(even);
    }else if(this.addmoreempfields==true && this.fileName4==null){
      const even = new ShowToastEvent({
        message: 'Please upload certificate!!',
        variant: 'error'
    });
    this.dispatchEvent(even);
    }else if(this.extraempfields==true && this.fileName5==null){
      const even = new ShowToastEvent({
        message: 'Please upload certificate!!',
        variant: 'error'
    });
    this.dispatchEvent(even);
    }else if(this.extraempfields1==true && this.fileName6==null){
      const even = new ShowToastEvent({
        message: 'Please upload certificate!!',
        variant: 'error'
    });
    this.dispatchEvent(even);
    }else if(this.extraempfields2==true && this.fileName7==null){
      const even = new ShowToastEvent({
        message: 'Please upload certificate!!',
        variant: 'error'
    });
    this.dispatchEvent(even);
    }else if(this.extraempfields3==true && this.fileName8==null){
      const even = new ShowToastEvent({
        message: 'Please upload certificate!!',
        variant: 'error'
    });
    this.dispatchEvent(even);
    }
    else{
      this.selectedStep = 'Step4'; 
      this.showWorkExperiance=true;
      this.showaddressdetail=false;
      this.showPersonaldetail = false;
      this.showeducationdetails=false;
      this.showSubmitted=false;
  }
  }else{
    const even = new ShowToastEvent({
      message: 'Please complete required field & avoid invalid data!!',
      variant: 'error'
  });
  this.dispatchEvent(even);
  }
   
    }else{
      this.selectedStep = 'Step4'; 
      this.showWorkExperiance=true;
      this.showaddressdetail=false;
      this.showPersonaldetail = false;
      this.showeducationdetails=false;
      this.showSubmitted=false;
      }      
        }

    selectStep5(){ 
        this.selectedStep = 'Step5';  
        this.showSubmitted=true;
        this.showaddressdetail=false;
        this.showPersonaldetail = false;
        this.showeducationdetails=false;
        this.showWorkExperiance=false;
    } 


        @track inputName

        inputhandler(event){
            this.inputName=event.target.value;
        }

 //personal details code here...
 get acceptedFormats() {
    return ['.pdf', '.png','.jpg','.jpeg'];
}

  @track firstName ;
  @track lastName ;
  @track pfn;
  @track fName;
  @track mName;
  @track gen;
  @track ph;
  @track dob;
  @track mstatus;
  @track spouse;
  @track dow;
  @track bg;
  @track aadhaarNo;
  @track panNo;
  @track pNum;
  @track nation;
  @track cd;
  altphone;
   personalemail;
    previouscompanyname;
    previouscompanyemailid;
  
  message;
  error;
 
  maritualS = [
      { label: 'Married', value: 'Married' },
      { label: 'Single', value: 'Single' }
     
    ];
    
    BloodG = [
      { label: 'A RhD positive (A+)', value:'A RhD positive (A+)'},
      { label: 'A RhD negative (A-)', value:'A RhD negative (A-)'},
      { label: 'B RhD positive (B+)', value:'B RhD positive (B+)'},
      { label: 'B RhD negative (B-)', value:'B RhD negative (B-)'},
      { label: 'O RhD positive (O+)', value:'O RhD positive (O+)'},
      { label: 'O RhD negative (O-)', value:'O RhD negative (O-)'},
      { label: 'AB RhD positive (AB+)', value:'AB RhD positive (AB+)'},
      { label: 'AB RhD negative (AB-)', value:'AB RhD negative (AB-)'},
      
      
    ];

    Gendervalue = [
      { label: 'Male', value:'Male'},
      { label: 'Female', value:'Female'},
      { label: 'Other', value:'Other'},
    ];

    LevelofEducationValue = [
      {label:'Std X/SSC',value:'Std X/SSC'},
      {label:'Std XII/HSC	',value:'Std XII/HSC'},
      { label: 'Graduate', value:'Graduate'},
      { label: 'Post Graduate', value:'Post Graduate'}
      
      
    ];
  
    PreviousPage(){
        this.selectedStep = 'Step2';
        this.showaddressdetail=false;
        this.showPersonaldetail = true;
        this.showeducationdetails=false;
        this.showWorkExperiance=false;
        this.showSubmitted=false; 
    }
  FatherName(event){
      this.fName = event.target.value; 
     // window.console.log(this.getAccountRecord.EMS_EM_Father__c);
    }
    Dateofwedding(event){
      this.dow = event.target.value; 

    }
   
    MotherName(event){
      this.mName = event.target.value; 
      //window.console.log(this.getAccountRecord.Name);
    }

    gender(event){
      this.gen = event.target.value; 
      //window.console.log(this.getAccountRecord.Name);
    }
    dateOfBirth(event){
      this.dob = event.target.value; 
      //window.console.log(this.getAccountRecord.Name);
    } 
    marialinfo=false;

    maritalstatus(event){
    //  console.log("checkbox check", event.target.checked);
      this.mstatus = event.target.value;

      if(this.mstatus=='Married'){
        this.marialinfo=true;
      }else{
        this.marialinfo=false;
      }
    }

    bloodgroup(event){
    //  console.log("checkbox check", event.target.checked);
      this.bg = event.target.value;

    }

    spousename(event){
      this.spouse = event.target.value; 
      //window.console.log(this.getAccountRecord.Name); 
    }  
   

   /* PassportNumber(event){
      this.pNum = event.target.value; 
      //window.console.log(this.getAccountRecord.Name); 
    }  */

    PFNumber(event){
      this.pfn = event.target.value; 
      //window.console.log(this.getAccountRecord.Name); 
    }  
    Nationality(event){
      this.nation = event.target.value; 
      //window.console.log(this.getAccountRecord.Name); 
    } 
    

    FirstName(event) {
    
      this.firstName = event.target.value;
    }

    LastName(event) {
    
      this.lastName = event.target.value;
    }


   
  changepreviouscompanyname(event){
    this.previouscompanyname = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  } 
  personalemailchange(event){
    this.personalemail = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  } 
  altephone(event){
    this.altphone =  event.target.value;
  
  }
  

 
  
  inputcheckboxValue;

  
  
    onboardID;
  
   
    phonenumber(event) {
     
      this.ph = event.target.value;
    }
   

handleSuccess(event) {
  const even = new ShowToastEvent({
      title: 'Success!',
      message: 'Record created!',
      variant: 'success'
  });
  this.dispatchEvent(even);
}
  
  handleError(event){
  const evt = new ShowToastEvent({
      title: 'Error!',
      message: event.detail.detail,
      variant: 'error',
      mode:'dismissable'
  });
  this.dispatchEvent(evt);
}
// Address details here....

@track cadrressline1;
@track cadrressline2;
@track padrressline1='';
@track padrressline2;
@track castate;
@track cacity;
@track cazip;
@track pastate;
@track pacity;
@track pazip;
message;
error;
addressId;
/*connectedCallback(){
    const queryString = window.location.search;
      const urlParams = new URLSearchParams(queryString);
     this.addressId = urlParams.get('recordId');
     //this.oldlastName = urlParams.get('lastName');

       console.log('this.loginPageId.LastName-->'+this.oldlastName);
     console.log('this.loginPageId-->'+this.onboardId);

  }*/
currentadrressline1(event){
    this.cadrressline1=event.target.value;
  } 

  currentadrressline2(event){
    this.cadrressline2=event.target.value;
  }
  CAState(event){
    this.castate = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  }  

  CACity(event){
    this.cacity = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  }   
  CAZip(event){
    this.cazip = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  } 
  permanentadrressline1(event){
    this.padrressline1=event.target.value;
  }
  permanentadrressline2(event){
    this.padrressline2=event.target.value;
  }

  PAState(event){
    this.pastate = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  }  
  PACity(event){
    this.pacity = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  }  

  PAZip(event){
    this.pazip = event.target.value; 
    //window.console.log(this.getAccountRecord.Name); 
  } 


  
  
  inputcheckboxValue;
  inputcheckboxexperience;
  showExperienceyouhave=false;

  AddressCheckboxChange(event){
    
    this.inputcheckboxValue = event.target.checked ? 'Checked' : 'Unchecked';
    console.log('this.inputcheckboxValue-->',this.inputcheckboxValue);

    if(this.inputcheckboxValue=='Checked'){
      console.log('address checked')
      this.padrressline1=this.cadrressline1;
      this.padrressline2=this.cadrressline2;
      this.pastate=this.castate;
      this.pacity=this.cacity;
      this.pazip=this.cazip;
  }else{
    console.log('address unchecked')
      this.padrressline1='';
      this.padrressline2='';
      this.pastate='';
      this.pacity='';
      this.pazip='';
  }   
}

experienceCheckboxChange(event){
  this.inputcheckboxexperience = event.target.checked ? 'Checked' : 'Unchecked';
  console.log('this.inputcheckboxexperience-->',this.inputcheckboxexperience);

  if(this.inputcheckboxexperience=='Checked'){
    this.showExperienceyouhave=true;
  }else{
    this.showExperienceyouhave=false;
  }
}

//Documents code here....
AdditionalrecordId;
onboardingrecordId;





//---------------------------------------------------------------------------------below code is for education 

LevelofEducationValue = [
        
  {label:'Std X/SSC',value:'Std X/SSC'},
  {label:'Std XII/HSC',value:'Std XII/HSC'},
  { label: 'Graduate', value:'Graduate'},
  { label: 'Post Graduate', value:'Post Graduate'}
  
  
];
LevelofEducationValue1 = [
  
  {label:'Std X/SSC',value:'Std X/SSC'},
  {label:'Std XII/HSC',value:'Std XII/HSC'},       
  { label: 'Graduate', value:'Graduate'},
  { label: 'Post Graduate', value:'Post Graduate'}
  
  
];
LevelofEducationValue2 = [
  
  {label:'Std X/SSC',value:'Std X/SSC'},
  {label:'Std XII/HSC',value:'Std XII/HSC'},
  { label: 'Graduate', value:'Graduate'},
  { label: 'Post Graduate', value:'Post Graduate'}
  
  
];
LevelofEducationValue3 = [
  
  {label:'Std X/SSC',value:'Std X/SSC'},
  {label:'Std XII/HSC',value:'Std XII/HSC'},
  { label: 'Graduate', value:'Graduate'},
  { label: 'Post Graduate', value:'Post Graduate'}
  
  
];
LevelofEducationValue4 = [
  
  {label:'Std X/SSC',value:'Std X/SSC'},
  {label:'Std XII/HSC',value:'Std XII/HSC'},
  { label: 'Graduate', value:'Graduate'},
  { label: 'Post Graduate', value:'Post Graduate'}
  
  
];

LevelofEducationValue5 = [
  
  {label:'Std X/SSC',value:'Std X/SSC'},
  {label:'Std XII/HSC',value:'Std XII/HSC'},
  { label: 'Graduate', value:'Graduate'},
  { label: 'Post Graduate', value:'Post Graduate'}
  
  
];

degree;
degree1;
degree2;
degree3;
degree4;
degree5;
levleofedu;
levleofedu1;
levleofedu2;
levleofedu3;
levleofedu4;
levleofedu5;
fieldOfStudy;
fieldOfStudy1;
fieldOfStudy2;
fieldOfStudy3;
fieldOfStudy4;
fieldOfStudy5;
instutionname;
instutionname1;
instutionname2;
instutionname3;
instutionname4;
instutionname5;
graduationDate;
graduationDate1;
graduationDate2;
graduationDate3;
graduationDate4;
graduationDate5;

// Certification Add more

Certificationname1;
Certificationname2;
Certificationname3;
Certificationname4;
Certificationname5;
Certificationname6;
Certificationname7;
Certificationname8;
Certificationname9;
Certificationname10;
Certificationname11;
Certificationname12;
Certificationname13;
Certificationname14;
Certificationname15;
Certificationname16;
Certificationname17;
Certificationname18;
Certificationname19;
Certificationname20;

ShowCertification = false;
      ShowCertification1 = false;
      ShowCertification2 = false;
      ShowCertification3 = false;
      ShowCertification4 = false;
      ShowCertification5 = false;
      ShowCertification6 = false;
      ShowCertification7 = false;
      ShowCertification8 = false;
      ShowCertification9 = false;
      ShowCertification10 = false;
      ShowCertification11 = false;
      ShowCertification12 = false;
      ShowCertification13 = false;
      ShowCertification14 = false;
      ShowCertification15 = false;
      ShowCertification16 = false;
      ShowCertification17 = false;
      ShowCertification18 = false;
      ShowCertification19 = false;
      ShowCertification20 = false;
      hideCertification2 = true;
      hideCertification3 = true;
      hideCertification4 = true;
      hideCertification5 = true;
      hideCertification6 = true;
      hideCertification7 = true;
      hideCertification8 = true;
      hideCertification9 = true;
      hideCertification10 = true;
      hideCertification11 = true;
      hideCertification12 = true;
      hideCertification13 = true;
      hideCertification14 = true;
      hideCertification15 = true;
      hideCertification16 = true;
      hideCertification17 = true;
      hideCertification18 = true;
      hideCertification19 = true;
      hideCertification20 = true;

handleraddCertification1(event){
  if(this.ShowCertification1 == false){
      this.ShowCertification1 = true;
      this.hideCertification2 = false;
  }else{
      this.ShowCertification1 = true;
  }   
}

removeCertification1(event){
  if(this.ShowCertification1 == true){
    this.ShowCertification1 = false;
    this.hideCertification2 = true;
}else{
    this.ShowCertification1 = true;
}   
}

handleraddCertification2(event){
  if(this.ShowCertification2 == false){
      this.ShowCertification2 = true;
      this.hideCertification3 = false;
  }else{
      this.ShowCertification2 = true;
  }   
}

removeCertification2(event){
  if(this.ShowCertification2 == true){
    this.ShowCertification2 = false;
    this.hideCertification3 = true;
}else{
    this.ShowCertification2 = true;
}   
}

handleraddCertification3(event){
  if(this.ShowCertification3 == false){
      this.ShowCertification3 = true;
      this.hideCertification4 = false;
  }else{
      this.ShowCertification3 = true;
  }   
}

removeCertification3(event){
  if(this.ShowCertification3 == true){
    this.ShowCertification3 = false;
    this.hideCertification4 = true;
}else{
    this.ShowCertification3 = true;
}   
}

handleraddCertification4(event){
  if(this.ShowCertification4 == false){
      this.ShowCertification4 = true;
      this.hideCertification5 = false;
  }else{
      this.ShowCertification4 = true;
  }   
}

removeCertification4(event){
  if(this.ShowCertification4 == true){
    this.ShowCertification4 = false;
    this.hideCertification5 = true;
}else{
    this.ShowCertification4 = true;
}   
}

handleraddCertification5(event){
  if(this.ShowCertification5 == false){
      this.ShowCertification5 = true;
      this.hideCertification6 = false;
  }else{
      this.ShowCertification5 = true;
  }   
}

removeCertification5(event){
  if(this.ShowCertification5 == true){
    this.ShowCertification5 = false;
    this.hideCertification6 = true;
}else{
    this.ShowCertification5 = true;
}   
}

handleraddCertification6(event){
  if(this.ShowCertification6 == false){
      this.ShowCertification6 = true;
      this.hideCertification7 = false;
  }else{
      this.ShowCertification6 = true;
  }   
}

removeCertification6(event){
  if(this.ShowCertification6 == true){
    this.ShowCertification6 = false;
    this.hideCertification7 = true;
}else{
    this.ShowCertification6 = true;
}   
}

handleraddCertification7(event){
  if(this.ShowCertification7 == false){
      this.ShowCertification7 = true;
      this.hideCertification8 = false;
  }else{
      this.ShowCertification7 = true;
  }   
}

removeCertification7(event){
  if(this.ShowCertification7 == true){
    this.ShowCertification7 = false;
    this.hideCertification8 = true;
}else{
    this.ShowCertification7 = true;
}   
}

handleraddCertification8(event){
  if(this.ShowCertification8 == false){
      this.ShowCertification8 = true;
      this.hideCertification9 = false;
  }else{
      this.ShowCertification8 = true;
  }   
}

removeCertification8(event){
  if(this.ShowCertification8 == true){
    this.ShowCertification8 = false;
    this.hideCertification9 = true;
}else{
    this.ShowCertification8 = true;
}   
}

handleraddCertification9(event){
  if(this.ShowCertification9 == false){
      this.ShowCertification9 = true;
      this.hideCertification10 = false;
  }else{
      this.ShowCertification9 = true;
  }   
}

removeCertification9(event){
  if(this.ShowCertification9 == true){
    this.ShowCertification9 = false;
    this.hideCertification10 = true;
}else{
    this.ShowCertification9 = true;
}   
}

handleraddCertification10(event){
  if(this.ShowCertification10 == false){
      this.ShowCertification10 = true;
      this.hideCertification11 = false;
  }else{
      this.ShowCertification10 = true;
  }   
}

removeCertification10(event){
  if(this.ShowCertification10 == true){
    this.ShowCertification10 = false;
    this.hideCertification11 = true;
}else{
    this.ShowCertification10 = true;
}   
}

handleraddCertification11(event){
  if(this.ShowCertification11 == false){
      this.ShowCertification11 = true;
      this.hideCertification12 = false;
  }else{
      this.ShowCertification11 = true;
  }   
}

removeCertification11(event){
  if(this.ShowCertification11 == true){
    this.ShowCertification11 = false;
    this.hideCertification12 = true;
}else{
    this.ShowCertification11 = true;
}   
}

handleraddCertification12(event){
  if(this.ShowCertification12 == false){
      this.ShowCertification12 = true;
      this.hideCertification13 = false;
  }else{
      this.ShowCertification12 = true;
  }   
}

removeCertification12(event){
  if(this.ShowCertification12 == true){
    this.ShowCertification12 = false;
    this.hideCertification13 = true;
}else{
    this.ShowCertification12 = true;
}   
}

handleraddCertification13(event){
  if(this.ShowCertification13 == false){
      this.ShowCertification13 = true;
      this.hideCertification14 = false;
  }else{
      this.ShowCertification13 = true;
  }   
}

removeCertification13(event){
  if(this.ShowCertification13 == true){
    this.ShowCertification13 = false;
    this.hideCertification14 = true;
}else{
    this.ShowCertification13 = true;
}   
}

handleraddCertification14(event){
  if(this.ShowCertification14 == false){
      this.ShowCertification14 = true;
      this.hideCertification15 = false;
  }else{
      this.ShowCertification14 = true;
  }   
}

removeCertification14(event){
  if(this.ShowCertification14 == true){
    this.ShowCertification14 = false;
    this.hideCertification15 = true;
}else{
    this.ShowCertification14 = true;
}   
}

handleraddCertification15(event){
  if(this.ShowCertification15 == false){
      this.ShowCertification15 = true;
      this.hideCertification16 = false;
  }else{
      this.ShowCertification15 = true;
  }   
}

removeCertification15(event){
  if(this.ShowCertification15 == true){
    this.ShowCertification15 = false;
    this.hideCertification16 = true;
}else{
    this.ShowCertification15 = true;
}   
}

handleraddCertification16(event){
  if(this.ShowCertification16 == false){
      this.ShowCertification16 = true;
      this.hideCertification17 = false;
  }else{
      this.ShowCertification16 = true;
  }   
}

removeCertification16(event){
  if(this.ShowCertification16 == true){
    this.ShowCertification16 = false;
    this.hideCertification17 = true;
}else{
    this.ShowCertification16 = true;
}   
}

handleraddCertification17(event){
  if(this.ShowCertification17 == false){
      this.ShowCertification17 = true;
      this.hideCertification18 = false;
  }else{
      this.ShowCertification17 = true;
  }   
}

removeCertification17(event){
  if(this.ShowCertification17 == true){
    this.ShowCertification17 = false;
    this.hideCertification18 = true;
}else{
    this.ShowCertification17 = true;
}   
}

handleraddCertification18(event){
  if(this.ShowCertification18 == false){
      this.ShowCertification18 = true;
      this.hideCertification19 = false;
  }else{
      this.ShowCertification18 = true;
  }   
}

removeCertification18(event){
  if(this.ShowCertification18 == true){
    this.ShowCertification18 = false;
    this.hideCertification19 = true;
}else{
    this.ShowCertification18 = true;
}   
}

handleraddCertification19(event){
  if(this.ShowCertification19 == false){
      this.ShowCertification19 = true;
      this.hideCertification20 = false;
  }else{
      this.ShowCertification19 = true;
  }   
}

removeCertification19(event){
  if(this.ShowCertification19 == true){
    this.ShowCertification19 = false;
    this.hideCertification20 = true;
}else{
    this.ShowCertification19 = true;
}   
}






selectstep4=true;
educationalId;

Degree(event){
    this.degree=event.target.value;
}

Degree1(event){
    this.degree1=event.target.value;
}

Degree2(event){
    this.degree2=event.target.value;
}

Degree3(event){
    this.degree3=event.target.value;
}

Degree4(event){
    this.degree4=event.target.value;
}

Degree5(event){
        this.degree5=event.target.value;     
}

LevelofEducation(event){
    this.levleofedu=event.target.value;
}

LevelofEducation1(event){
    this.levleofedu1=event.target.value;
}

LevelofEducation2(event){
    this.levleofedu2=event.target.value;
}

LevelofEducation3(event){
    this.levleofedu3=event.target.value;
}
                    
LevelofEducation4(event){
    this.levleofedu4=event.target.value;
}

LevelofEducation5(event){
    this.levleofedu5=event.target.value;
}

fieldofStudy(event){      
    this.fieldOfStudy=event.target.value;
  }

fieldofStudy1(event){      
    this.fieldOfStudy1=event.target.value;
  }

fieldofStudy2(event){      
    this.fieldOfStudy2=event.target.value;
  }

fieldofStudy3(event){      
    this.fieldOfStudy3=event.target.value;
  }

fieldofStudy4(event){      
    this.fieldOfStudy4=event.target.value;
  }

fieldofStudy5(event){
    this.fieldOfStudy5=event.target.value;
  }

InstitutionName(event){
    this.instutionname=event.target.value;
  }

  InstitutionName1(event){
    this.instutionname1=event.target.value;
  }

  InstitutionName2(event){
    this.instutionname2=event.target.value;
  }

  InstitutionName3(event){
    this.instutionname3=event.target.value;
  }

  InstitutionName4(event){
    this.instutionname4=event.target.value;
  }

  InstitutionName5(event){
    this.instutionname5=event.target.value;
  }

  GraduationDate(event){
    this.graduationDate=event.target.value;
  }

  GraduationDate1(event){
    this.graduationDate1=event.target.value;
  }

  GraduationDate2(event){
    this.graduationDate2=event.target.value;
  }

  GraduationDate3(event){
    this.graduationDate3=event.target.value;
  }

  GraduationDate4(event){
    this.graduationDate4=event.target.value;
  }

  GraduationDate5(event){
    this.graduationDate5=event.target.value;
  }
  
  certificationnamee1(event){
    this.Certificationname1=event.target.value;
  }
  certificationnamee2(event){
    this.Certificationname2=event.target.value;
  }
  certificationnamee3(event){
    this.Certificationname3=event.target.value;
  }
  certificationnamee4(event){
    this.Certificationname4=event.target.value;
  }
  certificationnamee5(event){
    this.Certificationname5=event.target.value;
  }
  certificationnamee6(event){
    this.Certificationname6=event.target.value;
  }
  certificationnamee7(event){
    this.Certificationname7=event.target.value;
  }
  certificationnamee8(event){
    this.Certificationname8=event.target.value;
  }
  certificationnamee9(event){
    this.Certificationname9=event.target.value;
  }
  certificationnamee10(event){
    this.Certificationname10=event.target.value;
  }
  certificationnamee11(event){
    this.Certificationname11=event.target.value;
  }
  certificationnamee12(event){
    this.Certificationname12=event.target.value;
  }
  certificationnamee13(event){
    this.Certificationname13=event.target.value;
  }
  certificationnamee14(event){
    this.Certificationname14=event.target.value;
  }
  certificationnamee15(event){
    this.Certificationname15=event.target.value;
  }
  certificationnamee16(event){
    this.Certificationname16=event.target.value;
  }
  certificationnamee17(event){
    this.Certificationname17=event.target.value;
  }
  certificationnamee18(event){
    this.Certificationname18=event.target.value;
  }
  certificationnamee19(event){
    this.Certificationname19=event.target.value;
  }
  certificationnamee20(event){
    this.Certificationname20=event.target.value;
  }
    

    addmoreempfields = false;
    addmoreeducationfield = false;
    addmoreempextrafields = false;
    extraempfields = false;
    extraempfields1 = false;
    extraempfields2 = false;
    extraempfields3 = false;
    hideadd = true;
    hideplus = true;
    hideextraadd = true;
    hideextraadd1 = true;
    hideextraadd2 = true;
    hideextraadd3 = true;

    handleraddmore(event){
        if(this.addmoreempfields == false){
            this.addmoreempfields = true;
            this.hideplus = false;
        }else{
            this.addmoreempfields = true;
            this.hideplus = true;
        }   
    }
    removesectionemp(event){
      if(this.addmoreempfields == true){
        this.addmoreempfields = false;
        this.hideplus = true;
    }else{
        this.addmoreempfields = true;
    }  
    }
    
    handlerEmpExtra(event){
        if(this.extraempfields == false){
            this.extraempfields = true;
            this.hideextraadd = false;
        }else{
            this.extraempfields = true;
            this.hideextraadd = true;
        }   
      }
      
      removesectionextra(event){
        if(this.extraempfields == true){
          this.extraempfields = false;
          this.hideextraadd = true;
      }else{
          this.extraempfields = true;
      }   
      } 
      handlerEmpExtra1(event){
        if(this.extraempfields1 == false){
            this.extraempfields1 = true;
            this.hideextraadd1 = false;
        }else{
            this.extraempfields1 = true;
            this.hideextraadd1 = true;
        }   
      }
      
      removesectionextra1(event){
        if(this.extraempfields1 == true){
          this.extraempfields1 = false;
          this.hideextraadd1 = true;
      }else{
          this.extraempfields1 = true;
      }   
      } 
      handlerEmpExtra2(event){
        if(this.extraempfields2 == false){
            this.extraempfields2 = true;
            this.hideextraadd2 = false;
        }else{
            this.extraempfields2 = true;
            this.hideextraadd2= true;
        }   
      }
      
      removesectionextra2(event){
        if(this.extraempfields2 == true){
          this.extraempfields2 = false;
          this.hideextraadd2 = true;
      }else{
          this.extraempfields2 = true;
      }   
      }  
      handlerEmpExtra3(event){
        if(this.extraempfields3 == false){
            this.extraempfields3 = true;
            this.hideextraadd3 = false;
        }else{
            this.extraempfields3 = true;
            this.hideextraadd3= true;
        }   
      }
      
      removesectionextra3(event){
        if(this.extraempfields3 == true){
          this.extraempfields3 = false;
          this.hideextraadd3 = true;
      }else{
          this.extraempfields3= true;
      }   
      } 

//---------------------------------------------------------------------------------below code is for work experience
@track jobtitle0;
@track fromdate0;
@track todate0;
@track previouscompanyname0;
@track previouscomemailid;

JobTitle(event){
  this.jobtitle0=event.target.value;
}

Fromdate(event){
  this.fromdate0=event.target.value;
}

Todate(event){
  this.todate0=event.target.value;
}

changepreviouscompanyname(event){
  this.previouscompanyname0=event.target.value;
}

changePreCEmailId(event){
  this.previouscomemailid=event.target.value;
}

jobtitle1;
fromdate1;
todate1;
previouscompanyname1;

JobTitle1(event){
  this.jobtitle1=event.target.value;
}

Fromdate1(event){
  this.fromdate1=event.target.value;
}

Todate1(event){
  this.todate1=event.target.value;
}

changepreviouscompanyname1(event){
  this.previouscompanyname1=event.target.value;
}

jobtitle2;
fromdate2;
todate2;
previouscompanyname2;

JobTitle2(event){
  this.jobtitle2=event.target.value;
}

Fromdate2(event){
  this.fromdate2=event.target.value;
}

Todate2(event){
  this.todate2=event.target.value;
}

changepreviouscompanyname2(event){
  this.previouscompanyname2=event.target.value;
}

jobtitle3;
fromdate3;
todate3;
previouscompanyname3;

JobTitle3(event){
  this.jobtitle3=event.target.value;
}

Fromdate3(event){
  this.fromdate3=event.target.value;
}

Todate3(event){
  this.todate3=event.target.value;
}

changepreviouscompanyname3(event){
  this.previouscompanyname3=event.target.value;
}

jobtitle4;
fromdate4;
todate4;
previouscompanyname4;

JobTitle4(event){
  this.jobtitle4=event.target.value;
}

Fromdate4(event){
  this.fromdate4=event.target.value;
}

Todate4(event){
  this.todate4=event.target.value;
}

changepreviouscompanyname4(event){
  this.previouscompanyname4=event.target.value;
}

jobtitle5;
fromdate5;
todate5;
previouscompanyname5;

JobTitle5(event){
  this.jobtitle5=event.target.value;
}

Fromdate5(event){
  this.fromdate5=event.target.value;
}

Todate5(event){
  this.todate5=event.target.value;
}

changepreviouscompanyname5(event){
  this.previouscompanyname5=event.target.value;
}

 //----work hide and show handler
 addmoreworkfields=false;
 hideplus1=true;
 addmoreworkfields1=false;
 hidesecondadd=true;
 addmoreworkfields2=false;
 hidethirdadd=true;
 addmoreworkfields3=false;
 hidefourthadd=true;
 addmoreworkfields4=false;
 hidefivthadd=true;

 handleraddwork(event){
   if(this.addmoreworkfields == false){
       this.addmoreworkfields = true;
       this.hideplus1 = false;
   }else{
       this.addmoreworkfields = true;
       this.hideplus1 = true;
   }   
}

removeworksection(){
 if(this.addmoreworkfields == true){
   this.addmoreworkfields = false;
   this.hideplus1 = true;
}else{
   this.addmoreworkfields = true;
} 
}

handleraddwork1(){
 if(this.addmoreworkfields1 == false){
   this.addmoreworkfields1 = true;
   this.hidesecondadd = false;
}else{
   this.addmoreworkfields1 = true;
   this.hidesecondadd = true;
} 
}

removeworksection1(){
 if(this.addmoreworkfields1 == true){
   this.addmoreworkfields1 = false;
   this.hidesecondadd = true;
}else{
   this.addmoreworkfields1 = true;
}
}

handleraddwork2(){
 if(this.addmoreworkfields2 == false){
   this.addmoreworkfields2 = true;
   this.hidethirdadd = false;
}else{
   this.addmoreworkfields2 = true;
   this.hidethirdadd = true;
}
}

removeworksection2(){
 if(this.addmoreworkfields2 == true){
   this.addmoreworkfields2 = false;
   this.hidethirdadd = true;
}else{
   this.addmoreworkfields2 = true;
}
}

handleraddwork3(){
 if(this.addmoreworkfields3 == false){
   this.addmoreworkfields3 = true;
   this.hidefourthadd = false;
}else{
   this.addmoreworkfields3 = true;
   this.hidefourthadd = true;
}
}

removeworksection3(){
 if(this.addmoreworkfields3 == true){
   this.addmoreworkfields3 = false;
   this.hidefourthadd = true;
}else{
   this.addmoreworkfields3 = true;
}
}

handleraddwork4(){
 if(this.addmoreworkfields4 == false){
   this.addmoreworkfields4 = true;
   this.hidefivthadd = false;
}else{
   this.addmoreworkfields4 = true;
   this.hidefivthadd = true;
}
}

removeworksection4(){
 if(this.addmoreworkfields4 == true){
   this.addmoreworkfields4 = false;
   this.hidefivthadd = true;
}else{
   this.addmoreworkfields4 = true;
}
}
isShowModal;
hideModalBox(){
  this.isShowModal=false;
}

ShowModalBox(){
  

  if(  this.readonlyfield!=true){
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
    .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
    }, true);
if (isInputsCorrect) {
  if(this.showExperienceyouhave==true && this.fileName9==null){

    const even = new ShowToastEvent({
      message: 'Please Provide Appointment Letter!',
      variant: 'error'
  });
  this.dispatchEvent(even);
  }else{
    this.isShowModal=true;
  }
}
 
  }else{
    this.isShowModal=true;
    }  
}

onboardingformId;
additionalId;
readonlyfield=false;



SaveSubmitOnboarding(event){
  
  let guestObj = { 'sobjectType': 'EMS_EM_Onboarding_Request__c' };
 
guestObj.EMS_EM_First_Name__c = this.firstName;
guestObj.EMS_EM_Last_Name__c = this.lastName;
guestObj.EMS_EM_Father__c =this.fName;
guestObj.EMS_EM_Mother__c =this.mName,        
guestObj.Phone_Number__c =this.ph;
guestObj.EMS_EM_Phone_Number__c=this.altphone;
guestObj.EMS_EM_DOB__c =this.dob;
guestObj.EMS_EM_Mstatus__c =this.mstatus;
guestObj.EMS_EM_Spouse__c =this.spouse;
guestObj.EMS_EM_DOW__c =this.dow;
guestObj.EMS_EM_Personal_Email__c= this.personalemail;
guestObj.EMS_EM_AadhaarNo__c=this.actualAadharNumber;
guestObj.EMS_EM_PanNo__c=this.actualPanNumber;
guestObj.EMS_EM_PassportNo__c=this.actualPassportNumber;
guestObj.EMS_EM_UAN_Number__c =this.pfn;
guestObj.EMS_EM_Nationality__c=this.nation;
guestObj.EMS_EM_Gender__c =this.gen;
guestObj.EMS_EM_BG__c =this.bg;
guestObj.EMS_EM_CA_State__c=this.castate;
guestObj.EMS_EM_PA_State__c=this.pastate;
guestObj.EMS_EM_CA_City__c=this.cacity;
guestObj.EMS_EM_PA_City__c =this.pacity;
guestObj.EMS_EM_CA_Zip__c=this.cazip;
guestObj.EMS_EM_PA_Zip__c=this.pazip;
guestObj.Current_Address_Line_1__c=this.cadrressline1;
guestObj.Current_Address_Line_2__c=this.cadrressline2;
guestObj.Permanent_Address_Line_1__c=this.padrressline1;
guestObj.Permanent_Address_Line_2__c=this.padrressline2;
guestObj.EMS_EM_Certification_Name__c=this.Certificationname1;
guestObj.EMS_EM_Certification_Name1__c=this.Certificationname2;
guestObj.EMS_EM_Certification_Name2__c=this.Certificationname3;
guestObj.EMS_EM_Certification_Name3__c=this.Certificationname4;
guestObj.EMS_EM_Certification_Name4__c=this.Certificationname5;
guestObj.EMS_EM_Certification_Name5__c=this.Certificationname6;
guestObj.EMS_EM_Certification_Name6__c=this.Certificationname7;
guestObj.EMS_EM_Certification_Name7__c=this.Certificationname8;
guestObj.EMS_EM_Certification_Name8__c=this.Certificationname9;
guestObj.EMS_EM_Certification_Name9__c=this.Certificationname10;
guestObj.EMS_EM_Certification_Name10__c=this.Certificationname11;
guestObj.EMS_EM_Certification_Name11__c=this.Certificationname12;
guestObj.EMS_EM_Certification_Name12__c=this.Certificationname13;
guestObj.EMS_EM_Certification_Name13__c=this.Certificationname14;
guestObj.EMS_EM_Certification_Name14__c=this.Certificationname15;
guestObj.EMS_EM_Certification_Name15__c=this.Certificationname16;
guestObj.EMS_EM_Certification_Name16__c=this.Certificationname17;
guestObj.EMS_EM_Certification_Name17__c=this.Certificationname18;
guestObj.EMS_EM_Certification_Name18__c=this.Certificationname19;
guestObj.EMS_EM_Certification_Name19__c=this.Certificationname20;
  console.log('guestObj-->'+guestObj);

 /* const value = true;
  const valueChangeEvent = new CustomEvent("valuechange", {
    detail: { value }
  });
  // Fire the custom event
  this.dispatchEvent(valueChangeEvent);*/

        let guestObj1 = { 'sobjectType': 'ems_EM_Additional_Detail__c' };
        
        guestObj1.EMS_EM_Education__c = this.levleofedu;
        guestObj1.EMS_EM_Field_of_Study__c = this.fieldOfStudy;
        guestObj1.EMS_EM_IName__c = this.instutionname;
        guestObj1.EMS_EM_GDate__c = this.graduationDate;
        guestObj1.EMS_EM_Degree__c=this.degree;

        guestObj1.EMS_EM_Education1__c = this.levleofedu1;
        guestObj1.EMS_EM_Field_of_Study1__c = this.fieldOfStudy1;
        guestObj1.EMS_EM_IName1__c = this.instutionname1;
        guestObj1.EMS_EM_GDate1__c = this.graduationDate1;
        guestObj1.EMS_EM_Degree1__c=this.degree1;

        guestObj1.EMS_EM_Education2__c = this.levleofedu2;
        guestObj1.EMS_EM_Field_of_Study2__c = this.fieldOfStudy2;
        guestObj1.EMS_EM_IName2__c = this.instutionname2;
        guestObj1.EMS_EM_GDate2__c = this.graduationDate2;
        guestObj1.EMS_EM_Degree2__c=this.degree2;

        guestObj1.EMS_EM_Education3__c = this.levleofedu3;
        guestObj1.EMS_EM_Field_of_Study3__c = this.fieldOfStudy3;
        guestObj1.EMS_EM_IName3__c = this.instutionname3;
        guestObj1.EMS_EM_GDate3__c = this.graduationDate3;
        guestObj1.EMS_EM_Degree3__c=this.degree3;

        guestObj1.EMS_EM_Education4__c = this.levleofedu4;
        guestObj1.EMS_EM_Field_of_Study4__c = this.fieldOfStudy4;
        guestObj1.EMS_EM_IName4__c = this.instutionname4;
        guestObj1.EMS_EM_GDate4__c = this.graduationDate4;
        guestObj1.EMS_EM_Degree4__c=this.degree4;

        guestObj1.EMS_EM_Education5__c = this.levleofedu5;
        guestObj1.EMS_EM_Field_of_Study5__c = this.fieldOfStudy5;
        guestObj1.EMS_EM_IName5__c = this.instutionname5;
        guestObj1.EMS_EM_GDate5__c = this.graduationDate5;
        guestObj1.EMS_EM_Degree5__c=this.degree5;

     //   guestObj1.Onboarding_Request__c=this.onboardingformId;

        guestObj1.EMS_EM_Job_Title__c=this.jobtitle0;
        guestObj1.EMS_EM_From_Date__c=this.fromdate0;
        guestObj1.EMS_EM_To_Date__c= this.todate0;
        guestObj1.EMS_EM_Previous_Company_Name__c= this.previouscompanyname0;
        guestObj1.EMS_EM_Previous_Company_HR_EmailId__c=this.previouscomemailid;

        guestObj1.EMS_EM_Job_Title1__c=this.jobtitle1;
        guestObj1.EMS_EM_From_Date1__c=this.fromdate1;
        guestObj1.EMS_EM_To_Date1__c=this.todate1;
        guestObj1.EMS_EM_Previous_Company_Name1__c=this.previouscompanyname1;

        guestObj1.EMS_EM_Job_Title2__c=this.jobtitle2;
        guestObj1.EMS_EM_From_Date2__c=this.fromdate2;
        guestObj1.EMS_EM_To_Date2__c=this.todate2;
        guestObj1.EMS_EM_Previous_Company_Name2__c=this.previouscompanyname2;

        guestObj1.EMS_EM_Job_Title3__c=this.jobtitle3;
        guestObj1.EMS_EM_From_Date3__c=this.fromdate3;
        guestObj1.EMS_EM_To_Date3__c=this.todate3;
        guestObj1.EMS_EM_Previous_Company_Name3__c=this.previouscompanyname3;

        guestObj1.EMS_EM_Job_Title4__c=this.jobtitle4;
        guestObj1.EMS_EM_From_Date4__c=this.fromdate4;
        guestObj1.EMS_EM_To_Date4__c=this.todate4;
        guestObj1.EMS_EM_Previous_Company_Name4__c=this.previouscompanyname4;

        guestObj1.EMS_EM_Job_Title5__c=this.jobtitle5;
        guestObj1.EMS_EM_From_Date5__c=this.fromdate5;
        guestObj1.EMS_EM_To_Date5__c=this.todate5;
        guestObj1.EMS_EM_Previous_Company_Name5__c=this.previouscompanyname5;

        this.hideModalBox();
        this.selectStep5();
        this.readonlyfield=true;
  createGuest({newRecord: guestObj , newaddRecord: guestObj1 , files: this.filesUploaded})
      .then(result => {     
         
          this.onboardingformId=result.Id;
          console.log('this.onboardingformID'+this.onboardingformId);    
          sendEmail({  subject: "Onboard Form Submission",recordId:this.onboardingformId,
          body: "Dear HR Team,"+"<Br/><Br/>"+"Employee  has submitted their onboarding form along with the required documents."+"<Br/><Br/>"+"Click here https://cpprd--uat.sandbox.lightning.force.com/"+this.onboardingformId+ "  to find and verify the details."})
    
                      
      })
      .catch(error => {
          this.error = error;
          console.log('this.error-->'+JSON.stringify(this.error));
      });
    
}
/*
file12: encodeURIComponent(this.fileContents), 
    fileName12: this.fileName12,
    file13: encodeURIComponent(this.fileContents), 
    fileName13: this.fileName13,
    file14: encodeURIComponent(this.fileContents), 
    fileName14: this.fileName14,
    file15: encodeURIComponent(this.fileContents), 
    fileName15: this.fileName15,
    file16: encodeURIComponent(this.fileContents), 
    fileName16: this.fileName16,
    file17: encodeURIComponent(this.fileContents), 
    fileName17: this.fileName17,



*/

  
//---------------------------------------------------------------------------- uploading
@track filesUploaded = [];
uploadedFiles = []; file; fileName;  
uploadedFiles1 = []; file1; fileName1;  
uploadedFiles2 = []; file2; fileName2; 
uploadedFiles3 = []; file3; fileName3;
uploadedFiles4 = []; file4; fileName4; 
uploadedFiles5 = []; file5; fileName5;
uploadedFiles6 = []; file6; fileName6; 
uploadedFiles7 = []; file7; fileName7;  
uploadedFiles8 = []; file8; fileName8;
uploadedFiles9 = []; file9; fileName9;
uploadedFiles10 = []; file10; fileName10;
uploadedFiles11 = []; file11; fileName11;
uploadedFiles12 = []; file12; fileName12;
uploadedFiles13 = []; file13; fileName13;
uploadedFiles14 = []; file14; fileName14;
uploadedFiles15 = []; file15; fileName15;
uploadedFiles16 = []; file16; fileName16;
uploadedFiles17 = []; file17; fileName17;
fileContents; fileReader; content; 
CertificationfileName1
CertificationfileName2
CertificationfileName3
CertificationfileName4
CertificationfileName5
CertificationfileName6
CertificationfileName7
CertificationfileName8
CertificationfileName9
CertificationfileName10
CertificationfileName11
CertificationfileName12
CertificationfileName13
CertificationfileName14
CertificationfileName15
CertificationfileName16
CertificationfileName17
CertificationfileName18
CertificationfileName19
CertificationfileName20

//uploading all files
@api accept = '.pdf';

onFileUpload(event) {  
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
} 
}

onFileUpload1(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName1 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload2(event){
  console.log('photo-->'+event.target.files[0].type); 
  
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && (event.target.files[0].type =="image/png" || event.target.files[0].type =="image/jpeg" || event.target.files[0].type =="image/jpg")) {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName2 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be image/jpeg/png/jpeg only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

file3;

onFileUpload3(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    this.file3 = event.target.value;
    console.log('this.file3-->'+this.file3);
    console.log('tevent.target.value-->'+event.target.value);
        let file = event.target.files[0];
        this.fileName3 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload4(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName4 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload5(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName5 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload6(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName6 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
} 
}

onFileUpload7(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName7 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
} 
}

onFileUpload8(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName8 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload9(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName9 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
} 
}

onFileUpload10(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName10 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload11(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName11 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload12(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName12 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload13(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName13 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onFileUpload14(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName14 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}   
}

onFileUpload15(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName15 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}   
}

onFileUpload16(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName16 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}   
}

onFileUpload17(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.fileName17 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload1(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName1 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload2(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName2 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}
onCertificationUpload3(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName3 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload4(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName4 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload5(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName5 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload6(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName6 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload7(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName7 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload8(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName8 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload9(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName9 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload10(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName10 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload11(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName11 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload12(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName12 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload13(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName13 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload14(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName14 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload15(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName15 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload16(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName16 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload17(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName17 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload18(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName18 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload19(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName19 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}

onCertificationUpload20(event){
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
    let files = [];
    
        let file = event.target.files[0];
        this.CertificationfileName20 = event.target.files[0].name; 
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            this.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
        };
        reader.readAsDataURL(file);
}else{
  const even = new ShowToastEvent({
    message: 'File Size must be less than 2Mb & file type should be PDF only',
    variant: 'error'
});
this.dispatchEvent(even);
}  
}


}