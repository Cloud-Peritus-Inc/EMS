import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import correctImage from '@salesforce/resourceUrl/Correct';
import wrongImage from '@salesforce/resourceUrl/Wrong';
import getUserContactInfo from '@salesforce/apex/GetDataForLoginUser.getUserContactInfo';
import WelcomeAboardData from '@salesforce/apex/GetDataForLoginUser.WelcomeAboardData';
import CompanyGridData from '@salesforce/apex/GetDataForLoginUser.CompanyGridData';
import pfFormsid from '@salesforce/apex/GetDataForLoginUser.pfFormsid';
import Documentsdata from '@salesforce/apex/GetDataForLoginUser.Documentsdata';
import CompanyPoliciesdata from '@salesforce/apex/GetDataForLoginUser.CompanyPoliciesdata';
import uploadFiles from '@salesforce/apex/GetDataForLoginUser.saveFiles';
import getRelatedFilesByRecordId from '@salesforce/apex/GetDataForLoginUser.getRelatedFilesByRecordId';
import Id from '@salesforce/user/Id';
import getLoginURL from '@salesforce/apex/GetDataForLoginUser.getLoginURL';
import getRelatedFilesByRecordIdForPayForms from '@salesforce/apex/GetDataForLoginUser.getRelatedFilesByRecordIdForPayForms';
import getContentDistributionForFile from '@salesforce/apex/GetDataForLoginUser.getContentDistributionForFile';
import getFamilyInfo from '@salesforce/apex/getFamilyInfoInOnboarding.getFamilyInfo';
import getPayrollInfo from '@salesforce/apex/GetDataForLoginUser.getPayrollInfo';
import updateStatus from '@salesforce/apex/GetDataForLoginUser.updateStatus';

import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';

import updateContact from '@salesforce/apex/GetDataForLoginUser.updateContact';


function uploadFilesFromThis(event, ts) {
  if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type == "application/pdf") {
    let file = event.target.files[0];
    let nameOfInput = event.target.name;
    let uploadedFileName = event.target.files[0].name;
    let fileNameToAdd = event.target.files[0].name;
    let fileTypeToAdd = event.target.files[0].type;
    let concatFileName;
    //console.log('nameOfInput-->', nameOfInput);
    if (nameOfInput === "Passport") {
      ts.fileName = uploadedFileName;
      concatFileName = 'Passport_' + fileNameToAdd;
    } else if (nameOfInput === "DrivingLicense") {
      ts.fileName1 = uploadedFileName;
      concatFileName = 'DrivingLicense_' + fileNameToAdd;
    }
    let reader = new FileReader();
    reader.onloadend = e => {
      let base64 = 'base64,';
      let content = reader.result.indexOf(base64) + base64.length;
      let fileContents = reader.result.substring(content);
      //  ts.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
      ts.filesUploaded = [...ts.filesUploaded, { PathOnClient: file.name, Title: concatFileName, VersionData: fileContents }]
    };
    reader.readAsDataURL(file);
  } else {
    const even = new ShowToastEvent({
      message: 'File Size must be less than 2Mb & file type should be PDF only',
      variant: 'error'
    });
    ts.dispatchEvent(even);
  }
}

function updateStatusFields(ts) {
  let statusfield = { 'sobjectType': 'Contact' };
  statusfield.Post_Onboarding_Confirm__c = ts.PostOnboardingConfirm;
  statusfield.ProfileConfirm__c = ts.isPersonalUpdateCheckbox;
  statusfield.IdentityInformationCheck__c = ts.isIdentifyDetailsCheckbox;
  statusfield.EmploymentDetailsCheck__c = ts.isEmploymentDetailsCheckbox;
  statusfield.Address_Details_Check__c = ts.isAddressDetailsCheckbox;
  statusfield.Family_Information_Check__c = ts.isFamilyInformationCheckbox;
  statusfield.Financial_Information_Check__c = ts.isFinancialInformationCheckbox;
  statusfield.Vehicle_Details_Check__c = ts.isVehicleDetailsCheckbox;
  statusfield.PF_Forms_Check__c = ts.isPFFormsCheckbox;
  statusfield.Documents_Check__c = ts.isDocumentsValueChecked;
  statusfield.Company_Policies_Check__c = ts.isCompanyPoliciesValueChecked;
  statusfield.Company_Information_Check__c = ts.isCompanyInformationValueChecked;
  updateStatus({ statusUpdate: statusfield, ConRecordid: ts.contactID })
    .then(result => {

      console.log('result', result);

    })
    .catch(error => {
      this.error = error;
      console.log('this.error-->' + JSON.stringify(this.error));
    });
}

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
const MAX_FILE_SIZE = 2097152;

export default class OnboardingProcessForEmployee extends NavigationMixin(LightningElement) {

  activeSections = ['Welcome aboard'];
  activeSectionsConfirm = ['Welcome aboard', 'Profile', 'Company Information', 'Forms', 'Documents & Policies'];
  activeSectionsMessage = '';
  isWelcomeaboard = true;
  isShowWelcomeaboard = true;
  isWelcomeaboardValueChecked = true;

  filesList = []
  wiredResultcon;
  @track dataPFList;
  @track dataDocList;
  userId = Id;
  contactID;
  UserName;
  currenttime;
  isShowPersonalDetails = false;
  isIdentityDetails = false;
  isEmploymentDetails = false;
  isAddressDetails = false;
  isFamilyInformation = false;
  isShowFinacialFrom = false;
  isShowVehicleFrom = false;
  isPFForms = false;
  isDocuments = false;
  isCompanyPolicies = false;
  isCompanyInformation = false;
  isConfirm = false;
  correctImages = correctImage;
  wrongImages = wrongImage;

  isPersonalUpdateCheckbox = false;
  isIdentifyDetailsCheckbox = false;
  isEmploymentDetailsCheckbox = false;
  isAddressDetailsCheckbox = false;
  isFamilyInformationCheckbox = false;
  isFinancialInformationCheckbox = false;
  isVehicleDetailsCheckbox = false;
  isPFFormsCheckbox = false;
  isDocumentsValueChecked = false;
  isCompanyPoliciesValueChecked = false;
  isCompanyInformationValueChecked = false;
  isConfirmSubmit = false;
  buttonDisable = false;
  expression1 = false;
  PostOnboardingConfirm = false;
  showSpinner = false;



  @track firstName;
  @track lastName;
  @track fName;
  @track mName;
  @track gen;
  @track ph;
  @track personalemail;
  @track dob;
  @track nation;
  @track mstatus;
  @track spouse;
  @track dow;
  @track bg;
  @track aadhaarNo;
  @track panNo;
  @track pfn;
  @track pNum;

  @track cd;
  @track filesData = [];
  @track filesDocData = [];

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

  @track dataList;

  connectedCallback() {
    var dateVar = new Date();
    //Current Time 
    this.currenttime = new Date().toLocaleTimeString();

    getUserContactInfo({ userId: this.userId }).then(result => {
      //console.log('getUserContactInfo------------->' ,result.contactDetails);
      //console.log('getUserContactInfo------------->' ,result.fileDetailsList);
      this.contactID = result.contactDetails.Id;
      this.UserName = result.contactDetails.Name;
      const employye = result.contactDetails;
      if (employye != null) {
        //this.readonlyfield=true;
        this.firstName = employye.FirstName;
        this.lastName = employye.LastName;
        this.dob = employye.EMS_EM_DOB__c;
        this.gen = employye.EMS_EM_Gender__c;
        this.ph = employye.EMS_Phone_Number__c;
        this.personalemail = employye.Personal_Email__c;
        this.bg = employye.EMS_EM_BG__c;
        this.nation = employye.EMS_EM_Nationality__c;
        this.PostOnboardingConfirm = employye.Post_Onboarding_Confirm__c;
        this.isPersonalUpdateCheckbox = employye.ProfileConfirm__c;
        this.isIdentifyDetailsCheckbox = employye.IdentityInformationCheck__c;
        this.isEmploymentDetailsCheckbox = employye.EmploymentDetailsCheck__c;
        this.isAddressDetailsCheckbox = employye.Address_Details_Check__c;
        this.isFamilyInformationCheckbox = employye.Family_Information_Check__c;
        this.isFinancialInformationCheckbox = employye.Financial_Information_Check__c;
        this.isVehicleDetailsCheckbox = employye.Vehicle_Details_Check__c;
        this.isPFFormsCheckbox = employye.PF_Forms_Check__c;
        this.isDocumentsValueChecked = employye.Documents_Check__c;
        this.isCompanyPoliciesValueChecked = employye.Company_Policies_Check__c;
        this.isCompanyInformationValueChecked = employye.Company_Information_Check__c;

        this.aadhaarNo = employye.EMS_EM_AadhaarNo__c;
        this.UANNo = employye.EMS_EM_PFno__c;
        this.panNo = employye.EMS_EM_PanNo__c;
        this.passport = employye.EMS_EM_PassportNo__c;
        this.DrivingLicense = employye.EMS_Driving_License_No__c;

        this.cd = employye.EMS_EM_Current_Address__c;
        this.castate = employye.EMS_EM_CA_State__c;
        this.pastate = employye.EMS_EM_PA_State__c;
        this.cacity = employye.EMS_EM_CA_City__c;
        this.pacity = employye.EMS_EM_PA_City__c;
        this.cazip = employye.EMS_EM_CA_Zip__c;
        this.pazip = employye.EMS_EM_PA_Zip__c;
        this.cadrressline1 = employye.EMS_EM_CAddress_Line_1__c;
        this.cadrressline2 = employye.EMS_EM_CAddress_Line_2__c;
        this.padrressline1 = employye.EMS_EM_PAddress_Line_1__c;
        this.padrressline2 = employye.EMS_EM_PAddress_Line_2__c;
        this.doyouhaveavehicleval = employye.Do_you_have_a_vehicle__c;
        this.Vehicletypeval = employye.Vehicle_Type__c;
        this.VehicleNumber = employye.Vehicle_Number__c;
        if (this.Vehicletypeval != null) {
          this.showvehicle = true;
          this.checkboxValue = true;
        }
        if (this.PostOnboardingConfirm == true) {
          this.buttonDisable = true;
          this.readonlyfield = true;
          this.expression1 = true;
          this.disableFlag = true;
          this.paFlag = true;
        }
        if(this.cadrressline1 !=null && this.padrressline1 != null){
          if (this.padrressline1 === this.cadrressline1) {
            this.paFlag = true;
          }
            else{
              this.disableFlag = false;
            }
         }
        
        this.dataList = result.fileDetailsList;
        let filteredFiles = this.dataList.filter((file) => file.title.includes('PF Form'));
        let filteredDocFiles = this.dataList.filter((file) => file.title.includes('Document'));
        this.dataPFList = filteredFiles;
        this.dataDocList = filteredDocFiles;
        //console.log('filteredFiles', filteredFiles);
        //console.table(filteredFiles.map(item => ({title: item.title, type: item.type})));

        result.fileDetailsList.forEach((currentItem) => {
          if (currentItem.title.includes('Passport_')) {
            this.fileName = currentItem.title;
          }
          else if (currentItem.title.includes('DrivingLicense_')) {
            this.fileName1 = currentItem.title;
          }
        })

        getPayrollInfo({ conId: this.contactID })
          .then(result => {
            const employye = result[0];
            if (employye != null) {

              this.beneficiaryName = employye.Beneficiary_Name__c;
              this.bankNameval = employye.Bank_Name__c;
              this.branchname = employye.Branch__c;
              this.accountNumber = employye.Beneficiary_Account_Number__c;
              this.iFSCRoutingNumber = employye.IFSC_Routing_Number__c;
              this.SodexoCardoption = employye.Sodexo_Card_Option__c;
            }
          }).catch(err => {
            //console.log('err----->',err);
          });
      }
    }).catch(err => {
      console.log(err);
    });
  }

  FirstName(event) {
    this.firstName = event.target.value;
  }
  LastName(event) {
    this.lastName = event.target.value;
  }

  gender(event) {
    this.gen = event.target.value;
    //window.console.log(this.getAccountRecord.Name);
  }
  dateOfBirth(event) {
    this.dob = event.target.value;
    //window.console.log(this.getAccountRecord.Name);
  }
  phonenumber(event) {
    this.ph = event.target.value;
  }
  personalemailchange(event) {
    this.personalemail = event.target.value;
  }
  Nationality(event) {
    this.nation = event.target.value;
  }
  BloodGroup(event) {
    this.bg = event.target.value;
  }

  BloodG = [
    { label: 'A RhD positive (A+)', value: 'A RhD positive (A+)' },
    { label: 'A RhD negative (A-)', value: 'A RhD negative (A-)' },
    { label: 'B RhD positive (B+)', value: 'B RhD positive (B+)' },
    { label: 'B RhD negative (B-)', value: 'B RhD negative (B-)' },
    { label: 'O RhD positive (O+)', value: 'O RhD positive (O+)' },
    { label: 'O RhD negative (O-)', value: 'O RhD negative (O-)' },
    { label: 'AB RhD positive (AB+)', value: 'AB RhD positive (AB+)' },
    { label: 'AB RhD negative (AB-)', value: 'AB RhD negative (AB-)' },


  ];

  BankNamevalue = [
    { label: 'Axis Bank Ltd.', value: 'Axis Bank Ltd.' },
    { label: 'Bandhan Bank Ltd.', value: 'Bandhan Bank Ltd.' },
    { label: 'Bank of Baroda', value: 'Bank of Baroda' },
    { label: 'Bank of India', value: 'Bank of India' },
    { label: 'Bank of Maharashtra', value: 'Bank of Maharashtra' },
    { label: 'Canara Bank', value: 'Canara Bank' },
    { label: 'Central Bank of India', value: 'Central Bank of India' },
    { label: 'City Union Bank Ltd.', value: 'City Union Bank Ltd.' },
    { label: 'CSB Bank Ltd.', value: 'CSB Bank Ltd.' },
    { label: 'DCB Bank Ltd.', value: 'DCB Bank Ltd.' },
    { label: 'Dhanlaxmi Bank Ltd.', value: 'Dhanlaxmi Bank Ltd.' },
    { label: 'Federal Bank Ltd.', value: 'Federal Bank Ltd.' },
    { label: 'HDFC Bank Ltd', value: 'HDFC Bank Ltd' },
    { label: 'ICICI Bank Ltd.', value: 'ICICI Bank Ltd.' },
    { label: 'IDBI Bank Ltd.', value: 'IDBI Bank Ltd.' },
    { label: 'IDFC First Bank Ltd.', value: 'IDFC First Bank Ltd.' },
    { label: 'Indian Bank', value: 'Indian Bank' },
    { label: 'Indian Overseas Bank', value: 'Indian Overseas Bank' },
    { label: 'Induslnd Bank Ltd', value: 'Induslnd Bank Ltd' },
    { label: 'Jammu & Kashmir Bank Ltd.', value: 'Jammu & Kashmir Bank Ltd.' },
    { label: 'Karnataka Bank Ltd.', value: 'Karnataka Bank Ltd.' },
    { label: 'Karur Vysya Bank Ltd.', value: 'Karur Vysya Bank Ltd.' },
    { label: 'Kotak Mahindra Bank Ltd', value: 'Kotak Mahindra Bank Ltd' },
    { label: 'Nainital Bank Ltd.', value: 'Nainital Bank Ltd.' },
    { label: 'Punjab & Sind Bank', value: 'Punjab & Sind Bank' },
    { label: 'Punjab National Bank', value: 'Punjab National Bank' },
    { label: 'RBL Bank Ltd.', value: 'RBL Bank Ltd.' },
    { label: 'South Indian Bank Ltd.', value: 'South Indian Bank Ltd.' },
    { label: 'State Bank of India', value: 'State Bank of India' },
    { label: 'Tamilnad Mercantile Bank Ltd.', value: 'Tamilnad Mercantile Bank Ltd.' },
    { label: 'UCO Bank', value: 'UCO Bank' },
    { label: 'Union Bank of India', value: 'Union Bank of India' },
    { label: 'YES Bank Ltd.', value: 'YES Bank Ltd.' }

  ];

  Gendervalue = [
    { label: 'Male', value: 'Male' },
    { label: 'Female', value: 'Female' },
    { label: 'Other', value: 'Other' },
  ];

  VehicleType = [
    { label: 'Four-wheeler', value: 'Four-wheeler' },
    { label: 'Two-wheeler', value: 'Two-wheeler' }

  ];

  sodexooptions = [
    { label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }
  ];


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
    } else {
      //console.log('address unchecked')
      this.padrressline1 = '';
      this.padrressline2 = '';
      this.pastate = '';
      this.pacity = '';
      this.pazip = '';
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
    if (field === 'EMS_EM_CAddress_Line_1__c') {
      this.cadrressline1 = event.target.value;
      //console.log('234',event.target.value);
      if (event.target.value == '') {
        //console.log('empty string');
        this.cadrressline1 = null;

      }
      if (this.inputcheckboxValue == 'Checked') {
        this.padrressline1 = this.cadrressline1;
      }
    }
    if (field === 'EMS_EM_CAddress_Line_2__c') {
      this.cadrressline2 = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.cadrressline2 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.padrressline2 = this.cadrressline2;
      }
    }
    if (field === 'EMS_EM_CA_State__c') {
      this.castate = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.castate = null;

      }
      if (this.inputcheckboxValue == 'Checked') {
        this.pastate = this.castate;
      }

    }
    if (field === 'EMS_EM_CA_City__c') {
      this.cacity = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.cacity = null;

      }
      if (this.inputcheckboxValue == 'Checked') {
        this.pacity = this.cacity;
      }

    }
    if (field === 'EMS_EM_CA_Zip__c') {
      this.cazip = event.target.value;
      //console.log(event.target.value);

      if (event.target.value == '') {
        this.cazip = null;

      }
      if (this.inputcheckboxValue == 'Checked') {
        this.pazip = this.cazip;
      }

    }
    //permanent address
    if (field === 'EMS_EM_PAddress_Line_1__c') {
      this.padrressline1 = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.padrressline1 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cadrressline1 = this.padrressline1;

      }

    }
    if (field === 'EMS_EM_PAddress_Line_2__c') {
      this.padrressline2 = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.padrressline2 = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cadrressline2 = this.padrressline2;
      }
    }
    if (field === 'EMS_EM_PA_State__c') {
      this.pastate = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.pastate = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.castate = this.pastate;
      }
    }
    if (field === 'EMS_EM_PA_City__c') {
      this.pacity = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.pacity = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cacity = this.pacity;
      }
    }
    if (field === 'EMS_EM_PA_Zip__c') {
      this.pazip = event.target.value;
      //console.log(event.target.value);
      if (event.target.value == '') {
        this.pazip = null;
      }
      if (this.inputcheckboxValue == 'Checked') {
        this.cazip = this.pazip;
      }
    }
  }

  // Identity Information"....

  @track aadhaarNo;
  @track passport;
  @track DrivingLicense;
  @track panNo;
  @track UANNo;

  handleAadharNumberChange(event) {
    this.aadhaarNo = event.target.value;
  }

  handlepassportNumberChange(event) {
    this.passport = event.target.value;
  }
  handleDrivingLicenseNoChange(event) {
    this.DrivingLicense = event.target.value;
    //window.console.log(this.getAccountRecord.Name); 
  }

  PANNumber(event) {
    this.panNo = event.target.value;
    //window.console.log(this.getAccountRecord.Name); 
  }
  UanChange(event) {
    this.UANNo = event.target.value;
    //window.console.log(this.getAccountRecord.Name); 
  }

  // Identity Information"....

  @track beneficiaryName;
  @track bankNameval;
  @track branchname;
  @track accountNumber;
  @track iFSCRoutingNumber;
  @track SodexoCardoption;
  @track Vehicletypeval;
  @track doyouhaveavehicleval;
  @track VehicleNumber;

  showvehicle = false;

  BeneficiaryNamechange(event) {
    this.beneficiaryName = event.target.value;
  }

  BankName(event) {
    this.bankNameval = event.target.value;
  }
  Branchname(event) {
    this.branchname = event.target.value;
  }

  AccountNumberChnage(event) {
    this.accountNumber = event.target.value;
  }
  ifscCodeChange(event) {
    this.iFSCRoutingNumber = event.target.value;
  }
  sodexoCardonchange(event) {
    this.SodexoCardoption = event.target.value;
  }

  Vehicletypechange(event) {
    this.Vehicletypeval = event.target.value;
  }
  VehicleNumberChange(event) {
    this.VehicleNumber = event.target.value;
  }
  doyouhaveavehicle(event) {
    this.checkboxValue = event.target.checked;
    //console.log('this.checkboxValue--------->'  +  this.checkboxValue)
    if (this.checkboxValue == true) {
      this.showvehicle = true;
      this.checkboxValue = true
      //console.log('this.checkboxValue--------->'  +  this.checkboxValue)
    } else {
      this.showvehicle = false;
    }
  }

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
    this.isWelcomeaboard = false;
    this.isShowWelcomeaboard = false;

    if (seletedDetails === "Welcome aboard") {
      this.isShowWelcomeaboard = true;
      this.isWelcomeaboardValueChecked = true;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    else if (seletedDetails === "Personal Details") {
      this.isShowPersonalDetails = true;
      this.isShowWelcomeaboard = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Identity Information") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = true;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Employment Details") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = true;
      this.isEmploymentDetailsCheckbox = true;
      updateStatusFields(this)
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    else if (seletedDetails === "Address Details") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = true;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Family Information") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = true;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Financial Information") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = true;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Vehicle Details") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = true;
      this.isVehicleDetailsCheckbox = true;
      updateStatusFields(this)
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "PF Forms") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = true;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Documents") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = true;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = false;
    }
    else if (seletedDetails === "Company Policies") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = true;
      this.isCompanyPoliciesValueChecked = true;
      updateStatusFields(this)
      this.isCompanyInformation = false;
      this.isConfirm = false;
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    else if (seletedDetails === "Company Information") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = true;
      this.isCompanyInformationValueChecked = true;
      updateStatusFields(this)
      this.isConfirm = false;
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    else if (seletedDetails === "Confirm") {
      this.isShowWelcomeaboard = false;
      this.isShowPersonalDetails = false;
      this.isIdentityDetails = false;
      this.isEmploymentDetails = false;
      this.isAddressDetails = false;
      this.isFamilyInformation = false;
      this.isShowFinacialFrom = false;
      this.isShowVehicleFrom = false;
      this.isPFForms = false;
      this.isDocuments = false;
      this.isCompanyPolicies = false;
      this.isCompanyInformation = false;
      this.isConfirm = true;
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
    }
  }



  VehicleType = [
    { label: 'Four-wheeler', value: 'Four-wheeler' },
    { label: 'Two-wheeler', value: 'Two-wheeler' }

  ];


  @track Name;
  @track Description;
  @track CPName;
  @track CPDescription;
  @track policiesId;
  @track pfId;
  @track docId;
  @track policiesDescription;
  @track PFDescription;
  @track docDescription;
  @track policiesName;
  @track PFName;
  @track docName;

  @wire(WelcomeAboardData)
  WelcomeAboard({ data, error }) {
    if (data) {
      this.Name = data[0].Name;
      this.Description = data[0].Description__c;
      //console.log('Dataaaa-->' + JSON.stringify(data) ); 
      //console.log('Description__cdata->' +  data[0].Name);
    } else if (error) {
      console.log(error);
    }
  }
  @wire(CompanyGridData)
  Companydata({ data, error }) {
    if (data) {
      this.CPName = data[0].Name;
      this.CPDescription = data[0].Description__c;
      //console.log('Dataaaa-->' + JSON.stringify(data) ); 
    } else if (error) {
      console.log(error);
    }
  }

  @wire(pfFormsid)
  pfFormsdata({ data, error }) {
    if (data) {
      this.pfId = data[0].Id;
      this.PFName = data[0].Name;
      this.PFDescription = data[0].Description__c;
      //console.log('pfFormsdata-->' + JSON.stringify(data[0].Id) ); 
    } else if (error) {
      console.log(error);
    }
  }

  @wire(Documentsdata)
  Documentdata({ data, error }) {
    if (data) {
      this.docId = data[0].Id;
      this.docName = data[0].Name;
      this.docDescription = data[0].Description__c;
      //console.log('Documentdata-->' + JSON.stringify(data[0].Id) ); 
    } else if (error) {
      console.log(error);
    }
  }
  @wire(CompanyPoliciesdata)
  CompPoliciesdata({ data, error }) {
    if (data) {
      this.policiesId = data[0].Id;
      this.policiesName = data[0].Name;
      this.policiesDescription = data[0].Description__c;
      //console.log('CompPoliciesdata-->' + JSON.stringify(data[0].Id) ); 
    } else if (error) {
      console.log(error);
    }
  }


  getBaseUrl() {
    let baseUrl = 'https://' + location.host + '/';
    getLoginURL()
      .then(result => {
        baseUrl = result;
        window.console.log(baseUrl);
      })
      .catch(error => {
        console.error('Error: \n ', error);
      });
    return baseUrl;
  }


  handleDownloadFile(e) {
    getContentDistributionForFile({
      contentDocumentId: e.target.dataset.id
    })
      .then(response => {
        //console.log('Disturbution----' + JSON.stringify(response));
        window.open(response.ContentDownloadUrl);
      })
      .catch(error => {
        console.log(JSON.stringify(error));
      })
  }

  //for Pf Forms Files
  filesList = [];
  @track documents;
  @wire(getRelatedFilesByRecordIdForPayForms, { recordId: '$pfId' })
  wiredResult({ data, error }) {
    if (data) {
      this.documents = data;
    }
    if (error) {
      console.log(error)
    }
  }
  // For Documents Files
  filesList0 = []
  @track docs;
  @wire(getRelatedFilesByRecordIdForPayForms, { recordId: '$docId' })
  wiredResult0({ data, error }) {
    if (data) {
      //console.log(this.filesList0)
      this.docs = data;
      //console.log('' + JSON.stringify(this.documents));
    }
    if (error) {
      // console.log(error)
    }
  }


  // For Company Policies Files
  filesList1 = []
  @track cpPolicies
  @wire(getRelatedFilesByRecordIdForPayForms, { recordId: '$policiesId' })
  wiredResult1({ data, error }) {
    if (data) {
      this.cpPolicies = data;
      //console.log(this.cpPolicies)
    }
    if (error) {
      //console.log(error)
    }
  }

  selectStep1() {
    if (this.readonlyfield != true) {
      if (this.firstName != null && this.firstName != '' && this.lastName != null && this.lastName != ''
        && this.ph.length == 10 &&
        this.nation != null && this.nation != '' && this.dob != null &&
        this.personalemail != null && this.gen != null && this.bg != null) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        if (this.dob >= today) {
          //console.log("I am in if");
          this.dispatchEvent(
            new ShowToastEvent({
              message: 'Please Enter correct date of birth',
              variant: 'error',
            }),
          );
          return false;
        }
        else {
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

    }
    else {
      return true;
    }
  }
  selectStep2() {
    if (this.readonlyfield != true) {
      if (this.aadhaarNo.length == 12 && this.panNo != null &&
        this.fileName != null && this.fileName1 != null) {
        return true;
      } else {
        const even = new ShowToastEvent({
          message: 'Please complete required field & avoid invalid data!',
          variant: 'error'
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
      if (this.Branchname != null && this.Branchname != '' && this.BeneficiaryName != null && this.BeneficiaryName != ''
        && this.IFSCRoutingNumber != null && this.IFSCRoutingNumber != '' && this.AccountNumber.length <= 20 &&
        this.BankNameval != null && this.SodexoCardoption != null) {
        return true;
      } else {
        const even = new ShowToastEvent({
          message: 'Please complete required field & avoid invalid data!',
          variant: 'error'
        });
        this.dispatchEvent(even);
        return false;
      }
    }
  }

  //uploading all files
  @track filesUploaded = [];
  uploadedFiles = []; file; fileName;
  uploadedFiles1 = []; file1; fileName1;
  uploadedFiles2 = []; file2; fileName2;
  uploadedFiles3 = []; file3; fileName3;
  uploadedFiles4 = []; file4; fileName4;
  uploadedFiles5 = []; file5; fileName5;
  uploadedFiles6 = []; file6; fileName6;
  uploadedFiles7 = []; file7; fileName7;

  fileContents; fileReader; content;
  error;
  @api accept = '.pdf';

  onFileUpload(event) {
    uploadFilesFromThis(event, this);
  }

  onFileUpload1(event) {
    uploadFilesFromThis(event, this);
  }

  handleFileUploaded(event) {
    if (event.target.files.length > 0) {
      for (var i = 0; i < event.target.files.length; i++) {
        if (event.target.files[i].size > MAX_FILE_SIZE) {
          this.showToast('error', 'File size exceeded the upload size limit.');
          return;
        }
        let file = event.target.files[i];
        let fileExtension = file.name.substring(file.name.lastIndexOf('.'));
        let newFileName = 'PF Form_' + file.name;
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
        let file = event.target.files[i];
        let fileExtension = file.name.substring(file.name.lastIndexOf('.'));
        let newFileName = 'Document_' + file.name;
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

  removeReceiptImage(event) {
    var index = event.currentTarget.dataset.id;
    this.filesData.splice(index, 1);
  }

  removedocReceiptImage(event) {
    var index = event.currentTarget.dataset.id;
    this.filesDocData.splice(index, 1);
  }

  readonlyfield = false;

  SaveSubmitcontact(event) {

    let contactObj = { 'sobjectType': 'Contact' };

    contactObj.FirstName = this.firstName;
    contactObj.LastName = this.lastName;
    contactObj.EMS_EM_DOB__c = this.dob;
    contactObj.EMS_EM_Gender__c = this.gen;
    contactObj.EMS_Phone_Number__c = this.ph;
    contactObj.Personal_Email__c = this.personalemail;
    contactObj.EMS_EM_Nationality__c = this.nation;
    contactObj.EMS_EM_BG__c = this.bg;

    // Address Details
    contactObj.EMS_EM_CAddress_Line_1__c = this.cadrressline1;
    contactObj.EMS_EM_CAddress_Line_2__c = this.cadrressline2;
    contactObj.EMS_EM_PAddress_Line_1__c = this.padrressline1;
    contactObj.EMS_EM_PAddress_Line_2__c = this.padrressline2;
    contactObj.EMS_EM_CA_Zip__c = this.cazip;
    contactObj.EMS_EM_PA_Zip__c = this.pazip;
    contactObj.EMS_EM_CA_City__c = this.cacity;
    contactObj.EMS_EM_PA_City__c = this.pacity;
    contactObj.EMS_EM_CA_State__c = this.castate;
    contactObj.EMS_EM_PA_State__c = this.pastate;

    // Identity Information
    contactObj.EMS_EM_AadhaarNo__c = this.aadhaarNo;
    contactObj.EMS_EM_PassportNo__c = this.passport;
    contactObj.EMS_Driving_License_No__c = this.DrivingLicense;
    contactObj.EMS_EM_PanNo__c = this.panNo;
    contactObj.EMS_EM_PFno__c = this.UANNo;

    // Vehicle From
    contactObj.Do_you_have_a_vehicle__c = this.doyouhaveavehicleval;
    contactObj.Vehicle_Type__c = this.Vehicletypeval;
    contactObj.Vehicle_Number__c = this.VehicleNumber;

    let payrollobj = { 'sobjectType': 'PayRoll__c' };

    payrollobj.Beneficiary_Name__c = this.beneficiaryName;
    payrollobj.Bank_Name__c = this.bankNameval;
    payrollobj.Branch__c = this.branchname;
    payrollobj.Beneficiary_Account_Number__c = this.accountNumber;
    payrollobj.IFSC_Routing_Number__c = this.iFSCRoutingNumber;
    payrollobj.Sodexo_Card_Option__c = this.SodexoCardoption;


    if (this.isShowPersonalDetails == true) {
      if (this.selectStep1()) {
        this.showSpinner = true;
        updateContact({ newRecord: contactObj, ConRecordid: this.contactID, newPayroll: payrollobj })
          .then(result => {
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Details saved successfully',
                variant: 'success',
              }),
            ); this.isPersonalUpdateCheckbox = true;
            updateStatusFields(this)
            this.showSpinner = false;
          })
          .catch(error => {
            this.error = error;
            //console.log('this.error-->'+JSON.stringify(this.error));
          });

      }
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    if (this.isIdentityDetails == true) {
      if (this.selectStep2) {
        //console.log('selectStep2');
        this.showSpinner = true;
        updateContact({ newRecord: contactObj, ConRecordid: this.contactID, newPayroll: payrollobj, files: this.filesUploaded })

          .then(result => {
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Details saved successfully',
                variant: 'success',
              }),
            ); this.isIdentifyDetailsCheckbox = true;
            updateStatusFields(this)
            this.showSpinner = false;
            //console.log('isIdentityDetails');
          })
          .catch(error => {
            this.error = error;
            //console.log('this.error-->' + JSON.stringify(this.error));
          });
      }
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    if (this.isAddressDetails == true) {
      if (this.selectStep3()) {
        this.showSpinner = true;
        updateContact({ newRecord: contactObj, ConRecordid: this.contactID, newPayroll: payrollobj })
          .then(result => {
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Details saved successfully',
                variant: 'success',
              }),
            ); this.isAddressDetailsCheckbox = true;
            updateStatusFields(this)
            this.showSpinner = false;
          })
          .catch(error => {
            this.error = error;
            //console.log('this.error-->'+JSON.stringify(this.error));
          });

      }
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }

    if (this.isShowFinacialFrom) {

      const isInputsCorrect = [...this.template.querySelectorAll('lightning-input, lightning-combobox')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
      if (isInputsCorrect) {
        this.showSpinner = true;
        updateContact({ newRecord: contactObj, ConRecordid: this.contactID, newPayroll: payrollobj })

          .then(result => {
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Details saved successfully',
                variant: 'success',
              }),
            ); this.isFinancialInformationCheckbox = true;
            updateStatusFields(this)
            this.showSpinner = false;
            //console.log('isIdentityDetails');

          })
          .catch(error => {
            this.error = error;
            //console.log('this.error-->' + JSON.stringify(this.error));
          });
      }
      else {
        const even = new ShowToastEvent({
          message: 'Please complete required field & avoid invalid data!!',
          variant: 'error'
        });
        this.dispatchEvent(even);
        return false;
      }
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }

    if (this.isShowVehicleFrom == true) {
      // if(this.selectStep3){
      const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
      if (isInputsCorrect) {
        this.showSpinner = true;
        updateContact({ newRecord: contactObj, ConRecordid: this.contactID, newPayroll: payrollobj })
          .then(result => {
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Details saved successfully',
                variant: 'success',
              }),
            ); this.isVehicleDetailsCheckbox = true;
            updateStatusFields(this)
            this.showSpinner = false;
          })
          .catch(error => {
            this.error = error;
            //console.log('this.error-->' + JSON.stringify(this.error));
          });
      }
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }

    if (this.isPFForms == true) {

      //console.log('recordId ', this.contactID);
      //console.log('filesData length:', this.filesData.length);
      if (this.filesData == [] || this.filesData.length == 0) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Please select files first',
            variant: 'error',
          }),
        ); return;
      }
      this.showSpinner = true;
      uploadFiles({
        recordId: this.contactID,
        filedata: JSON.stringify(this.filesData)
      })
        .then(result => {
          //console.log(result);
          if (result && result == 'success') {
            //console.log('Upload successful---->', result);
            this.filesData = [];
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'PF Forms Uploaded successfully.',
                variant: 'success',
              }),
            ); this.isPFFormsCheckbox = true;
            updateStatusFields(this)
            // Refresh the data
            getUserContactInfo({ userId: this.userId })
              .then((result) => {
                this.contactID = result.contactDetails.Id;
                this.dataList = result.fileDetailsList;
                let filteredFiles = this.dataList.filter((file) =>
                  file.title.includes('PF Form')
                );
                let filteredDocFiles = this.dataList.filter((file) =>
                  file.title.includes('Document')
                );
                this.dataPFList = filteredFiles;
                this.dataDocList = filteredDocFiles;
              })
              .catch((err) => {
                console.log(err);
              });
          } else {
            //console.log('Upload failed:', result);
            this.dispatchEvent(
              new ShowToastEvent({
                message: result,
                variant: 'error',
              }),
            );
            //this.showToast('error', result);
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
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }
    if (this.isDocuments == true) {
      console.log('recordId ', this.contactID);
      console.log('filesDocData length:', this.filesDocData.length);
      if (this.filesDocData == [] || this.filesDocData.length == 0) {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Please select files first',
            variant: 'error',
          }),
        ); return;
      }
      this.showSpinner = true;
      uploadFiles({
        recordId: this.contactID,
        filedata: JSON.stringify(this.filesDocData)
      })
        .then(result => {
          console.log(result);
          if (result && result == 'success') {
            console.log('Upload successful---->', result);
            this.filesDocData = [];
            this.dispatchEvent(
              new ShowToastEvent({
                message: 'Documents Uploaded successfully.',
                variant: 'success',
              }),
            ); this.isDocumentsValueChecked = true;
            updateStatusFields(this)
            // Refresh the data
            getUserContactInfo({ userId: this.userId })
              .then((result) => {
                this.contactID = result.contactDetails.Id;
                this.dataList = result.fileDetailsList;
                let filteredFiles = this.dataList.filter((file) =>
                  file.title.includes('PF Form')
                );
                let filteredDocFiles = this.dataList.filter((file) =>
                  file.title.includes('Document')
                );
                this.dataPFList = filteredFiles;
                this.dataDocList = filteredDocFiles;
              })
              .catch((err) => {
                console.log(err);
              });
          } else {
            console.log('Upload failed:', result);
            this.dispatchEvent(
              new ShowToastEvent({
                message: result,
                variant: 'error',
              }),
            );
            //this.showToast('error', result);
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
      if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
        || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
        this.buttonDisable = true;
      }
      else {
        this.buttonDisable = false;
      }
    }

  }


  confirmSubmit(event) {
    if (this.isWelcomeaboardValueChecked && this.isPersonalUpdateCheckbox && this.isIdentifyDetailsCheckbox && this.isEmploymentDetailsCheckbox && this.isAddressDetailsCheckbox && this.isFamilyInformationCheckbox && this.isFinancialInformationCheckbox
      && this.isVehicleDetailsCheckbox && this.isPFFormsCheckbox && this.isDocumentsValueChecked && this.isCompanyPoliciesValueChecked && this.isCompanyInformationValueChecked) {
      this.PostOnboardingConfirm = true;
      this.readonlyfield = true;
      updateStatusFields(this)
      //console.log('confirm', confirm, 'this.PostOnboardingConfirm', this.PostOnboardingConfirm);
      this.dispatchEvent(
        new ShowToastEvent({
          message: 'Onboarding Form Submitted Successfully',
          variant: 'success',
        }),
      );
      this.buttonDisable = true;
      this.expression1 = true
      this.disableFlag = true;
      this.paFlag = true;

    }
    else {
      const even = new ShowToastEvent({
        message: 'Please complete all the required section',
        variant: 'error'
      });
      this.dispatchEvent(even);
      //console.log('error', error);
      return false;
    }
  }

  // Family Information

  @track totalFamilyRecords;
  @track dependenciesRecordsArray = [];

  @wire(getFamilyInfo, { contactId: "$contactID" })
  getfamilyinformationrecords(totalRecords) {
    this.totalFamilyRecords = totalRecords;
    refreshApex(this.totalFamilyRecords);
    //console.log('this.totalFamilyRecords---> ' + JSON.stringify(this.totalFamilyRecords));
    if (totalRecords.data) {
      if (totalRecords.data.listfamilyrecords && (totalRecords.data.listfamilyrecords.length > 0)) {
        this.dependenciesRecordsArray = totalRecords.data.listfamilyrecords;
        //console.log('this.dependenciesRecordsArray---> ' + JSON.stringify(this.dependenciesRecordsArray));
      }
    }
    if (totalRecords.error) {
      //console.log("Error OCcured With", totalRecords.error);
    }
  }
  isLoaded = false;
  Emergencycheckboxval;
  inputcheckboxdependent;
  memberDateOfBirth = false;
  contactPhone = false;

  Emergencycheckbox(event) {
    this.Emergencycheckboxval = event.target.value;
    //console.log('this.Emergencycheckboxval-->', this.Emergencycheckboxval);
    if (this.Emergencycheckboxval == true) {
      this.contactPhone = true;
    } else {
      this.contactPhone = false;
    }
  }

  Dependentcheckbox(event) {
    this.inputcheckboxdependent = event.target.value;
    //console.log('this.Dependentcheckbox-->', this.inputcheckboxdependent);
    if (this.inputcheckboxdependent == true) {
      this.memberDateOfBirth = true;
    } else {
      this.memberDateOfBirth = false;
    }

  }

  handlefamilySuccess(event) {
    this.dispatchEvent(
      new ShowToastEvent({
        message: 'Family Member Added successfully',
        variant: 'success',
      }),
    );

    refreshApex(this.totalFamilyRecords);
    const inputFields = this.template.querySelectorAll('lightning-input-field');
    if (inputFields) {
      inputFields.forEach(field => {
        field.reset();
      });
    } this.isLoaded = false;
    this.isFamilyInformationCheckbox = true;
    updateStatusFields(this)
    this.memberDateOfBirth = false;
    this.contactPhone = false;

    if (this.isWelcomeaboardValueChecked === false || this.isPersonalUpdateCheckbox === false || this.isIdentifyDetailsCheckbox === false || this.isEmploymentDetailsCheckbox === false || this.isAddressDetailsCheckbox === false || this.isFamilyInformationCheckbox === false || this.isFinancialInformationCheckbox === false
      || this.isVehicleDetailsCheckbox === false || this.isPFFormsCheckbox === false || this.isDocumentsValueChecked === false || this.isCompanyPoliciesValueChecked === false || this.isCompanyInformationValueChecked === false) {
      this.buttonDisable = true;
    }
    else {
      this.buttonDisable = false;
    }
  }

  handlesubmitfamily(event) {

    event.preventDefault();
    const fields = event.detail.fields;
    fields.Resource__c = this.contactID;
    this.template.querySelector('lightning-record-edit-form').submit(fields);
    this.isLoaded = true;
  }

  handlefamilyerror(event) {

    this.dispatchEvent(
      new ShowToastEvent({
        message: event.detail.detail,
        variant: 'error',
      }),
    );
    this.isLoaded = false;
  }


  deleteDependencyRecord(event) {
    this.isLoaded = true;
    const recordId = event.target.dataset.recordid;
    //console.log('record id--------> ' + event.target.dataset.recordid);
    deleteRecord(recordId)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Family Member Deleted Suscessfully',
            variant: 'success'
          })
        );
        refreshApex(this.totalFamilyRecords);
        this.isLoaded = false;
        this.isFamilyInformationCheckbox = true;
        updateStatusFields(this)
        if (this.totalFamilyRecords.data.listfamilyrecords.length === 1) {
          this.dependenciesRecordsArray = [];
        }
      })
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            message: 'Error Deleting record',
            variant: 'error'
          })
        );
      });
  }

}