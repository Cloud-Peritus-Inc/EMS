import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import fetchCertifications from '@salesforce/apex/certificationController.fetchEducation';
import dmlOnCertifications from '@salesforce/apex/certificationController.dmlOnEducation';
import uploadFile from '@salesforce/apex/certificationController.uploadFiles';
import { refreshApex } from '@salesforce/apex';
 
export default class AccountContactTable extends LightningElement {
   /* @api recordId;
    @track isLoading = true;
    @track records;
    wiredRecords;
    error;
    @track deleteCertificationIds = '';

    certificationName = [
        { label: 'Salesforce Certified Associate', value: 'Salesforce Certified Associate' },
        { label: 'Salesforce Certified Administrator', value: 'Salesforce Certified Administrator' },
        { label: 'Salesforce Certified Advanced Administrator', value: 'Salesforce Certified Advanced Administrator' },
      ];

      certificationtype = [
        { label: 'Certification', value: 'Certification' },
        { label: 'Skill', value: 'Skill' }
      ];
 
 
    //to add row
    addRow() {
        let randomId = Math.random() * 16;
        let myNewElement = { Type__c: 'Certification',  Certification_Name__c: "", Id: randomId, Completion_Date__c: "", Onboarding_Request__c: this.recordId};
        this.records = [...this.records, myNewElement];
    }
 
    get isDisable(){
        return (this.isLoading || (this.wiredRecords.data.length == 0 && this.records.length == 0));
    }
 
    //show/hide spinner
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
 
    //update table row values in list
    updateValues(event){
        var foundelement = this.records.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name === 'Certification_Name__c'){
            foundelement.Certification_Name__c = event.target.value;
        } else if(event.target.name === 'Completion_Date__c'){
            foundelement.Completion_Date__c = event.target.value;
        }
    }
 
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
            this.updateRecordView(this.recordId);
            this.closeAction();
            this.showToast('Success', result, 'Success', 'dismissable');
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
 
    //fetch account contact records
    @wire(fetchCertifications, {recordId : '$recordId'})  
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
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 3000); 
       */

       @api recordId;
    @track isLoading = true;
    @track records;
    wiredRecords;
    error;
    @track deleteCertificationIds = '';

    LevelofEducationValue = [

        { label: 'Std X/SSC', value: 'Std X/SSC' },
        { label: 'Std XII/HSC', value: 'Std XII/HSC' },
        { label: 'Graduate', value: 'Graduate' },
        { label: 'Post Graduate', value: 'Post Graduate' }
    
    
      ];

      
      get acceptedFormats() {
        return ['.pdf', '.png', '.jpg', '.jpeg'];
      }

    //to add row
    addRow() {
        let randomId = Math.random() * 16;
        let myNewElement = { RecordTypeId: '01252000002eZUiAAM',  EMS_EM_Education__c: "", Id: randomId, EMS_EM_Degree__c: "", EMS_EM_Field_of_Study__c: "", EMS_EM_IName__c: "", EMS_EM_GDate__c: "",  Onboarding_Request__c: this.recordId};
        let fileObj = {
            fileName: "",
            fileType: "",
            fileContent: null
          };
        
          // Add the file object to the new element
          myNewElement.File__c = fileObj;
        this.records = [...this.records, myNewElement];
    }

    handleFileInputChange(event) {
        const rowId = event.target.dataset.id;
        const files = event.detail.files;
        const file = files[0];
      
        let updatedEducationDetails = [...this.educationDetails];
        let rowToUpdate = updatedEducationDetails.find(row => row.Id === rowId);
        rowToUpdate.File__c = file;
      
        this.educationDetails = updatedEducationDetails;
      }
 
    get isDisable(){
        return (this.isLoading || (this.wiredRecords.data.length == 0 && this.records.length == 0));
    }
 
    //show/hide spinner
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }
 
    //update table row values in list
    updateValues(event){
        var foundelement = this.records.find(ele => ele.Id == event.target.dataset.id);
        if(event.target.name === 'EMS_EM_Education__c'){
            foundelement.EMS_EM_Education__c = event.target.value;
        } else if(event.target.name === 'EMS_EM_Degree__c'){
            foundelement.EMS_EM_Degree__c = event.target.value;
        }else if(event.target.name === 'EMS_EM_Field_of_Study__c'){
            foundelement.EMS_EM_Field_of_Study__c = event.target.value;
        }else if(event.target.name === 'EMS_EM_IName__c'){
            foundelement.EMS_EM_IName__c = event.target.value;
        }else if(event.target.name === 'EMS_EM_GDate__c'){
            foundelement.EMS_EM_GDate__c = event.target.value;
        }
    }
 
    //handle save and process dml 
    handleSaveAction(){
        this.handleIsLoading(true);
     
        if(this.deleteCertificationIds !== ''){
            this.deleteCertificationIds = this.deleteCertificationIds.substring(1);
        }
    
        let promises = [];
    
        this.records.forEach(res =>{
            if(!isNaN(res.Id)){
                res.Id = null;
            }
            
            // Check if there's a file to upload
            if(res.File__c && res.File__c.size > 0) {
                // Create a new promise for each file upload
                let promise = new Promise((resolve, reject) => {
                    let reader = new FileReader();
                    reader.onload = () => {
                        let base64 = reader.result.split(',')[1];
                        uploadFile({ parentId: this.recordId, fileName: res.File__c.name, base64Data: base64 })
                            .then(result => {
                                res.File__c = result.Id;
                                resolve();
                            })
                            .catch(error => {
                                reject(error);
                            });
                    };
                    reader.onerror = () => {
                        reject(reader.error);
                    };
                    reader.readAsDataURL(res.File__c);
                });
                promises.push(promise);
            }
        });
    
        Promise.all(promises)
            .then(() => {
                dmlOnCertifications({data: this.records, removeCertificationIds : this.deleteCertificationIds})
                    .then( result => {
                        this.handleIsLoading(false);
                        refreshApex(this.wiredRecords);
                        this.updateRecordView(this.recordId);
                        this.closeAction();
                        this.showToast('Success', result, 'Success', 'dismissable');
                    }).catch( error => {
                        this.handleIsLoading(false);
                        console.log(error);
                        this.showToast('Error updating or refreshing records', error.body.message, 'Error', 'dismissable');
                    });
            })
            .catch(error => {
                this.handleIsLoading(false);
                console.log(error);
                this.showToast('Error uploading file', error.body.message, 'Error', 'dismissable');
            });
    }
    
 
    //remove records from table
    handleDeleteAction(event){
        if(isNaN(event.target.dataset.id)){
            this.deleteCertificationIds = this.deleteCertificationIds + ',' + event.target.dataset.id;
        }
        this.records.splice(this.records.findIndex(row => row.Id === event.target.dataset.id), 1);
    }
 
    //fetch account contact records
    @wire(fetchCertifications, {recordId : '$recordId'})  
    wiredContact(result) {
        this.wiredRecords = result; // track the provisioned value
        const { data, error } = result;
 
        if(data) {
            this.records = JSON.parse(JSON.stringify(data));
            console.log('data.RecordTypeId-->'+data.RecordTypeId);
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
       setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
       }, 3000); 
    }

    handleUploadClick() {
        const fileUpload = this.template.querySelector('lightning-file-upload');
        fileUpload.click();
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;

        const formData = new FormData();

        // Loop over the uploaded files and rename them before uploading
        for (let i = 0; i < uploadedFiles.length; i++) {
            const file = uploadedFiles[i];
            const newName = `newfilename_${file.name}`;

            // Create a new File object with the renamed file
            const renamedFile = new File([file], newName, { type: file.type });

            // Append the renamed file to the FormData object
            formData.append('file', renamedFile);
        }

        // Use the Fetch API to upload the files to the server
        fetch('/upload', {
            method: 'POST',
            body: formData
        })
        .then(response => {
            console.log('Files uploaded successfully');
        })
        .catch(error => {
            console.error('Error uploading files:', error);
        });
    }
}