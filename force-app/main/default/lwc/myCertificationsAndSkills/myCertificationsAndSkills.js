import { LightningElement,track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMyCertificationsAndSkills from '@salesforce/apex/mySkillsAndCertifcations.getMyCertificationsAndSkills';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class MyCertificationsAndSkills extends NavigationMixin(LightningElement) {
@track skillList ;

openModal = false;
showtable = false;
resourceId;
showskill = false;
showcertification = false;
createdRecordId ;
connectedCallback(){

}

loaded = false
    @wire(getMyCertificationsAndSkills) 
    wiredLabels({error, data}){
        if(data){
        this.skillList = data.skillList;
        this.resourceId = data.resourceId;
        if(this.skillList.length > 0){
           this.showtable = true;
        }
        this.loaded = true;
       
    }
        if(error){
            console.log('-======---=ERROR==--=-=-'+JSON.stringify(error));
        }
    }

    handleClick(){
       this.openModal = true;
    }

    handleCancel(event) {
      this.openModal = false;
    }

handleTypeChange(event){
this.showskill = false;
this.showcertification = false;
let changedVal = event.target.value;
    if(changedVal == 'Skill'){
    this.showskill = true;
    this.showcertification = false;
    }else{
    this.showskill = false;
    this.showcertification = true;    
    }
}

handleNavClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/recordlist/Certifications__c/Default'
            }
        });
}

handleexpClick(event){
let selectexp = event.currentTarget.dataset.id;
this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectexp,
                objectApiName: 'Certifications__c',
                actionName: 'view'
            },
         });
}

handleFormSubmit(event) {

}

 handleSuccess(event) {
    console.log('=====event.detail.id====='+event.detail.id);
        getMyCertificationsAndSkills()
         .then(result => {
            const even = new ShowToastEvent({
            title: 'Success!',
            message: 'Successfully created the record!',
            variant: 'success'
        });
        this.dispatchEvent(even);
         console.log('===data===='+JSON.stringify(result));
         this.skillList = result.skillList;
        this.resourceId = result.resourceId;
        if(this.skillList.length > 0){
           this.showtable = true;
        }  
           this.openModal = false;  
         })
         .catch(error => {
             console.log('===ERROR===='+JSON.stringify(error));
             const event = new ShowToastEvent({
                 title : 'Error',
                 message : 'Error in creating a record. Please Contact System Admin',
                 variant : 'error'
             });
             this.dispatchEvent(event);
         });
}

    handleError(event){
        console.log('====event.detail.detail======'+JSON.stringify(event.detail.detail));
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: event.detail.detail,
            variant: 'error',
            mode:'dismissable'
        });
        this.dispatchEvent(evt);
    }


}