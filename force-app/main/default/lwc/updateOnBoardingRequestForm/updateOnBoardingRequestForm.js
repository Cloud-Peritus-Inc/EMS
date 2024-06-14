import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getonOnboardformInfo from '@salesforce/apex/EMS_EM_CreationOnboard.getonOnboardformInfo';
import updateOnboardingInfo from '@salesforce/apex/EMS_EM_CreationOnboard.updateonboardingDetails';
import createGuest from '@salesforce/apex/EMS_EM_CreationOnboard.createGuest';


const maskAccountNumber = value => {

  if (value === undefined || value === null || value === "") {
    return value;
  }
  let v = value.replace(/\D/g, '');
  let str = v.replace(/\d(?=\d{4})/g, "*");
  return str;
}

const maskPanNumber = value => {

  if (value === undefined || value === null || value === "") {
    return value;
  }
  let str = value.replace(/\d(?=\d{0})/g, "*");
  return str;
}

function uploadFilesFromThis(event,ts){
    if (event.target.files.length > 0 && event.target.files[0].size < 2000000 && event.target.files[0].type =="application/pdf") {
        let file = event.target.files[0];
       let nameOfInput = event.target.name;
       let uploadedFileName = event.target.files[0].name; 
       let fileNameToAdd = event.target.files[0].name;
       let fileTypeToAdd = event.target.files[0].type;
       let concatFileName;
       if(nameOfInput === "aadharCard"){
         ts.fileName = uploadedFileName;
         concatFileName = 'aadharCard_'+fileNameToAdd;
       } else if(nameOfInput === "panCard"){
         ts.fileName1 = uploadedFileName;
         concatFileName = 'panCard_'+fileNameToAdd;
       }

        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
            ts.filesUploaded = [...ts.filesUploaded,{PathOnClient: file.name, Title: concatFileName, VersionData: fileContents}]
        };
        reader.readAsDataURL(file);
    }else{
     const even = new ShowToastEvent({
     message: 'The maximum file size is 2MB and the supported file type is PDF',
     variant: 'error'
    });
   ts.dispatchEvent(even);
   } 
}



function updateOnBoardingRequest(ts){
let guestObj = { 'sobjectType': 'EMS_EM_Onboarding_Request__c' };
guestObj.Id = ts.onboardingformId;
//console.log('Id => ' ,guestObj.Id);
//console.log('onboardingformId => ' ,ts.onboardingformId);
//console.log('onboardingformId 2 => ' ,ts.onboardingformId);
guestObj.EMS_EM_First_Name__c = ts.firstName;
guestObj.EMS_EM_Last_Name__c = ts.lastName;
guestObj.Trailblazer_ID_or_Public_URL__c=ts.Trailblazerval;
guestObj.Phone_Number__c = ts.ph;
guestObj.EMS_EM_Phone_Number__c= ts.altphone;
guestObj.EMS_EM_DOB__c = ts.dob;
guestObj.EMS_EM_Personal_Email__c= ts.personalemail;
guestObj.EMS_EM_AadhaarNo__c= ts.actualAadharNumber;
guestObj.EMS_EM_PanNo__c= ts.actualPanNumber;
guestObj.EMS_EM_PassportNo__c=ts.actualPassportNumber;
guestObj.EMS_EM_UAN_Number__c = ts.pfn;
guestObj.EMS_EM_Nationality__c = ts.nation;
guestObj.EMS_EM_Gender__c = ts.gen;
guestObj.EMS_EM_CA_State__c=ts.castate;
guestObj.EMS_EM_PA_State__c=ts.pastate;
guestObj.EMS_EM_CA_City__c=ts.cacity;
guestObj.EMS_EM_PA_City__c =ts.pacity;
guestObj.EMS_EM_CA_Zip__c=ts.cazip;
guestObj.EMS_EM_PA_Zip__c=ts.pazip;
guestObj.CA_Country__c=ts.countryval;
guestObj.PA_Country__c=ts.countryvalpa;
guestObj.Current_Address_Line_1__c=ts.cadrressline1;
guestObj.Current_Address_Line_2__c=ts.cadrressline2;
guestObj.Permanent_Address_Line_1__c=ts.padrressline1;
guestObj.Permanent_Address_Line_2__c=ts.padrressline2;
guestObj.Personal_Details_Value_Filled__c = ts.isPersonalUpdateCheckbox;
guestObj.Identify_Details_Value_Filled__c = ts.isIdentifyDetailsCheckbox;
guestObj.Other_Certifications_Value_Filled__c=ts.isOtherCertificationsCheckbox;
guestObj.Address_Details_Value_Filled__c = ts.isAddressDetailsCheckbox;
guestObj.Company_Information_Viewed__c = ts.isCompanyInformationValueChecked;
guestObj.Education_Details_Filled__c=ts.isEducationDetailsCheckbox;
guestObj.Work_Details_Filled__c=ts.isWorkExperienceCheckbox;
guestObj.Is_Confirm__c = ts.isConfirmSubmit;
guestObj.Status__c = ts.statusUpdate;
if(ts.isWorkExperience){
  guestObj.Do_you_have_work_experience__c = ts.doYouHaveExp;
}
        //ts.readonlyfield=true;
        createGuest({newRecord: guestObj , files: ts.filesUploaded})
      .then(result => {  
          ts.onboardingformId=result.onboarding.Id;
          ts.filesUploaded = [];   
         // console.log('this.onboardingformID'+ts.onboardingformId); 
          if(ts.isShowPersonalDetails){
            displayShowtoastMessage('Details saved successfully','success',ts);
            ts.isShowPersonalDetailsValueFilled = true;
            //console.log('Details Filled',ts.isShowPersonalDetailsValueFilled);
       }
         if(ts.isIdentifyDetails){     
           displayShowtoastMessage('Details saved successfully','success',ts); 
       }  
       if(ts.isAddressDetails){
        displayShowtoastMessage('Details saved successfully','success',ts); 
       }
       if(ts.isEducationDetails){
       }
      
       if(ts.isWorkExperience){
          //displayShowtoastMessage('Success','Onboarding Form Work Experience Details Saved Successfully','success',ts); 
       }
          ts.handleIsLoading(false);               
      })
      .catch(error => {
          ts.error = error;
          console.log('this.error-->'+JSON.stringify(ts.error));
          //this.handleIsLoading(false);
      });
    

}

function updateOnboardingInfoOnPageLoads(ts){
        ts.selectedStep = 'Step1';
          const queryString = window.location.search;
          const urlParams = new URLSearchParams(queryString);
          ts.personalemail = urlParams.get('emailid');
          var completedu = decodeURIComponent(urlParams);
         // console.log('=completedu===='+completedu);
          const myArray = completedu.split("=");
         let word = myArray[1];
          ts.personalemail = word;
          //console.log('=completedu===='+ts.personalemail);
          getonOnboardformInfo({onboardEmailid: ts.personalemail})
          .then(result => {
            //console.log('result-->',result);
            //console.log('result'+JSON.stringify(result));
            const onboarding = result.onboarding;
            //const additionalDetails = result.additionalDetails;
            //ts.additionalDetailsRecordId = result.additionalDetails.Id;
            ts.onboardingformId = onboarding.Id;
            ts.firstName = onboarding.EMS_EM_First_Name__c;
            ts.lastName=onboarding.EMS_EM_Last_Name__c;
            ts.ph=onboarding.Phone_Number__c;
            ts.contactId = onboarding.ContactId1__c;
            //console.log('onboardingformId------>' ,onboarding.ContactId1__r.EMS_Employee_Type__c);
            ts.companyInformation = result.gridConfiguration;
           // console.log("result.gridConfiguration", JSON.stringify(result.gridConfiguration));
              //ts.dataList = result.contentDocumentLink;
              let filteredFiles = result.contentDocumentLink.filter((file) => file.Title.includes('Work_Details_'));
              if (filteredFiles.length > 0) {
                ts.isUploadReq = false;
                ts.dataDocList = filteredFiles;
              } else {
                ts.isUploadReq = true;
                ts.dataDocList = undefined;
              }
              let filteredEduFiles = result.contentDocumentLink.filter((file) => file.Title.includes('Certificate_'));
              if (filteredEduFiles.length > 0) {
                ts.isUploadEduReq = false
                ts.dataPFList = filteredEduFiles;
              } else {
                ts.isUploadEduReq = true;
                ts.dataPFList = undefined;
              }
            result.contentDocumentLink.forEach((currentItem) => {
              if(currentItem.Title.includes('Picture_')){
              ts.fileName2 = currentItem.Title;
             // console.log('passport photo',ts.fileName2);
              }
             else if(currentItem.Title.includes('aadharCard_')){
                ts.fileName = currentItem.Title;
               // console.log('aadhar photo',ts.fileName);
                }
             else if(currentItem.Title.includes('panCard_')){
                  ts.fileName1 = currentItem.Title;
                 // console.log('pan photo',ts.fileName1);
             }
          })
            if(onboarding !=null){
             // this.readonlyfield=true;
              ts.firstName = onboarding.EMS_EM_First_Name__c;
              ts.lastName=onboarding.EMS_EM_Last_Name__c;
              ts.Trailblazerval = onboarding.Trailblazer_ID_or_Public_URL__c;
              ts.gen=onboarding.EMS_EM_Gender__c;
              ts.ph=onboarding.Phone_Number__c;
              ts.dob=onboarding.EMS_EM_DOB__c;
              ts.doYouHaveExp=onboarding.Do_you_have_work_experience__c;
              ts.aadhaarNo=maskAccountNumber(onboarding.EMS_EM_AadhaarNo__c);
              ts.panNo=maskPanNumber(onboarding.EMS_EM_PanNo__c);
              ts.nation=onboarding.EMS_EM_Nationality__c;
              ts.altphone=onboarding.EMS_EM_Phone_Number__c;
              ts.castate=onboarding.EMS_EM_CA_State__c;
              ts.pastate=onboarding.EMS_EM_PA_State__c;
              ts.cacity=onboarding.EMS_EM_CA_City__c;
              ts.pacity=onboarding.EMS_EM_PA_City__c;
              ts.cazip=onboarding.EMS_EM_CA_Zip__c;
              ts.pazip=onboarding.EMS_EM_PA_Zip__c;
              ts.countryval=onboarding.CA_Country__c;
              ts.countryvalpa=onboarding.PA_Country__c;
              ts.cadrressline1=onboarding.Current_Address_Line_1__c;
              ts.cadrressline2=onboarding.Current_Address_Line_2__c;
              ts.padrressline1=onboarding.Permanent_Address_Line_1__c;
              ts.padrressline2=onboarding.Permanent_Address_Line_2__c;
              if(ts.cadrressline1 !=null && ts.padrressline1 != null){
                if(ts.cadrressline1 === ts.padrressline1){
                  ts.paFlag = true;
                  ts.readonlyfield1 = true;
                  ts.disableFlag = false;
                  }
                  else{
                    ts.disableFlag = false;
                    ts.readonlyfield1 = false;
                  }
               }
              ts.EmployeeType=onboarding.ContactId1__r.EMS_Employee_Type__c;         
              ts.isPersonalUpdateCheckbox = onboarding.Personal_Details_Value_Filled__c;
              ts.isIdentifyDetailsCheckbox = onboarding.Identify_Details_Value_Filled__c;
              ts.isAddressDetailsCheckbox = onboarding.Address_Details_Value_Filled__c;
              ts.isOtherCertificationsCheckbox = onboarding.Other_Certifications_Value_Filled__c;
              ts.isEducationDetailsCheckbox = onboarding.Education_Details_Filled__c;
              ts.isWorkExperienceCheckbox = onboarding.Work_Details_Filled__c;
              ts.isCompanyInformationValueChecked = onboarding.Company_Information_Viewed__c;
              ts.isConfirmSubmit = onboarding.Is_Confirm__c;
              ts.statusUpdate = onboarding.Status__c;
              
              
              if(result.onboarding.Personal_Details_Value_Filled__c === true){
                ts.isPersonalUpdateCheckbox = true;
                ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Identify_Details_Value_Filled__c === true){
                  ts.isIdentifyDetailsCheckbox = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Address_Details_Value_Filled__c === true){
                  ts.isAddressDetailsCheckbox = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Other_Certifications_Value_Filled__c === true){
                  ts.isOtherCertificationsCheckbox = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Education_Details_Filled__c === true){
                  ts.isEducationDetailsCheckbox = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Work_Details_Filled__c === true){
                  ts.isWorkExperienceCheckbox = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Company_Information_Viewed__c === true){
                  ts.isCompanyInformationValueChecked = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Is_Confirm__c === true){
                  ts.isConfirmSubmit = true;
                  ts.readonlyfield=true;
                  ts.readonlyfield1 = true;
                  ts.statusUpdate = 'Submitted for Review';
                  ts.buttonDisable = true;
                  ts.expression1 = true;
                  ts.disableFlag = true;
                  //console.log('Is_Confirm__c',ts.confirmStatusUpdate);
                }
                
            }
        })
        .catch(error => {
            ts.error = error;
            console.log('this.error-->'+ts.error);
            //this.handleIsLoading(false);
        });
    
}

function displayShowtoastMessage( messageToDisplay, variantToDisplay,ts){
    const evt = new ShowToastEvent({
            message: messageToDisplay,
            variant: variantToDisplay,
        });
        ts.dispatchEvent(evt);

}

export {uploadFilesFromThis, updateOnBoardingRequest, updateOnboardingInfoOnPageLoads, displayShowtoastMessage}