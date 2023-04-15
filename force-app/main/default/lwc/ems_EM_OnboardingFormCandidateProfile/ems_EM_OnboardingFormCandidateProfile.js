import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchCertifications from '@salesforce/apex/EMS_EM_CreationOnboard.fetchCertifications';
import dmlOnCertifications from '@salesforce/apex/EMS_EM_CreationOnboard.dmlOnCertifications';
import fetchWorkEduData from '@salesforce/apex/EMS_EM_CreationOnboard.fetchEducation';
import dmlOnEducation from '@salesforce/apex/EMS_EM_CreationOnboard.dmlOnEducation';
import uploadFiles from '@salesforce/apex/EMS_EM_CreationOnboard.saveFiles';
import { refreshApex } from '@salesforce/apex';
import BannerPreOn from '@salesforce/resourceUrl/BannerPreOn';
import { uploadFilesFromThis, updateOnBoardingRequest, updateOnboardingInfoOnPageLoads, displayShowtoastMessage } from 'c/updateOnBoardingRequestForm';
import correctImage from '@salesforce/resourceUrl/Correct';
import wrongImage from '@salesforce/resourceUrl/Wrong';
const MAX_FILE_SIZE = 20971520; // 20 MB

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
  //console.log('sdfghn' + str)
  return str;
}

const maskPanNumber = value => {

  if (value === undefined || value === null || value === "") {
    return value;
  }

  //let v = value.replace(/\W/g,'');
  let str = value.replace(/\d(?=\d{0})/g, "*");
  //console.log('sdfghn' + str)
  return str;
}

const maskPassportNumber = value => {

  if (value === undefined || value === null || value === "") {
    return value;
  }

  //let v = value.replace(/\W/g,'');
  let str = value.replace(/\w(?=\w{4})/g, "*");
  //console.log('sdfghn' + str)
  return str;
}

export default class LightningExampleAccordionMultiple extends LightningElement {
  onboardingformId
  activeSections = ['Profile'];
  activeSectionsConfirm = ['Profile', 'Company Information'];
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
  expression1 = false;
  isUploadReq = true;
  isUploadEduReq = true;

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
    //console.log(event.target.value);
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
      if (this.educationDetails.length == 0) {
        this.addRowEdu();
      } 

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
      this.statusUpdate = 'In Progress';
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
      //this.isWorkExperienceCheckbox = true;
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
      //console.log('Confirm Info', this.isConfirm);
      this.isWorkExperience = false;
      this.isOtherCertifications = false;
      this.isEducationDetails = false;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isAddressDetails = false;
      this.isCompanyInformation = false;
      if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
    }
    else if (seletedDetails === "Company Information") {
      this.isCompanyInformation = true;
      this.isCompanyInformationValueChecked = true;
      updateOnBoardingRequest(this);
      if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }

      //console.log('Company Info', this.isCompanyInformation);
      this.isAddressDetails = false;
      this.isShowPersonalDetails = false;
      this.isIdentifyDetails = false;
      this.isEducationDetails = false;
      this.isOtherCertifications = false;
      this.isWorkExperience = false;
      this.isConfirm = false;
      if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
  }

  //Aadhar Number
  @api aadhaarNo;
  @api actualAadharNumber;
  @track companyInformation;
  @track dataList;

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
    //console.log('actualPanNumber', +this.actualPanNumber);
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
    //console.log('actualPassportNumber', +this.actualPassportNumber);
  }


  PassportNumber(event) {
    let value = event.detail.value;
    this.actualPassportNumber = value.replace(/\W/g, '');
    //console.log('actualPassportNumber', +this.actualPassportNumber);
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
        today = yyyy + '-' + mm + '-' + dd;
        if (this.dob >= today) {
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Please enter a valid date of birth',
              variant: 'error',
            }),
          ); this.handleIsLoading(false);
          return false;
        } else if (this.ph === this.altphone) {
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Contact Number and Alternate Contact Number should not be the same.',
              variant: 'error'
            })
          ); this.handleIsLoading(false);
          return false;
        } else {
          return true;
        }
      } else {
        const even = new ShowToastEvent({
          message: 'Please complete the required field and avoid invalid data.',
          variant: 'error'
        }); this.handleIsLoading(false);
        this.dispatchEvent(even);
        return false;
      }
    } else {
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
          }); this.handleIsLoading(false);
          this.dispatchEvent(even);
          return false;
        }
      } else {
        const even = new ShowToastEvent({
          message: "Please complete the required field and avoid invalid data.",
          variant: "error"
        }); this.handleIsLoading(false);
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
          }); this.handleIsLoading(false);
          this.dispatchEvent(even);
          return false;
        }

      } else {
        const even = new ShowToastEvent({
          message: 'Please complete the required field and avoid invalid data.',
          variant: 'error'
        }); this.handleIsLoading(false);
        this.dispatchEvent(even);
        return false;
      }
    } this.handleIsLoading(true);
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
  @track doYouHaveExp;
  @track ph;
  @track dob;
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

  personalemailchange(event) {
    this.personalemail = event.target.value;
  }
  altephone(event) {
    this.altphone = event.target.value;
  }

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
    if (this.inputcheckboxValue == 'Checked') {
      //console.log('address checked')
      this.padrressline1 = this.cadrressline1;
      this.padrressline2 = this.cadrressline2;
      this.pastate = this.castate;
      this.pacity = this.cacity;
      this.pazip = this.cazip;
      this.paFlag = true;
      this.readonlyfield1 = true;

    } else {
      //console.log('address unchecked')
      this.padrressline1 = '';
      this.padrressline2 = '';
      this.pastate = '';
      this.pacity = '';
      this.pazip = '';
      this.readonlyfield1 = false;
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
      this.paFlag = false;
    }
    const field = event.target.name;
    if (field === 'Current_Address_Line_1__c') {
      this.cadrressline1 = event.target.value;
      if (event.target.value == '') {
        this.cadrressline1 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.padrressline1 = this.cadrressline1;
      }
    }
    if (field === 'Current_Address_Line_2__c') {
      this.cadrressline2 = event.target.value;
      if (event.target.value == '') {
        this.cadrressline2 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.padrressline2 = this.cadrressline2;
      }
    }
    if (field === 'EMS_EM_CA_State__c') {
      this.castate = event.target.value;
      if (event.target.value == '') {
        this.castate = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.pastate = this.castate;
      }
    }
    if (field === 'EMS_EM_CA_City__c') {
      this.cacity = event.target.value;
      if (event.target.value == '') {
        this.cacity = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.pacity = this.cacity;
      }
    }
    if (field === 'EMS_EM_CA_Zip__c') {
      this.cazip = event.target.value;
      if (event.target.value == '') {
        this.cazip = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.pazip = this.cazip;
      }
    }
    //permanent address
    if (field === 'Permanent_Address_Line_1__c') {
      this.padrressline1 = event.target.value;
      if (event.target.value == '') {
        this.padrressline1 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cadrressline1 = this.padrressline1;
      }
    }
    if (field === 'Permanent_Address_Line_2__c') {
      this.padrressline2 = event.target.value;
      if (event.target.value == '') {
        this.padrressline2 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cadrressline2 = this.padrressline2;
      }
    }
    if (field === 'EMS_EM_PA_State__c') {
      this.pastate = event.target.value;
      if (event.target.value == '') {
        this.pastate = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.castate = this.pastate;
      }
    }
    if (field === 'EMS_EM_PA_City__c') {
      this.pacity = event.target.value;
      if (event.target.value == '') {
        this.pacity = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cacity = this.pacity;
      }
    }
    if (field === 'EMS_EM_PA_Zip__c') {
      this.pazip = event.target.value;
      if (event.target.value == '') {
        this.pazip = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cazip = this.pazip;
      }
    }
  }




  //Documents code here....
  AdditionalrecordId;
  onboardingrecordId;
  //---------------------------------------------------------------------------------below code is for education 

  DateofBirthValidation(event) {
    this.dob = event.target.value;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, '0');
    var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    if (this.dob >= today) {
      this.dispatchEvent(
        new ShowToastEvent({
          message: 'Please enter a valid date of birth.',
          variant: 'error',
        }),
      ); this.handleIsLoading(false);
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
          message: 'Please complete the required field and avoid invalid data.',
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
  readonlyfield1 = false;

  SaveSubmitOnboarding(event) {
    this.handleIsLoading(true);
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
      .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    if (this.isShowPersonalDetails) {
      if (this.selectStep1()) {
        if(isInputsCorrect){
          this.isPersonalUpdateCheckbox = true;
          this.statusUpdate = 'In Progress';
          updateOnBoardingRequest(this);
          if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
            this.buttonDisable = true;
          }
          else {
            this.buttonDisable = false;
          }
        }else {
          this.handleIsLoading(false);
          const even = new ShowToastEvent({
            message: 'Please complete the required field and avoid invalid data.',
            variant: 'error'
          });
          this.dispatchEvent(even);
        }      
      }
    }
    if (this.isIdentifyDetails) {
      this.handleIsLoading(false);
      if (this.selectStep2()) {
        this.isIdentifyDetailsCheckbox = true;
        this.statusUpdate = 'In Progress';
        this.handleIsLoading(true);
        updateOnBoardingRequest(this);

        if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
          this.buttonDisable = true;
        }
        else {
          this.buttonDisable = false;
        }
      }
    }
    if (this.isAddressDetails) {
      if (this.selectStep3()) {
        this.isAddressDetailsCheckbox = true;
        this.statusUpdate = 'In Progress';
        updateOnBoardingRequest(this);
        if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
          this.buttonDisable = true;
        }
        else {
          this.buttonDisable = false;
        }
      }
    }
    if (this.isEducationDetails) {
      if (this.selectStep4()) {
        this.isEducationDetailsCheckbox = true;
        this.statusUpdate = 'In Progress';
        updateOnBoardingRequest(this);
        if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
          this.buttonDisable = true;
        }
        else {
          this.buttonDisable = false;
        }
      }
    }
    if (this.isOtherCertifications) {
      this.isOtherCertificationsCheckbox = true;
      this.statusUpdate = 'In Progress';
      updateOnBoardingRequest(this);
      if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    if (this.isWorkExperience) {
      if (this.selectStep5()) {
        this.isWorkExperienceCheckbox = true;
        this.statusUpdate = 'In Progress';
        updateOnBoardingRequest(this);
        if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
          this.buttonDisable = true;
        }
        else {
          this.buttonDisable = false;
        }
      }
    }
  }

  confirmSubmit(event) {
    if (this.isPersonalUpdateCheckbox && this.isIdentifyDetailsCheckbox && this.isAddressDetailsCheckbox && this.isEducationDetailsCheckbox && this.isOtherCertificationsCheckbox && this.isWorkExperienceCheckbox && this.isCompanyInformationValueChecked) {
      this.isConfirmSubmit = true;
      this.readonlyfield = true;
      this.statusUpdate = 'Submitted for Review';
      updateOnBoardingRequest(this);
      displayShowtoastMessage('Onboarding form submitted successfully', 'success', this);
      this.buttonDisable = true;
      this.expression1 = true
      this.disableFlag = true;
      this.readonlyfield1 = true;
    }
    else {
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
  fileContents; fileReader; content;

  //uploading all files
  @api accept = '.pdf';

  onFileUpload(event) {

    uploadFilesFromThis(event, this);
  }

  onFileUpload1(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload2(event) {
    if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && (event.target.files[0].type == "image/png" || event.target.files[0].type == "image/jpeg" || event.target.files[0].type == "image/jpg")) {
      let files = [];
      let file = event.target.files[0];
      this.fileName2 = event.target.files[0].name;
      let reader = new FileReader();
      reader.onloadend = e => {
        let base64 = 'base64,';
        let content = reader.result.indexOf(base64) + base64.length;
        let fileContents = reader.result.substring(content);
        this.filesUploaded.push({ PathOnClient: file.name, Title: 'Picture_' + file.name, VersionData: fileContents });
      };
      reader.readAsDataURL(file);
    } else {
      const even = new ShowToastEvent({
        message: 'The maximum file size is 2MB and the supported file type is image/jpeg/png/jpeg only',
        variant: 'error'
      });
      this.dispatchEvent(even);
    }

  }

  file3;

  onFileUpload3(event) {
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
    { label: 'Salesforce Certified Pardot Specialist', value: 'Salesforce Certified Pardot Specialist' }
  ];

  //to add row
  addRow() {
    this.countcerti = this.records.length + 1;
    let randomId = Math.random() * 16;
    let myNewElement = { Type__c: 'Certification', Certification_Name__c: "", Other__c: "", Id: randomId, Completion_Date__c: "", Contact__c: this.contactId, Onboarding_Request__c: this.onboardingformId };
    this.records = [...this.records, myNewElement];
    this.countcerti++;
  }

  get isDisable() {
    return (this.isLoading || (this.wiredRecords.data.length == 0 && this.records.length == 0));
  }


  //show/hide spinner
  handleIsLoading(isLoading) {
    this.isLoading = isLoading;
  }

  @track countcerti = 0;
  otherfield = false;
  //update table row values in list
  updateValues(event) {
    var foundelement = this.records.find(ele => ele.Id == event.target.dataset.id);
    if (event.target.name === 'Certification_Name__c') {
      foundelement.Certification_Name__c = event.target.value;
      if (foundelement.Certification_Name__c === 'Other') {
        this.otherfield = true;
      }
      else {
        this.otherfield = false;
      }
    } else if (event.target.name === 'Completion_Date__c') {
      foundelement.Completion_Date__c = event.target.value;
      var today = new Date();
      var dd = String(today.getDate()).padStart(2, '0');
      var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
      var yyyy = today.getFullYear();
      today = yyyy + '-' + mm + '-' + dd;
      if (foundelement.Completion_Date__c >= today) {
        foundelement.Completion_Date__c = undefined;
        displayShowtoastMessage('Please enter a valid certification completion date', 'error', this);
      }
    } else if (event.target.name === 'Other__c') {
      foundelement.Other__c = event.target.value;
    }

  }
  //handle save and process dml 
  handleSaveAction() {
    this.handleIsLoading(true);

    /* if (this.deleteCertificationIds !== '') {
      this.deleteCertificationIds = this.deleteCertificationIds.substring(1);
    } */

    this.records.forEach(res => {
      if (!isNaN(res.Id)) {
        res.Id = null;
      }
    });
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
      .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    if (isInputsCorrect) {
      dmlOnCertifications({ data: this.records, removeCertificationIds: this.deleteCertificationIds })
        .then(result => {
          this.handleIsLoading(false);
          refreshApex(this.wiredRecords);
          this.updateRecordView(this.onboardingformId);
          this.statusUpdate = 'In Progress';
          updateOnBoardingRequest(this);
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Details saved successfully',
              variant: 'success',
            }),
          );
          //this.showToast('Success', result, 'Success', 'dismissable');
        }).catch(error => {
          this.handleIsLoading(false);
          //console.log(error);
          this.showToast('Please refresh the page and retry.', error.body.message, 'Error', 'dismissable');
        });

    } else {
      this.handleIsLoading(false);
      const even = new ShowToastEvent({
        message: 'Please complete the required field and avoid invalid data.',
        variant: 'error'
      });
      this.dispatchEvent(even);
    }
  }

  //remove records from table
  handleDeleteAction(event) {
    if (isNaN(event.target.dataset.id)) {
      this.deleteCertificationIds = this.deleteCertificationIds + ',' + event.target.dataset.id;
    }
    this.records.splice(this.records.findIndex(row => row.Id === event.target.dataset.id), 1);
  }

  //fetch fetch Certifications records
  @wire(fetchCertifications, { recordId: '$onboardingformId' })
  wiredContact(result) {
    this.wiredRecords = result; // track the provisioned value
    //console.log('fetchCertifications------------>' , this.wiredRecords);
    const { data, error } = result;

    if (data) {
      this.records = JSON.parse(JSON.stringify(data));
      this.error = undefined;
      this.handleIsLoading(false);
    } else if (error) {
      this.error = error;
      this.records = undefined;
      this.handleIsLoading(false);
    }
  }

  showToast(message, variant, mode) {
    const event = new ShowToastEvent({
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(event);
  }

  updateRecordView() {
  }

  // Work Experience Details

  @track educationDetails;
  @track workDetails;
  @track deleteEduWorkIds = '';
  @track deleteWorkIds = '';
  @track filesData = [];
  @track filesDocData = [];
  @track dataDocList;

  DoyouName = [
    { label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' },
  ]
  @track count = 0;
  @track isdel = false;

  @track counting = 0;
  @track isdeleting = false;
  @track hidePreviousCompanyHR = true;


  addRowEdu() {
    this.count = this.educationDetails.length + 1;
    if (this.count == 1) {
      this.isdel = false;
    } else {
      this.isdel = true;
    }

    let randomId = Math.random() * 16;
    let myNewElement = { RecordType: { Name: 'Education Details' }, index: this.count, isDelete: this.isdel, EMS_EM_Education__c: "", Id: randomId, EMS_EM_Degree__c: "", EMS_EM_Field_of_Study__c: "", EMS_EM_IName__c: "", EMS_EM_GDate__c: "", Onboarding_Request__c: this.onboardingformId, ContactId__c: this.contactId };
    this.educationDetails = [...this.educationDetails, myNewElement];
    this.count++;
  }

  //handle save and process dml 
  handleSaveEduAction() {
    this.handleIsLoading(true);
    this.educationDetails.forEach(res => {
      if (!isNaN(res.Id)) {
        res.Id = null;
      }
    });
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
      .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    if (isInputsCorrect) {
      dmlOnEducation({ data: this.educationDetails, removeEducationIds: this.deleteEduWorkIds })
        .then(result => {
          /* this.educationDetails=[];
          for(let i=0;i<result.length;i++){
            this.educationDetails.push(result[i]); 
          } */
          this.handleIsLoading(false);
          this.isEducationDetailsCheckbox = true;
          this.statusUpdate = 'In Progress';
          updateOnBoardingRequest(this);
          refreshApex(this.wiredEdu);
          this.updateEduRecordView(this.onboardingformId);
          uploadFiles({ recordId: this.onboardingformId, filedata: JSON.stringify(this.filesData) })
            .then(result => {
              if (result && result == 'success') {
                this.filesData = [];
                updateOnboardingInfoOnPageLoads(this);
              } else {
                this.dispatchEvent(
                  new ShowToastEvent({
                    message: result,
                    variant: 'error',
                  }),
                );
              }
            }).catch(error => {
              if (error && error.body && error.body.message) {
                this.dispatchEvent(
                  new ShowToastEvent({
                    message: error.body.message,
                    variant: 'error',
                  }),
                );
              }
            }).finally(() => this.showSpinner = false);
          if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
            this.buttonDisable = true;
          }
          else {
            this.buttonDisable = false;
          }
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Details saved successfully',
              variant: 'success',
            }),
          );
        }).catch(error => {
          this.handleIsLoading(false);
          console.log(error);
          this.showToast('Please refresh the page and retry.', error.body.message, 'Error', 'dismissable');
        });

    } else {
      const even = new ShowToastEvent({
        message: 'Please complete the required field and avoid invalid data.',
        variant: 'error'
      }); this.handleIsLoading(false);
      this.dispatchEvent(even);

    }
  }


  handleDeleteEduAction(event) {
    this.count--;
     if (isNaN(event.target.dataset.id) && this.deleteEduWorkIds != '' ) {
      this.deleteEduWorkIds = this.deleteEduWorkIds + ',' + event.target.dataset.id;
    }else{
      this.deleteEduWorkIds =  event.target.dataset.id;
    }
    this.educationDetails.splice(this.educationDetails.findIndex(row => row.Id === event.target.dataset.id), 1);
  }

  eduupdateValues(event) {
    var foundelement = this.educationDetails.find(ele => ele.Id == event.target.dataset.id);
    if (event.target.name === 'EMS_EM_Education__c') {
      foundelement.EMS_EM_Education__c = event.target.value;
    } else if (event.target.name === 'EMS_EM_Degree__c') {
      foundelement.EMS_EM_Degree__c = event.target.value;
    } else if (event.target.name === 'EMS_EM_Field_of_Study__c') {
      foundelement.EMS_EM_Field_of_Study__c = event.target.value;
    } else if (event.target.name === 'EMS_EM_IName__c') {
      foundelement.EMS_EM_IName__c = event.target.value;
    } else if (event.target.name === 'EMS_EM_GDate__c') {
      foundelement.EMS_EM_GDate__c = event.target.value;
      var today = new Date();
      var dd = String(today.getDate()).padStart(2, '0');
      var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
      var yyyy = today.getFullYear();
      today = yyyy + '-' + mm + '-' + dd;
      if (foundelement.EMS_EM_GDate__c >= today) {
        foundelement.EMS_EM_GDate__c = undefined;
        displayShowtoastMessage('Please enter a valid graduation date.', 'error', this);
      }
    }
  }

  handleFileUploaded(event) {
    if (event.target.files.length > 0) {
      for (var i = 0; i < event.target.files.length; i++) {
        if (event.target.files[i].size > MAX_FILE_SIZE) {
          this.showToast('error', 'File size exceeded the upload size limit.');
          return;
        }
        if (event.target.files[i].type != "application/pdf" && event.target.files[i].name.split('.').pop().toLowerCase() !== 'zip') {
          this.showToast('error', 'Only PDF and Zip file formats are allowed.');
          return;
        }
        let file = event.target.files[i];
        let fileExtension = file.name.substring(file.name.lastIndexOf('.'));
        let newFileName = 'Certificate_' + file.name;
        let renamedFile = new File([file], newFileName, { type: file.type });
        let reader = new FileReader();
        reader.onload = e => {
          var fileContents = reader.result.split(',')[1]
          this.filesData.push({ 'fileName': renamedFile.name, 'fileContent': fileContents });
        };
        reader.readAsDataURL(renamedFile);
      }
    }
  }

  handleDocFileUploaded(event) {
    if (event.target.files.length > 0) {
      for (var i = 0; i < event.target.files.length; i++) {
        if (event.target.files[i].size > MAX_FILE_SIZE) {
          this.showToast('error', 'File size exceeded the upload size limit.');
          return;
        }
        if (event.target.files[i].type != "application/pdf" && event.target.files[i].name.split('.').pop().toLowerCase() !== 'zip') {
          this.showToast('error', 'Only PDF and Zip file formats are allowed.');
          return;
        }
        let file = event.target.files[i];
        let fileExtension = file.name.substring(file.name.lastIndexOf('.'));
        let newFileName = 'Work_Details_' + file.name;
        let renamedFile = new File([file], newFileName, { type: file.type });
        let reader = new FileReader();
        reader.onload = e => {
          var fileContents = reader.result.split(',')[1]
          this.filesDocData.push({ 'fileName': renamedFile.name, 'fileContent': fileContents });
        };
        reader.readAsDataURL(renamedFile);
      }
    }
  }

  showToast(variant, message) {
    this.dispatchEvent(
      new ShowToastEvent({
        variant: variant,
        message: message,
      })
    );
  }
  removeReceiptImage(event) {
    var index = event.currentTarget.dataset.id;
    this.filesData.splice(index, 1);
  }

  removedocReceiptImage(event) {
    var index = event.currentTarget.dataset.id;
    this.filesDocData.splice(index, 1);
  }
  @wire(fetchWorkEduData, { recordId: '$onboardingformId' })
  WiredWorkEdu(result) {
    this.wiredEdu = result;

    if (result.data) {
      // Handle both Education and Work Details data separately
      const details = JSON.parse(JSON.stringify(result.data));
      this.educationDetails = details.filter(detail => detail.RecordType.Name === 'Education Details');
      if (this.educationDetails != null) {
        for (let i = 0; i < this.educationDetails.length; i++) {
          this.educationDetails[i].index = i + 1;
          if (i == 0) {
            this.educationDetails[i].isDelete = false;
          } else {
            this.educationDetails[i].isDelete = true;
          }
        }
      }
      if (this.educationDetails != null) {
        this.count++;
      }
      this.workDetails = details.filter(detail => detail.RecordType.Name === 'Work Details');
      if (this.workDetails != null) {
        for (let i = 0; i < this.workDetails.length; i++) {
          this.workDetails[i].index1 = i + 1;
          if (i == 0) {
            this.workDetails[i].isDelete1 = false;
            this.workDetails[i].isHide = true;
          } else {
            this.workDetails[i].isDelete1 = true;
            this.workDetails[i].isHide = false;
          }
        }
      }

      if (this.workDetails != null) {
        this.counting++;
      }
        if(this.workDetails.length > 0 && this.doYouHaveExp === 'Yes') {
          this.showExperienceyouhave = true;
       } 
      this.error = undefined;
      this.handleIsLoading(false);
    } else if (result.error) {
      // Handle any errors
      this.error = result.error;
      this.educationDetails = undefined;
      this.workDetails = undefined;
      this.handleIsLoading(false);
    }
  }
  updateEduRecordView() {
  }

  doYouHaveExp;
  showExperienceyouhave = false;
  experienceChange(event) {
    this.doYouHaveExp = event.target.value;
    if (this.doYouHaveExp === 'Yes') {
      this.showExperienceyouhave = true;
      if (this.workDetails.length < 1) {
        this.addRowWork();
      }
    }
    else {
      this.showExperienceyouhave = false;
      this.workDetails = [];

    }
  }

  addRowWork() {
    this.counting = this.workDetails.length + 1;
    if (this.counting == 1) {
      this.isdeleting = false;
      this.hidePreviousCompanyHR = true;
    } else {
      this.isdeleting = true;
      this.hidePreviousCompanyHR = false;
    }
    let randomId = Math.random() * 16;
    let myNewElement = {
      RecordType: { Name: 'Work Details' }, EMS_EM_Job_Title__c: "", Id: randomId, EMS_EM_From_Date__c: "",
      EMA_EM_To_Date__c: "", EMS_EM_Previous_Company_Name__c: "", EMS_EM_Previous_Company_HR_EmailId__c: "",
      index1: this.counting, isHide: this.hidePreviousCompanyHR,  isDelete1: this.isdeleting, Onboarding_Request__c: this.onboardingformId, ContactId__c: this.contactId
    };
    this.workDetails = [...this.workDetails, myNewElement];
    this.counting++;
  }

  handleDeleteWorkAction(event) {
    this.counting--;
    if (isNaN(event.target.dataset.id)) {
      this.deleteWorkIds = this.deleteWorkIds + ',' + event.target.dataset.id;
    }
    this.workDetails.splice(this.workDetails.findIndex(row => row.Id === event.target.dataset.id), 1);
/*     this.handleSaveWorkAction();
 */    if (this.workDetails.length < 1) {
      this.doYouHaveExp = undefined;
    }
  }

  workUpdateValues(event) {
    var foundelement = this.workDetails.find(ele => ele.Id == event.target.dataset.id);
    if (event.target.name === 'EMS_EM_Job_Title__c') {
      foundelement.EMS_EM_Job_Title__c = event.target.value;
    } else if (event.target.name === 'EMS_EM_From_Date__c') {
      foundelement.EMS_EM_From_Date__c = event.target.value;
      var today = new Date();
      var dd = String(today.getDate()).padStart(2, '0');
      var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
      var yyyy = today.getFullYear();
      today = yyyy + '-' + mm + '-' + dd;
      if (foundelement.EMS_EM_From_Date__c >= today) {
        foundelement.EMS_EM_From_Date__c = null;
        displayShowtoastMessage('Please enter a valid from date', 'error', this);
      }
    } else if (event.target.name === 'EMS_EM_To_Date__c') {
      foundelement.EMS_EM_To_Date__c = event.target.value;
      if (foundelement.EMS_EM_To_Date__c <= foundelement.EMS_EM_From_Date__c) {
        foundelement.EMS_EM_To_Date__c = null;
        displayShowtoastMessage('Please enter a valid to date', 'error', this);
      }

    } else if (event.target.name === 'EMS_EM_Previous_Company_Name__c') {
      foundelement.EMS_EM_Previous_Company_Name__c = event.target.value;
    } else if (event.target.name === 'EMS_EM_Previous_Company_HR_EmailId__c') {
      foundelement.EMS_EM_Previous_Company_HR_EmailId__c = event.target.value;
    }
  }

  handleSaveWorkAction() {
    this.handleIsLoading(true);
    /* if (this.deleteWorkIds !== '') {
      this.deleteWorkIds = this.deleteWorkIds.substring(1);
    } */
    this.workDetails.forEach(res => {
      if (!isNaN(res.Id)) {
        res.Id = null;
      }
    });
    const isInputsCorrect = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
      .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
      }, true);
    if (isInputsCorrect) {
      dmlOnEducation({ data: this.workDetails, removeEducationIds: this.deleteWorkIds })
        .then(result => {
          this.handleIsLoading(false);
          refreshApex(this.wiredEdu);
          this.updateWorkRecordView(this.onboardingformId);
          this.isWorkExperienceCheckbox = true;
          this.statusUpdate = 'In Progress';
          updateOnBoardingRequest(this);
          uploadFiles({ recordId: this.onboardingformId, filedata: JSON.stringify(this.filesDocData) })
            .then(result => {
              if (result && result == 'success') {
                this.filesDocData = [];
                updateOnboardingInfoOnPageLoads(this);
              } else {
                this.dispatchEvent(
                  new ShowToastEvent({
                    message: result,
                    variant: 'error',
                  }),
                );
              }
            }).catch(error => {
              if (error && error.body && error.body.message) {
                this.dispatchEvent(
                  new ShowToastEvent({
                    message: error.body.message,
                    variant: 'error',
                  }),
                );
              }
            }).finally(() => this.showSpinner = false);
          if (this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isEducationDetailsCheckbox === false || this.isOtherCertificationsCheckbox === false || this.isWorkExperienceCheckbox === false || this.isCompanyInformationValueChecked === false) {
            this.buttonDisable = true;
          }
          else {
            this.buttonDisable = false;
          }
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Details saved successfully',
              variant: 'success',
            }),
          );
          //this.showToast('Success', result, 'Success', 'dismissable');
        }).catch(error => {
          this.handleIsLoading(false);
          console.log(error);
          this.showToast('Please refresh the page and retry.', error.body.message, 'Error', 'dismissable');
        });updateOnboardingInfoOnPageLoads(this);
    } else {
      this.handleIsLoading(false);
      const even = new ShowToastEvent({
        message: 'Please complete the required field and avoid invalid data.',
        variant: 'error'
      });
      this.dispatchEvent(even);
    }
  }
  updateWorkRecordView() {
  }
}