import { LightningElement,api, track} from 'lwc';
import getUserContactInfo from '@salesforce/apex/EMS_EM_RequestViewFetch.getUserContactInfo';
export default class EMS_EM_Request_View extends LightningElement {
  @api recordId;
  @track contactRecordId;
  @track requestType;
  @track personalDetailsChoice;
  @track educationalDetailsChoice;
  @track TopDisplayText;
  @track oldMarStatusToggle;
  @track newMarStatusToggle;
  @track alwaysfalse=true;

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

 //Other info
  OtherInfo = false;


    connectedCallback(){
        //console.log('printing something' + this.recordId );
        //this.reqId = this.recordId;

        getUserContactInfo({reqrecordId: this.recordId}).then( result => {

          //console.log('this.contactID==>' + result.Contact__c);
            this.contactRecordId = result.Contact__c;
            this.requestType = result.EMS_EM_Request_Type__c;
            this.personalDetailsChoice = result.What_do_you_want_to_change__c;
            this.educationalDetailsChoice = result.EMS_EM_Add_Education__c;

            if(result.EMS_EM_Mstatus__c == 'Single'){
              this.newMarStatusToggle = false;
            }
            else{
              this.newMarStatusToggle = true;
            }

            if(result.EMS_EM_Mstatus_Old__c == 'Single'){
              this.oldMarStatusToggle = false;
            }
            else{
              this.oldMarStatusToggle = true;
            }
            //this.oldMarStatus = result.EMS_EM_Mstatus_Old__c;
            //this.newMarStatus = result.EMS_EM_Mstatus__c;


            
            //console.log('this.contactID==>' + this.contactRecordId);
            //console.log('this.requestType==>' + this.requestType);
            //console.log('this.personalDetailsChoice==>' + this.personalDetailsChoice);
            //console.log('this.educationalDetailsChoice==>' + this.educationalDetailsChoice);
            

            if(this.requestType == 'Address Details'){
              this.DisplayAddressDetails = true;
              this.TopDisplayText = 'Address Details Change Request';
            }
            else if(this.requestType == 'Bank Details'){
              this.DisplayBankDetails = true;
              this.TopDisplayText = 'Bank Details Change request';
            }
            else if(this.requestType == 'Emergency Details'){
              this.DisplayEmergencyDetails = true;
              this.TopDisplayText = 'Emergency Details Change Request';
            }
            else if(this.requestType == 'Vehicle Details'){
              this.DisplayVehicleDetails = true;
              this.TopDisplayText = 'Vehicle Details Change Request';
            }
            else if(this.requestType == 'Personal Details'){

              if(this.personalDetailsChoice == 'Contact Info'){
                  this.DisplayContactInfo = true;
                  this.TopDisplayText = 'Personal Info Change Request';
              }
              else if(this.personalDetailsChoice == 'Marital Status'){
                  this.DisplayMaritalStatus = true;
                  this.TopDisplayText = 'Marital Status Update Request';
              }
              else if(this.personalDetailsChoice == 'Update Resume'){
                  this.DisplayUpdatedResume = true;
                  this.TopDisplayText = 'Resume Update Request';
              }

            }
            else if(this.requestType == 'Education Details'){

              if(this.educationalDetailsChoice == 'Degree'){
                  this.DisplayDegreeInfo = true;
                  this.TopDisplayText = 'Education Details Update Request';
              }
              else if(this.educationalDetailsChoice == 'Certificate'){
                  this.DisplayCertificateInfo = true;
                  this.TopDisplayText = 'Education Details Update Request';
              }

            }
            if(this.DisplayAddressDetails == true || this.DisplayBankDetails == true || this.DisplayEmergencyDetails == true || this.DisplayContactInfo == true || this.DisplayMaritalStatus == true || this.DisplayVehicleDetails == true){
              this.OtherInfo = true;
            }

          //console.log(this.DisplayUpdatedResume);

            }).catch(err => {
                console.log(err);
            });
      }
}