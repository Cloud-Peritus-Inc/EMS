import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRequest from '@salesforce/apex/EMS_EM_Request.createRequest';
import getUserContactInfo from '@salesforce/apex/EMS_EM_Request.getUserContactInfo';
import uploadFileToNewContact from  '@salesforce/apex/EMS_EM_Request.uploadFileToNewContact';
import getRequestHistory from '@salesforce/apex/Ems_Em_Request_DataFetch.getRequestHistory';
import getRelatedFilesByRecordId from '@salesforce/apex/Ems_Em_Request_DataFetch.getRelatedFilesByRecordId';

import LightningConfirm from "lightning/confirm";
import LightningAlert from 'lightning/alert';
import {refreshApex} from '@salesforce/apex';
import {CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import recallApproval from '@salesforce/apex/ApprovalProcessController.recallApproval';

import Id from '@salesforce/user/Id';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import EndDate from '@salesforce/schema/Contract.EndDate';
export default class EMS_EM_EMP_PRTL_Request extends LightningElement {
    @track ReqRecId;
    @track ReqRecordId;
    @track Requeststatus;
    @track maritalstatus;
    @track fields;
    refreshTable;
    @track selectedItemValue;
    @api recordId;
    @track EMS_EM_CAddress_Line_1__c;
    @track EMS_EM_CAddress_Line_2__c ;
    @track EMS_EM_CA_State__c ;
    @track EMS_EM_CA_City__c ;
    @track EMS_EM_CA_Zip__c ;
    @track EMS_EM_PAddress_Line_1__c ;
    @track EMS_EM_PAddress_Line_2__c ;
    @track EMS_EM_PA_State__c ;
    @track EMS_EM_PA_City__c ;
    @track EMS_EM_PA_Zip__c ;
    @track EMS_EM_ED_Name__c;
    @track EMS_EM_ED_Relation__c;
    @track EMS_EM_ED_Address__c;
    @track EMS_EM_ED_Phone__c;
    @track EMS_EM_ED_Email__c;
    @track Vehicle_Type__c;
    @track Vehicle_Number__c;
    @track  Bank_Name__c = null;
    @track Account_Number__c;
    @track IFSC_Code__c;
    @track Account_Holder_Name__c;
    @track EMS_EM_Contact_Number__c;
    @track Personal_Email_Id__c;
    @track EMS_EM_Mstatus__c;
    @track EMS_EM_Spouse_Name__c;
    @track EMS_EM_DOW__c;
    @track EMS_EM_Add_Education__c;
    @track EMS_EM_Certification_Name__c;
    @track EMS_EM_Level_of_Education__c;
    @track EMS_EM_Degree__c;
    @track EMS_EM_IName__c;
    @track EMS_EM_Field_of_Study__c;
    @track EMS_EM_GDate__c;
    @track What_do_you_want_to_change__c;
    @track EMS_EM_Certificate_URL__c;
    @track SingleMarriedToggle = false;
    @track maxDate;
    @track contactMaritalStatusFlag;
    @track selectRequest= "All Requests";


    @api objectApiName;
    userId = Id;
    contactID;
    fileData
    customValue1;
    customValue2;
    @track data = [];
    @track fiteredData = [];
    @track error;
    @track isShowViewRequest = false;
    @track showcancelbutton = false;
    @track contactRecordId;
    @track requestType;
    @track personalDetailsChoice;
    @track educationalDetailsChoice;

    @api ReqRecordId;
    filesList =[]


  DisplayAddressDetails = false;
  DisplayBankDetails = false;
  DisplayEmergencyDetails = false;
  DisplayVehicleDetails = false;

  //personal details display flags
  DisplayContactInfo = false;
  DisplayMaritalStatus = false;
  DisplayUpdatedResume = false;

  //educational details display flags
  DisplayDegreeInfo = false;
  DisplayCertificateInfo = false;
  wiredRequestResult;

  @track currentPageReference;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
    if (currentPageReference && !this.recordId) {
        this.recordId = currentPageReference.state.c__recordId;
    }}



    connectedCallback(){

      let today = new Date() ;
            //console.log(this.today);
            let dd = today.getDate() -1;
            let mm = today.getMonth() + 1;
            let y = today.getFullYear();
            this.maxDate = y + '-' + mm + '-' + dd;

            //console.log('max date ' + this.maxDate);

        getUserContactInfo({userId :this.userId}).then( result => {
            this.contactID=result.Id;
            this.recordId = result.Id;
            //this.contactMaritalStatus = result.EMS_EM_Mstatus__c;
            //console.log('this.contactMaritalStatus==>'+this.contactMaritalStatus);
            //console.log('this.contactID==>'+this.recordId);
            //console.log('this.contactID==>'+ result.Name);
            if(result.EMS_EM_Mstatus__c == 'Single'){
              this.contactMaritalStatusFlag = false;
            }
            else{
              this.contactMaritalStatusFlag = true;
            }

        }).catch(err => {
            console.log(err);

        });
      }




    PersonalDetailsPicklist = [
        { label: 'Contact Info', value: 'Contact Info' },
        { label: 'Marital Status', value: 'Marital Status' },
    { label: 'Update Resume', value: 'Update Resume' }

      ];
    EducationalDetailsPicklist = [
        { label: 'Degree', value: 'Degree' },
        { label: 'Certificate', value: 'Certificate' }
      ];
    VehicleType = [
        { label: 'Four-wheeler', value: 'Four-wheeler' },
        { label: 'Two-wheeler', value: 'Two-wheeler' }

      ];
    MaritalStatusPicklist = [
        { label: 'Single', value: 'Single' },
        { label: 'Married', value: 'Married' }

      ];
      LevelOfEducation = [
        { label: 'Graduation', value: 'Graduation' },
        { label: 'Post-Graduation', value: 'Post-Graduation' }

      ];

    BankName = [
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



    ready1 = false;
    ready2 = false;
    ready3 = false;
    ready4 = false;
    ready5 = false;
    ready6 = false;

    DisplayContactInfo = false;
    DisplayMaritalStatus = false;
    DisplayUpdateResume = false;
    DisplayDegreeInfo = false;
    DisplayCertificateInfo = false;
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
          this.EMS_EM_CAddress_Line_1__c = event.target.value;
          //console.log('234',event.target.value);
          if(event.target.value == ''){
            //console.log('empty string');
            this.EMS_EM_CAddress_Line_1__c = null;

          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_PAddress_Line_1__c = this.EMS_EM_CAddress_Line_1__c;

          }


      }
       if (field === 'EMS_EM_CAddress_Line_2__c') {
          this.EMS_EM_CAddress_Line_2__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_CAddress_Line_2__c = null;
          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_PAddress_Line_2__c = this.EMS_EM_CAddress_Line_2__c;
          }


      }
        if (field === 'EMS_EM_CA_State__c') {
          this.EMS_EM_CA_State__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_CA_State__c = null;

          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_PA_State__c = this.EMS_EM_CA_State__c;
          }

      }
        if (field === 'EMS_EM_CA_City__c') {
          this.EMS_EM_CA_City__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_CA_City__c = null;

          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_PA_City__c = this.EMS_EM_CA_City__c;
          }

      }
       if (field === 'EMS_EM_CA_Zip__c') {
          this.EMS_EM_CA_Zip__c = event.target.value;
          //console.log(event.target.value);

          if(event.target.value == ''){
            this.EMS_EM_CA_Zip__c = null;

          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_PA_Zip__c = this.EMS_EM_CA_Zip__c;
          }

      }
      //permanent address
      if (field === 'EMS_EM_PAddress_Line_1__c') {
          this.EMS_EM_PAddress_Line_1__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_PAddress_Line_1__c = null;
          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_CAddress_Line_1__c = this.EMS_EM_PAddress_Line_1__c;

          }

      }
       if (field === 'EMS_EM_PAddress_Line_2__c') {
          this.EMS_EM_PAddress_Line_2__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_PAddress_Line_2__c = null;
          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_CAddress_Line_2__c = this.EMS_EM_PAddress_Line_2__c;
          }
      }
        if (field === 'EMS_EM_PA_State__c') {
          this.EMS_EM_PA_State__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_PA_State__c = null;
          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_CA_State__c = this.EMS_EM_PA_State__c;
          }
      }
        if (field === 'EMS_EM_PA_City__c') {
          this.EMS_EM_PA_City__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_PA_City__c = null;
          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_CA_City__c = this.EMS_EM_PA_City__c;
          }
      }
        if (field === 'EMS_EM_PA_Zip__c') {
          this.EMS_EM_PA_Zip__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_PA_Zip__c = null;
          }
          if (this.inputcheckboxValue == 'Checked'){
            this.EMS_EM_CA_Zip__c = this.EMS_EM_PA_Zip__c;
          }
      }
      //Emergency details change
      else if (field === 'EMS_EM_ED_Name__c') {
          this.EMS_EM_ED_Name__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_ED_Name__c = null;
          }
      }
      else if (field === 'EMS_EM_ED_Relation__c') {
          this.EMS_EM_ED_Relation__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_ED_Relation__c = null;
          }
      }
      else if (field === 'EMS_EM_ED_Address__c') {
          this.EMS_EM_ED_Address__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_ED_Address__c = null;
          }
      }
      else if (field === 'EMS_EM_ED_Phone__c') {
          this.EMS_EM_ED_Phone__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_ED_Phone__c = null;
          }
      }
      else if (field === 'EMS_EM_ED_Email__c') {
          this.EMS_EM_ED_Email__c = event.target.value;
          //.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_ED_Email__c = null;
          }
      }
      //Vehicle details change
      else if (field === 'Vehicle_Type__c') {
          this.Vehicle_Type__c = event.target.value;

      }
      else if (field === 'Vehicle_Number__c') {
          this.Vehicle_Number__c = event.target.value;
          if(event.target.value == ''){
            this.Vehicle_Number__c = null;
          }
      }
      //Bank details change handle
      else if (field === 'Bank_Name__c') {
          this.Bank_Name__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.Bank_Name__c = null;
          }
      }
      else if (field === 'Account_Number__c') {
          this.Account_Number__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.Account_Number__c = null;
          }
      }
      else if (field === 'IFSC_Code__c') {
          this.IFSC_Code__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.IFSC_Code__c = null;
          }
      }
      else if (field === 'Account_Holder_Name__c') {
          this.Account_Holder_Name__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.Account_Holder_Name__c = null;
          }
      }
      else if (field === 'What_do_you_want_to_change__c') {
          this.What_do_you_want_to_change__c = event.target.value;
          //console.log(event.target.value);
          if(this.What_do_you_want_to_change__c == 'Contact Info'){
            this.DisplayContactInfo = true;
            this.DisplayMaritalStatus = false;
            this.DisplayUpdateResume = false;
          }
          //console.log(event.target.value);
          if(this.What_do_you_want_to_change__c == 'Marital Status'){
            this.DisplayContactInfo = false;
            this.DisplayMaritalStatus = true;
            this.DisplayUpdateResume = false;
          }
          //console.log(event.target.value);
          if(this.What_do_you_want_to_change__c == 'Update Resume'){
            this.DisplayContactInfo = false;
            this.DisplayMaritalStatus = false;
            this.DisplayUpdateResume = true;
          }
      }
      else if (field === 'EMS_EM_Contact_Number__c') {
          this.EMS_EM_Contact_Number__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.EMS_EM_Contact_Number__c = null;
          }
      }
      else if (field === 'Personal_Email_Id__c') {
          this.Personal_Email_Id__c = event.target.value;
          //console.log(event.target.value);
          if(event.target.value == ''){
            this.Personal_Email_Id__c = null;
          }
      }
      else if (field === 'EMS_EM_Mstatus__c') {
          this.EMS_EM_Mstatus__c = event.target.value;
          //console.log(event.target.value);
          if(this.EMS_EM_Mstatus__c == 'Single'){
            this.SingleMarriedToggle = false;
            this.EMS_EM_Spouse_Name__c = null;
            this.EMS_EM_DOW__c = null;
          }
          if(this.EMS_EM_Mstatus__c == 'Married'){
            this.SingleMarriedToggle = true;
          }

      }
      else if (field === 'EMS_EM_Spouse_Name__c') {
          this.EMS_EM_Spouse_Name__c = event.target.value;
          //console.log(this.EMS_EM_Spouse_Name__c);
          if(event.target.value == ''){
            this.EMS_EM_Spouse_Name__c = null;
          }
      }
      else if (field === 'EMS_EM_Spouse_Name__c') {
          this.EMS_EM_Spouse_Name__c = event.target.value;
          //console.log(this.EMS_EM_Spouse_Name__c);
          if(event.target.value == ''){
            this.EMS_EM_Spouse_Name__c = null;
          }
      }
      else if (field === 'EMS_EM_DOW__c') {
          this.EMS_EM_DOW__c = event.target.value;
          //console.log(this.EMS_EM_DOW__c);
          let enteredDate = new Date(event.target.value);
          //console.log(enteredDate);

      }

      //education details
      else if (field === 'EMS_EM_Add_Education__c') {
          this.EMS_EM_Add_Education__c = event.target.value;
          //console.log(event.target.value);
          if(this.EMS_EM_Add_Education__c == 'Degree'){
            this.DisplayDegreeInfo = true;
            this.DisplayCertificateInfo = false;
          }

          if(this.EMS_EM_Add_Education__c == 'Certificate'){
            this.DisplayDegreeInfo = false;
            this.DisplayCertificateInfo = true;
          }
      }
      else if (field === 'EMS_EM_Certification_Name__c') {
          this.EMS_EM_Certification_Name__c = event.target.value;
          //console.log(this.EMS_EM_Certification_Name__c);
          if(event.target.value == ''){
            this.EMS_EM_Certification_Name__c = null;
          }
      }

      else if (field === 'EMS_EM_Level_of_Education__c') {
          this.EMS_EM_Level_of_Education__c = event.target.value;
          //console.log(this.EMS_EM_Level_of_Education__c);
          if(event.target.value == ''){
            this.EMS_EM_Level_of_Education__c = null;
          }
      }
      else if (field === 'EMS_EM_Degree__c') {
          this.EMS_EM_Degree__c = event.target.value;
          //console.log(this.EMS_EM_Degree__c);
          if(event.target.value == ''){
            this.EMS_EM_Degree__c = null;
          }
      }
      else if (field === 'EMS_EM_IName__c') {
          this.EMS_EM_IName__c = event.target.value;
          //console.log(this.EMS_EM_IName__c);
          if(event.target.value == ''){
            this.EMS_EM_IName__c = null;
          }
      }
      else if (field === 'EMS_EM_Field_of_Study__c') {
          this.EMS_EM_Field_of_Study__c = event.target.value;
          //console.log(this.EMS_EM_Field_of_Study__c);
          if(event.target.value == ''){
            this.EMS_EM_Field_of_Study__c = null;
          }
      }
      else if (field === 'EMS_EM_GDate__c') {
          this.EMS_EM_GDate__c = event.target.value;
          //console.log(this.EMS_EM_GDate__c);
          if(event.target.value == ''){
            this.EMS_EM_GDate__c = null;
          }
      }
  }



  handleOnselect(event) {
      this.selectedItemValue = event.detail.value;
      //alert(this.selectedItemValue);
      if(this.selectedItemValue == 'AddressDetails')
      {
        this.ready1 = true;

      }
      else if ((this.selectedItemValue == 'BankDetails')) {
        this.ready2 = true;
      }
      else if ((this.selectedItemValue == 'EducationalDetails')) {
        this.ready3 = true;
      }
      else if ((this.selectedItemValue == 'EmergencyDetails')) {
        this.ready4 = true;
      }
      else if ((this.selectedItemValue == 'PersonalDetails')) {
        this.ready5 = true;
      }
      else if ((this.selectedItemValue == 'VehicleDetails')) {
        //console.log('vehicledetailtype'+ this.Vehicle_Type__c);
        if(this.Vehicle_Type__c == null){
          //console.log('null');
        }
        if(this.Vehicle_Type__c == ''){
          //console.log('==');
        }
        if(this.Vehicle_Type__c === ''){
          //console.log('===');
        }
        this.ready6 = true;
    }

  }
 // Filter Requests by Date
 dateHandler(event){
  console.log(event.target.value);
  //  const dateFilter = event.target.name;
    var newDate = new Date();
    var today = newDate.toISOString().slice(0, 10);
    this.todayDate = newDate.toISOString().slice(0, 10);
   var stDate=this.template.querySelector(".startDate").value;
   var edDate=this.template.querySelector(".endDate").value;

    if(event.target.value > today){
      event.target.value = today;
      // this.handleInvalidDateAlert("Please Select a Valid Date");
      return
    }

   if (stDate !=''  && edDate !='' ){
      if( stDate <= edDate){
        console.log('Valid----'+stDate +'----'+ edDate);
        this.data = this.fiteredData.filter(req=>{
          // console.log( req.EMS_EM_Raised_On__c +"----"+stDate+"---"+edDate);
          // console.log( (req.EMS_EM_Raised_On__c)  <= edDate);
          return req.EMS_EM_Raised_On__c >= stDate &&  req.EMS_EM_Raised_On__c <= edDate ;
          })
      } else
        {
          this.handleInvalidDateAlert("End Date should be greater than Start Date");
          this.data = this.fiteredData;
          console.log('invalid---' +stDate +'---'+ edDate);
          return
    }
  }
}


  // Filter Requests by Status
  handleFilter(event){
    this.selectedItemValue = event.detail.value;
    this.selectRequest= this.selectedItemValue;
    console.log(this.selectedItemValue);
    var stDate=this.template.querySelector(".startDate").value;
   var edDate=this.template.querySelector(".endDate").value;
   if (stDate!='' && edDate !=''){
     if(this.selectedItemValue!='Allrequests'){
        this.data = this.fiteredData.filter(req=>{
          return (req.EMS_EM_Request_Status__c == this.selectedItemValue
            && req.EMS_EM_Raised_On__c >= stDate &&  req.EMS_EM_Raised_On__c <= edDate);
          })
      } else {
      // this.data = this.fiteredData;
      this.data = this.fiteredData.filter(req=>{
        // console.log( req.EMS_EM_Raised_On__c +"----"+stDate+"---"+edDate);
        // console.log( (req.EMS_EM_Raised_On__c)  <= edDate);
        return req.EMS_EM_Raised_On__c >= stDate &&  req.EMS_EM_Raised_On__c <= edDate ;
       })
      }
   } else { // If any of the dates empty
    if(this.selectedItemValue!='Allrequests'){
      this.data = this.fiteredData.filter(req=>{
        return (req.EMS_EM_Request_Status__c == this.selectedItemValue);
        })
    } else {
      this.data = this.fiteredData;
    }
   }
   }




  closeModal(){
      this.ready1 = false;
      this.ready2 = false;
      this.ready3 = false;
      this.ready4 = false;
      this.ready5 = false;
      this.ready6 = false;
      this.DisplayContactInfo = false;
      this.DisplayMaritalStatus = false;
      this.DisplayUpdateResume = false;
      this.DisplayDegreeInfo = false;
      this.DisplayCertificateInfo = false;
      this.EMS_EM_CAddress_Line_1__c = null;
      this.EMS_EM_CAddress_Line_2__c = null;
      this.EMS_EM_CA_State__c = null;
      this.EMS_EM_CA_City__c = null;
      this.EMS_EM_CA_Zip__c = null;
      this.EMS_EM_PAddress_Line_1__c = null;
      this.EMS_EM_PAddress_Line_2__c = null;
      this.EMS_EM_PA_State__c = null;
      this.EMS_EM_PA_City__c = null;
      this.EMS_EM_PA_Zip__c = null;
      this.EMS_EM_ED_Name__c = null;
      this.EMS_EM_ED_Relation__c = null;
      this.EMS_EM_ED_Address__c = null;
      this.EMS_EM_ED_Phone__c = null;
      this.EMS_EM_ED_Email__c = null;
      this.Vehicle_Type__c = null;
      this.Vehicle_Number__c = null;
      this.Bank_Name__c = null;
      this.Account_Number__c = null;
      this.IFSC_Code__c = null;
      this.Account_Holder_Name__c = null;
      this.EMS_EM_Contact_Number__c = null;
      this.Personal_Email_Id__c = null;
      this.EMS_EM_Mstatus__c = null;
      this.EMS_EM_Spouse_Name__c = null;
      this.EMS_EM_DOW__c = null;
      this.EMS_EM_Add_Education__c = null;
      this.EMS_EM_Certification_Name__c = null;
      this.EMS_EM_Level_of_Education__c = null;
      this.EMS_EM_Degree__c = null;
      this.EMS_EM_IName__c = null;
      this.EMS_EM_Field_of_Study__c = null;
      this.EMS_EM_GDate__c = null;
      this.recordId = this.contactID;
      this.inputcheckboxValue = null;
      this.SingleMarriedToggle = false;

  }

  openfileUpload(event) {
        const file = event.target.files[0]
        if(file.size < 2097152 && file.name.includes('.pdf')){
            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                this.fileData = {
                    'filename': file.name,
                    'base64': base64
                    //'recordId': this.recordId
                }
                //console.log(this.fileData)
            }
            reader.readAsDataURL(file)

        }
        else{
          if(file.size > 2097152 && !(file.name.includes('.pdf'))){
          const evt = new ShowToastEvent({
                      message: 'Unsupported File',
                      variant: 'error',
                        });
                        this.dispatchEvent(evt);

          }
          else if(file.size > 2097152){
                const evt = new ShowToastEvent({
            message: 'Please upload document less than 2MB',
            variant: 'error',
              });
              this.dispatchEvent(evt);
          }
          else{
            const evt = new ShowToastEvent({
            message: 'Only Document type PDF is allowed ',
            variant: 'error',
            });
            this.dispatchEvent(evt);
          }
        }

    }

  submitAddressDetails() {

    if((this.EMS_EM_CAddress_Line_1__c != null &&  this.EMS_EM_CA_State__c != null && this.EMS_EM_CA_City__c != null && this.EMS_EM_CA_Zip__c != null) || (this.EMS_EM_PAddress_Line_1__c != null && this.EMS_EM_PA_State__c != null && this.EMS_EM_PA_City__c != null && this.EMS_EM_PA_Zip__c != null) ){

        //console.log(this.userId);
    getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
           //console.log('result'+result);
           //console.log('result'+JSON.stringify(result));

          const employye = result;
          //console.log('employye.LastName'+employye.LastName);

        let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };
        guestObj.EMS_EM_CAddress_Line_1__c = this.EMS_EM_CAddress_Line_1__c;
        guestObj.EMS_EM_CAddress_Line_2__c = this.EMS_EM_CAddress_Line_2__c;
        guestObj.EMS_EM_CA_State__c = this.EMS_EM_CA_State__c;
        guestObj.EMS_EM_CA_City__c = this.EMS_EM_CA_City__c;
        guestObj.EMS_EM_CA_Zip__c = this.EMS_EM_CA_Zip__c;
        guestObj.EMS_EM_PAddress_Line_1__c = this.EMS_EM_PAddress_Line_1__c;
        guestObj.EMS_EM_PAddress_Line_2__c = this.EMS_EM_PAddress_Line_2__c;
        guestObj.EMS_EM_PA_State__c = this.EMS_EM_PA_State__c;
        guestObj.EMS_EM_PA_City__c = this.EMS_EM_PA_City__c;
        guestObj.EMS_EM_PA_Zip__c = this.EMS_EM_PA_Zip__c;
        guestObj.EMS_EM_Request_Status__c = 'Pending';
        guestObj.EMS_EM_Request_Type__c = 'Address Details';
        guestObj.Contact__c = this.contactID;
        //console.log('guestObj-->'+guestObj);

        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);

        saveRequest({newRecord: guestObj})
        .then(result => {
            //console.log('this.recordId-->'+this.recordId);
            this.recordId = result;
            //console.log('this.recordId-->'+this.recordId);

          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Request for address details change successfully submitted',
                variant: 'success',
            }),
        );


        this.closeModal();
        return refreshApex(this.refreshTable);
        //location.reload();

        })
        .catch(error => {
            this.error = error;
            console.log('this.error-->'+JSON.stringify(this.error));
        });


       }).catch(err => {
           console.log(err);

       });

    }
    else{
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the current address or permanent address fields',
                variant: 'error',
            }),
        );

    }



}


  //handle emergency details submission
  submitEmergencyDetails() {

    if(this.EMS_EM_ED_Name__c != null || this.EMS_EM_ED_Relation__c != null || this.EMS_EM_ED_Address__c != null || this.EMS_EM_ED_Phone__c != null || this.EMS_EM_ED_Email__c != null){

        //console.log(this.userId);
    getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.EMS_EM_ED_Name__c==>'+this.EMS_EM_ED_Name__c);


        const employye = result;
        //console.log('employye.LastName'+employye.LastName);
        let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };
        guestObj.EMS_EM_ED_Name__c = this.EMS_EM_ED_Name__c;
        guestObj.EMS_EM_ED_Relation__c = this.EMS_EM_ED_Relation__c;
        guestObj.EMS_EM_ED_Address__c = this.EMS_EM_ED_Address__c;
        guestObj.EMS_EM_ED_Phone__c = this.EMS_EM_ED_Phone__c;
        guestObj.EMS_EM_ED_Email__c = this.EMS_EM_ED_Email__c;
        guestObj.EMS_EM_Request_Status__c = 'Pending';
        guestObj.EMS_EM_Request_Type__c = 'Emergency Details';
        guestObj.Contact__c = this.contactID;
        //console.log('guestObj-->'+guestObj);

        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);

        saveRequest({newRecord: guestObj})
        .then(result => {
            //console.log('this.recordId-->'+this.recordId);
            this.recordId = result;
            //console.log('this.recordId-->'+this.recordId);

          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Request for emergency details change successfully submitted',
                variant: 'success',

            }),

        );

        this.closeModal();
        return refreshApex(this.refreshTable);
        //location.reload();

        })
        .catch(error => {
            this.error = error;
            console.log('this.error-->'+JSON.stringify(this.error));
        });

       }).catch(err => {
           console.log(err);

       });

    }
    else{
      this.dispatchEvent(
      new ShowToastEvent({
                title: 'Error',
                message: 'Please fill atleast one field to raise the request',
                variant: 'error',

            }),

        );
    }


}

  //handle Vehicle details submission
  submitVehicleDetails() {
    if(this.Vehicle_Type__c != null &&  this.Vehicle_Number__c!=null){

      //console.log(this.userId);
    getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
        //console.log('result'+result);
        //console.log('result'+JSON.stringify(result));

        const employye = result;
        //console.log('employye.LastName'+employye.LastName);

        //create request object to insert record
        let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };

        guestObj.Vehicle_Type__c = this.Vehicle_Type__c;
        guestObj.Vehicle_Number__c = this.Vehicle_Number__c;
        guestObj.EMS_EM_Request_Status__c = 'Pending';
        guestObj.EMS_EM_Request_Type__c = 'Vehicle Details';
        guestObj.Contact__c = this.contactID;
        //console.log('guestObj-->'+guestObj);

        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
          detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);

        saveRequest({newRecord: guestObj})
        .then(result => {
            //console.log('this.recordId-->'+this.recordId);
            this.recordId = result;
            //console.log('this.recordId-->'+this.recordId);

          this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Request for vehicle Details change successfully submitted',
                variant: 'success',
            }),
        );

        this.closeModal();
        return refreshApex(this.refreshTable);
       // location.reload();

        })
        .catch(error => {
            this.error = error;
            console.log('this.error-->'+JSON.stringify(this.error));
        });

       }).catch(err => {
           console.log(err);

       });

    }
    else{
      this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Please fill all the vehicle details',
                variant: 'error',
            }),
        );
    }


}
    //handle Bank details submission
  submitBankDetails() {
     //for IFSC validation
    let validateIFSC = false;
    const ifscRej = /^[A-Z a-z]{4}[a-z A-Z 0-9]{7}$/;
    let ifsc = this.template.querySelector(".ifsc");
    let ifscvalue = ifsc.value;
    if (ifscvalue.match(ifscRej)) {
      ifsc.setCustomValidity("");
    } else {
      ifsc.setCustomValidity("Please Enter Valid IFSC Code");
      validateIFSC = true;
    }
    ifsc.reportValidity();
     //for Account Number validation
     let validateAccNumber = false;
     const accNumRej = /^[0-9]{12,18}/;
     let accNum = this.template.querySelector(".accNum");
     let accNumvalue = accNum.value;
     if (accNumvalue.match(accNumRej)) {
      accNum.setCustomValidity("");
     } else {
      accNum.setCustomValidity("Please Enter Valid Account Number");
       validateAccNumber = true;
     }
     accNum.reportValidity();

    if(!validateIFSC && !validateAccNumber && this.Bank_Name__c !== null && this.Account_Number__c != null && this.IFSC_Code__c != null && this.Account_Holder_Name__c != null){

      getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
           //console.log('result'+result);
           //console.log('result'+JSON.stringify(result));

          const employye = result;
          //console.log('employye.LastName'+employye.LastName);
          let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };
          guestObj.Bank_Name__c = this.Bank_Name__c;
          guestObj.Account_Number__c = this.Account_Number__c;
          guestObj.IFSC_Code__c = this.IFSC_Code__c;
          guestObj.Account_Holder_Name__c = this.Account_Holder_Name__c;
          guestObj.EMS_EM_Request_Status__c = 'Pending';
          guestObj.EMS_EM_Request_Type__c = 'Bank Details';
          guestObj.Contact__c = this.contactID;
          //console.log('guestObj-->'+guestObj);

          const value = true;
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);

          saveRequest({newRecord: guestObj})
          .then(result => {
              //console.log('this.recordId-->'+this.recordId);
              this.recordId = result;
              //console.log('this.recordId-->'+this.recordId);

            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Request for bank details change successfully submitted',
                  variant: 'success',
              }),
          );


          this.closeModal();
          return refreshApex(this.refreshTable);
          //location.reload();

          })
          .catch(error => {
              this.error = error;
              console.log('this.error-->'+JSON.stringify(this.error));
          });


        }).catch(err => {
            console.log(err);

        });
    }
    else{
      this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please fill all the details and try again!',
                  variant: 'error',
              }),
          );
    }



  }


  //handle personal details

  submitPersonalDetails(){

    if(this.DisplayContactInfo == true || this.DisplayMaritalStatus == true){

        getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
           //console.log('result'+result);
           //console.log('result'+JSON.stringify(result));

          const employye = result;
          //console.log('employye.LastName'+employye.LastName);

          let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };

          if(this.DisplayContactInfo == true){
            if(this.EMS_EM_Contact_Number__c != null || this.Personal_Email_Id__c != null){
                //console.log('inside sisplaycontactinfo');
            guestObj.EMS_EM_Contact_Number__c = this.EMS_EM_Contact_Number__c;
            guestObj.Personal_Email_Id__c = this.Personal_Email_Id__c;
            guestObj.What_do_you_want_to_change__c = this.What_do_you_want_to_change__c;
            guestObj.EMS_EM_Request_Status__c = 'Pending';
            guestObj.EMS_EM_Request_Type__c = 'Personal Details';
            guestObj.Contact__c = this.contactID;
            }
            else{
              this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please fill atleast one field and try again!',
                  variant: 'error',
              }),
          );
            }



          }
          else if(this.DisplayMaritalStatus == true){

            if(this.EMS_EM_Mstatus__c == 'Single' ||(this.EMS_EM_Mstatus__c == 'Married' && this.EMS_EM_Spouse_Name__c != null && this.EMS_EM_DOW__c != null)){
              guestObj.EMS_EM_Mstatus__c = this.EMS_EM_Mstatus__c;
            guestObj.EMS_EM_Spouse_Name__c = this.EMS_EM_Spouse_Name__c;
            guestObj.EMS_EM_DOW__c = this.EMS_EM_DOW__c;
            guestObj.What_do_you_want_to_change__c = this.What_do_you_want_to_change__c;
            guestObj.EMS_EM_Request_Status__c = 'Pending';
            guestObj.EMS_EM_Request_Type__c = 'Personal Details';
            guestObj.Contact__c = this.contactID;
            }
            else{
              if(this.EMS_EM_Mstatus__c == 'Single' == null){
                this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please select marital status and try again!',
                  variant: 'error',
              }),
          );
              }
              else{
                this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please fill all details and try again!',
                  variant: 'error',
              }),
          );
              }

            }

          }

          //console.log('guestObj-->'+guestObj);

          const value = true;
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);

          saveRequest({newRecord: guestObj})
          .then(result => {
              //console.log('this.recordId-->'+this.recordId);
              this.recordId = result;
              //console.log('this.recordId-->'+this.recordId);

            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Request for personal details change successfully submitted',
                  variant: 'success',
              }),
          );

          this.closeModal();
          return refreshApex(this.refreshTable);
          //location.reload();

          })
          .catch(error => {
              this.error = error;
              console.log('this.error-->'+JSON.stringify(this.error));
          });


        }).catch(err => {
            console.log(err);

        });

    }
    else if(this.DisplayUpdateResume == true){
      if(this.fileData != null){
          //console.log('inside upload resume else if condition');


      getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
           //console.log('result'+result);
           //console.log('result'+JSON.stringify(result));

          const employye = result;
          //console.log('employye.LastName'+employye.LastName);
          let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };
          guestObj.What_do_you_want_to_change__c = this.What_do_you_want_to_change__c;
          guestObj.EMS_EM_Request_Status__c = 'Pending';
          guestObj.EMS_EM_Request_Type__c = 'Personal Details';
          guestObj.Contact__c = this.contactID;
          //console.log('guestObj-->'+guestObj);

          const value = true;
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);



          const {base64, filename} = this.fileData;
        //console.log(base64);
        //console.log(filename);
        uploadFileToNewContact({newRecord: guestObj, base64, filename })
          .then(result => {

		      this.fileData = null


            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Request for updation of resume successfully submitted',
                  variant: 'success',
              }),
          );


          this.closeModal();
          return refreshApex(this.refreshTable);
          //location.reload();

          })
          .catch(error => {
              this.error = error;
              console.log('this.error-->'+JSON.stringify(this.error));
          });


        }).catch(err => {
            console.log(err);

        });
      }
      else{
        this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please upload resume and try again!',
                  variant: 'error',
              }),
          );
      }

  }
  else{
    this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please select what you want to change!',
                  variant: 'error',
              }),
          );
  }


  }

      //handle educational details

  submitEducationalDetails(){

    if( this.DisplayCertificateInfo == true){
      //for certification name validation
      let validateCertName = false;
      const certNameRej = /^[a-z A-Z 0-9 & -]{2,80}$/;
      let certName = this.template.querySelector(".certName");
      let certNamevalue = certName.value;
      if (certNamevalue.match(certNameRej)) {
        certName.setCustomValidity("");
      } else {
        certName.setCustomValidity("Please Enter Valid Certification Name");
        validateCertName = true;
      }
      certName.reportValidity();

      if(!validateCertName && this.EMS_EM_Certification_Name__c != null){
        //console.log('inside upload resume else if condition');


      getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
        //console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
           //console.log('result'+result);
           //console.log('result'+JSON.stringify(result));

          const employye = result;
          //console.log('employye.LastName'+employye.LastName);
          let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };

          guestObj.EMS_EM_Add_Education__c = this.EMS_EM_Add_Education__c;
          guestObj.EMS_EM_Certification_Name__c = this.EMS_EM_Certification_Name__c;
          guestObj.EMS_EM_Request_Status__c = 'Pending';
          guestObj.EMS_EM_Request_Type__c = 'Education Details';
          guestObj.Contact__c = this.contactID;
          //console.log('guestObj-->'+guestObj);

          const value = true;
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);

          if(this.fileData != null){
              const {base64, filename} = this.fileData;
          //console.log(base64);
          //console.log(filename);
          uploadFileToNewContact({newRecord: guestObj, base64, filename })
          .then(result => {

		      this.fileData = null

            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Request for addition of certification details successfully submitted',
                  variant: 'success',
              }),
          );


          this.closeModal();
          return refreshApex(this.refreshTable);
          //location.reload();

          })
          .catch(error => {
              this.error = error;
              console.log('this.error-->'+JSON.stringify(this.error));
          });
          }
          else{
            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please upload relevant document',
                  variant: 'error',
              }),
          );
          }




        }).catch(err => {
            console.log(err);

        });

      }
      else{
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please fill all the details and try again!',
                  variant: 'error',
              }),
          );

      }

      }

    else if(this.DisplayDegreeInfo == true){

      if(this.EMS_EM_Level_of_Education__c != null && this.EMS_EM_Degree__c != null && this.EMS_EM_IName__c != null && this.EMS_EM_Field_of_Study__c != null && this.EMS_EM_GDate__c != null){

        //console.log('inside upload resume else if condition');


      getUserContactInfo({userId :this.userId}).then( result => {
         //console.log(this.userId);
       // console.log('result.Id==>'+result.Id);
      //  console.log('visiable edit__c==>'+result.visiable_to_edit__c);


        this.contactID=result.Id;
        //console.log('this.contactID==>'+this.contactID);
           //console.log('result'+result);
           //console.log('result'+JSON.stringify(result));

          const employye = result;
          //console.log('employye.LastName'+employye.LastName);
          let guestObj = { 'sobjectType': 'EMS_EM_Request__c' };

          guestObj.EMS_EM_Add_Education__c = this.EMS_EM_Add_Education__c;
          guestObj.EMS_EM_Level_of_Education__c = this.EMS_EM_Level_of_Education__c;
          guestObj.EMS_EM_Degree__c = this.EMS_EM_Degree__c;
          guestObj.EMS_EM_IName__c = this.EMS_EM_IName__c;
          guestObj.EMS_EM_Field_of_Study__c = this.EMS_EM_Field_of_Study__c;
          guestObj.EMS_EM_GDate__c = this.EMS_EM_GDate__c;
          guestObj.EMS_EM_Request_Status__c = 'Pending';
          guestObj.EMS_EM_Request_Type__c = 'Education Details';
          guestObj.Contact__c = this.contactID;
          //console.log('guestObj-->'+guestObj);

          const value = true;
          const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value }
          });
          // Fire the custom event
          this.dispatchEvent(valueChangeEvent);


          if(this.fileData != null){
            const {base64, filename} = this.fileData;
          //console.log(base64);
          //console.log(filename);
          uploadFileToNewContact({newRecord: guestObj, base64, filename })
          .then(result => {

		      this.fileData = null

            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Success',
                  message: 'Request for addition of education details successfully submitted',
                  variant: 'success',
              }),
          );


          this.closeModal();
          return refreshApex(this.refreshTable);
          //location.reload();

          })
          .catch(error => {
              this.error = error;
              console.log('this.error-->'+JSON.stringify(this.error));
          });
          }
          else{
            this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please upload relevant document',
                  variant: 'error',
              }),
          );
          }



        }).catch(err => {
            console.log(err);

        });

      }
      else{
    this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please fill all the details and try again!',
                  variant: 'error',
              }),
          );
  }
  }
  else{
    this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error',
                  message: 'Please fill all the details and try again!',
                  variant: 'error',
              }),
          );
  }


  }

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
  @track paFlag;
  AddressCheckboxChange(event) {
    this.inputcheckboxValue = event.target.checked ? 'Checked' : 'Unchecked';
    //console.log('this.inputcheckboxValue-->', this.inputcheckboxValue);



    if (this.inputcheckboxValue == 'Checked') {
      //console.log('address checked')
      this.EMS_EM_PAddress_Line_1__c = this.EMS_EM_CAddress_Line_1__c;
      this.EMS_EM_PAddress_Line_2__c = this.EMS_EM_CAddress_Line_2__c;
      this.EMS_EM_PA_State__c = this.EMS_EM_CA_State__c;
      this.EMS_EM_PA_City__c = this.EMS_EM_CA_City__c;
      this.EMS_EM_PA_Zip__c = this.EMS_EM_CA_Zip__c;
    } else {
      //console.log('address unchecked')
      this.EMS_EM_PAddress_Line_1__c = null;
      this.EMS_EM_PAddress_Line_2__c = null;
      this.EMS_EM_PA_State__c = null;
      this.EMS_EM_PA_City__c = null;
      this.EMS_EM_PA_Zip__c = null;
      //this.paFlag = false;
    }
  }
  // -------------Request History-------------



  @wire(getRequestHistory)
    requesthistory(result) {
      this.refreshTable = result;
        if (result.data) {
            this.data = result.data;
            this.fiteredData =   result.data;
            this.error = undefined;

        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }



    //for Request View popUp
    HandelViewRequestModel(event) {
      this.isShowViewRequest = true;
      this.requestType = event.target.dataset.value;
      this.ReqRecordId=event.target.dataset.recordId;
      console.log('mukesh console--->',event.target.dataset.recordId);
      //console.log('RequestType--->',event.target.dataset.value);
      //console.log('personalDetailsChoice--->',event.target.dataset.value1);
      //console.log('EducationChoice--->',event.target.dataset.value2);
      //const menuItem = this.template.querySelector('lightning-menu-item');
      this.personalDetailsChoice = event.target.dataset.value1;
      this.educationalDetailsChoice = event.target.dataset.value2;

      console.log('personalDetailsChoice--->',this.personalDetailsChoice);
      console.log('EducationChoice--->',this.educationalDetailsChoice);



      if(this.requestType == 'Address Details'){
        this.DisplayAddressDetails = true;

        }
      else if(this.requestType == 'Bank Details'){
        this.DisplayBankDetails = true;
      }
      else if(this.requestType == 'Emergency Details'){
        this.DisplayEmergencyDetails = true;
      }
      else if(this.requestType == 'Vehicle Details'){
        this.DisplayVehicleDetails = true;
      }
      else if(this.requestType == 'Personal Details'){

        if(this.personalDetailsChoice == 'Contact Info'){
            this.DisplayContactsInfo = true;
        }
        else if(this.personalDetailsChoice == 'Marital Status'){
            this.DisplayMaritalsStatus = true;
        }
        else if(this.personalDetailsChoice == 'Update Resume'){
            this.DisplayUpdatedResume = true;
        }
        return refreshApex(this.refreshTable);

      }
      else if(this.requestType == 'Education Details'){

        if(this.educationalDetailsChoice == 'Degree'){
            this.DisplayDegreesInfo = true;
        }
        else if(this.educationalDetailsChoice == 'Certificate'){
            this.DisplayCertificatesInfo = true;
        }
        return refreshApex(this.refreshTable);

      }
      if(this.DisplayAddressDetails == true || this.DisplayBankDetails == true || this.DisplayEmergencyDetails == true || this.DisplayContactsInfo == true || this.DisplayMaritalsStatus == true || this.DisplayVehicleDetails == true){
        this.OtherInfo = true;
      }
      return refreshApex(this.refreshTable);

    }
  hideModalBox() {
        this.isShowViewRequest = false;
        this.DisplayAddressDetails = false;
        this.DisplayBankDetails = false;
        this.DisplayEmergencyDetails = false;
        this.DisplayVehicleDetails = false;
        this.DisplayContactsInfo = false;
        this.DisplayMaritalsStatus = false;
        this.DisplayUpdatedResume = false;
        this.DisplayDegreesInfo = false;
        this.DisplayCertificatesInfo = false;
        return refreshApex(this.refreshTable);
  }
// Cancel Request
  handleCancelButton(event){
    console.log('RequestStatus--->',event.target.dataset.value);
    this.requeststatus = event.target.dataset.value;
    //
    if(this.requeststatus == 'Pending'){
      this.showcancelbutton = true;
    }
    else
    this.showcancelbutton = false;

  }

  async handleConfirmClick(event) {

    this.Requeststatus=event.target.dataset.value;
    console.log('cancel Record Id--->',event.target.dataset.value);
    this.ReqRecId=event.target.dataset.recordId;

    const result = await LightningConfirm.open({
        message: "Are you sure you want to Cancel this request?",
        variant: "default", // headerless
        theme: 'error', // more would be success, info, warning
        label: "Cancel the request"
    });
    //Confirm has been closed

    //result is true if OK was clicked

    if (result) {
      recallApproval({recId : this.ReqRecId})
        .then(result=> {
          this.dispatchEvent(new ShowToastEvent({
              title: 'Success!!',
              message: 'Request Cancelled Successfully !!.',
              variant: 'success'
          }),);
          return refreshApex(this.refreshTable);
      })
      .catch(error => {
          window.console.log('Error ====> '+error);
          this.dispatchEvent(new ShowToastEvent({
              title: 'Error!!',
              message: error.message,
              variant: 'error'
          }),);
      });

        }


     else {
    }


}


// Date Range Filter
async handleInvalidDateAlert( alertmessage) {
  await LightningAlert.open({
     message:alertmessage,
      theme: "Error",
      label: "Error!"
  });
}

  //Retrive Files

  @wire(getRelatedFilesByRecordId, {recordId: '$ReqRecordId'})
    wiredResult({data, error}){
        if(data){
            console.log(data)
            this.filesList = Object.keys(data).map(item=>({"label":data[item],
             "value": item,
             "url":`/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
        }
        if(error){
            console.log(error)
        }
    }


  }