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
       else if(nameOfInput === "certificate"){
         ts.fileName3 = uploadedFileName;
         concatFileName = 'certificate_'+fileNameToAdd;
       }
       else if(nameOfInput === "certificate1"){
         ts.fileName4 = uploadedFileName;
          concatFileName = 'certificate1_'+fileNameToAdd;
       }
       else if(nameOfInput === "certificate2"){
             ts.fileName5 = uploadedFileName;
             concatFileName = 'certificate2_'+fileNameToAdd;
       }
       else if(nameOfInput === "certificate3"){
             ts.fileName6 = uploadedFileName;
             concatFileName = 'certificate3_'+fileNameToAdd;
       }
       else if(nameOfInput === "certificate4"){
             ts.fileName7 = uploadedFileName;
             concatFileName ='certificate4_'+fileNameToAdd;
       }
       else if(nameOfInput === "certificate5"){
        ts.fileName8 = uploadedFileName;
        concatFileName = 'certificate5_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate6"){
        ts.CertificationfileName1 = uploadedFileName;
        concatFileName = 'Certificate6_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate7"){
        ts.CertificationfileName2 = uploadedFileName;
        concatFileName = 'Certificate7_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate8"){
        ts.CertificationfileName3 = uploadedFileName;
        concatFileName = 'Certificate8_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate9"){
        ts.CertificationfileName4 = uploadedFileName;
        concatFileName = 'Certificate9_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate10"){
        ts.CertificationfileName5 = uploadedFileName;
        concatFileName = 'Certificate10_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate11"){
        ts.CertificationfileName6 = uploadedFileName;
        concatFileName = 'Certificate11_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate12"){
        ts.CertificationfileName7 = uploadedFileName;
        concatFileName = 'Certificate12_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate13"){
        ts.CertificationfileName8 = uploadedFileName;
        concatFileName = 'Certificate13_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate14"){
        ts.CertificationfileName9 = uploadedFileName;
        concatFileName = 'Certificate14_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate15"){
        ts.CertificationfileName10 = uploadedFileName;
        concatFileName = 'Certificate15_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate16"){
        ts.CertificationfileName11 = uploadedFileName;
        concatFileName = 'Certificate16_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate17"){
        ts.CertificationfileName12 = uploadedFileName;
        concatFileName = 'Certificate17_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate18"){
        ts.CertificationfileName13 = uploadedFileName;
        concatFileName = 'Certificate18_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate19"){
        ts.CertificationfileName14 = uploadedFileName;
        concatFileName = 'Certificate19_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate20"){
        ts.CertificationfileName15 = uploadedFileName;
        concatFileName = 'Certificate20_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate21"){
        ts.CertificationfileName16 = uploadedFileName;
        concatFileName = 'Certificate21_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate22"){
        ts.CertificationfileName17 = uploadedFileName;
        concatFileName = 'Certificate22_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate23"){
        ts.CertificationfileName18 = uploadedFileName;
        concatFileName = 'Certificate23_'+fileNameToAdd;
       } 
       else if(nameOfInput === "Certificate24"){
        ts.CertificationfileName19 = uploadedFileName;
        concatFileName = 'Certificate24_'+fileNameToAdd;
       }
       else if(nameOfInput === "Certificate25"){
        ts.CertificationfileName20 = uploadedFileName;
        concatFileName = 'Certificate25_'+fileNameToAdd;
       } 
       else if(nameOfInput === "Certificate26"){
        ts.fileName9 = uploadedFileName;
        concatFileName = 'Certificate26_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate27"){
        ts.fileName10 = uploadedFileName;
        concatFileName = 'Certificate27_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate28"){
        ts.fileName11 = uploadedFileName;
        concatFileName = 'Certificate28_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate29"){
            ts.fileName12 = uploadedFileName;
            concatFileName = 'Certificate29_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate30"){
            ts.fileName13 = uploadedFileName;
            concatFileName = 'Certificate30_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate31"){
            ts.fileName14 = uploadedFileName;
            concatFileName = 'Certificate31_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate32"){
       ts.fileName15 = uploadedFileName;
       concatFileName = 'Certificate32_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate33"){
        ts.fileName16 = uploadedFileName;
        concatFileName = 'Certificate33_'+fileNameToAdd;
      }
      else if(nameOfInput === "Certificate34"){
       ts.fileName17 = uploadedFileName;
       concatFileName = 'Certificate34_'+fileNameToAdd;
     }   
       
        let reader = new FileReader();
        reader.onloadend = e => {
            let base64 = 'base64,';
            let content = reader.result.indexOf(base64) + base64.length;
            let fileContents = reader.result.substring(content);
          //  ts.filesUploaded.push({PathOnClient: file.name, Title: file.name, VersionData: fileContents});
            ts.filesUploaded = [...ts.filesUploaded,{PathOnClient: file.name, Title: concatFileName, VersionData: fileContents}]
        };
        reader.readAsDataURL(file);
    }else{
     const even = new ShowToastEvent({
     message: 'File Size must be less than 2Mb & file type should be PDF only',
     variant: 'error'
    });
   ts.dispatchEvent(even);
   } 
}



function updateOnBoardingRequest(ts){
let guestObj = { 'sobjectType': 'EMS_EM_Onboarding_Request__c' };
guestObj.Id = ts.onboardingformId;
//console.log('Id => ' ,guestObj.Id);
//console.log('onboardingformId => ' ,onboardingformId);
console.log('onboardingformId 2 => ' ,ts.onboardingformId);
guestObj.EMS_EM_First_Name__c = ts.firstName;
guestObj.EMS_EM_Last_Name__c = ts.lastName;
guestObj.Phone_Number__c = ts.ph;
guestObj.EMS_EM_Phone_Number__c= ts.altphone;
guestObj.EMS_EM_DOB__c = ts.dob;
guestObj.EMS_EM_Mstatus__c = ts.mstatus;
guestObj.EMS_EM_Spouse__c = ts.spouse;
guestObj.EMS_EM_DOW__c = ts.dow;
guestObj.EMS_EM_Personal_Email__c= ts.personalemail;
guestObj.EMS_EM_AadhaarNo__c= ts.actualAadharNumber;
guestObj.EMS_EM_PanNo__c= ts.actualPanNumber;
guestObj.EMS_EM_PassportNo__c=ts.actualPassportNumber;
guestObj.EMS_EM_UAN_Number__c = ts.pfn;
guestObj.EMS_EM_Nationality__c = ts.nation;
guestObj.EMS_EM_Gender__c = ts.gen;
guestObj.EMS_EM_BG__c = ts.bg;
guestObj.EMS_EM_CA_State__c=ts.castate;
guestObj.EMS_EM_PA_State__c=ts.pastate;
guestObj.EMS_EM_CA_City__c=ts.cacity;
guestObj.EMS_EM_PA_City__c =ts.pacity;
guestObj.EMS_EM_CA_Zip__c=ts.cazip;
guestObj.EMS_EM_PA_Zip__c=ts.pazip;
guestObj.Current_Address_Line_1__c=ts.cadrressline1;
guestObj.Current_Address_Line_2__c=ts.cadrressline2;
guestObj.Permanent_Address_Line_1__c=ts.padrressline1;
guestObj.Permanent_Address_Line_2__c=ts.padrressline2;
guestObj.EMS_EM_Certification_Name__c=ts.Certificationname1;
guestObj.EMS_EM_Certification_Name1__c=ts.Certificationname2;
guestObj.EMS_EM_Certification_Name2__c=ts.Certificationname3;
guestObj.EMS_EM_Certification_Name3__c=ts.Certificationname4;
guestObj.EMS_EM_Certification_Name4__c=ts.Certificationname5;
guestObj.EMS_EM_Certification_Name5__c=ts.Certificationname6;
guestObj.EMS_EM_Certification_Name6__c=ts.Certificationname7;
guestObj.EMS_EM_Certification_Name7__c=ts.Certificationname8;
guestObj.EMS_EM_Certification_Name8__c=ts.Certificationname9;
guestObj.EMS_EM_Certification_Name9__c=ts.Certificationname10;
guestObj.EMS_EM_Certification_Name10__c=ts.Certificationname11;
guestObj.EMS_EM_Certification_Name11__c=ts.Certificationname12;
guestObj.EMS_EM_Certification_Name12__c=ts.Certificationname13;
guestObj.EMS_EM_Certification_Name13__c=ts.Certificationname14;
guestObj.EMS_EM_Certification_Name14__c=ts.Certificationname15;
guestObj.EMS_EM_Certification_Name15__c=ts.Certificationname16;
guestObj.EMS_EM_Certification_Name16__c=ts.Certificationname17;
guestObj.EMS_EM_Certification_Name17__c=ts.Certificationname18;
guestObj.EMS_EM_Certification_Name18__c=ts.Certificationname19;
guestObj.EMS_EM_Certification_Name19__c=ts.Certificationname20;
guestObj.Personal_Details_Value_Filled__c = ts.isPersonalUpdateCheckbox;
guestObj.Identify_Details_Value_Filled__c = ts.isIdentifyDetailsCheckbox;
guestObj.Other_Certifications_Value_Filled__c=ts.isOtherCertificationsCheckbox;
guestObj.Address_Details_Value_Filled__c = ts.isAddressDetailsCheckbox;
guestObj.Company_Information_Viewed__c = ts.isCompanyInformationValueChecked;
guestObj.Is_Confirm__c = ts.isConfirmSubmit;
guestObj.Status__c = ts.statusUpdate;
guestObj.Status__c = ts.isIdentityStatusUpdate;
guestObj.Status__c = ts.isAdressStatusUpdate;
guestObj.Status__c = ts.isEducationStatusUpdate;
guestObj.Status__c = ts.isCertificationStatusUpdate;
guestObj.Status__c = ts.isWorkExperienceStatusUpdate;
guestObj.Status__c = ts.confirmStatusUpdate;

  console.log('guestObj-->'+guestObj);
  
  let guestObj1 = { 'sobjectType': 'ems_EM_Additional_Detail__c' };
        guestObj1.Id = ts.additionalDetailsRecordId;
        guestObj1.EMS_EM_Education__c = ts.levleofedu;
        guestObj1.EMS_EM_Field_of_Study__c = ts.fieldOfStudy;
        guestObj1.EMS_EM_IName__c = ts.instutionname;
        guestObj1.EMS_EM_GDate__c = ts.graduationDate;
        guestObj1.EMS_EM_Degree__c=ts.degree;

        guestObj1.EMS_EM_Education1__c = ts.levleofedu1;
        guestObj1.EMS_EM_Field_of_Study1__c = ts.fieldOfStudy1;
        guestObj1.EMS_EM_IName1__c = ts.instutionname1;
        guestObj1.EMS_EM_GDate1__c = ts.graduationDate1;
        guestObj1.EMS_EM_Degree1__c=ts.degree1;

        guestObj1.EMS_EM_Education2__c = ts.levleofedu2;
        guestObj1.EMS_EM_Field_of_Study2__c = ts.fieldOfStudy2;
        guestObj1.EMS_EM_IName2__c = ts.instutionname2;
        guestObj1.EMS_EM_GDate2__c = ts.graduationDate2;
        guestObj1.EMS_EM_Degree2__c=ts.degree2;

        guestObj1.EMS_EM_Education3__c = ts.levleofedu3;
        guestObj1.EMS_EM_Field_of_Study3__c = ts.fieldOfStudy3;
        guestObj1.EMS_EM_IName3__c = ts.instutionname3;
        guestObj1.EMS_EM_GDate3__c = ts.graduationDate3;
        guestObj1.EMS_EM_Degree3__c=ts.degree3;

        guestObj1.EMS_EM_Education4__c = ts.levleofedu4;
        guestObj1.EMS_EM_Field_of_Study4__c = ts.fieldOfStudy4;
        guestObj1.EMS_EM_IName4__c = ts.instutionname4;
        guestObj1.EMS_EM_GDate4__c = ts.graduationDate4;
        guestObj1.EMS_EM_Degree4__c=ts.degree4;

        guestObj1.EMS_EM_Education5__c = ts.levleofedu5;
        guestObj1.EMS_EM_Field_of_Study5__c = ts.fieldOfStudy5;
        guestObj1.EMS_EM_IName5__c = ts.instutionname5;
        guestObj1.EMS_EM_GDate5__c = ts.graduationDate5;
        guestObj1.EMS_EM_Degree5__c=ts.degree5;

        guestObj1.EMS_EM_Job_Title__c=ts.jobtitle0;
        guestObj1.EMS_EM_From_Date__c=ts.fromdate0;
        guestObj1.EMS_EM_To_Date__c= ts.todate0;
        guestObj1.EMS_EM_Previous_Company_Name__c= ts.previouscompanyname0;
        guestObj1.EMS_EM_Previous_Company_HR_EmailId__c=ts.previouscomemailid;
        

        guestObj1.EMS_EM_Job_Title1__c=ts.jobtitle1;
        guestObj1.EMS_EM_From_Date1__c=ts.fromdate1;
        guestObj1.EMS_EM_To_Date1__c=ts.todate1;
        guestObj1.EMS_EM_Previous_Company_Name1__c=ts.previouscompanyname1;

        guestObj1.EMS_EM_Job_Title2__c=ts.jobtitle2;
        guestObj1.EMS_EM_From_Date2__c=ts.fromdate2;
        guestObj1.EMS_EM_To_Date2__c=ts.todate2;
        guestObj1.EMS_EM_Previous_Company_Name2__c=ts.previouscompanyname2;

        guestObj1.EMS_EM_Job_Title3__c=ts.jobtitle3;
        guestObj1.EMS_EM_From_Date3__c=ts.fromdate3;
        guestObj1.EMS_EM_To_Date3__c=ts.todate3;
        guestObj1.EMS_EM_Previous_Company_Name3__c=ts.previouscompanyname3;

        guestObj1.EMS_EM_Job_Title4__c=ts.jobtitle4;
        guestObj1.EMS_EM_From_Date4__c=ts.fromdate4;
        guestObj1.EMS_EM_To_Date4__c=ts.todate4;
        guestObj1.EMS_EM_Previous_Company_Name4__c=ts.previouscompanyname4;

        guestObj1.EMS_EM_Job_Title5__c=ts.jobtitle5;
        guestObj1.EMS_EM_From_Date5__c=ts.fromdate5;
        guestObj1.EMS_EM_To_Date5__c=ts.todate5;
        guestObj1.EMS_EM_Previous_Company_Name5__c=ts.previouscompanyname5;
        guestObj1.Education_Details_Filled__c=ts.isEducationDetailsCheckbox;
        guestObj1.Work_Details_Filled__c=ts.isWorkExperienceCheckbox;

      //  ts.hideModalBox();
        //ts.readonlyfield=true;
        createGuest({newRecord: guestObj , newaddRecord: guestObj1 , files: ts.filesUploaded})
      .then(result => {  
          ts.onboardingformId=result.onboarding.Id;
          ts.additionalDetailsRecordId = result.additionalDetails.Id;
          ts.filesUploaded = [];   
          console.log('this.onboardingformID'+ts.onboardingformId); 
          if(ts.isShowPersonalDetails){
            displayShowtoastMessage('Success','Onboarding Form Personal Details Saved Successfully','success',ts);
            ts.isShowPersonalDetailsValueFilled = true;
            console.log('Details Filled',ts.isShowPersonalDetailsValueFilled);
       }
         if(ts.isIdentifyDetails){     
           displayShowtoastMessage('Success','Onboarding Form Identification Details Saved Successfully','success',ts); 
       }  
       if(ts.isAddressDetails){
        displayShowtoastMessage('Success','Onboarding Form Address Details Saved Successfully','success',ts); 
       }
       if(ts.isEducationDetails){
          displayShowtoastMessage('Success','Onboarding Form Educational Details Saved Successfully','success',ts); 
       }
       if(ts.isOtherCertifications){
        displayShowtoastMessage('Success','Onboarding Form Other Certification Details Saved Successfully','success',ts);
       }
       if(ts.isWorkExperience){
          displayShowtoastMessage('Success','Onboarding Form Work Experience Details Saved Successfully','success',ts); 
       }
  //         sendEmail({  subject: "Onboard Form Submission",recordId:ts.onboardingformId,
  //         body: "Dear HR Team,"+"<Br/><Br/>"+"Employee  has submitted their onboarding form along with the required documents."+"<Br/><Br/>"+"Click here https://cpprd.lightning.force.com/"+this.onboardingformId+ "  to find and verify the details."})
  //  // https://cpprd--uat.sandbox.lightning.force.com/
           console.log('this.onboardingformID'+this.additionalDetailsRecordId);    
                      
      })
      .catch(error => {
          ts.error = error;
          console.log('this.error-->'+JSON.stringify(ts.error));
      });
    

}

function updateOnboardingInfoOnPageLoads(ts){
        ts.selectedStep = 'Step1';
          const queryString = window.location.search;
          const urlParams = new URLSearchParams(queryString);
          ts.personalemail = urlParams.get('emailid');
          console.log('emailid==>',ts.personalemail);

          getonOnboardformInfo({onboardEmailid: ts.personalemail})
          .then(result => {
            console.log('result-->',result);
            console.log('result'+JSON.stringify(result));
            const onboarding = result.onboarding;
            const additionalDetails = result.additionalDetails;
            ts.additionalDetailsRecordId = result.additionalDetails.Id;
            ts.onboardingformId = onboarding.Id;
            ts.companyInformation = result.gridConfiguration;
            console.log("result.gridConfiguration", JSON.stringify(result.gridConfiguration));
            console.log('onboarding'+onboarding);
            console.log('FILES ' , result.contentDocumentLink);
            result.contentDocumentLink.forEach((currentItem) => {
              if(currentItem.Title.includes('passport_')){
              ts.fileName2 = currentItem.Title;
              console.log('passport photo',ts.fileName2);
              }
             else if(currentItem.Title.includes('aadharCard_')){
                ts.fileName = currentItem.Title;
                console.log('aadhar photo',ts.fileName);
                }
             else if(currentItem.Title.includes('panCard_')){
                  ts.fileName1 = currentItem.Title;
                  console.log('pan photo',ts.fileName1);
             }
             else if(currentItem.Title.includes('certificate_')){
              ts.fileName3 = currentItem.Title;
              console.log('certificate photo',ts.fileName3);
             }
             else if(currentItem.Title.includes('certificate1_')){
              ts.fileName4 = currentItem.Title;
              console.log('certificate photo',ts.fileName4);
             }
             else if(currentItem.Title.includes('certificate2_')){
              ts.fileName5 = currentItem.Title;
              console.log('certificate photo',ts.fileName5);
             }
             else if(currentItem.Title.includes('certificate3_')){
              ts.fileName6 = currentItem.Title;
              console.log('certificate photo',ts.fileName6);
             }
             else if(currentItem.Title.includes('certificate4_')){
              ts.fileName7 = currentItem.Title;
              console.log('certificate photo',ts.fileName7);
             }
             else if(currentItem.Title.includes('certificate5_')){
              ts.fileName8 = currentItem.Title;
              console.log('certificate photo',ts.fileName8);
             }
             else if(currentItem.Title.includes('Certificate6_')){
              ts.CertificationfileName1 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName1);
             }
             else if(currentItem.Title.includes('Certificate7_')){
              ts.CertificationfileName2 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName2);
             }
             else if(currentItem.Title.includes('Certificate8_')){
              ts.CertificationfileName3 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName3);
             }
             else if(currentItem.Title.includes('Certificate9_')){
              ts.CertificationfileName4 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName4);
             }
             else if(currentItem.Title.includes('Certificate10_')){
              ts.CertificationfileName5 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName5);
             }
             else if(currentItem.Title.includes('Certificate11_')){
              ts.CertificationfileName6 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName6);
             }
             else if(currentItem.Title.includes('Certificate12_')){
              ts.CertificationfileName7 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName7);
             }
             else if(currentItem.Title.includes('Certificate13_')){
              ts.CertificationfileName8 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName8);
             }
             else if(currentItem.Title.includes('Certificate14_')){
              ts.CertificationfileName9 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName9);
             }
             else if(currentItem.Title.includes('Certificate15_')){
              ts.CertificationfileName10 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName10);
             }
             else if(currentItem.Title.includes('Certificate16_')){
              ts.CertificationfileName11 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName11);
             }
             else if(currentItem.Title.includes('Certificate17_')){
              ts.CertificationfileName12 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName12);
             }
             else if(currentItem.Title.includes('Certificate18_')){
              ts.CertificationfileName13 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName13);
             }
             else if(currentItem.Title.includes('Certificate19_')){
              ts.CertificationfileName14 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName14);
             }
             else if(currentItem.Title.includes('Certificate20_')){
              ts.CertificationfileName15 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName15);
             }
             else if(currentItem.Title.includes('Certificate21_')){
              ts.CertificationfileName16 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName16);
             }
             else if(currentItem.Title.includes('Certificate22_')){
              ts.CertificationfileName17 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName17);
             }
             else if(currentItem.Title.includes('Certificate23_')){
              ts.CertificationfileName18 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName18);
             }
             else if(currentItem.Title.includes('Certificate24_')){
              ts.CertificationfileName19 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName19);
             }
             else if(currentItem.Title.includes('Certificate25_')){
              ts.CertificationfileName20 = currentItem.Title;
              console.log('certificate photo',ts.CertificationfileName20);
             }
             else if(currentItem.Title.includes('Certificate26_')){
              ts.fileName9 = currentItem.Title;
              console.log('certificate photo',ts.fileName9);
             }
             else if(currentItem.Title.includes('Certificate27_')){
              ts.fileName10 = currentItem.Title;
              console.log('certificate photo',ts.fileName10);
             }
             else if(currentItem.Title.includes('Certificate28_')){
              ts.fileName11 = currentItem.Title;
              console.log('certificate photo',ts.fileName11);
             }
             else if(currentItem.Title.includes('Certificate29_')){
              ts.fileName12 = currentItem.Title;
              console.log('certificate photo',ts.fileName12);
             }
             else if(currentItem.Title.includes('Certificate30_')){
              ts.fileName13 = currentItem.Title;
              console.log('certificate photo',ts.fileName13);
             }
             else if(currentItem.Title.includes('Certificate31_')){
              ts.fileName14 = currentItem.Title;
              console.log('certificate photo',ts.fileName14);
             }
             else if(currentItem.Title.includes('Certificate32_')){
              ts.fileName15 = currentItem.Title;
              console.log('certificate photo',ts.fileName15);
             }
             else if(currentItem.Title.includes('Certificate33_')){
              ts.fileName16 = currentItem.Title;
              console.log('certificate photo',ts.fileName16);
             }
             else if(currentItem.Title.includes('Certificate34_')){
              ts.fileName17 = currentItem.Title;
              console.log('certificate photo',ts.fileName17);
             }
            })
            if(onboarding !=null){
             // this.readonlyfield=true;
              ts.firstName = onboarding.EMS_EM_First_Name__c;
              ts.lastName=onboarding.EMS_EM_Last_Name__c;
              ts.gen=onboarding.EMS_EM_Gender__c;
              ts.ph=onboarding.Phone_Number__c;
              ts.dob=onboarding.EMS_EM_DOB__c;
              ts.mstatus=onboarding.EMS_EM_Mstatus__c;
              ts.spouse=onboarding.EMS_EM_Spouse__c;
              ts.dow=onboarding.EMS_EM_DOW__c;
              ts.bg=onboarding.EMS_EM_BG__c;
              ts.aadhaarNo=maskAccountNumber(onboarding.EMS_EM_AadhaarNo__c);
              ts.pfn=onboarding.EMS_EM_UAN_Number__c;
              ts.panNo=maskPanNumber(onboarding.EMS_EM_PanNo__c);
              ts.pNum=onboarding.EMS_EM_PassportNo__c;
              ts.nation=onboarding.EMS_EM_Nationality__c;
              ts.cd=onboarding.EMS_EM_Current_Address__c;
              ts.altphone=onboarding.EMS_EM_Phone_Number__c;
              ts.previouscompanyname=onboarding.EMS_EM_Previous_Company_Name__c;
              ts.castate=onboarding.EMS_EM_CA_State__c;
              ts.pastate=onboarding.EMS_EM_PA_State__c;
              ts.cacity=onboarding.EMS_EM_CA_City__c;
              ts.pacity=onboarding.EMS_EM_PA_City__c;
              ts.cazip=onboarding.EMS_EM_CA_Zip__c;
              ts.pazip=onboarding.EMS_EM_PA_Zip__c;
              ts.cadrressline1=onboarding.Current_Address_Line_1__c;
              ts.cadrressline2=onboarding.Current_Address_Line_2__c;
              ts.padrressline1=onboarding.Permanent_Address_Line_1__c;
              ts.padrressline2=onboarding.Permanent_Address_Line_2__c;
              ts.Certificationname1=onboarding.EMS_EM_Certification_Name__c;
              ts.Certificationname2=onboarding.EMS_EM_Certification_Name1__c;
              ts.Certificationname3=onboarding.EMS_EM_Certification_Name2__c;
              ts.Certificationname4=onboarding.EMS_EM_Certification_Name3__c;
              ts.Certificationname5=onboarding.EMS_EM_Certification_Name4__c;
              ts.Certificationname6=onboarding.EMS_EM_Certification_Name5__c;
              ts.Certificationname7=onboarding.EMS_EM_Certification_Name6__c;
              ts.Certificationname8=onboarding.EMS_EM_Certification_Name7__c;
              ts.Certificationname9=onboarding.EMS_EM_Certification_Name8__c;
              ts.Certificationname10=onboarding.EMS_EM_Certification_Name9__c;
              ts.Certificationname11=onboarding.EMS_EM_Certification_Name10__c;
              ts.Certificationname12=onboarding.EMS_EM_Certification_Name11__c;
              ts.Certificationname13=onboarding.EMS_EM_Certification_Name12__c;
              ts.Certificationname14=onboarding.EMS_EM_Certification_Name13__c;
              ts.Certificationname15=onboarding.EMS_EM_Certification_Name14__c;
              ts.Certificationname16=onboarding.EMS_EM_Certification_Name15__c;
              ts.Certificationname17=onboarding.EMS_EM_Certification_Name16__c;
              ts.Certificationname17=onboarding.EMS_EM_Certification_Name16__c;
              ts.Certificationname18=onboarding.EMS_EM_Certification_Name17__c;
              ts.Certificationname19=onboarding.EMS_EM_Certification_Name18__c;
              ts.Certificationname20=onboarding.EMS_EM_Certification_Name19__c;
              ts.levleofedu=additionalDetails.EMS_EM_Education__c;
              ts.fieldOfStudy=additionalDetails.EMS_EM_Field_of_Study__c;
              ts.instutionname=additionalDetails.EMS_EM_IName__c;
              ts.graduationDate=additionalDetails.EMS_EM_GDate__c;
              ts.degree=additionalDetails.EMS_EM_Degree__c;          
              ts.levleofedu1=additionalDetails.EMS_EM_Education1__c;
              ts.fieldOfStudy1=additionalDetails.EMS_EM_Field_of_Study1__c;
              ts.instutionname1=additionalDetails.EMS_EM_IName1__c;
              ts.graduationDate1=additionalDetails.EMS_EM_GDate1__c;
              ts.degree1=additionalDetails.EMS_EM_Degree1__c;             
              ts.levleofedu2=additionalDetails.EMS_EM_Education2__c;
              ts.fieldOfStudy2=additionalDetails.EMS_EM_Field_of_Study2__c;
              ts.instutionname2=additionalDetails.EMS_EM_IName2__c;
              ts.graduationDate2=additionalDetails.EMS_EM_GDate2__c;
              ts.degree2=additionalDetails.EMS_EM_Degree2__c;         
              ts.levleofedu3=additionalDetails.EMS_EM_Education3__c;
              ts.fieldOfStudy3=additionalDetails.EMS_EM_Field_of_Study3__c;
              ts.instutionname3=additionalDetails.EMS_EM_IName3__c;
              ts.graduationDate3=additionalDetails.EMS_EM_GDate3__c;
              ts.degree3=additionalDetails.EMS_EM_Degree3__c;           
              ts.levleofedu4=additionalDetails.EMS_EM_Education4__c;
              ts.fieldOfStudy4=additionalDetails.EMS_EM_Field_of_Study4__c;
              ts.instutionname4=additionalDetails.EMS_EM_IName4__c;
              ts.graduationDate4=additionalDetails.EMS_EM_GDate4__c;
              ts.degree4=additionalDetails.EMS_EM_Degree4__c;
              ts.levleofedu5=additionalDetails.EMS_EM_Education5__c;
              ts.fieldOfStudy5=additionalDetails.EMS_EM_Field_of_Study5__c;
              ts.instutionname5=additionalDetails.EMS_EM_IName5__c;
              ts.graduationDate5=additionalDetails.EMS_EM_GDate5__c;
              ts.degree5=additionalDetails.EMS_EM_Degree5__c;
              ts.jobtitle0=additionalDetails.EMS_EM_Job_Title__c;
              ts.fromdate0=additionalDetails.EMS_EM_From_Date__c;
              ts.todate0=additionalDetails.EMS_EM_To_Date__c;
              ts.previouscompanyname0=additionalDetails.EMS_EM_Previous_Company_Name__c;
              ts.previouscomemailid=additionalDetails.EMS_EM_Previous_Company_HR_EmailId__c;
              if(ts.jobtitle0 !=null || ts.fromdate0 != null || ts.todate0 !=null ||
                ts.previouscompanyname0 !=null || ts.previouscomemailid !=null){
                       ts.showExperienceyouhave=true;
                       ts.inputcheckboxexperience = true;
             }
             
              ts.jobtitle1=additionalDetails.EMS_EM_Job_Title1__c;
              ts.fromdate1=additionalDetails.EMS_EM_From_Date1__c;
              ts.todate1=additionalDetails.EMS_EM_To_Date1__c;
              ts.previouscompanyname1=additionalDetails.EMS_EM_Previous_Company_Name1__c;
              ts.jobtitle2=additionalDetails.EMS_EM_Job_Title2__c;
              ts.fromdate2=additionalDetails.EMS_EM_From_Date2__c;
              ts.todate2=additionalDetails.EMS_EM_To_Date2__c;
              ts.previouscompanyname2=additionalDetails.EMS_EM_Previous_Company_Name2__c;
              ts.jobtitle3=additionalDetails.EMS_EM_Job_Title3__c;
              ts.fromdate3=additionalDetails.EMS_EM_From_Date3__c;
              ts.todate3=additionalDetails.EMS_EM_To_Date3__c;
              ts.previouscompanyname3=additionalDetails.EMS_EM_Previous_Company_Name3__c;
              ts.jobtitle4=additionalDetails.EMS_EM_Job_Title4__c;
              ts.fromdate4=additionalDetails.EMS_EM_From_Date4__c;
              ts.todate4=additionalDetails.EMS_EM_To_Date4__c;
              ts.previouscompanyname4=additionalDetails.EMS_EM_Previous_Company_Name4__c;
              ts.jobtitle5=additionalDetails.EMS_EM_Job_Title5__c;
              ts.fromdate5=additionalDetails.EMS_EM_From_Date5__c;
              ts.todate5=additionalDetails.EMS_EM_To_Date5__c;
              ts.previouscompanyname5=additionalDetails.EMS_EM_Previous_Company_Name5__c; 
              ts.isPersonalUpdateCheckbox = onboarding.Personal_Details_Value_Filled__c;
              ts.isIdentifyDetailsCheckbox = onboarding.Identify_Details_Value_Filled__c;
              ts.isAddressDetailsCheckbox = onboarding.Address_Details_Value_Filled__c;
              ts.isOtherCertificationsCheckbox = onboarding.Other_Certifications_Value_Filled__c;
              ts.isEducationDetailsCheckbox = additionalDetails.Education_Details_Filled__c;
              ts.isWorkExperienceCheckbox = additionalDetails.Work_Details_Filled__c;
              ts.isCompanyInformationValueChecked = onboarding.Company_Information_Viewed__c;
              ts.isConfirmSubmit = onboarding.Is_Confirm__c;
              ts.statusUpdate = onboarding.Status__c;
              ts.isIdentityStatusUpdate = onboarding.Status__c;
              ts.isAdressStatusUpdate = onboarding.Status__c;
              ts.isEducationStatusUpdate = onboarding.Status__c;
              ts.isCertificationStatusUpdate = onboarding.Status__c;
              ts.isWorkExperienceStatusUpdate = onboarding.Status__c;

              ts.confirmStatusUpdate = onboarding.Status__c;

              if(ts.levleofedu1){
                ts.addmoreempfields = true;
                ts.hideplus = false;
              }
              if(ts.levleofedu2){
                ts.extraempfields = true;
                ts.hideextraadd = false;
              }
              if(ts.levleofedu3){
                ts.extraempfields1 = true;
                ts.hideextraadd1 = false;
              }
              if(ts.levleofedu4){
                ts.extraempfields2 = true;
                ts.hideextraadd2 = false;
              }
              if(ts.levleofedu5){
                ts.extraempfields3 = true;
                ts.hideextraadd3 = false;
              }
              if(ts.Certificationname2){
                ts.ShowCertification1 = true;
                ts.hideCertification2 = false;
              }
              if(ts.Certificationname3){
                ts.ShowCertification2 = true;
                ts.hideCertification3 = false;
              }
              if(ts.Certificationname4){
                ts.ShowCertification3 = true;
                ts.hideCertification4 = false;
              }
              if(ts.Certificationname5){
                ts.ShowCertification4 = true;
                ts.hideCertification5 = false;
              }
              if(ts.Certificationname6){
                ts.ShowCertification5 = true;
                ts.hideCertification6 = false;
              }
              if(ts.Certificationname7){
                ts.ShowCertification6 = true;
                ts.hideCertification7 = false;
              }
              if(ts.Certificationname8){
                ts.ShowCertification7 = true;
                ts.hideCertification8 = false;
              }
              if(ts.Certificationname9){
                ts.ShowCertification8 = true;
                ts.hideCertification9 = false;
              }
              if(ts.Certificationname10){
                ts.ShowCertification9 = true;
                ts.hideCertification10 = false;
              }
              if(ts.Certificationname11){
                ts.ShowCertification10 = true;
                ts.hideCertification11 = false;
              }
              if(ts.Certificationname12){
                ts.ShowCertification11 = true;
                ts.hideCertification12 = false;
              }
              if(ts.Certificationname13){
                ts.ShowCertification12 = true;
                ts.hideCertification13 = false;
              }
              if(ts.Certificationname14){
                ts.ShowCertification13 = true;
                ts.hideCertification14 = false;
              }
              if(ts.Certificationname15){
                ts.ShowCertification14 = true;
                ts.hideCertification15 = false;
              }
              if(ts.Certificationname16){
                ts.ShowCertification15 = true;
                ts.hideCertification16 = false;
              }
              if(ts.Certificationname17){
                ts.ShowCertification16 = true;
                ts.hideCertification17 = false;
              }
              if(ts.Certificationname18){
                ts.ShowCertification17 = true;
                ts.hideCertification18 = false;
              }
              if(ts.Certificationname19){
                ts.ShowCertification18 = true;
                ts.hideCertification19 = false;
              }
              if(ts.Certificationname20){
                ts.ShowCertification19 = true;
                ts.hideCertification20 = false;
              }
              if(ts.jobtitle1){
                ts.addmoreworkfields = true;
                ts.hideplus1 = false;
              }
              if(ts.jobtitle2){
                ts.addmoreworkfields1 = true;
                ts.hidesecondadd = false;
              }
              if(ts.jobtitle3){
                ts.addmoreworkfields2 = true;
                ts.hidethirdadd = false;
              }
              if(ts.jobtitle4){
                ts.addmoreworkfields3 = true;
                ts.hidefourthadd = false;
              }
              if(ts.jobtitle5){
                ts.addmoreworkfields4 = true;
                ts.hidefivthadd = false;
              }
              if(result.onboarding.Personal_Details_Value_Filled__c === true){
                ts.isPersonalUpdateCheckbox = true;
                ts.statusUpdate = 'In Progress';
                console.log('check box personal',ts.isPersonalUpdateCheckbox);
                }
                if(result.onboarding.Identify_Details_Value_Filled__c === true){
                  ts.isIdentifyDetailsCheckbox = true;
                  ts.isIdentityStatusUpdate = 'In Progress';
                  console.log('check box personal',ts.isIdentifyDetailsCheckbox);
                }
                if(result.onboarding.Address_Details_Value_Filled__c === true){
                  ts.isAddressDetailsCheckbox = true;
                  ts.isAdressStatusUpdate = 'In Progress';
                }
                if(result.onboarding.Other_Certifications_Value_Filled__c === true){
                  ts.isOtherCertificationsCheckbox = true;
                  ts.isCertificationStatusUpdate = 'In Progress';
                }
                if(result.additionalDetails.Education_Details_Filled__c === true){
                  ts.isEducationDetailsCheckbox = true;
                  ts.isEducationStatusUpdate = 'In Progress';
                }
                if(result.additionalDetails.Work_Details_Filled__c === true){
                  ts.isWorkExperienceCheckbox = true;
                  ts.isWorkExperienceStatusUpdate = 'In Progress';
                }
                if(result.onboarding.Company_Information_Viewed__c === true){
                  ts.isCompanyInformationValueChecked = true;
                  ts.statusUpdate = 'In Progress';
                }
                if(result.onboarding.Is_Confirm__c === true){
                  ts.isConfirmSubmit = true;
                  ts.readonlyfield=true;
                  ts.confirmStatusUpdate = 'Submitted for Review';
                  ts.buttonDisable = true;
                }
                
            }
        })
        .catch(error => {
            ts.error = error;
            console.log('this.error-->'+JSON.stringify(ts.error));
        });
    
}

function displayShowtoastMessage(titleToDisplay, messageToDisplay, variantToDisplay,ts){
    const evt = new ShowToastEvent({
            title: titleToDisplay,
            message: messageToDisplay,
            variant: variantToDisplay,
        });
        ts.dispatchEvent(evt);

}

export {uploadFilesFromThis, updateOnBoardingRequest, updateOnboardingInfoOnPageLoads, displayShowtoastMessage}