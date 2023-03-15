import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createGuest from '@salesforce/apex/EMS_EM_CreationOnboard.createGuest';
import getCompanyInformation from '@salesforce/apex/EMS_EM_GridConfigurationSettings.getCompanyInformation';
import fetchCertifications from '@salesforce/apex/EMS_EM_CreationOnboard.fetchCertifications';
import dmlOnCertifications from '@salesforce/apex/EMS_EM_CreationOnboard.dmlOnCertifications';
import { refreshApex } from '@salesforce/apex';
import BannerPreOn from '@salesforce/resourceUrl/BannerPreOn';
import { uploadFilesFromThis, updateOnBoardingRequest, updateOnboardingInfoOnPageLoads, displayShowtoastMessage } from 'c/updateOnBoardingRequestForm';
import getonOnboardformInfo from '@salesforce/apex/EMS_EM_CreationOnboard.getonOnboardformInfo';
	
import correctImage from '@salesforce/resourceUrl/Correct';
import wrongImage from '@salesforce/resourceUrl/Wrong';

const isAllowedKeyCode = keyCode => {
  if (keyCode === 8 // backspace
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

  if (value === undefined || value === null || value === "") {
    return value;
  }

  let v = value.replace(/\D/g, '');
  let str = v.replace(/\d(?=\d{4})/g, "*");
  console.log('sdfghn' + str)
  return str;
}

const maskPanNumber = value => {

  if (value === undefined || value === null || value === "") {
    return value;
  }

  //let v = value.replace(/\W/g,'');
  let str = value.replace(/\d(?=\d{0})/g, "*");
  console.log('sdfghn' + str)
  return str;
}

const maskPassportNumber = value => {

  if (value === undefined || value === null || value === "") {
    return value;
  }

  //let v = value.replace(/\W/g,'');
  let str = value.replace(/\w(?=\w{4})/g, "*");
  console.log('sdfghn' + str)
  return str;
}

export default class LightningExampleAccordionMultiple extends LightningElement {
  onboardingformId
  activeSections = ['Profile'];
  activeSectionsConfirm = ['Profile','Company Information'];
  isPersonaldetails = true;
  isShowPersonalDetails = true;
  isIdentifyDetails = false;
  isAddressDetails = false;
  isEducationDetails = false;
  isOtherCertifications = false;
  isWorkExperience = false;
  isConfirm = false;
  isCompanyInformation = false;
  correctImages = correctImage;
  wrongImages = wrongImage;
  isPersonalUpdateCheckbox = false;
  statusUpdate;
  confirmStatusUpdate;
  isIdentifyDetailsCheckbox = false;
  isAddressDetailsCheckbox = false;
  isEducationDetailsCheckbox = false;
  isOtherCertificationsCheckbox = false;
  isWorkExperienceCheckbox = false;
  isCompanyInformationValueChecked = false;
  isConfirmSubmit = false;
  isIdentityStatusUpdate;
  isAdressStatusUpdate;
  isEducationStatusUpdate;
  isCertificationStatusUpdate;
  isWorkExperienceStatusUpdate;
  buttonDisable = false;

  @track imageUrl = BannerPreOn;


  handleSectionToggle(event) {
    const openSections = event.detail.openSections;

    if (openSections.length === 0) {
      this.activeSectionsMessage = 'All sections are closed';
    } else {
      this.activeSectionsMessage =
        'Open sections: ' + openSections.join(', ');
    }
  }
  selectedDetails(event) {
    console.log(event.target.value);
    let seletedDetails = event.target.value
    this.isPersonaldetails = false;
    this.isShowPersonalDetails = false;
    if (seletedDetails === "Personal Details") {
      this.isShowPersonalDetails = true;
      this.isIdentifyDetails = false;
      this.isAddressDetails = false;
      this.isEducationDetails = false;
      this.isOtherCertifications = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      this.isCompanyInformation = false;
    }
    else if (seletedDetails === "Identity Information") {
      this.isIdentifyDetails = true;
      this.isShowPersonalDetails = false;
      this.isAddressDetails = false;
      this.isEducationDetails = false;
      this.isOtherCertifications = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      this.isCompanyInformation = false;
    }
    else if (seletedDetails === "Address Details") {
      this.isAddressDetails = true;
      
       
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isEducationDetails = false;
      this.isOtherCertifications = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      this.isCompanyInformation = false;
    }
    else if (seletedDetails === "Education Details") {
      this.isEducationDetails = true;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isAddressDetails = false;
      this.isOtherCertifications = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      this.isCompanyInformation = false;
    }
    else if (seletedDetails === "Other Certifications") {
      this.isOtherCertifications = true;
      this.isOtherCertificationsCheckbox = true;
      this.isEducationDetails = false;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isAddressDetails = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      this.isCompanyInformation = false;
    }
    else if (seletedDetails === "Work Experience") {
      this.isWorkExperience = true;
      this.isWorkExperienceCheckbox = true;
      this.isOtherCertifications = false;
      this.isEducationDetails = false;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isAddressDetails = false;
      this.isConfirm = false;
      this.isCompanyInformation = false;
    }
    else if (seletedDetails === "Confirm") {
      this.isConfirm = true;
      console.log('Confirm Info', this.isConfirm);
      this.isWorkExperience = false;
      this.isOtherCertifications = false;
      this.isEducationDetails = false;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isAddressDetails = false;
      this.isCompanyInformation = false;
      if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
      {
        this.buttonDisable = true;
      }
    }
    else if (seletedDetails === "Company Information") {
      this.isCompanyInformation = true;
      this.isCompanyInformationValueChecked = true;
      updateOnBoardingRequest(this);
      if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        } 
      console.log('Company Info', this.isCompanyInformation);
      this.isAddressDetails = false;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isEducationDetails = false;
      this.isOtherCertifications = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
      {
        this.buttonDisable = true;
      }
      else{
        this.buttonDisable = false;
      }
    }
  }

  //Aadhar Number
  @api aadhaarNo;
  @api actualAadharNumber;
  @track companyInformation;

  handleAadharNumberFocusIn(event) {
    this.aadhaarNo = this.actualAadharNumber;
  }

  handleAadharNumberChange(event) {
    let value = event.detail.value;
    this.actualAadharNumber = value.replace(/\D/g, '');
    this.aadhaarNo = value;
    event.target.value = value;
  }

  handleAadharNumberFocusOut(event) {

    let newValue = maskAccountNumber(this.aadhaarNo);
    this.aadhaarNo = newValue;

    const evt = new CustomEvent("card_account_number_change", {
      detail: { actualAadharNumber: this.actualAadharNumber, aadhaarNo: this.aadhaarNo }
      , bubbles: true
      , composed: true
    });
    this.dispatchEvent(evt);

  }
  handleAadharNumberKeyDown(event) {
    if (isAllowedKeyCode(event.keyCode)) {
      return;
    }

    if (!event.key.match(/[0-9]/)) {
      event.preventDefault();
    }
  }

  handleFirstLastNameKeyDown(event) {
    if (isAllowedKeyCode(event.keyCode)) {
      return;
    }

    if (!event.key.match(/[A-Z a-z._-]/)) {
      event.preventDefault();
    }
  }
  // PAN Number
  @api panNo;
  @api actualPanNumber;
  additionalDetailsRecordId;
  handlePanNumberFocusIn(event) {
    this.panNo = this.actualPanNumber;
    console.log('actualPanNumber', +this.actualPanNumber);
  }

  PANNumber(event) {
    let value = event.detail.value;
    this.actualPanNumber = value.replace(/\W/g, '');
    this.panNo = value;
    event.target.value = value;
  }

  handlePanNumberFocusOut(event) {
    let newValue = maskPanNumber(this.panNo);
    this.panNo = newValue;

    const evt = new CustomEvent("card_account_number_change", {
      detail: { actualPanNumber: this.actualPanNumber, panNo: this.panNo }
      , bubbles: true
      , composed: true
    });
    this.dispatchEvent(evt);
  }

  //Passport Number
  @api pNum;
  @api actualPassportNumber;

  handlePassportNumberFocusIn(event) {
    this.pNum = this.actualPassportNumber;
    console.log('actualPassportNumber', +this.actualPassportNumber);
  }


  PassportNumber(event) {
    let value = event.detail.value;
    this.actualPassportNumber = value.replace(/\W/g, '');
    console.log('actualPassportNumber', +this.actualPassportNumber);
    this.pNum = value;
    event.target.value = value;
  }

  handlePassportNumberFocusOut(event) {
    let newValue = maskPassportNumber(this.pNum);
    this.pNum = newValue;

    const evt = new CustomEvent("card_account_number_change", {
      detail: { actualPassportNumber: this.actualPassportNumber, pNum: this.pNum }
      , bubbles: true
      , composed: true
    });
    this.dispatchEvent(evt);
  }
  //------------End

  connectedCallback() {
    updateOnboardingInfoOnPageLoads(this);
    
  }

  selectStep1() {
    if (this.readonlyfield != true) {
      if (this.firstName != null && this.firstName != '' && this.lastName != null && this.lastName != ''
        && this.ph.length == 10 &&
        this.nation != null && this.nation != '' && this.dob != null &&
        this.personalemail != null && this.gen != null &&
        this.fileName2 != null) {
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
              //console.log("I am in if");
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Error',
                      message: 'Please Enter correct date of birth',
                      variant: 'error',
                  }),
              );
              return false;
          }else if (this.ph === this.altphone) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error',
          message: 'Contact Number and Alternate Contact Number should not be the same',
          variant: 'error'
        })
      );
      return false;
    } else {
      return true;
    }
  } else {
    const even = new ShowToastEvent({
      message: 'Please complete required field & avoid invalid data!',
      variant: 'error'
    });
    this.dispatchEvent(even);
    return false;
  }
}else{
   return true;
  }
 }
 selectStep2() {
  if (!this.readonlyfield) {
    if (this.aadhaarNo.length === 12 && this.panNo != null && this.fileName != null && this.fileName1 != null) {
      const panCardRegex = /[A-Z]{5}[*]{4}[A-Z]{1}$/;
      let panCard = this.template.querySelector(".panCard");
      let panCardVal = this.panNo;
      if (panCardRegex.test(panCardVal)) {
        panCard.setCustomValidity("");
        panCard.reportValidity();
        return true;
      } else {
        panCard.setCustomValidity("Please enter a valid PAN card number");
        panCard.reportValidity();
        const even = new ShowToastEvent({
          message: "Please enter a valid PAN card number",
          variant: "error"
        });
        this.dispatchEvent(even);
        return false;
      }
    } else {
      const even = new ShowToastEvent({
        message: "Please complete required fields and avoid invalid data!",
        variant: "error"
      });
      this.dispatchEvent(even);
      return false;
    }
  }
}

  selectStep3() {
    if (this.readonlyfield != true) {
      const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
      if (isInputsCorrect) {
        if (this.pazip.length == 6 && this.cazip.length == 6) {
         return true;
        } else {
          const even = new ShowToastEvent({
            message: 'Invalid zip!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        }

      } else {
        const even = new ShowToastEvent({
          message: 'Please complete required field & avoid invalid data!!',
          variant: 'error'
        });
        this.dispatchEvent(even);
        return false;
      }

    }

  }

  selectStep4() {
    if (this.readonlyfield != true) {
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
        today = yyyy + '-' + mm + '-' + dd;
        console.log("this.graduationDate", this.graduationDate);
        if (this.graduationDate >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please enter correct Graduation Date',
              variant: 'error',
            }),
          );
          return false;
        }
        else if (this.graduationDate1 >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please enter correct Graduation Date',
              variant: 'error',
            }),
          );
          return false;
        }
        else if (this.graduationDate2 >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please enter correct Graduation Date',
              variant: 'error',
            }),
          );
          return false;
        }
        else if (this.graduationDate3 >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please enter correct Graduation Date',
              variant: 'error',
            }),
          );
          return false;
        }
        else if (this.graduationDate4 >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please enter correct Graduation Date',
              variant: 'error',
            }),
          );
          return false;
        }
        else if (this.graduationDate5 >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: 'Error',
              message: 'Please enter correct Graduation Date',
              variant: 'error',
            }),
          );
          return false;
        }
        else if (this.fileName3 == null) {
          const even = new ShowToastEvent({
            message: 'Please upload certificate!!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } else if (this.addmoreempfields == true && this.fileName4 == null) {
          const even = new ShowToastEvent({
            message: 'Please upload certificate!!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } else if (this.extraempfields == true && this.fileName5 == null) {
          const even = new ShowToastEvent({
            message: 'Please upload certificate!!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } else if (this.extraempfields1 == true && this.fileName6 == null) {
          const even = new ShowToastEvent({
            message: 'Please upload certificate!!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } else if (this.extraempfields2 == true && this.fileName7 == null) {
          const even = new ShowToastEvent({
            message: 'Please upload certificate!!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } else if (this.extraempfields3 == true && this.fileName8 == null) {
          const even = new ShowToastEvent({
            message: 'Please upload certificate!!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        }
        else{
          return true;
      }
      } else {
        const even = new ShowToastEvent({
          message: 'Please complete required field & avoid invalid data!!',
          variant: 'error'
        });
        this.dispatchEvent(even);
        return false;
      }
    } 
    else{
       return true;
      }      
  }
  
  @track inputName

  inputhandler(event) {
    this.inputName = event.target.value;
  }

  //personal details code here...
  get acceptedFormats() {
    return ['.pdf', '.png', '.jpg', '.jpeg'];
  }

  @track firstName;
  @track lastName;
  @track Trailblazerval;
  @track pfn;
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


  Gendervalue = [
    { label: 'Male', value: 'Male' },
    { label: 'Female', value: 'Female' },
    { label: 'Other', value: 'Other' },
  ];

  LevelofEducationValue = [
    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC	', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


  ];


  
  gender(event) {
    this.gen = event.target.value;
  }
 

  PFNumber(event) {
    this.pfn = event.target.value;
  }
  Nationality(event) {
    this.nation = event.target.value;
  }


  FirstName(event) {

    this.firstName = event.target.value;
  }

  LastName(event) {

    this.lastName = event.target.value;
  }
  TrailblazerIDorPublic(event) {

    this.Trailblazerval = event.target.value;
  }


  changepreviouscompanyname(event) {
    this.previouscompanyname = event.target.value;
  }
  personalemailchange(event) {
    this.personalemail = event.target.value;
  }
  altephone(event) {
    this.altphone = event.target.value;

  }
  onboardID;


  phonenumber(event) {

    this.ph = event.target.value;
  }

  // Address details here....

  @track cadrressline1;
  @track cadrressline2;
  @track padrressline1;
  @track padrressline2;
  @track castate;
  @track cacity;
  @track cazip;
  @track pastate;
  @track pacity;
  @track pazip;
  message;
  error;

  

  inputcheckboxValue;


  AddressCheckboxChange(event) {

    this.inputcheckboxValue = event.target.checked ? 'Checked' : 'Unchecked';
    //console.log('this.inputcheckboxValue-->', this.inputcheckboxValue);

    if (this.inputcheckboxValue == 'Checked') {
      //console.log('address checked')
      this.padrressline1 = this.cadrressline1;
      this.padrressline2 = this.cadrressline2;
      this.pastate = this.castate;
      this.pacity = this.cacity;
      this.pazip = this.cazip;
      this.paFlag = true;
      
    } else {
      //console.log('address unchecked')
      this.padrressline1 = '';
      this.padrressline2 = '';
      this.pastate = '';
      this.pacity = '';
      this.pazip = '';
  this.paFlag = false;
    }
  }

  @track paFlag;
  @track addressFlag;
  @track disableFlag = true;

  handleChange(event) {

    this.addressFlag = true;
        let addressList = this.template.querySelectorAll('.addressClass');
        if (this.addressFlag) {
          addressList.forEach((ele) => {
            if (!ele.value) {
              this.addressFlag = false;
            }
          });
        }
    this.disableFlag = this.addressFlag ? false : true;
    if (!this.addressFlag) {
      //console.log('1473');
      this.paFlag = false;

    }
    const field = event.target.name;
    if (field === 'Current_Address_Line_1__c') {
        this.cadrressline1 = event.target.value;
        //console.log('234',event.target.value);
        if(event.target.value == ''){
          //console.log('empty string');
          this.cadrressline1 = null;

        }
        if (this.inputcheckboxValue == 'Checked'){
          this.padrressline1 = this.cadrressline1;

        }


    }
     if (field === 'Current_Address_Line_2__c') {
        this.cadrressline2 = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.cadrressline2 = null;
        }
        if (this.inputcheckboxValue == 'Checked'){
          this.padrressline2 = this.cadrressline2;
        }


    }
      if (field === 'EMS_EM_CA_State__c') {
        this.castate = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.castate = null;

        }
        if (this.inputcheckboxValue == 'Checked'){
          this.pastate = this.castate;
        }

    }
      if (field === 'EMS_EM_CA_City__c') {
        this.cacity = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.cacity = null;

        }
        if (this.inputcheckboxValue == 'Checked'){
          this.pacity = this.cacity;
        }

    }
     if (field === 'EMS_EM_CA_Zip__c') {
        this.cazip = event.target.value;
        //console.log(event.target.value);

        if(event.target.value == ''){
          this.cazip = null;

        }
        if (this.inputcheckboxValue == 'Checked'){
          this.pazip = this.cazip;
        }

    }
    //permanent address
    if (field === 'Permanent_Address_Line_1__c') {
        this.padrressline1 = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.padrressline1 = null;
        }
        if (this.inputcheckboxValue == 'Checked'){
          this.cadrressline1 = this.padrressline1;

        }

    }
     if (field === 'Permanent_Address_Line_2__c') {
        this.padrressline2 = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.padrressline2 = null;
        }
        if (this.inputcheckboxValue == 'Checked'){
          this.cadrressline2 = this.padrressline2;
        }
    }
      if (field === 'EMS_EM_PA_State__c') {
        this.pastate = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.pastate = null;
        }
        if (this.inputcheckboxValue == 'Checked'){
          this.castate = this.pastate;
        }
    }
      if (field === 'EMS_EM_PA_City__c') {
        this.pacity = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.pacity = null;
        }
        if (this.inputcheckboxValue == 'Checked'){
          this.cacity = this.pacity;
        }
    }
      if (field === 'EMS_EM_PA_Zip__c') {
        this.pazip = event.target.value;
        //console.log(event.target.value);
        if(event.target.value == ''){
          this.pazip = null;
        }
        if (this.inputcheckboxValue == 'Checked'){
          this.cazip = this.pazip;
        }
    }
  }



  inputcheckboxexperience;
  showExperienceyouhave = false;
  experienceCheckboxChange(event) {
    this.inputcheckboxexperience = event.target.checked;
    //console.log('this.inputcheckboxexperience-->', this.inputcheckboxexperience);

    if (this.inputcheckboxexperience == true) {
      this.showExperienceyouhave = true;
      this.inputcheckboxexperience = true;
    }
     else {
      this.showExperienceyouhave = false;
    }
    
  }


  //Documents code here....
  AdditionalrecordId;
  onboardingrecordId;
  //---------------------------------------------------------------------------------below code is for education 

  LevelofEducationValue = [

    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


  ];
  LevelofEducationValue1 = [

    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


  ];
  LevelofEducationValue2 = [

    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


  ];
  LevelofEducationValue3 = [

    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


  ];
  LevelofEducationValue4 = [

    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


  ];

  LevelofEducationValue5 = [

    { label: 'Std X/SSC', value: 'Std X/SSC' },
    { label: 'Std XII/HSC', value: 'Std XII/HSC' },
    { label: 'Graduate', value: 'Graduate' },
    { label: 'Post Graduate', value: 'Post Graduate' }


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


  educationalId;

  Degree(event) {
    this.degree = event.target.value;
  }

  Degree1(event) {
    this.degree1 = event.target.value;
  }

  Degree2(event) {
    this.degree2 = event.target.value;
  }

  Degree3(event) {
    this.degree3 = event.target.value;
  }

  Degree4(event) {
    this.degree4 = event.target.value;
  }

  Degree5(event) {
    this.degree5 = event.target.value;
  }

  LevelofEducation(event) {
    this.levleofedu = event.target.value;
  }

  LevelofEducation1(event) {
    this.levleofedu1 = event.target.value;
  }

  LevelofEducation2(event) {
    this.levleofedu2 = event.target.value;
  }

  LevelofEducation3(event) {
    this.levleofedu3 = event.target.value;
  }

  LevelofEducation4(event) {
    this.levleofedu4 = event.target.value;
  }

  LevelofEducation5(event) {
    this.levleofedu5 = event.target.value;
  }

  fieldofStudy(event) {
    this.fieldOfStudy = event.target.value;
  }

  fieldofStudy1(event) {
    this.fieldOfStudy1 = event.target.value;
  }

  fieldofStudy2(event) {
    this.fieldOfStudy2 = event.target.value;
  }

  fieldofStudy3(event) {
    this.fieldOfStudy3 = event.target.value;
  }

  fieldofStudy4(event) {
    this.fieldOfStudy4 = event.target.value;
  }

  fieldofStudy5(event) {
    this.fieldOfStudy5 = event.target.value;
  }

  InstitutionName(event) {
    this.instutionname = event.target.value;
  }

  InstitutionName1(event) {
    this.instutionname1 = event.target.value;
  }

  InstitutionName2(event) {
    this.instutionname2 = event.target.value;
  }

  InstitutionName3(event) {
    this.instutionname3 = event.target.value;
  }

  InstitutionName4(event) {
    this.instutionname4 = event.target.value;
  }

  InstitutionName5(event) {
    this.instutionname5 = event.target.value;
  }

  GraduationDate(event) {
    this.graduationDate = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    console.log("this.graduationDate", this.graduationDate);
    if (this.graduationDate >= today) {

      displayShowtoastMessage('Error', 'Please Enter Correct Graduation Date', 'error', this);
    }
  }

  GraduationDate1(event) {
    this.graduationDate1 = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    console.log("this.graduationDate", this.graduationDate1);
    if (this.graduationDate1 >= today) {
      displayShowtoastMessage('Error', 'Please Enter Correct Graduation Date', 'error', this);
    }
  }

  GraduationDate2(event) {
    this.graduationDate2 = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    console.log("this.graduationDate", this.graduationDate2);
    if (this.graduationDate2 >= today) {
      displayShowtoastMessage('Error', 'Please Enter Correct Graduation Date', 'error', this);
    }
  }

  GraduationDate3(event) {
    this.graduationDate3 = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    console.log("this.graduationDate", this.graduationDate3);
    if (this.graduationDate3 >= today) {
      displayShowtoastMessage('Error', 'Please Enter Correct Graduation Date', 'error', this);
    }
  }

  GraduationDate4(event) {
    this.graduationDate4 = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    console.log("this.graduationDate", this.graduationDate4);
    if (this.graduationDate4 >= today) {
      displayShowtoastMessage('Error', 'Please Enter Correct Graduation Date', 'error', this);
    }
  }

  GraduationDate5(event) {
    this.graduationDate5 = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    console.log("this.graduationDate", this.graduationDate5);
    if (this.graduationDate5 >= today) {
      displayShowtoastMessage('Error', 'Please Enter Correct Graduation Date', 'error', this);
    }
  }

  DateofBirthValidation(event) {
    this.dob = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy +'-'+ mm +'-'+dd;
   console.log("this.dob", this.dob);
   console.log("this.graduationDate", this.graduationDate);
    console.log("today", today);
    if(this.dob >= today ){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please Enter correct date of birth',
                variant: 'error',
            }),
        );
    }
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

  handleraddmore(event) {
    if (this.addmoreempfields == false) {
      this.addmoreempfields = true;
      this.hideplus = false;
    } else {
      this.addmoreempfields = true;
      this.hideplus = true;
    }
  }
  removesectionemp(event) {
    if (this.addmoreempfields == true) {
      this.addmoreempfields = false;
      this.hideplus = true;
    } else {
      this.addmoreempfields = true;
    }
  }

  handlerEmpExtra(event) {
    if (this.extraempfields == false) {
      this.extraempfields = true;
      this.hideextraadd = false;
    } else {
      this.extraempfields = true;
      this.hideextraadd = true;
    }
  }

  removesectionextra(event) {
    if (this.extraempfields == true) {
      this.extraempfields = false;
      this.hideextraadd = true;
    } else {
      this.extraempfields = true;
    }
  }
  handlerEmpExtra1(event) {
    if (this.extraempfields1 == false) {
      this.extraempfields1 = true;
      this.hideextraadd1 = false;
    } else {
      this.extraempfields1 = true;
      this.hideextraadd1 = true;
    }
  }

  removesectionextra1(event) {
    if (this.extraempfields1 == true) {
      this.extraempfields1 = false;
      this.hideextraadd1 = true;
    } else {
      this.extraempfields1 = true;
    }
  }
  handlerEmpExtra2(event) {
    if (this.extraempfields2 == false) {
      this.extraempfields2 = true;
      this.hideextraadd2 = false;
    } else {
      this.extraempfields2 = true;
      this.hideextraadd2 = true;
    }
  }

  removesectionextra2(event) {
    if (this.extraempfields2 == true) {
      this.extraempfields2 = false;
      this.hideextraadd2 = true;
    } else {
      this.extraempfields2 = true;
    }
  }
  handlerEmpExtra3(event) {
    if (this.extraempfields3 == false) {
      this.extraempfields3 = true;
      this.hideextraadd3 = false;
    } else {
      this.extraempfields3 = true;
      this.hideextraadd3 = true;
    }
  }

  removesectionextra3(event) {
    if (this.extraempfields3 == true) {
      this.extraempfields3 = false;
      this.hideextraadd3 = true;
    } else {
      this.extraempfields3 = true;
    }
  }

  //---------------------------------------------------------------------------------below code is for work experience
  @track jobtitle0;
  @track fromdate0;
  @track todate0;
  @track previouscompanyname0;
  @track previouscomemailid;

  JobTitle(event) {
    this.jobtitle0 = event.target.value;
  }

  Fromdate(event) {
    this.fromdate0 = event.target.value;
  }

  Todate(event) {
    this.todate0 = event.target.value;
  }

  changepreviouscompanyname(event) {
    this.previouscompanyname0 = event.target.value;
  }

  changePreCEmailId(event) {
    this.previouscomemailid = event.target.value;
  }

  jobtitle1;
  fromdate1;
  todate1;
  previouscompanyname1;

  JobTitle1(event) {
    this.jobtitle1 = event.target.value;
  }

  Fromdate1(event) {
    this.fromdate1 = event.target.value;
  }

  Todate1(event) {
    this.todate1 = event.target.value;
  }

  changepreviouscompanyname1(event) {
    this.previouscompanyname1 = event.target.value;
  }

  jobtitle2;
  fromdate2;
  todate2;
  previouscompanyname2;

  JobTitle2(event) {
    this.jobtitle2 = event.target.value;
  }

  Fromdate2(event) {
    this.fromdate2 = event.target.value;
  }

  Todate2(event) {
    this.todate2 = event.target.value;
  }

  changepreviouscompanyname2(event) {
    this.previouscompanyname2 = event.target.value;
  }

  jobtitle3;
  fromdate3;
  todate3;
  previouscompanyname3;

  JobTitle3(event) {
    this.jobtitle3 = event.target.value;
  }

  Fromdate3(event) {
    this.fromdate3 = event.target.value;
  }

  Todate3(event) {
    this.todate3 = event.target.value;
  }

  changepreviouscompanyname3(event) {
    this.previouscompanyname3 = event.target.value;
  }

  jobtitle4;
  fromdate4;
  todate4;
  previouscompanyname4;

  JobTitle4(event) {
    this.jobtitle4 = event.target.value;
  }

  Fromdate4(event) {
    this.fromdate4 = event.target.value;
  }

  Todate4(event) {
    this.todate4 = event.target.value;
  }

  changepreviouscompanyname4(event) {
    this.previouscompanyname4 = event.target.value;
  }

  jobtitle5;
  fromdate5;
  todate5;
  previouscompanyname5;

  JobTitle5(event) {
    this.jobtitle5 = event.target.value;
  }

  Fromdate5(event) {
    this.fromdate5 = event.target.value;
  }

  Todate5(event) {
    this.todate5 = event.target.value;
  }

  changepreviouscompanyname5(event) {
    this.previouscompanyname5 = event.target.value;
  }

  //----work hide and show handler
  addmoreworkfields = false;
  hideplus1 = true;
  addmoreworkfields1 = false;
  hidesecondadd = true;
  addmoreworkfields2 = false;
  hidethirdadd = true;
  addmoreworkfields3 = false;
  hidefourthadd = true;
  addmoreworkfields4 = false;
  hidefivthadd = true;

  handleraddwork(event) {
    if (this.addmoreworkfields == false) {
      this.addmoreworkfields = true;
      this.hideplus1 = false;
    } else {
      this.addmoreworkfields = true;
      this.hideplus1 = true;
    }
  }

  removeworksection() {
    if (this.addmoreworkfields == true) {
      this.addmoreworkfields = false;
      this.hideplus1 = true;
    } else {
      this.addmoreworkfields = true;
    }
  }

  handleraddwork1() {
    if (this.addmoreworkfields1 == false) {
      this.addmoreworkfields1 = true;
      this.hidesecondadd = false;
    } else {
      this.addmoreworkfields1 = true;
      this.hidesecondadd = true;
    }
  }

  removeworksection1() {
    if (this.addmoreworkfields1 == true) {
      this.addmoreworkfields1 = false;
      this.hidesecondadd = true;
    } else {
      this.addmoreworkfields1 = true;
    }
  }

  handleraddwork2() {
    if (this.addmoreworkfields2 == false) {
      this.addmoreworkfields2 = true;
      this.hidethirdadd = false;
    } else {
      this.addmoreworkfields2 = true;
      this.hidethirdadd = true;
    }
  }

  removeworksection2() {
    if (this.addmoreworkfields2 == true) {
      this.addmoreworkfields2 = false;
      this.hidethirdadd = true;
    } else {
      this.addmoreworkfields2 = true;
    }
  }

  handleraddwork3() {
    if (this.addmoreworkfields3 == false) {
      this.addmoreworkfields3 = true;
      this.hidefourthadd = false;
    } else {
      this.addmoreworkfields3 = true;
      this.hidefourthadd = true;
    }
  }

  removeworksection3() {
    if (this.addmoreworkfields3 == true) {
      this.addmoreworkfields3 = false;
      this.hidefourthadd = true;
    } else {
      this.addmoreworkfields3 = true;
    }
  }

  handleraddwork4() {
    if (this.addmoreworkfields4 == false) {
      this.addmoreworkfields4 = true;
      this.hidefivthadd = false;
    } else {
      this.addmoreworkfields4 = true;
      this.hidefivthadd = true;
    }
  }

  removeworksection4() {
    if (this.addmoreworkfields4 == true) {
      this.addmoreworkfields4 = false;
      this.hidefivthadd = true;
    } else {
      this.addmoreworkfields4 = true;
    }
  }

  selectStep5() {
    if (this.readonlyfield != true) {
      const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
      if (isInputsCorrect) {
        if (this.showExperienceyouhave == true && this.fileName9 == null && this.fileName12 == null) {

          const even = new ShowToastEvent({
            message: 'Please Provide Appointment Letter!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } if (this.showExperienceyouhave == true && this.fileName12 == null) {

          const even = new ShowToastEvent({
            message: 'Please Provide Last 6 months Payslips!',
            variant: 'error'
          });
          this.dispatchEvent(even);
          return false;
        } 
        else {
          return true;
        }
      }
  else {
      const even = new ShowToastEvent({
        message: 'Please complete required field & avoid invalid data!!',
        variant: 'error'
      });
      this.dispatchEvent(even);
      return false;
    
    }
  }
}

  onboardingformId;
  additionalId;
  readonlyfield = false;

  SaveSubmitOnboarding(event) {
    if(this.isShowPersonalDetails){
      if(this.selectStep1()){
        //console.log('step1 => ',this.selectStep1);
        this.isPersonalUpdateCheckbox = true;
       this.statusUpdate = 'In Progress';
        //console.log('check box',this.isPersonalUpdateCheckbox);
        console.log('check box',this.statusUpdate);
        updateOnBoardingRequest(this);  
        console.log('check box',this.statusUpdate);
        if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        }
      }
    }
    if(this.isIdentifyDetails){
      if(this.selectStep2()){
        this.isIdentifyDetailsCheckbox = true;
        this.isIdentityStatusUpdate = 'In Progress';
        updateOnBoardingRequest(this); 
        if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        }    
      }
    }
  if(this.isAddressDetails){
    if(this.selectStep3()){
      this.isAddressDetailsCheckbox = true;
      this.isAdressStatusUpdate = 'In Progress';
      updateOnBoardingRequest(this); 
      if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        }
    }
    }
  if(this.isEducationDetails){
   if(this.selectStep4()) {  
    this.isEducationDetailsCheckbox = true;
    this.isEducationStatusUpdate = 'In Progress';
      updateOnBoardingRequest(this);
      if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        }
    }
  }
  if(this.isOtherCertifications){
    this.isOtherCertificationsCheckbox = true;
    this.isCertificationStatusUpdate = 'In Progress';
    updateOnBoardingRequest(this);
    if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        }
  }
  if(this.isWorkExperience){
    if(this.selectStep5()){
     this.isWorkExperienceCheckbox = true;
     this.isWorkExperienceStatusUpdate = 'In Progress';
    updateOnBoardingRequest(this);
    if(this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false)
        {
          this.buttonDisable = true;
        }
        else{
          this.buttonDisable = false;
        }
  }
}
  }
  confirmSubmit(event){
  if(this.isPersonalUpdateCheckbox && this.isIdentifyDetailsCheckbox && this.isAddressDetailsCheckbox && this.isEducationDetailsCheckbox && this.isOtherCertificationsCheckbox && this.isWorkExperienceCheckbox && this.isCompanyInformationValueChecked) 
  {
    this.isConfirmSubmit = true;
    this.readonlyfield = true;
    this.confirmStatusUpdate = 'Submitted for Review';
    updateOnBoardingRequest(this);
    displayShowtoastMessage('Success','Onboarding Form Submitted Successfully','success',this);
    this.buttonDisable = true;
  }
  else{
    const even = new ShowToastEvent({
      message: 'Please complete all the required section',
      variant: 'error'
    });
    this.dispatchEvent(even);
    return false;

  }
  }

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

    uploadFilesFromThis(event, this);
  }

  onFileUpload1(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload2(event) {
    if(event.target.files.length > 0 && event.target.files[0].size < 2000000 && (event.target.files[0].type =="image/png" || event.target.files[0].type =="image/jpeg" || event.target.files[0].type =="image/jpg")) {
      let files = [];
          let file = event.target.files[0];
          this.fileName2 = event.target.files[0].name;
          let reader = new FileReader();
          reader.onloadend = e => {
              let base64 = 'base64,';
              let content = reader.result.indexOf(base64) + base64.length;
              let fileContents = reader.result.substring(content);
              this.filesUploaded.push({PathOnClient: file.name, Title: 'passport_'+file.name, VersionData: fileContents});
          };
          reader.readAsDataURL(file);
  }else{
    const even = new ShowToastEvent({
      message: 'File Size must be less than 2Mb & file type should be image/jpeg/png/jpeg only',
      variant: 'error'
  });
  this.dispatchEvent(even);
  } 
  //  console.log('photo-->' + event.target.files[0].type);
   // uploadFilesFromThis(event, this);
  }

  file3;

  onFileUpload3(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload4(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload5(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload6(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload7(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload8(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload9(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload10(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload11(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload12(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload13(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload14(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload15(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload16(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload17(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload1(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload2(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload3(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload4(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload5(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload6(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload7(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload8(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload9(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload10(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload11(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload12(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload13(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload14(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload15(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload16(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload17(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload18(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload19(event) {
    uploadFilesFromThis(event, this);
  }

  onCertificationUpload20(event) {
    // uploadFiles(event,this);
    uploadFilesFromThis(event, this);
  }

  // other certifications 

@track isLoading = true;
@track records;
wiredRecords;
contactId;
error;
@track deleteCertificationIds = '';

certificationName = [
    { label: 'Salesforce Certified Associate', value: 'Salesforce Certified Associate' },
    { label: 'Salesforce Certified Administrator', value: 'Salesforce Certified Administrator' },
    { label: 'Salesforce Certified Advanced Administrator', value: 'Salesforce Certified Advanced Administrator' },
    { label: 'Salesforce Certified Business Analyst', value: 'Salesforce Certified Business Analyst' },
    { label: 'Salesforce Certified Platform App Builder', value: 'Salesforce Certified Platform App Builder' },
    { label: 'Salesforce Certified Data Architect', value: 'Salesforce Certified Data Architect' },
    { label: 'Salesforce Certified Development Lifecycle and Deployment Architect', value: 'Salesforce Certified Development Lifecycle and Deployment Architect' },
    { label: 'Salesforce Certified Identity and Access Management Architect', value: 'Salesforce Certified Identity and Access Management Architect' },
    { label: 'Salesforce Certified Integration Architect', value: 'Salesforce Certified Integration Architect' },
    { label: 'Salesforce Certified Sharing and Visibility Architect', value: 'Salesforce Certified Sharing and Visibility Architect' },
    { label: 'Salesforce Certified System Architect', value: 'Salesforce Certified System Architect' },
    { label: 'Salesforce Certified Application Architect', value: 'Salesforce Certified Application Architect' },
    { label: 'Salesforce Certified Heroku Architect', value: 'Salesforce Certified Heroku Architect' },
    { label: 'Salesforce Certified B2B Solution Architect', value: 'Salesforce Certified B2B Solution Architect' },
    { label: 'Salesforce Certified B2C Commerce Architect', value: 'Salesforce Certified B2C Commerce Architect' },
    { label: 'Salesforce Certified B2C Solution Architect', value: 'Salesforce Certified B2C Solution Architect' },
    { label: 'Certified Technical Architect (CTA)', value: 'Certified Technical Architect (CTA)' },
    { label: 'Salesforce Certified Education Cloud Consultant', value: 'Salesforce Certified Education Cloud Consultant' },
    { label: 'Salesforce Certified Experience Cloud Consultant', value: 'Salesforce Certified Experience Cloud Consultant' },
    { label: 'Salesforce Certified Field Service Consultant', value: 'Salesforce Certified Field Service Consultant' },
    { label: 'Salesforce Certified Nonprofit Cloud Consultant', value: 'Salesforce Certified Nonprofit Cloud Consultant' },
    { label: 'Salesforce Certified OmniStudio Consultant', value: 'Salesforce Certified OmniStudio Consultant' },
    { label: 'Salesforce Certified Sales Cloud Consultant', value: 'Salesforce Certified Sales Cloud Consultant' },
    { label: 'Salesforce Certified Service Cloud Consultant', value: 'Salesforce Certified Service Cloud Consultant' },
    { label: 'Salesforce Certified Tableau CRM and Einstein Discovery Consultant', value: 'Salesforce Certified Tableau CRM and Einstein Discovery Consultant' },
    { label: 'Salesforce Certified CPQ Specialist', value: 'Salesforce Certified CPQ Specialist' },
    { label: 'Salesforce Certified User Experience Designer', value: 'Salesforce Certified User Experience Designer' },
    { label: 'Salesforce Certified Strategy Designer', value: 'Salesforce Certified Strategy Designer' },
    { label: 'Salesforce Certified B2C Commerce Developer', value: 'Salesforce Certified B2C Commerce Developer' },
    { label: 'Salesforce Certified Industries CPQ Developer', value: 'Salesforce Certified Industries CPQ Developer' },
    { label: 'Salesforce Certified JavaScript Developer I – Multiple Choice', value: 'Salesforce Certified JavaScript Developer I – Multiple Choice' },
    { label: 'Salesforce Certified OmniStudio Developer', value: 'Salesforce Certified OmniStudio Developer' },
    { label: 'Salesforce Certified Platform Developer', value: 'Salesforce Certified Platform Developer' },
    { label: 'Salesforce Certified Platform Developer II – Multiple Choice', value: 'Salesforce Certified Platform Developer II – Multiple Choice' },
    { label: 'Salesforce Certified Marketing Cloud Administrator', value: 'Salesforce Certified Marketing Cloud Administrator' },
    { label: 'Salesforce Certified Marketing Cloud Consultant', value: 'Salesforce Certified Marketing Cloud Consultant' },
    { label: 'Salesforce Certified Marketing Cloud Developer', value: 'Salesforce Certified Marketing Cloud Developer' },
    { label: 'Salesforce Certified Marketing Cloud Email Specialist', value: 'Salesforce Certified Marketing Cloud Email Specialist' },
    { label: 'Salesforce Certified Pardot Consultant', value: 'Salesforce Certified Pardot Consultant' },
    { label: 'Salesforce Certified Pardot Specialist', value: 'Salesforce Certified Pardot Specialist' },
    { label: 'Other', value: 'Other' }
  ];

//to add row
addRow() {
    let randomId = Math.random() * 16;
    let myNewElement = { Type__c: 'Certification' ,  Certification_Name__c: "", Other__c: "", Id: randomId, Completion_Date__c: "", Contact__c: this.contactId, Onboarding_Request__c: this.onboardingformId};
    this.records = [...this.records, myNewElement];
}

get isDisable(){
    return (this.isLoading || (this.wiredRecords.data.length == 0 && this.records.length == 0));
}


//show/hide spinner
handleIsLoading(isLoading) {
    this.isLoading = isLoading;
}
otherfield = false;
//update table row values in list
updateValues(event){
    var foundelement = this.records.find(ele => ele.Id == event.target.dataset.id);
    if(event.target.name === 'Certification_Name__c'){
        foundelement.Certification_Name__c = event.target.value;
        if(foundelement.Certification_Name__c === 'Other'){
          this.otherfield = true;
        }
        else{
          this.otherfield = false;
        }
    } else if(event.target.name === 'Completion_Date__c'){
        foundelement.Completion_Date__c = event.target.value;
    }else if(event.target.name === 'Other__c'){
      foundelement.Other__c = event.target.value;
  }
  
}

// get otherfield() {
//   return foundelement.Certification_Name__c === 'Other' ? true : false;
// }

//handle save and process dml 
handleSaveAction(){
    this.handleIsLoading(true);

    if(this.deleteCertificationIds !== ''){
        this.deleteCertificationIds = this.deleteCertificationIds.substring(1);
    }

    this.records.forEach(res =>{
        if(!isNaN(res.Id)){
            res.Id = null;
        }
    });
     
    dmlOnCertifications({data: this.records, removeCertificationIds : this.deleteCertificationIds})
    .then( result => {
        this.handleIsLoading(false);
        refreshApex(this.wiredRecords);
        this.updateRecordView(this.onboardingformId);
        updateOnBoardingRequest(this);
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Onboarding Form Other Certification Details Saved Successfully',
            variant: 'success',
          }),
        );
        //this.showToast('Success', result, 'Success', 'dismissable');
    }).catch( error => {
        this.handleIsLoading(false);
        console.log(error);
        this.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
    });
}

//remove records from table
handleDeleteAction(event){
    if(isNaN(event.target.dataset.id)){
        this.deleteCertificationIds = this.deleteCertificationIds + ',' + event.target.dataset.id;
    }
    this.records.splice(this.records.findIndex(row => row.Id === event.target.dataset.id), 1);
}

//fetch fetch Certifications records
@wire(fetchCertifications, {recordId : '$onboardingformId'})  
wiredContact(result) {
    this.wiredRecords = result; // track the provisioned value
    const { data, error } = result;

    if(data) {
        this.records = JSON.parse(JSON.stringify(data));
        this.error = undefined;
        this.handleIsLoading(false);
    } else if(error) {
        this.error = error;
        this.records = undefined;
        this.handleIsLoading(false);
    }
} 

showToast(title, message, variant, mode) {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    this.dispatchEvent(event);
}

updateRecordView() {
  //  setTimeout(() => {
  //       eval("$A.get('e.force:refreshView').fire();");
  //  }, 3000); 
}

}